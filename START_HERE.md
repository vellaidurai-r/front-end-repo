# 🚀 START HERE - EC2 t2.micro Setup

## 📋 Quick Checklist

You have **3 options** to get started:

### ✅ Option 1: AWS Console (Easiest)
```
1. Go to EC2 Dashboard
2. Click "Launch Instances"
3. Choose "Amazon Linux 2 AMI" (Free tier)
4. Instance: t2.micro
5. Storage: 30 GB gp2 (default)
6. Security Group: Allow ports 3000, 3001, 3002
7. Launch!
```

### ✅ Option 2: AWS CLI (Fast)
```bash
./launch-ec2-instance.sh
```

### ✅ Option 3: Manual Commands
```bash
# See EC2_RDS_SETUP_GUIDE.md for full commands
```

## 🔧 After Launching EC2:

```bash
# 1. SSH into your instance
ssh -i your-key.pem ec2-user@<PUBLIC_IP>

# 2. Run setup (copy entire script at once)
bash << 'SCRIPT'
sudo yum update -y
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker

# Start all 3 frontend containers
docker run -d --name frontend-dev --restart always -p 3000:3000 -e VITE_ENVIRONMENT=development -e VITE_BACKEND_URL=http://3.24.242.50:3000 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-dev:latest

docker run -d --name frontend-staging --restart always -p 3001:3000 -e VITE_ENVIRONMENT=staging -e VITE_BACKEND_URL=http://3.25.70.32:3000 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-staging:latest

docker run -d --name frontend-prod --restart always -p 3002:3000 -e VITE_ENVIRONMENT=production -e VITE_BACKEND_URL=http://16.176.7.157:3000 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-prod:latest

echo "✅ All containers started!"
docker ps
SCRIPT
```

## 🌐 Access Your Apps

After setup is complete:

| Environment | URL |
|---|---|
| **Dev** | `http://<PUBLIC_IP>:3000` |
| **Staging** | `http://<PUBLIC_IP>:3001` |
| **Production** | `http://<PUBLIC_IP>:3002` |

## 🔐 Make IP Static

```bash
# Allocate Elastic IP
aws ec2 allocate-address --domain vpc --region ap-southeast-2

# Note the AllocationId and PublicIp

# Associate with EC2 instance
aws ec2 associate-address \
  --instance-id <YOUR_INSTANCE_ID> \
  --allocation-id <ALLOCATION_ID> \
  --region ap-southeast-2
```

## 💾 Optional: Set Up RDS Database

```bash
aws rds create-db-instance \
  --db-instance-identifier frontend-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YourPassword123! \
  --allocated-storage 20 \
  --region ap-southeast-2
```

## 💰 Your Cost:

- **Year 1**: FREE 🎉
- **Year 2+**: ~$25/month

## 📚 Full Documentation:

- **EC2_RDS_SETUP_GUIDE.md** - Detailed instructions
- **MIGRATION_SUMMARY.md** - Overview of changes
- **launch-ec2-instance.sh** - Launch script
- **setup-ec2-frontend.sh** - Setup script

## 🚀 That's It!

You now have:
✅ 3 frontend environments (Dev, Staging, Prod)
✅ Static IP (if you allocated Elastic IP)
✅ Database ready (RDS - optional)
✅ All FREE for 12 months!

**Happy learning! 🎉**
