# Frontend CI/CD Pipeline Explanation

**Date**: May 4, 2026  
**Pipeline**: GitHub Actions  
**Language**: YAML (`.github/workflows/frontend-cicd.yml`)

---

## 🎯 Pipeline Overview

Your pipeline is a **3-environment deployment system** that automatically builds and deploys your React frontend to AWS ECS Fargate whenever you push to GitHub.

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  You push to GitHub (main/staging/develop)              │
│           ↓                                              │
│  GitHub Actions Triggers                                │
│           ↓                                              │
│  Build React App                                        │
│           ↓                                              │
│  Push to AWS ECR (Docker Registry)                      │
│           ↓                                              │
│  Update ECS Service                                     │
│           ↓                                              │
│  Deploy to Fargate (Auto-restart containers)           │
│           ↓                                              │
│  ✅ Done! App is live                                   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 📋 Branch Mapping

| Git Branch | Environment | ECS Cluster | Service | URL |
|-----------|-------------|------------|---------|-----|
| `main` | **Production** | my-node-api-cluster-prod | frontend-service-prod | IP:3000 |
| `staging` | **Staging** | my-node-api-cluster-staging | frontend-service-staging | IP:3000 |
| `develop` | **Development** | my-node-api-cluster-dev | frontend-service-dev | IP:3000 |

**How it works:**
- Push to `develop` → Deploys to Dev environment
- Push to `staging` → Deploys to Staging environment  
- Push to `main` → Deploys to Production environment

---

## 🔄 Pipeline Jobs (4 Steps)

### JOB 1: Determine Environment
```yaml
determines-environment:
  Purpose: Figure out which environment to deploy to
  Trigger: Always runs first
  Outputs:
    - environment (dev/staging/prod)
    - ecr-repo (frontend-dev/staging/prod)
    - cluster (my-node-api-cluster-*)
    - service (frontend-service-*)
    - backend-url (IP of backend API)
```

**Logic:**
```
IF branch == main
  → Production environment
ELSE IF branch == staging
  → Staging environment
ELSE (develop)
  → Development environment
```

**Backend URLs Hardcoded** (⚠️ Important):
```
Dev:       http://3.24.242.50:3000
Staging:   http://3.25.70.32:3000
Prod:      http://16.176.7.157:3000
```

---

### JOB 2: Build and Test
```yaml
build-and-test:
  Purpose: Build your React app locally
  Steps:
    1. Checkout code (from GitHub)
    2. Set up Node.js v20
    3. Install dependencies (npm install)
    4. Run linter (if configured)
    5. Build React app (npm run build)
    6. Upload build artifacts
```

**Output:**
- Creates `/dist/` folder with optimized React build
- Uploads to GitHub artifacts storage
- Used by Deploy job

**Environment Variables Passed:**
```
VITE_ENVIRONMENT=${environment}      // development/staging/production
VITE_BACKEND_URL=${backend-url}      // IP of backend API
```

---

### JOB 3: Deploy
```yaml
deploy:
  Purpose: Upload to AWS and update ECS service
  Requires: build-and-test success
  Steps:
    1. Download build artifacts (from Job 2)
    2. Configure AWS credentials
    3. Login to Amazon ECR
    4. Build Docker image
    5. Tag and push to ECR
    6. Update ECS service
    7. Wait for stability
    8. Print summary
```

**What Happens in Deploy:**

#### Step 1-3: AWS Setup
```bash
# Configure AWS credentials (from GitHub Secrets)
AWS_ACCESS_KEY_ID=***
AWS_SECRET_ACCESS_KEY=***
AWS_REGION=ap-southeast-2

# Login to your ECR (Docker registry)
# Outputs registry URL like: 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com
```

#### Step 4-5: Build & Push Docker Image
```dockerfile
# Dockerfile builds with your environment variables
FROM node:20
ARG VITE_ENVIRONMENT
ARG VITE_BACKEND_URL
# ... build steps ...
RUN npm run build
```

```bash
# Tag image
docker tag image:commit-hash image:latest

# Push to ECR (2 tags)
docker push 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-dev:abc123def456
docker push 497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-dev:latest
```

#### Step 6-7: Update ECS & Wait
```bash
# Tell ECS to update service with new image
aws ecs update-service \
  --cluster my-node-api-cluster-dev \
  --service frontend-service-dev \
  --force-new-deployment

# ECS automatically:
# 1. Pulls new image from ECR
# 2. Stops old container
# 3. Starts new container
# 4. Assigns new public IP (this changes! ⚠️)

# Pipeline waits up to 3 minutes for stability
for i in {1..20}; do
  Check: running_count == desired_count?
  If yes → ✅ Done!
  If no → sleep 10 seconds, retry
done
```

---

### JOB 4: Summary
```yaml
summary:
  Purpose: Print final status
  Runs: Always (even if deployment fails)
  Output: Build status and instructions
```

---

## 🎨 What Gets Built

### Vite Build Configuration
```bash
npm run build
# Creates: dist/ folder with:
#  - index.html (main entry point)
#  - js/app-*.js (React code, minified)
#  - js/vendor-*.js (dependencies)
#  - css/*.css (Tailwind styles)
#  - All static assets
```

### Environment Variables Injected
```javascript
// In your React app, access via:
import.meta.env.VITE_ENVIRONMENT  // e.g., "development"
import.meta.env.VITE_BACKEND_URL  // e.g., "http://3.24.242.50:3000"
```

---

## 📊 Current Configuration

### AWS Resources Used

| Resource | Type | Value |
|----------|------|-------|
| AWS Region | | ap-southeast-2 (Sydney) |
| AWS Account | | 497162053399 |
| ECR Repositories | | frontend-dev, frontend-staging, frontend-prod |
| ECS Clusters | | my-node-api-cluster-dev/staging/prod |
| Node Version | | 20 (LTS) |

### GitHub Secrets Required
```
AWS_ACCESS_KEY_ID          (stored in repo secrets)
AWS_SECRET_ACCESS_KEY      (stored in repo secrets)
```

---

## ⚠️ Known Issues & Limitations

### 1. **Backend URLs are Hardcoded** 
```yaml
Dev backend:     http://3.24.242.50:3000
Staging backend: http://3.25.70.32:3000
Prod backend:    http://16.176.7.157:3000
```

**Problem:** These IPs change when backend containers restart!

**Solution:** Use Elastic IPs (static addresses) for backend, or use domain names

---

### 2. **Frontend IP Changes on Deployment**
**Problem:** Public IP reassigned when container restarts
**Why:** Fargate doesn't support stable IPs without Elastic IP
**Solution:** Use Elastic IPs or domain names (DNS)

---

### 3. **No Rollback Mechanism**
**Current:** If new deployment fails, stuck with failed version
**Fix:** Add manual rollback steps or use Blue-Green deployment

---

## 🔄 Deployment Flow Example

### When you push to `develop`:

```
1. GitHub detects push to develop branch
2. GitHub Actions starts workflow
3. Job: Determine Environment
   → Sets: environment=development, cluster=my-node-api-cluster-dev, etc.
4. Job: Build and Test
   → Installs deps: npm install --legacy-peer-deps
   → Builds app: npm run build
   → Creates dist/ folder
5. Job: Deploy
   → Gets AWS credentials from secrets
   → Builds Docker image with VITE_ENVIRONMENT=development
   → Pushes to ECR as: frontend-dev:abc123def456
   → Tells ECS to update frontend-service-dev
   → ECS pulls new image and starts container
   → Pipeline waits for container to be ready
6. Job: Summary
   → Prints: "✅ Frontend deployment to development completed!"
   → App is now live at: http://3.104.64.134:3000 (or current IP)
```

---

## 📈 Performance

| Step | Time |
|------|------|
| Build & Test | ~2-3 minutes |
| Docker build & push | ~1-2 minutes |
| ECS update | ~30 seconds |
| Container startup | ~1-2 minutes |
| **Total** | **~5-8 minutes** |

---

## ✅ What Works Well

✅ Automatic deployment on push  
✅ Three separate environments (dev/staging/prod)  
✅ Environment variables properly injected  
✅ Build artifacts cached  
✅ Stability checks before finishing  
✅ Good error handling and messages  
✅ AWS credentials from secrets (secure)  

---

## ❌ What Could Be Improved

❌ Backend URLs hardcoded (should use domains)  
❌ No Elastic IPs for stable frontend IP  
❌ No rollback mechanism  
❌ No health checks post-deployment  
❌ No automatic testing (jest, etc.)  
❌ No database migrations step  
❌ No environment parity checks  

---

## 🚀 Common Tasks

### To force redeploy without code changes:
```bash
git commit --allow-empty -m "Force redeploy"
git push origin develop
```

### To check deployment status:
```bash
aws ecs describe-services \
  --cluster my-node-api-cluster-dev \
  --services frontend-service-dev \
  --region ap-southeast-2
```

### To view logs:
```bash
aws logs tail /ecs/frontend-development --follow --region ap-southeast-2
```

### To get current frontend IP:
```bash
aws ecs list-tasks --cluster my-node-api-cluster-dev \
  --service-name frontend-service-dev --region ap-southeast-2 \
  --query 'taskArns[0]' --output text | \
  xargs -I {} aws ecs describe-tasks --cluster my-node-api-cluster-dev \
  --tasks {} --region ap-southeast-2 \
  --query 'tasks[0].attachments[0].details[?name==`privateIPv4Address`].value' \
  --output text
```

---

## 📚 Files Referenced

- `.github/workflows/frontend-cicd.yml` - Main pipeline (this file)
- `Dockerfile` - Docker image definition
- `package.json` - Build scripts (npm run build)
- `vite.config.ts` - Vite configuration
- `.env` files - Local environment variables (not used in CI/CD)

---

## Summary

Your CI/CD pipeline is a **well-structured, multi-environment deployment system** that:

1. ✅ Automatically builds React app when you push
2. ✅ Runs on all 3 branches (main/staging/develop)
3. ✅ Deploys to separate ECS services per environment
4. ✅ Handles AWS credentials securely
5. ✅ Waits for deployment stability
6. ✅ Provides clear feedback

**Main areas for improvement:**
- Use Elastic IPs or domains instead of hardcoded IPs
- Add automated testing before deployment
- Add rollback mechanism
- Add health checks post-deployment
