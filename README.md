# consuming_modules

An app team's infrastructure repo. It consumes the shared modules from [temecez_modules](https://github.com/Temecez/temecez_modules) and is deployed by Spacelift stacks that the platform's [spacelift_admin](https://github.com/Temecez/spacelift_admin) creates from this repo's `spacelift.yaml`.

## Layout

```
main.tf  providers.tf  versions.tf  variables.tf  outputs.tf   # written once, shared by all deployments
envs/
  <environment>/<region>.tfvars   # one file per deployment
  dev/us-east-2.tfvars
  dev/us-east-1.tfvars
  prod/us-east-1.tfvars
spacelift.yaml                    # which accounts/regions to deploy to (read by spacelift_admin)
```

## Deployments

`spacelift.yaml` lists **where** this repo deploys. Each entry becomes a Spacelift stack named `consuming_modules-<account>-<region>`:

```yaml
deployments:
  - account: temecez10_dev        # AWS account name from Organizations
    region: us-east-2
    var_file: envs/dev/us-east-2.tfvars
```

The repo opts in with two GitHub topics: `spacelift-managed` and `team-poc` (its owning team). The platform decides the rest:

- **Which accounts are allowed.** The team may only use accounts in its allowed environments (OUs). Anything else is skipped and reported in `spacelift_admin`.
- **AWS access.** Each account has a `spacelift` role and Spacelift integration managed by the platform. This repo never creates IAM roles for deployment.
- **Autodeploy.** Allowed in non-prod if requested (`autodeploy: true`); always off in prod.

To add a region: add `envs/<environment>/<region>.tfvars` and an entry in `spacelift.yaml`. The stack appears on the next `spacelift_admin` run.

## Usage

Changes are deployed by Spacelift, not from a laptop:

1. Push a branch and open a PR. Spacelift can show a proposed plan on the PR.
2. Merge to `main`. Each stack starts a run: `tofu plan -var-file=envs/<environment>/<region>.tfvars`.
3. Review the plan in Spacelift and click **Confirm** to apply.

There's no backend block in `versions.tf`: Spacelift injects its own at run time and holds each stack's state. To check the code locally without touching state:

```powershell
terraform init -backend=false
terraform validate
```

## Module versions

| Bundle | Version |
|---|---|
| `aws` | `aws/v1.1.0-rc.2` (move to `aws/v1.1.0`, identical code) |

Modules are pinned by git tag in each `source`:

```hcl
source = "git::https://github.com/Temecez/temecez_modules.git//modules/aws/s3-bucket?ref=aws/v1.1.0"
```

Terraform doesn't allow variables in `source`, so **all deployments share the version in the code**. Versions are promoted by *when* each stack is applied:

1. On a branch, bump the `ref` (or point it at a release candidate like `aws/v1.2.0-rc.1`) in **every** `aws` module block.
2. Use the PR's proposed runs to check dev.
3. Merge to `main`; confirm dev first, then prod.

Check the [aws changelog](https://github.com/Temecez/temecez_modules/blob/main/modules/aws/CHANGELOG.md) for breaking changes before bumping a major version.

## Tagging

Two layers apply tags:

- **Provider `default_tags`** (`providers.tf`) tags every AWS resource in the configuration, including plain `aws_*` resources that don't come from a module.
- **Module-enforced tags** (e.g. `infra = "true"` in `s3-bucket`) can't be overridden by callers.
