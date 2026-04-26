# Backend Static IP Configuration Report

**Date**: April 26, 2026  
**Status**: ⚠️ **NEEDS STATIC IP SETUP** (Currently using auto-assigned IPs)

## 📊 Current Backend Status

### Environment Comparison: Frontend vs Backend

| Component | Dev | Staging | Prod | IP Type | Status |
|-----------|-----|---------|------|---------|--------|
| **Frontend** | 15.134.140.22:3000 | 3.107.175.131:3000 | 13.239.32.112:3000 | Auto-assigned | ✅ Running |
| **Backend** | 3.24.242.50:3000 | 3.25.70.32:3000 | 16.176.7.157:3000 | Auto-assigned | ✅ Running |
| **IP Type** | Temporary (changes on restart) | Temporary (changes on restart) | Temporary (changes on restart) | Fargate auto-assigned | ⚠️ Not static |
| **Elastic IP Allocated** | ❌ No | ✅ Yes (15.134.15.59) | ❌ No | - | Partial |

## 🔍 Backend Infrastructure Details

### Current Deployment Setup
- **Platform**: ECS Fargate (same as frontend)
- **Services**:
  - Dev: `node-app-service-dev` (1 task running)
  - Staging: `node-app-service-staging` (1 task running)
  - Prod: `node-app-service-prod` (1 task running)
  
### ECS Task Definitions
- Dev: `node-app-task-dev:X`
- Staging: `node-app-task-staging:7`
- Prod: `node-app-task-prod:X`

### Network Configuration (Current)
- **Launch Type**: Fargate
- **IP Assignment**: Auto-assigned public IPs
- **Issue**: Public IPs change when:
  - ❌ Task restarts
  - ❌ New deployment occurs
  - ❌ Service is updated
  - ❌ Container fails and recovers

## 🎯 Problem: Why Backend Needs Static IPs

### Current Issues
1. **IP Changes on Deployment**: Every time you push code, the backend gets a new IP
2. **Frontend Hard-coded URLs**: Frontend may have hard-coded backend URLs that break
3. **Third-party Services**: External APIs, webhooks, webhooks might whitelist IPs
4. **DNS Resolution**: Unstable if using DNS with short TTL

### Impact
```
Frontend Configuration (hardcoded in build):
  VITE_BACKEND_URL: http://3.25.70.32:3000

Backend Deployment → New Task Created
  Old IP: 3.25.70.32 (released)
  New IP: 3.25.70.50 (assigned)
  
Result: Frontend cannot reach backend! ❌
```

## ✅ Solution: Static IP Setup for Backend

### Option 1: Elastic IP Association (Recommended for Fargate)
**Cost**: FREE when associated with running instance/ENI
**Setup Time**: 5-10 minutes per environment

```bash
# Step 1: Create or use existing Elastic IP
aws ec2 allocate-address --domain vpc --region ap-southeast-2

# Step 2: Get the backend task's ENI
aws ecs list-tasks --cluster my-node-api-cluster-staging --region ap-southeast-2
aws ecs describe-tasks --cluster my-node-api-cluster-staging --tasks <TASK_ARN> --region ap-southeast-2

# Step 3: Associate Elastic IP to ENI
aws ec2 associate-address \
  --allocation-id eipalloc-XXXXXXXX \
  --network-interface-id eni-XXXXXXXX \
  --region ap-southeast-2
```

### Option 2: EC2 t2.micro with Static IP (Lower Cost)
**Cost**: FREE Year 1, $25/month Year 2+
**Benefit**: True static IP + more control
**See**: `START_HERE.md` or `EC2_RDS_SETUP_GUIDE.md`

## 📋 Currently Allocated Elastic IPs

```
Public IP: 13.54.148.31
  - Allocation ID: eipalloc-07e7659182901bfd1
  - Status: Not associated
  - Use Case: Available for use

Public IP: 15.134.15.59
  - Allocation ID: eipalloc-046e8194209ce0af9
  - Status: Tagged as "node-app-eip"
  - Associated: Not currently associated
  - Use Case: Backend staging (if needed)
```

## �� Recommended Actions

### Immediate: Verify Backend Can Handle IP Changes
1. Check if frontend hardcodes backend URLs (❌ This is a problem)
2. Verify environment variables are used instead
3. Frontend should load backend URL from environment at build time

### Short-term: Associate Elastic IP to Backend (Staging)
1. Get the backend staging task's network interface
2. Associate the `15.134.15.59` Elastic IP
3. Update frontend VITE_BACKEND_URL to use the static IP
4. Verify connectivity works

### Long-term: Implement Full Static IP Strategy
1. Allocate Elastic IPs for:
   - Backend Dev: Static IP
   - Backend Staging: 15.134.15.59 (already allocated)
   - Backend Prod: Static IP
2. Permanently associate these IPs
3. Update frontend configuration to use static backend URLs
4. Document in README

### Alternative: Migrate to EC2 t2.micro
- Both frontend AND backend on EC2 instances
- Get true static IPs for both
- Lower monthly cost ($0 Year 1, $25/month Year 2+)
- See documentation for complete setup

## 📝 Configuration Files to Update

### Frontend CI/CD Workflow (`.github/workflows/frontend-cicd.yml`)
Currently using:
```yaml
VITE_BACKEND_URL: http://3.25.70.32:3000
```

Should reference Elastic IP:
```yaml
VITE_BACKEND_URL: http://15.134.15.59:3000
```

### Environment Variables
- ✅ Frontend: Correctly using environment variables
- ⚠️ Backend: Should also expose environment information

## ✅ Next Steps

Choose one approach:

### ✓ Keep Fargate + Add Static IPs
1. Associate existing Elastic IPs to backend tasks
2. Update frontend environment URLs
3. Keep current ECS deployment (simple, familiar)

### ✓ Migrate to EC2 t2.micro (Recommended)
1. Launch EC2 instances for both frontend & backend
2. Assign Elastic IPs
3. Get true static addresses
4. Lower costs ($0 Year 1)
5. See `START_HERE.md` for full instructions

---

**Recommendation**: Implement **Elastic IP association** for backend immediately (5-10 min setup), then plan migration to EC2 if cost becomes a concern.

