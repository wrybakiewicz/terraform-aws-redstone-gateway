# Terraform AWS Redstone Gateway module

Terraform module which deploys [Redstone Gateway](https://github.com/redstone-finance/redstone-oracles-monorepo/tree/main/packages/cache-service) with required resources and configuration.

This module relies on 2 providers - AWS and MongoDb Atlas. 
MongoDb Atlas provider must have `Organization Project Creator` permission.

Used services:
- ECS Fargate for deploying Docker container with application
- MongoDb Atlas Cluster as database for application, connected with ECS using VPC Peering
- Application Load Balancer
- CloudFront for providing HTTPS endpoints without custom domain
- CloudWatch Logs for ECS container logs
- System Manager Parameter Store for securely storing MongoDb credentials and application api key

## Inputs
- `admin_routes_api_key` - API key for admin routes in gateway service
- `mongodbatlas_region` - MongoDB Atlas region e.g.:
[MongoDb Atlas AWS Regions](https://docs.atlas.mongodb.com/reference/amazon-aws/). 
MongoDb Atlas region must correspond with AWS provider region e.g. `EU_CENTRAL_1` and `eu-central-1`

## Outputs
- `api_url` - API url
- `mongodb_connection_string` - MongoDb connection string used in application