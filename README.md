================================================================================
                    8BYTE.AI DEVOPS ASSESSMENT
================================================================================

PROJECT OVERVIEW
================================================================================
This repository contains the complete infrastructure setup for the 8Byte.AI 
DevOps assessment. The project demonstrates end-to-end DevOps practices 
including Infrastructure as Code (IaC), CI/CD pipelines, monitoring, and 
logging on AWS.

I have taken a step-by-step approach and have tried to constrain myself to 
keep this in the free tier, using minimal resources while touching up on all assignment points.

My approach mostly stuck to what i have previously dealth with in my last 
organisation and so somethings are rather simple. 
However i wanted to have something for all points and hence kept in mind the time.

I used plan.txt while building this project and challenges.txt for challenges please do 
refer to them as well for understanding what i went through while building.


The assignment requirements and what i have acheived:

1. Infrastructure Provisioning - Terraform-based AWS infrastructure -------DONE
   -VPC with public and private subnets
   -EC2 instances or ECS/EKS for application hosting 
   -RDS for PostgreSQL database
   -Security groups with appropriate rules 
   -Load balancer for the frontend 
   -Include variables.tf for configurable parameters 
   -Implement proper state management 
   -Add outputs for key resources

2. Deployment Automation - CI/CD pipelines with GitHub Actions
   -Run tests on PR creation ---------------------------------------------DONE
   -Build and push Docker images to a registry on merge to main-----------NOT DONE 
   -Deploy to staging environment ----------------------------------------DONE
   -Include a manual approval step for production deployment--------------DONE 
   -Run unit and integration tests ---------------------------------------NOT DONE
   -Scan for vulnerabilities in dependencies and containers---------------NOT DONE 
   -Notify on failures (Slack/email)--------------------------------------DEFAULT DONE

3. Monitoring & Logging - CloudWatch monitoring and centralized logging
   -Infrastructure metrics (CPU, memory, disk)----------------------------DONE 
   -Application metrics (request rate, error rate, latency)---------------NOT DONE 
   -Database metrics -----------------------------------------------------DONE
   -Application logs -----------------------------------------------------DONE
   -System logs ----------------------------------------------------------DONE
   -Access logs ----------------------------------------------------------DONE
   -Create at least two meaningful dashboards ----------------------------1 DONE

4. Documentation - Comprehensive setup and architecture documentation
   -Secret management ----------------------------------------------------NOT REALLY
   -Backup strategy ------------------------------------------------------KIND OFF


================================================================================
PART 1: INFRASTRUCTURE PROVISIONING
================================================================================

ARCHITECTURE OVERVIEW
--------------------------------------------------------------------------------
The infrastructure consists of:
- VPC with public and private subnets (2 public + 2 private)
- Application Load Balancer (ALB) for traffic distribution
- EC2 instances (t3.micro) for application hosting
- RDS PostgreSQL database (db.t4g.micro)
- Security Groups with least-privilege rules
- S3 Bucket for Terraform state management with DynamoDB state locking

TERRAFORM SETUP
--------------------------------------------------------------------------------
Prerequisites:
- Terraform v1.6.0+ installed locally
- AWS CLI configured with appropriate credentials
- AWS account with programmatic access

Infrastructure Deployment Process:
1. Navigate to the terraform directory
2. Initialize Terraform to download required providers
3. Review the execution plan
4. Apply the infrastructure to create all resources

KEY RESOURCES DEPLOYED
--------------------------------------------------------------------------------
VPC           : Custom CIDR 10.0.0.0/16
Subnets       : 2 Public, 2 Private distributed across availability zones
EC2           : t3.micro with Amazon Linux 2023 AMI
RDS           : db.t4g.micro, PostgreSQL 15, 1-day backup retention
ALB           : Application Load Balancer, internet-facing
S3            : Terraform state management with locking

SECURITY GROUPS CONFIGURATION
--------------------------------------------------------------------------------
- ALB Security Group: Allows HTTP and HTTPS traffic from anywhere
- Application Security Group: Allows traffic only from the ALB
- RDS Security Group: Allows PostgreSQL traffic only from the Application SG


================================================================================
PART 2: DEPLOYMENT AUTOMATION
================================================================================

CI/CD PIPELINE ARCHITECTURE
--------------------------------------------------------------------------------
Three-tier pipeline with environment-specific deployments:
- Development: Automatic deployment on push to development branch
- Testing: Automatic deployment on PR to test branch (requires passing tests)
- Production: Manual approval required before deployment

BRANCH STRATEGY
--------------------------------------------------------------------------------
Branch          Environment     Trigger                 Approval Required
dev             8BYTE EC2         Push                    No
test            8BYTE EC2         PR/push                      No (after tests pass)
main            8BYTE EC2         PR/merge                Yes

GITHUB ACTIONS WORKFLOWS
--------------------------------------------------------------------------------
Three separate workflows:
- Development Pipeline: Runs on push to development branch, deploys automatically
- Testing Pipeline: Runs on push to test branch, executes dummy test before deployment
- Production Pipeline: Includes manual approval step via GitHub Environments

DOCKER INTEGRATION
--------------------------------------------------------------------------------
The application is containerized and deployed via Docker on the EC2 instance. 
Each deployment builds the Docker image and runs it on dev:80 test:8080 & prod:8081 
ports.

DEPLOYMENT PROCESS
--------------------------------------------------------------------------------
Application deployment involves:
1. configures appleboySSH and  passes secres.variables
2. "cd" into the right directory
on test and prod. dummy test loop checked
3. Pulling the latest code
4. Building the Docker image
5. Running the container with proper secrets.variables


================================================================================
PART 3: MONITORING & LOGGING
================================================================================

CLOUDWATCH MONITORING SETUP
--------------------------------------------------------------------------------
Infrastructure Metrics Collected:
- EC2 Metrics: CPU Utilization, Memory Usage, Disk Usage
- RDS Metrics: Memory Utilisation, CPU Utilization
- ALB Metrics: Request Count, Target Response Time

CloudWatch Agent Configuration:
The CloudWatch agent collects system-level metrics and forwards them to 
CloudWatch with appropriate namespaces and dimensions. It's installed via 
EC2 shell.

DASHBOARDS CREATED
--------------------------------------------------------------------------------
1. Infrastructure Health Dashboard:
   Tracks infrastructure metrics including CPU, memory, disk utilization, 
   database connection counts and ALB request-response time

CENTRALIZED LOGGING
--------------------------------------------------------------------------------
Logs collected from three sources:
- Application Logs: docker container logs
- System Logs: Linux rsyslog messages

All logs are pushed to CloudWatch Logs with 1-day retention policy.

================================================================================
SECURITY CONSIDERATIONS
================================================================================

IAM & ACCESS MANAGEMENT
--------------------------------------------------------------------------------
- Terraform uses programmatic IAM user with limited permissions
- EC2 instances have an IAM role granting necessary CloudWatch and S3 access
- No root user access used throughout the process
- sagar_user created for console access

NETWORK SECURITY
--------------------------------------------------------------------------------
- VPC isolation with public and private subnets
- RDS deployed in private subnets with no direct internet access
- Security groups follow least-privilege principle
- ALB serves as the single entry point to the application

SECRET MANAGEMENT
--------------------------------------------------------------------------------
Current Implementation:
- Terraform variables in gitignored .tfvars file
- GitHub Actions secrets for CI/CD variables
- Environment variables for runtime secrets

Recommended Improvements:
- Migrate to AWS Secrets Manager for production
- Implement automatic secret rotation
- Consider HashiCorp Vault for advanced secret management

DATA PROTECTION
--------------------------------------------------------------------------------
- RDS encryption at rest enabled
- TLS/SSL with SSH Tunneling for database connections
- 1-day automated backup retention (optimized for free tier)

================================================================================
COST OPTIMIZATION MEASURES
================================================================================

FREE TIER OPTIMIZATION
--------------------------------------------------------------------------------
- EC2: Using t3.micro instances (free tier eligible)
- RDS: db.t4g.micro with reduced backup retention
- ALB: Single availability zone to minimize costs
- Storage: Appropriate EBS volume sizing
- Shuttoff when not working on env

COST MONITORING
--------------------------------------------------------------------------------
- Budget alert configured at $15/month


RESOURCE MANAGEMENT
--------------------------------------------------------------------------------
- Development environment can be stopped when not in use
- Regular review of unused resources

================================================================================
CHALLENGES FACED & SOLUTIONS
================================================================================

1. Git and .terraform Files
   Challenge: Pushed .terraform folder to git causing push failures
   Solution: Added .terraform to .gitignore

2. RDS Naming Constraints
   Challenge: RDS name couldn't start with numeric "8"
   Solution: Changed project name to "eight"

3. AMI Configuration Error
   Challenge: Wrong AMI name used in EC2 configuration
   Solution: Removed "-gp2" suffix from AMI name

4. Free Tier Eligibility Issues
   Challenge: t2.micro not free tier eligible, RDS 7-day backup too costly
   Solution: Changed to t3.micro and set backup_retention to 1 day

5. Security Group Configuration
   Challenge: Used cidr_block instead of security_groups in RDS config
   Solution: Corrected to reference security group IDs

6. Database Connection Issues
   Challenge: Security group misconfiguration causing connection failures
   Solution: Updated resource references to correct security groups
   (spent significant time debugging)

7. Special Characters in Database Password
   Challenge: $ character in DB password causing authentication failures
   Solution: Removed special characters, implemented proper string handling

8. CI/CD Security Concerns
   Challenge: Opening SSH to 0.0.0.0 for GitHub Actions
   Solution: Temporary opening with planned closure, exploring self-hosted runners

9. CloudWatch Agent Storage
   Challenge: Insufficient disk space for CloudWatch agent installation
   Solution: Increased EBS volume by 6GB

10. Log Collection on New AWS Image
    Challenge: New AWS images use systemd journal instead of traditional syslog
    Solution: Installed rsyslog and configured /var/log/messages for CloudWatch


================================================================================
BEST PRACTICES CONSIDERATIONS
================================================================================

1. Kubernetes Migration: Move from EC2 to EKS/ECS for better orchestration
2. Infrastructure Testing: Implement Terratest for infrastructure validation
3. Alerting: Set up CloudWatch alarms with SNS notifications
4. Disaster Recovery:RDS Multi-region deployment with automated failover
5. Use custom scripts to pull db images for backup
6. Never open 0.0.0.0 to public on anything - for cicd use a runner agent or jenkins
7. configure a jump-server for development on ec2 or at least make least-privilige user access
8. Secret Management: Migrate to AWS Secrets Manager dont inject during run time plz 
9. Auto-shutdown for env
10.Use Resource tagging for cost allocation
11.I used the same ec2 for all env's please have dedicated insances for env's
12.EC2 has public ip use elastic and/or keep private and use jump server with IGW
13.Use Roll-back strategy for ci/cd i didnt
14.Configure ec2 more deeply in terraform with default apps needed.

================================================================================
HOW TO RUN THE PROJECT
================================================================================

1. Clone the Repository
   Clone the repository to your local machine

2. Infrastructure Setup
   Navigate to the terraform directory, initialize, and apply the 
   infrastructure configuration

3. Application Deployment
   Deploy via console then use GitHub Actions (automatic on push)

4. Monitoring Setup
   CloudWatch agent is installed automatically via EC2 user data; access 
   dashboards through AWS Console


================================================================================
ASSESSMENT TIMELINE
================================================================================

Start Date:     August 31, 2026
End Date:       September 3, 2026
Status:         Complete "relatively"
Hours:          16
Credits used:   5$ 

================================================================================