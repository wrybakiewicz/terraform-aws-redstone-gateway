# Complete

Example with complete configuration for module.

## Usage

To run this example you need to set environment variables:

For MongoDb Atlas - API Key must have `Organization Project Creator` permission
- MONGODB_ATLAS_PUBLIC_KEY
- MONGODB_ATLAS_PRIVATE_KEY

For AWS or have AWS CLI installed and configured:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

And run:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

After apply completion, wait few minutes for stack to start.