# consuming_modules

Infrastructure that consumes the shared modules from [temecez_modules](https://github.com/Temecez/temecez_modules).

## Layout

```
main.tf  providers.tf  versions.tf  variables.tf  outputs.tf   # written once, shared by all deployments
envs/
  <environment>/<region>.tfvars   # one file per deployment
  dev/us-east-2.tfvars
  dev/us-east-1.tfvars
  prod/us-east-1.tfvars
admin/                            # sets up Spacelift (see below); not run by the stacks
```

Two dimensions:

| Concept | Means | Gets |
|---|---|---|
| **Environment** (`dev`, `prod`) | An **AWS account** | One Spacelift IAM role + one AWS integration, shared by all its deployments |
| **Deployment** (`dev-us-east-2`, ...) | An environment in one **region** | One Spacelift stack, running this folder with `envs/<environment>/<region>.tfvars` and its own Spacelift-managed state |

One codebase for everything. Today every environment points at the same AWS account; making them separate accounts only changes the account mapping in `admin/providers.tf`.

To add a region to an environment: add `envs/<environment>/<region>.tfvars` and an entry in `deployments` in `admin/variables.tf`. To add an environment (account): also add it to `environments`, plus a provider alias and integration/role blocks in `admin/`.

## Usage

Changes are deployed by Spacelift, not from a laptop:

1. Push a branch and open a PR. Spacelift can show a proposed plan on the PR.
2. Merge to `main`. Each stack starts a run: `tofu plan -var-file=envs/<environment>/<region>.tfvars`.
3. Review the plan in Spacelift and click **Confirm** to apply (`autodeploy` is off).

There's no backend block in `versions.tf`: Spacelift injects its own at run time and holds each stack's state. To check the code locally without touching state:

```powershell
terraform init -backend=false
terraform validate
```

Running `plan`/`apply` locally would use a separate local state file that Spacelift knows nothing about, so don't apply from a laptop.

The stacks need Spacelift's GitHub app to have access to this repo **and** to `temecez_modules`, which `tofu init` downloads modules from.

## Module versions

| Bundle | Version |
|---|---|
| `aws` | `aws/v1.1.0-rc.2` (move to `aws/v1.1.0`, identical code) |

Modules are pinned by git tag in each `source`:

```hcl
source = "git::https://github.com/Temecez/temecez_modules.git//modules/aws/s3-bucket?ref=aws/v1.0.0"
```

Terraform doesn't allow variables in `source`, so **all environments share the version in the code**. Versions are promoted through environments by *when* each environment is applied, not by separate code:

1. On a branch, bump the `ref` (or point it at a release candidate like `aws/v1.1.0-rc.1`) in **every** `aws` module block, then `terraform init -upgrade`.
2. Plan and apply **dev** from the branch. Test.
3. Merge to `main`. **stage** and then **prod** are applied from `main` (in CI, behind approvals).

Prod only ever runs what's on `main`. Check the [aws changelog](https://github.com/Temecez/temecez_modules/blob/main/modules/aws/CHANGELOG.md) for breaking changes before bumping a major version.

## Spacelift

`admin/` is a separate configuration that sets up Spacelift to run this repo, using the shared modules:

- per **environment** (account): `spacelift/aws-integration` and `aws/spacelift-role` (`spacelift-dev`, `spacelift-prod`). The role trusts any stack attached to its integration, so adding a region needs no IAM change.
- per **deployment**: `spacelift/stack`, with its environment's integration and the `github-modules-read` context attached.

Apply it from your machine. It is not run by the stacks it creates.

```powershell
# One-time: save the API key for your Windows user (prompts, so the secret
# never lands in PowerShell history). Open a new terminal afterwards.
$cred = Get-Credential -Message "Spacelift API key"   # username = key ID, password = secret
[Environment]::SetEnvironmentVariable("SPACELIFT_API_KEY_ID",     $cred.UserName, "User")
[Environment]::SetEnvironmentVariable("SPACELIFT_API_KEY_SECRET", $cred.GetNetworkCredential().Password, "User")

cd admin
terraform init
terraform plan "-out=admin.tfplan"
terraform apply admin.tfplan
```

Stacks run with OpenTofu (Spacelift's Terraform option stops at 1.5.x) and pass `-var-file=envs/<environment>/<region>.tfvars` through `TF_CLI_ARGS_plan`.

The `github-modules-read` context is created by hand in Spacelift (it holds a GitHub token, which shouldn't be in Terraform state); `admin/` only attaches it.

## Tagging

Two layers apply tags:

- **Provider `default_tags`** (`providers.tf`) tags every AWS resource in the configuration, including plain `aws_*` resources that don't come from a module.
- **Module-enforced tags** (e.g. `infra = "true"` in `s3-bucket`) can't be overridden by callers.
