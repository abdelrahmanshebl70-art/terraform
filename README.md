Terraform AWS Infrastructure: Auto-Scaling Web Tier with MySQL

Infrastructure as Code for a three-tier AWS environment (web/app tier on an Auto Scaling Group, MySQL on RDS, network split into public, private and database subnets), written in Terraform and deployed to us-east-1. The sample application is named RetailEdge.

Architecture
                         VPC 10.0.0.0/16  (us-east-1a, us-east-1b)
 ┌────────────────────────────────────────────────────────────────────┐
 │  Public subnets     10.0.1.0/24 (1a)   10.0.2.0/24 (1b)             │
 │                                                                    │
 │  Private subnets    10.0.3.0/24 (1a)   10.0.4.0/24 (1b)             │
 │    └─ Auto Scaling Group (t3.micro instances, port 8080)           │
 │         └─ registered to the ALB target group `app-target-group`   │
 │                                                                    │
 │  Database subnets   10.0.7.0/24 (1a)   10.0.6.0/24 (1b)             │
 │    └─ RDS MySQL 8.0 (db.t3.micro)                                  │
 └────────────────────────────────────────────────────────────────────┘

 Traffic chain (security groups):
   shipl_sg (443 from internet) ──► app_sg (8080 from shipl_sg) ──► rds_sg (3306 from app_sg)
What gets provisioned
File	Resources
provider.tf	AWS provider (hashicorp/aws ~> 5.0), region us-east-1
backend.tf	Remote state in S3 with native state locking (use_lockfile = true)
vpc.tf	1 VPC and 6 subnets across 2 Availability Zones: 2 public, 2 private, 2 database
sg.tf	3 chained security groups: shipl_sg, app_sg, rds_sg
comput.tf	Launch template, Auto Scaling Group, CPU target-tracking policy, scheduled scale-up
lb.tf	Target group (HTTP:8080, target type instance) that the Auto Scaling Group registers to
database.tf	RDS MySQL 8.0 instance, DB subnet group, ElastiCache subnet group
variable.tf	my_ami: AMI ID used by the launch template
output.tf	vpc_id, database_endpoint, autoscaling_group_name
Key design decisions
Three network tiers. Web/app instances sit in private subnets with no public IP. The database lives in its own subnets, spread over two Availability Zones.
Least-privilege traffic flow. app_sg accepts port 8080 only from shipl_sg, and rds_sg accepts port 3306 only from app_sg, so the database cannot be reached directly from the internet.
Auto scaling on load. The Auto Scaling Group runs 2 to 5 instances (desired 2) and scales to keep average CPU at 60% using a target-tracking policy.
Planned traffic spike. A scheduled action raises capacity to 6 to 10 instances every Friday at 20:00 UTC (0 20 * * FRI) to cover peak shopping traffic.
Safe rollouts. Instance refresh uses a rolling strategy that keeps at least 90% of instances healthy, and the group uses ELB health checks.
Remote state. State is stored in S3 with locking, so the configuration can be run from any machine without conflicts.
Prerequisites
Terraform >= 1.10 (needed for S3 native locking via use_lockfile)
AWS credentials configured (aws configure or environment variables) with permissions for VPC, EC2, Auto Scaling, RDS, ElastiCache and S3
An S3 bucket for remote state, with its name set in backend.tf
A valid AMI ID in us-east-1 (see Variables)
Usage
bash
git clone https://github.com/abdelrahmanshebl70-art/terraform.git
cd terraform

terraform init       # downloads providers and configures the S3 backend
terraform fmt        # optional: format the files
terraform validate   # check the configuration
terraform plan       # preview the changes
terraform apply      # create the infrastructure

terraform destroy    # remove everything when you are done
Variables
Name	Type	Description
my_ami	string	AMI ID for the launch template. It has a default value, which you should replace with an AMI that exists in your account/region.
Outputs
Name	Description
vpc_id	ID of the VPC
database_endpoint	Connection endpoint of the RDS MySQL instance
autoscaling_group_name	Name of the Auto Scaling Group
Current limitations and next steps

This is a learning project, so some parts are intentionally simple and are on my improvement list:

 Move the database password out of database.tf into a sensitive variable or AWS Secrets Manager
 Add the load balancer itself and its listener in front of the existing target group
 Add an internet gateway, NAT gateway and route tables so public and private subnets have the right routing
 Enable storage encryption, Multi-AZ and longer backup retention on RDS for production use
 Replace the placeholder user data script with a real application bootstrap
 Split the configuration into reusable modules
