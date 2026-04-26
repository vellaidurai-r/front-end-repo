# Single EC2 t2.micro Setup Guide - Frontend + Backend

**Goal**: Run both frontend (3 envs) + backend (3 envs) on ONE EC2 t2.micro instance

**Timeline**: ~40-50 minutes (easy steps)

**Cost**: $0 Year 1, $28.19/month Year 2+

---

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│         EC2 t2.micro Instance                   │
│                                                 │
│  ├─ Frontend Dev       http://<IP>:3000         │
│  ├─ Frontend Staging   http://<IP>:3001         │
│  ├─ Frontend Prod      http://<IP>:3002         │
│  │                                              │
│  ├─ Backend Dev        http://<IP>:3100         │
│  ├─ Backend Staging    http://<IP>:3101         │
│  └─ Backend Prod       http://<IP>:3102         │
│                                                 │
└─────────────────────────────────────────────────┘
                        ↓
            Elastic IP (Static)
                  <YOUR_IP>
                        ↓
        Optional: RDS Database (MySQL/PostgreSQL)
```

---

## 🚀 STEP-BY-STEP SETUP

### STEP 1: Launch EC2 t2.micro Instance (5 minutes)

#### Option A: AWS Console (Easiest)
1. Go to **EC2 Dashboard**
2. Click **"Launch Instances"**
3. **Select Amazon Linux 2 AMI** (Free tier eligible)
4. **Instance type**: t2.micro (Free tier)
5. **Network settings**:
   - VPC: Default
   - Subnet: Any available
   - Auto-assign public IP: Enable
6. **Storage**: 30 GB gp2 (default, FREE)
7. **Security Group** - Create new with:
   - Inbound: SSH (port 22) from your IP
   - Inbound: HTTP (port 80) from 0.0.0.0/0
   - Inbound: TCP ports 3000-3102 from 0.0.0.0/0
8. **Key pair**: Create or select existing
9. Click **"Launch"**

#### Option B: AWS CLI
```bash
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --key-name your-key-name \
  --security-groups default \
  --region ap-southeast-2 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=frontend-backend-instance}]'
```

**Note**: Save the Instance ID from output

---

### STEP 2: Get Public IP & Connect (2 minutes)

```bash
# Get your instance public IP
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxxxxxxxxx \
  --region ap-southeast-2 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text

# SSH into instance
ssh -i your-key.pem ec2-user@<PUBLIC_IP>
```

---

### STEP 3: Install Docker & Docker Compose (10 minutes)

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker git

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user
newgrp docker

# Test Docker
docker --version
```

---

### STEP 4: Create Docker Compose File (5 minutes)

SSH into your EC2 instance and create docker-compose.yml:

```bash
# Create directory
mkdir -p ~/deployment
cd ~/deployment

# Create docker-compose.yml with all 6 services
cat > docker-compose.yml << 'COMPOSE'
version: '3.8'

services:
  # ========== FRONTEND CONTAINERS ==========
  
  frontend-dev:
    image: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-dev:latest
    ports:
      - "3000:3000"
    environment:
      - VITE_ENVIRONMENT=development
      - VITE_BACKEND_URL=http://<YOUR_STATIC_IP>:3100
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend-staging:
    image: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-staging:latest
    ports:
      - "3001:3000"
    environment:
      - VITE_ENVIRONMENT=staging
      - VITE_BACKEND_URL=http://<YOUR_STATIC_IP>:3101
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend-prod:
    image: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-prod:latest
    ports:
      - "3002:3000"
    environment:
      - VITE_ENVIRONMENT=production
      - VITE_BACKEND_URL=http://<YOUR_STATIC_IP>:3102
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3002"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ========== BACKEND CONTAINERS ==========
  
  backend-dev:
    image: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/backend-dev:latest
    ports:
      - "3100:3000"
    environment:
      - NODE_ENV=development
      - ENVIRONMENT=dev
      - FRONTEND_URL=http://<YOUR_STATIC_IP>:3000
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend-staging:
    image: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/backend-staging:latest
    ports:
      - "3101:3000"
    environment:
      - NODE_ENV=staging
      - ENVIRONMENT=staging
      - FRONTEND_URL=http://<YOUR_STATIC_IP>:3001
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend-prod:
    image: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/backend-prod:latest
    ports:
      - "3102:3000"
    environment:
      - NODE_ENV=production
      - ENVIRONMENT=prod
      - FRONTEND_URL=http://<YOUR_STATIC_IP>:3002
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
COMPOSE
```

**Important**: Replace `<YOUR_STATIC_IP>` with your Elastic IP (you'll get it in Step 6)

---

### STEP 5: Deploy Containers (10 minutes)

```bash
# Ensure you're in the directory with docker-compose.yml
cd ~/deployment

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version

# Login to ECR (replace with your AWS credentials if needed)
aws ecr get-login-password --region ap-southeast-2 | \
  docker login --username AWS --password-stdin 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com

# Start all containers
docker-compose up -d

# Check status
docker-compose ps
```

---

### STEP 6: Allocate & Associate Elastic IP (5 minutes)

From your **local machine** (not SSH):

```bash
# Get your instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=frontend-backend-instance" \
  --region ap-southeast-2 \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

# Allocate Elastic IP
ALLOCATION_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --region ap-southeast-2 \
  --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=frontend-backend-eip}]' \
  --query 'AllocationId' \
  --output text)

# Get the public IP
PUBLIC_IP=$(aws ec2 describe-addresses \
  --allocation-ids $ALLOCATION_ID \
  --region ap-southeast-2 \
  --query 'Addresses[0].PublicIp' \
  --output text)

# Associate Elastic IP to instance
aws ec2 associate-address \
  --instance-id $INSTANCE_ID \
  --allocation-id $ALLOCATION_ID \
  --region ap-southeast-2

echo "Your Static IP: $PUBLIC_IP"
echo "Instance ID: $INSTANCE_ID"
echo "Allocation ID: $ALLOCATION_ID"
```

**Save these values!**

---

### STEP 7: Update docker-compose.yml with Static IP (5 minutes)

SSH back into your instance:

```bash
# Update docker-compose.yml with your static IP
cd ~/deployment

# Replace <YOUR_STATIC_IP> with actual IP
sed -i 's/<YOUR_STATIC_IP>/YOUR_ACTUAL_IP/g' docker-compose.yml

# Restart containers with new config
docker-compose down
docker-compose up -d

# Verify
docker-compose ps
```

---

### STEP 8: Test All Environments (10 minutes)

From your **local machine**:

```bash
# Test Frontend
echo "Frontend Dev:"
curl -I http://<STATIC_IP>:3000

echo -e "\nFrontend Staging:"
curl -I http://<STATIC_IP>:3001

echo -e "\nFrontend Prod:"
curl -I http://<STATIC_IP>:3002

# Test Backend
echo -e "\nBackend Dev:"
curl -I http://<STATIC_IP>:3100

echo -e "\nBackend Staging:"
curl -I http://<STATIC_IP>:3101

echo -e "\nBackend Prod:"
curl -I http://<STATIC_IP>:3102
```

Or visit in browser:
- Dev: http://<STATIC_IP>:3000
- Staging: http://<STATIC_IP>:3001
- Prod: http://<STATIC_IP>:3002

---

## 🔧 USEFUL COMMANDS

### SSH into instance
```bash
ssh -i your-key.pem ec2-user@<STATIC_IP>
```

### View logs
```bash
# All containers
docker-compose logs -f

# Specific container
docker-compose logs -f frontend-dev
```

### Restart containers
```bash
docker-compose restart
```

### Stop all containers
```bash
docker-compose stop
```

### Start all containers
```bash
docker-compose start
```

### Rebuild images
```bash
docker-compose pull
docker-compose up -d
```

### View running processes
```bash
docker-compose ps
```

---

## 📊 WHAT YOU'LL HAVE

| Environment | Frontend URL | Backend URL | Status |
|---|---|---|---|
| Dev | http://<IP>:3000 | http://<IP>:3100 | ✅ Running |
| Staging | http://<IP>:3001 | http://<IP>:3101 | ✅ Running |
| Prod | http://<IP>:3002 | http://<IP>:3102 | ✅ Running |

---

## 💰 COSTS

| Period | Cost | Notes |
|--------|------|-------|
| Year 1 | **$0** | All FREE (AWS Free Tier) |
| Year 2+ | **$28.19/month** | EC2 + RDS + Storage |
| vs Fargate | **52% cheaper** | Saves $374/year |

---

## ⚠️ IMPORTANT NOTES

### 1. ECR Images
- Make sure your ECR images exist for all 6 environments:
  - frontend-dev, frontend-staging, frontend-prod
  - backend-dev, backend-staging, backend-prod

### 2. Environment Variables
- Frontend uses `VITE_` prefix (built into static assets)
- Backend uses `NODE_ENV` / `ENVIRONMENT`
- Update docker-compose.yml if you have different vars

### 3. Database (Optional)
- If you need RDS, follow the guide in `EC2_RDS_SETUP_GUIDE.md`
- Or skip for now and add later

### 4. Static IP
- Elastic IP is FREE when associated
- You pay $0.05/month if NOT associated
- Keep it associated!

### 5. Stop when not needed
- Stop EC2 instance to save money (you're not paying for stopped instances)
- Restart anytime (IP stays the same)

---

## 🔄 MIGRATION FROM FARGATE

If you're moving from current Fargate setup:

1. Keep Fargate running during setup (no downtime)
2. Once EC2 is ready and tested, simply stop Fargate services
3. No data loss (both are stateless frontends/backends)
4. Can easily switch back if needed

---

## 📝 QUICK CHECKLIST

- [ ] EC2 instance launched
- [ ] Connected via SSH
- [ ] Docker installed
- [ ] docker-compose.yml created
- [ ] All 6 containers running (docker-compose ps)
- [ ] Elastic IP allocated
- [ ] Elastic IP associated to instance
- [ ] docker-compose.yml updated with static IP
- [ ] All environments tested via curl/browser
- [ ] Environment URLs bookmarked

---

## ❓ TROUBLESHOOTING

### Containers not starting?
```bash
docker-compose logs -f
# Check for image pull errors or port conflicts
```

### Can't connect to IP?
```bash
# Check security group allows ports 3000-3102
aws ec2 describe-security-groups --region ap-southeast-2

# Test from EC2:
curl -I http://localhost:3000
```

### Docker permission denied?
```bash
sudo usermod -aG docker ec2-user
newgrp docker
```

### Out of storage?
```bash
docker system prune -a
# Frees up space by removing old images/containers
```

---

## 🎯 NEXT STEPS (After Migration)

1. **Add Database (Optional)**
   - See: `EC2_RDS_SETUP_GUIDE.md`

2. **Stop Fargate Services**
   - Keep EC2 running instead

3. **Update DNS (If using custom domain)**
   - Point domain to Elastic IP

4. **Backup Configuration**
   - Save docker-compose.yml in git repo

5. **Monitor Costs**
   - Set AWS billing alerts

---

**Created**: April 26, 2026
**Region**: ap-southeast-2 (Sydney)
**Account**: 497162053399
**Repository**: vellaidurai-r/front-end-repo
