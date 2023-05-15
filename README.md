# Terraform AWS Redstone Gateway module

Terraform module which deploys [Redstone Gateway](https://github.com/redstone-finance/redstone-oracles-monorepo/tree/main/packages/cache-service) with required resources and configuration.

Used services:
- ECS for deploying Docker container with application
- MongoDb Atlas Cluster as database for application, connected with ECS using VPC Peering
- Application Load Balancer
- CloudFront for providing HTTPS endpoints without domain
- CloudWatch Logs for ECS container logs
- System Manager Parameter Store for securely storing MongoDb credentials and application api key

## Inputs
- `admin_routes_api_key` - API key for admin routes in gateway service
- `mongodbatlas_region` - MongoDB Atlas region e.g.:
[MongoDb Atlas AWS Regions](https://docs.atlas.mongodb.com/reference/amazon-aws/). 
MongoDb Atlas region must correspond with AWS provider region e.g. `EU_CENTRAL_1` and `eu-central-1`

## Outputs
- `app_url` - API url
- `mongodb_username` - MongoDb user username 
- `mongodb_password` - MongoDb user generated password
- `mongodb_connection_string` - MongoDb connection string used in application