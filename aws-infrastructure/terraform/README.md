# Plan to create infra in AWS

This terraform plan creates resources:
- VPC network
- IPSec VPN
- Transit Gateway
- EC2 Instances

## Prerequisites

- [awscli](https://github.com/aws/aws-cli) >= 1.27.53
- [terraform](https://www.terraform.io/downloads.html) >= 1.3.4

## AWS credentials

To authenticate terraform plan AWS credentials should be configured for programmatic access
```
aws configure
```
If you use multiple credential profiles defined in `~/.aws/credentials`, choose proper one
```
export AWS_PROFILE=<profile-name>
```

## Terraform state backend

Terraform configured to keep it's state on s3 bucket. The configuration is defined in the environment's `backend.tf` file (./backend.tf)
```
terraform {
  backend "s3" {
    bucket  = "terraform-states"
    key     = "<folder-name>"
    region  = "us-east-2"
    encrypt = true
  }
}
```

__NOTE:__
- Bucket that mentioned in `bucket` key should be created first, if not done yet you can do it with
  ```
  aws s3api create-bucket --bucket terraform-states --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
  ```
- Bucket name must be unique across all existing bucket names and comply with DNS naming conventions
- If you create new environment make sure that you are using unique `key` in the terraform backend configuration
- You can override `backend.tf` configuration with terraform CLI arguments:
  ```
  # using separate bucket for environment
  terraform init -backend-config "bucket=terraform-states-custom"
  ```

## Usage

Resources are logically grouped using Terraform [workspaces](https://www.terraform.io/cli/workspaces) as environments: `default`, `dev`, `prod`, etc.

Init terraform backend
```
cd terraform
terraform init
```

List environments:
```
terraform workspace list
```

Switch or use the environment:
```
terraform workspace select <env-name>
```

### Customization

Per environment configuration files with name `<env-name>.tfvars` are used to customize deployments. The default values are provided in [default.tfvars](./default.tfvars)

__NOTE:__ That we have to set path to the environment's tfvars files explicitly when run terraform commands, otherwise defaults will be used, e.g. `terraform plan -var-file <env-name>.tfvars`

#### Create new environment

Create workspace for the new environment:
```
terraform workspace new <env-name>
```

Copy environment-specific configuration from `default.tfvars` or any other value's file to `<env-name>.tfvars` and change env related names and variables in it.

__NOTE:__ That we have to set path to the environment tfvars files explicitly when run terraform commands, otherwise defaults will be used, e.g. `terraform plan -var-file <env-name>.tfvars`

### Create / Update

To create/update the environment execute terraform plan:
```
terraform plan -var-file <env-name>.tfvars
terraform apply -var-file <env-name>.tfvars
```

### Destroy

To remove environment's resources run:
```
TF_WARN_OUTPUT_ERRORS=1 terraform destroy -var-file <env-name>.tfvars
```
