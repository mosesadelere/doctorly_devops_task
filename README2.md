# Structuring Terraform project for multiple project
#1 Each environment (dev/staging/prod) must has its own directory
#2 Modularization of infrastructure components to promote consistency and reusability
#3 In each enviroment(stage/dev/prod), there must be separate directories per providers
#4 version control to track changes and rollback possibility


terraform/
├── modules/
│   ├── aws/
│   │   ├── ec2/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── vpc/
│   │   │   └── ...
│   │   └── s3/
│   │       └── ...
│   ├── azure/
│   │   ├── vm/
│   │   │   └── ...
│   │   └── vnet/
│   │       └── ...
│   └── gcp/
│       ├── compute/
│       │   └── ...
│       └── network/
│           └── ...
├── environments/
│   ├── dev/
│   │   ├── aws/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   ├── azure/
│   │   │   └── ...
│   │   └── gcp/
│   │       └── ...
│   ├── staging/
│   │   ├── aws/
│   │   │   └── ...
│   │   └── azure/
│   │       └── ...
│   └── prod/
│       ├── aws/
│       │   └── ...
│       └── azure/
│           └── ...
├── scripts/
│   └── ansible/
│       └── playbook.yml
└── shared/
    ├── versions.tf
    ├── providers.tf
    └── variables.tf

# 2
clone the repository
cd terraform

# initilize terraform
terraform init

# Review the plan if necessary
terraform plan

# Apply the configuration
terraform apply -auto-approve

# To access the instance
ssh -i ~/.ssh/id_rsa ansible_user@<public_ip>

# To destroy the infra
terraform destroy