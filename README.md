# 🚀 AWS Auto Scaling Infrastructure with Terraform

> **Production-ready, highly available web application infrastructure on AWS**

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Free_Tier-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🏗️ Architecture Overview

```
┌─────────────┐    ┌──────────────────────┐    ┌─────────────────┐
│   Internet  │───▶│  Application Load    │───▶│  Target Group   │
│             │    │     Balancer         │    │                 │
└─────────────┘    └──────────────────────┘    └─────────────────┘
                                                         │
                                                         ▼
                                               ┌─────────────────┐
                                               │ Auto Scaling    │
                                               │     Group       │
                                               └─────────────────┘
                                                         │
                                        ┌────────────────┼────────────────┐
                                        ▼                                 ▼
                                ┌─────────────────┐              ┌─────────────────┐
                                │ EC2 Instance    │              │ EC2 Instance    │
                                │     (AZ-1a)     │              │     (AZ-1b)     │
                                │   nginx server  │              │   nginx server  │
                                └─────────────────┘              └─────────────────┘
```

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🌐 **High Availability** | Multi-AZ deployment across different availability zones |
| 📈 **Auto Scaling** | Automatic scaling (1-3 instances) based on health checks |
| ⚖️ **Load Balancing** | Application Load Balancer with health monitoring |
| 🔒 **Security** | IMDSv2 tokens, proper security groups, git-ignored credentials |
| 💰 **Cost Optimized** | Free Tier friendly using t2.micro instances |
| 🔍 **Monitoring** | Real-time instance identification and health tracking |

## 🚀 Quick Deploy

```bash
# 1. Clone and setup
git clone <your-repo>
cd autoscalling-ec2

# 2. Configure your environment
cp variable.tf.example variable.tf
# Edit variable.tf with your AWS resources

# 3. Deploy infrastructure
terraform init
terraform plan
terraform apply

# 4. Get your application URL
terraform output load_balancer_url
```

## 📊 What You'll Get

After deployment, you'll have:
- **2 EC2 instances** running nginx web servers
- **Application Load Balancer** distributing traffic
- **Auto healing** - failed instances automatically replaced
- **Web interface** showing which instance you're hitting

### 🌐 Live Demo

Once deployed, your web interface will show:
```
🚀 EC2 Instance Dashboard

Instance Identifier: i-0123456789abcdef0

📍 Network Information
Public IP: 13.233.123.45
Private IP: 10.0.1.100

🌍 Location Information
Availability Zone: ap-south-1a

⚡ Server Status
Nginx Status: ✅ Running
Load Balancer: Connected via ALB

Refresh this page to see different instances!
```

## 🛠️ Infrastructure Components

```hcl
# Core Resources Created
├── Launch Template      # EC2 configuration with nginx
├── Auto Scaling Group   # Manages 2 instances (scales 1-3)
├── Load Balancer       # Routes traffic across instances
├── Target Group        # Health checks and routing rules
└── Security Group      # Network access controls
```

## 📁 Project Structure

```
autoscalling-ec2/
├── main.tf                 # 🏗️ Core infrastructure
├── variable.tf.example     # 📝 Configuration template
├── output.tf              # 📤 Resource outputs
├── .gitignore            # 🔒 Security exclusions
└── README.md             # 📖 This documentation
```

## 🔧 Prerequisites

- [Terraform](https://terraform.io/downloads.html) `>= 1.0`
- AWS CLI configured or environment variables set
- Existing VPC with public subnets in different AZs
- EC2 Key Pair for SSH access

## ⚙️ Configuration Guide

### Required Variables Setup

Copy the example file and configure with your AWS resources:

```bash
cp variable.tf.example variable.tf
```

### 📝 Variables to Configure

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `access_key` | AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` | ✅ |
| `secret_key` | AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` | ✅ |
| `region` | AWS region for deployment | `ap-south-1` | ✅ |
| `vpc_id` | Your existing VPC ID | `vpc-12345678` | ✅ |
| `subnet_ids` | Public subnets in different AZs | `["subnet-12345678", "subnet-87654321"]` | ✅ |
| `key_name` | EC2 Key Pair for SSH access | `my-key-pair` | ✅ |
| `ami` | Ubuntu AMI ID (region-specific) | `ami-0f918f7e67a3323f0` | Optional |
| `instance_type` | EC2 instance size | `t2.micro` | Optional |

### 🔍 How to Find Your Values

**VPC ID & Subnet IDs:**
```bash
# List your VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table

# List subnets in your VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=YOUR_VPC_ID" --query 'Subnets[*].[SubnetId,AvailabilityZone,MapPublicIpOnLaunch]' --output table
```

**Key Pair:**
```bash
# List your key pairs
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table
```

**AMI ID (Ubuntu 22.04 LTS):**
```bash
# Find latest Ubuntu AMI for your region
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" --query 'Images[*].[ImageId,Name]' --output table
```

### ⚠️ Security Best Practices

- **Never commit `variable.tf`** - It's git-ignored for security
- **Use IAM roles** instead of access keys when possible
- **Rotate credentials** regularly
- **Use least privilege** IAM policies

## 💡 Advanced Usage

### Custom Configuration
```hcl
# variable.tf - Optional customizations
instance_type = "t3.micro"    # Upgrade instance type (default: t2.micro)
region = "us-east-1"          # Change deployment region
```

### Alternative Authentication Methods

**Option 1: Environment Variables (Recommended)**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
# Leave access_key and secret_key empty in variable.tf
```

**Option 2: AWS CLI Profile**
```bash
aws configure --profile myproject
# Then use: terraform apply -var="profile=myproject"
```

### Monitoring & Debugging
```bash
# Check instance health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# View auto scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name $(terraform output -raw autoscaling_group_name)
```

## 🎯 Use Cases

- **Learning AWS** - Hands-on experience with core services
- **Portfolio Projects** - Demonstrate cloud architecture skills
- **Proof of Concepts** - Quick scalable web application setup
- **Interview Prep** - Real-world infrastructure examples

## 🔐 Security Best Practices

✅ **Implemented:**
- Credentials excluded from version control
- IMDSv2 metadata service tokens
- Least privilege security groups
- Multi-AZ deployment for resilience

## 💰 Cost Breakdown

| Resource | Quantity | Monthly Cost (Free Tier) |
|----------|----------|-------------------------|
| t2.micro instances | 2 | $0 (750 hours free) |
| Application Load Balancer | 1 | $0 (750 hours free) |
| Data Transfer | <15GB | $0 (15GB free) |
| **Total** | | **$0/month** |

## 🧹 Cleanup

```bash
terraform destroy
```

## 🤝 Contributing

Found an issue or want to improve this? 
1. Fork the repository
2. Create your feature branch
3. Submit a pull request

---

<div align="center">

**⭐ Star this repo if it helped you learn AWS and Terraform!**

[Report Bug](../../issues) • [Request Feature](../../issues) • [Documentation](../../wiki)

</div>