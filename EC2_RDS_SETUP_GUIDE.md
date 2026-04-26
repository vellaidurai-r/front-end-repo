# EC2 t2.micro + RDS Setup Guide

## 🎯 Overview

This guide will help you set up a cost-effective infrastructure for learning:

- **EC2 t2.micro**: Run all 3 frontend environments (Dev, Staging, Prod) using Docker
- **RDS t3.micro**: Database for your backend (optional)
- **Elastic IP**: Static IP for EC2 instance
- **Cost**: **FREE for 12 months** (within AWS Free Tier)

## ✅ Step 1: Create EC2 Instance

### Option A: Using AWS Console
1. Go to **EC2 Dashboard**
2. Click **Launch Instances**
3. Select **Amazon Linux 2 AMI** (Free tier eligible)
4. Instance type: **t2.micro**
5. VPC: **Default VPC**
6. Subnet: **Any available subnet**
7. Storage: **30 GB gp2** (Default)
8. Security Group: Allow inbound on ports **3000, 3001, 3002** (HTTP)
9. Launch and download key pair

### Option B: Using AWS CLI
```bash
# Make scripts executable
chmod +x launch-ec2-instance.sh
chmod +x setup-ec2-frontend.sh

# Edit launch-ec2-instance.sh and set your key pair name
# Then run:
./launch-ec2-instance.sh
```

## ✅ Step 2: Set Up Docker on EC2

### SSH into your instance:
```bash
ssh -i your-key.pem ec2-user@<PUBLIC_IP>
```

### Run setup script:
```bash
# Option 1: Download and run directly
curl -O https://raw.githubusercontent.com/vellaidurai-r/front-end-repo/develop/setup-ec2-frontend.sh
chmod +x setup-ec2-frontend.sh
./setup-ec2-frontend.sh

# Option 2: Manual setup
sudo yum update -y
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
```

## ✅ Step 3: Start Frontend Containers

```bash
# Dev Environment (Port 3000)
docker run -d \
  --name frontend-dev \
  --restart always \
  -p 3000:3000 \
  -e VITE_ENVIRONMENT=development \
  -e VITE_BACKEND_URL=http://3.24.242.50:3000 \
  497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-dev:latest

# Staging Environment (Port 3001)
docker run -d \
  --name frontend-staging \
  --restart always \
  -p 3001:3000 \
  -e VITE_ENVIRONMENT=staging \
  -e VITE_BACKEND_URL=http://3.25.70.32:3000 \
  497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-staging:latest

# Production Environment (Port 3002)
docker run -d \
  --name frontend-prod \
  --restart always \
  -p 3002:3000 \
  -e VITE_ENVIRONMENT=production \
  -e VITE_BACKEND_URL=http://16.176.7.157:3000 \
  497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-prod:latest
```

## ✅ Step 4: Allocate Static IP (Elastic IP)

```bash
# Allocate an Elastic IP
aws ec2 allocate-address --domain vpc --region ap-southeast-2

# Associate it with your instance
aws ec2 associate-address \
  --instance-id <YOUR_INSTANCE_ID> \
  --allocation-id <YOUR_ALLOCATION_ID> \
  --region ap-southeast-2
```

## ✅ Step 5: Set Up RDS (Optional)

### Create RDS Database
```bash
aws rds create-db-instance \
  --db-instance-identifier frontend-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YourSecurePassword123! \
  --allocated-storage 20 \
  --storage-type gp2 \
  --availability-zone ap-southeast-2a \
  --vpc-security-group-ids sg-xxxxxx \
  --publicly-accessible true \
  --region ap-southeast-2
```

### Access RDS
```bash
# Get RDS endpoint
aws rds describe-db-instances \
  --db-instance-identifier frontend-db \
  --region ap-southeast-2 \
  --query 'DBInstances[0].Endpoint.Address'

# Connect
psql -h <RDS_ENDPOINT> -U admin -d postgres
```

## 🌐 Access Your Apps

After setup is complete:

| Environment | URL | Port |
|---|---|---|
| **Development** | `http://<STATIC_IP>:3000` | 3000 |
| **Staging** | `http://<STATIC_IP>:3001` | 3001 |
| **Production** | `http://<STATIC_IP>:3002` | 3002 |

## 📊 Verify Containers

```bash
# List all running containers
docker ps

# View logs
docker logs -f frontend-dev
docker logs -f frontend-staging
docker logs -f frontend-prod

# Stop/start containers
docker stop frontend-dev
docker start frontend-dev

# Remove containers
docker rm frontend-dev
```

## 💰 Cost Breakdown

### Year 1 (Free Tier):
```
EC2 t2.micro:     FREE ✅
RDS t3.micro:     FREE ✅
Elastic IP:       FREE ✅ (when associated)
─────────────────
TOTAL:            $0/month 🎉
```

### Year 2+ (After Free Tier):
```
EC2 t2.micro:     $8.47/month
RDS t3.micro:     $16.72/month
Elastic IP:       FREE (when associated)
─────────────────
TOTAL:            $25.19/month
```

## 🚀 Useful Commands

```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@<PUBLIC_IP>

# View EC2 instances
aws ec2 describe-instances --region ap-southeast-2 --query 'Reservations[0].Instances[0].[InstanceId, PublicIpAddress, State.Name]'

# View RDS instances
aws rds describe-db-instances --region ap-southeast-2 --query 'DBInstances[0].[DBInstanceIdentifier, Endpoint.Address, DBInstanceStatus]'

# View Elastic IPs
aws ec2 describe-addresses --region ap-southeast-2 --query 'Addresses[*].[PublicIp, InstanceId, AllocationId]'

# Stop EC2 (saves compute cost)
aws ec2 stop-instances --instance-ids <INSTANCE_ID> --region ap-southeast-2

# Start EC2
aws ec2 start-instances --instance-ids <INSTANCE_ID> --region ap-southeast-2

# Terminate EC2 (delete instance)
aws ec2 terminate-instances --instance-ids <INSTANCE_ID> --region ap-southeast-2
```

## ⚠️ Important Notes

1. **Elastic IP charges**: Only charged when NOT associated with running instance
2. **Data transfer**: First 100 GB/month outbound is FREE
3. **Backups**: RDS automated backups count towards free storage tier
4. **Monitoring**: EC2 monitoring is FREE for basic metrics
5. **Free tier ends**: After 12 months from account creation

## 📝 Next Steps

1. Launch EC2 instance
2. Set up Docker with three containers
3. Allocate Elastic IP for static address
4. (Optional) Create RDS database
5. Update your DNS/bookmarks with the static IP
6. Start learning and building!

## 🆘 Troubleshooting

### Containers not starting?
```bash
# Check Docker service
sudo systemctl status docker

# View error logs
docker logs frontend-dev

# Rebuild image locally
docker build -t frontend-dev:latest .
```

### Can't connect to EC2?
```bash
# Check security group
aws ec2 describe-security-groups --group-ids <SG_ID> --region ap-southeast-2

# Add port 3000
aws ec2 authorize-security-group-ingress \
  --group-id <SG_ID> \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0 \
  --region ap-southeast-2
```

### ECR authentication failed?
```bash
# Login to ECR
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com
```

---

Happy learning! 🚀
