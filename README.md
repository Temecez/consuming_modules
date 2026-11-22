# consuming_modules

Infrastructure that consumes the shared modules from [temecez_modules](https://github.com/Temecez/temecez_modules).

## Layout

```
main.tf  providers.tf  versions.tf  variables.tf  outputs.tf   # written once, shared by all envs
envs/
  dev.tfvars    dev.tfbackend     # per-env settings + where that env's state lives
  prod.tfvars   prod.tfbackend
```

One codebase, many environments. Each environment differs only by its variables (`envs/<env>.tfvars`) and its state (`envs/<env>.tfbackend`). Add `stage` by adding those two files.

## Usage

```sh
# pick the environment (re-run with -reconfigure whenever you switch)
terraform init -reconfigure -backend-config=envs/dev.tfbackend

terraform plan  -var-file=envs/dev.tfvars -out=dev.tfplan
terraform apply dev.tfplan
```

**On Windows PowerShell, quote any argument that contains a `.`**, or PowerShell splits it at the dot and Terraform fails with "No positional arguments are expected":

```powershell
terraform init -reconfigure "-backend-config=envs/dev.tfbackend"
terraform plan "-var-file=envs/dev.tfvars" "-out=dev.tfplan"
terraform apply dev.tfplan
```

**Always pass the matching pair** (`dev.tfbackend` with `dev.tfvars`). Mixing them would plan dev settings against prod state. A CI pipeline removes this risk by passing both from one environment name.

Requires AWS credentials for the environment's account, and git access to the private `temecez_modules` repo.

## Module versions

| Bundle | Version |
|---|---|
| `aws` | `aws/v1.0.0` |

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

`admin/` is a separate configuration that sets up Spacelift to run this repo. For each environment it creates a stack, an IAM role in that environment's account, and an AWS integration connecting the two. Apply it once from your machine. It is not run by the stacks it creates.

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

Stacks run with OpenTofu (Spacelift's Terraform option stops at 1.5.x) and pass `-var-file=envs/<env>.tfvars` through `TF_CLI_ARGS_plan`.

## Tagging

Two layers apply tags:

- **Provider `default_tags`** (`providers.tf`) tags every AWS resource in the configuration, including plain `aws_*` resources that don't come from a module.
- **Module-enforced tags** (e.g. `infra = "true"` in `s3-bucket`) can't be overridden by callers.
