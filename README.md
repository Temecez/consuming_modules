# consuming_modules

An app team's infrastructure repo. It consumes the shared modules from [temecez_modules](https://github.com/Temecez/temecez_modules) and is deployed by Spacelift stacks that the platform's [spacelift_admin](https://github.com/Temecez/spacelift_admin) creates from this repo's layout.

## Layout

```
main.tf  providers.tf  versions.tf  variables.tf  outputs.tf   # written once, shared by all deployments
envs/
  <environment>/<name>.tfvars   # one file per deployment = one Spacelift stack
  dev/dev.tfvars                # → stack consuming_modules-dev
  test/test.tfvars              # → stack consuming_modules-test
  prod/prod.tfvars              # → stack consuming_modules-prod
```

## Deployments

The repo opts in with two GitHub topics: `spacelift-managed` and `team-poc` (its owning team). Then **each var file is a deployment**:

- **Environment** = the folder name (`dev`, `test`, `prod`, matching the AWS OUs).
- **Account** = the team's account in that environment, resolved by the platform from the account's `team` tag. The repo never names accounts, roles or integrations.
- **Region** = `region` in the var file. Use `us-east-2` unless there's a reason not to.

To add a deployment, add a var file and the stack appears on the next `spacelift_admin` run. For example, a second region in dev is `envs/dev/us-east-1.tfvars`, which becomes stack `consuming_modules-dev-us-east-1`.

An optional `spacelift.yaml` holds overrides such as `autodeploy` (never honoured in prod) or `project_root`; see [spacelift/repo-stacks](https://github.com/Temecez/temecez_modules/tree/main/modules/spacelift/repo-stacks).

## Usage

Changes are deployed by Spacelift, not from a laptop:

1. Push a branch and open a PR. Spacelift can show a proposed plan on the PR.
2. Merge to `main`. Each stack starts a run: `tofu plan -var-file=envs/<environment>/<name>.tfvars`.
3. Review the plan in Spacelift and click **Confirm** to apply.

There's no backend block in `versions.tf`: Spacelift injects its own at run time and holds each stack's state. To check the code locally without touching state:

```powershell
terraform init -backend=false
terraform validate
```

## Module versions

| Bundle | Version |
|---|---|
| `aws` | `aws/v1.1.0` |

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
