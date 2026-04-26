# Frontend Static IP Setup - COMPLETE (Manual Association Needed)

**Date**: April 26, 2026

---

## ✅ STEP 1: Elastic IPs Allocated (DONE)

### Your New Static IPs

| Environment | IP Address | Allocation ID | Status |
|-------------|-----------|---------------|--------|
| **Frontend Dev** | `54.66.244.84` | eipalloc-0c310f3fe5cf6aa40 | ✅ Allocated |
| **Frontend Staging** | `54.252.205.222` | eipalloc-062b14baa8716f2ef | ✅ Allocated |
| **Frontend Prod** | `3.27.118.143` | eipalloc-0a4856c578692a0d1 | ✅ Allocated |

---

## ⏳ STEP 2: Manual Association Required

Due to IAM permission constraints with GitHub Actions, the association needs to be done manually via AWS Console.

### How to Associate (AWS Console - 5 minutes)

**For each environment, follow these steps:**

#### Frontend Dev
1. Go to **AWS EC2 Dashboard** → **Elastic IPs**
2. Find IP: `54.66.244.84`
3. Click **"Actions"** → **"Associate Elastic IP address"**
4. Select:
   - Resource type: **Network interface**
   - Network interface: **eni-0c8912e6670bc2de7**
   - Private IP address: **172.31.0.233**
5. Click **"Associate"**

#### Frontend Staging
1. Go to **AWS EC2 Dashboard** → **Elastic IPs**
2. Find IP: `54.252.205.222`
3. Click **"Actions"** → **"Associate Elastic IP address"**
4. Get the current staging task's network interface ID:
   ```bash
   aws ecs list-tasks --cluster my-node-api-cluster-staging --service-name frontend-service-staging --region ap-southeast-2 --query 'taskArns[0]' --output text
   # Then describe to get the ENI
   ```
5. Select that network interface
6. Click **"Associate"**

#### Frontend Prod
1. Go to **AWS EC2 Dashboard** → **Elastic IPs**
2. Find IP: `3.27.118.143`
3. Click **"Actions"** → **"Associate Elastic IP address"**
4. Get the current prod task's network interface ID:
   ```bash
   aws ecs list-tasks --cluster my-node-api-cluster-prod --service-name frontend-service-prod --region ap-southeast-2 --query 'taskArns[0]' --output text
   # Then describe to get the ENI
   ```
5. Select that network interface
6. Click **"Associate"**

---

## 📋 Commands to Get Network Interface IDs

Run these to find ENI IDs for staging and prod:

### Frontend Staging ENI
```bash
aws ecs list-tasks --cluster my-node-api-cluster-staging --service-name frontend-service-staging --region ap-southeast-2 --query 'taskArns[0]' --output text | head -1 > /tmp/staging-task.txt

aws ecs describe-tasks --cluster my-node-api-cluster-staging --tasks $(cat /tmp/staging-task.txt) --region ap-southeast-2 --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text
```

### Frontend Prod ENI
```bash
aws ecs list-tasks --cluster my-node-api-cluster-prod --service-name frontend-service-prod --region ap-southeast-2 --query 'taskArns[0]' --output text | head -1 > /tmp/prod-task.txt

aws ecs describe-tasks --cluster my-node-api-cluster-prod --tasks $(cat /tmp/prod-task.txt) --region ap-southeast-2 --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text
```

---

## 🎯 What You'll Have After Association

```
http://54.66.244.84:3000      ← Frontend Dev (NEVER changes!)
http://54.252.205.222:3000    ← Frontend Staging (NEVER changes!)
http://3.27.118.143:3000      ← Frontend Prod (NEVER changes!)
```

---

## 💰 Cost Status

✅ **All 3 IPs allocated and waiting for association**
✅ **Cost: $0/month** (will remain $0 when associated)
✅ **No charges yet** (and won't be charged until associated)

---

## ✅ Next Actions

### Option 1: Manual Association via Console (5 minutes)
- Go to AWS Console
- Associate each IP to its frontend
- IPs will work immediately

### Option 2: Wait for Permission Update
- Update GitHub Actions IAM role
- Run association script
- Fully automated

### Option 3: Use AWS CLI Locally
```bash
# If you have local AWS credentials with proper permissions:
aws ec2 associate-address --allocation-id eipalloc-0c310f3fe5cf6aa40 --network-interface-id eni-0c8912e6670bc2de7 --private-ip-address 172.31.0.233 --region ap-southeast-2
```

---

## 📝 Summary

| Status | Result |
|--------|--------|
| Elastic IPs Allocated | ✅ DONE |
| Cost | $0/month (FREE when associated) |
| Next Step | Associate via AWS Console |
| Time Needed | 5 minutes |
| Benefit | Static IPs forever! |

---

## 🚀 Recommendation

**I suggest doing manual association via AWS Console** - it's the fastest way to get your static IPs working immediately!

Would you like me to provide step-by-step screenshots instructions, or do you want to proceed with the console association?
