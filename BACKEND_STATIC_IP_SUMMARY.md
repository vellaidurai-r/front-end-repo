# Backend Static IP Status - Quick Summary

## ❌ Current Status: Backend Does NOT Have Static IPs

Your **backend** is currently running on **ECS Fargate** with **auto-assigned public IPs** that change on each deployment.

| Environment | Current IP | Type | Status |
|-------------|-----|------|--------|
| **Dev** | 3.24.242.50:3000 | Auto-assigned | ⚠️ Changes on restart |
| **Staging** | 3.25.70.32:3000 | Auto-assigned | ⚠️ Changes on restart |
| **Prod** | 16.176.7.157:3000 | Auto-assigned | ⚠️ Changes on restart |

**vs Frontend** (also auto-assigned, same limitation)

| Environment | Current IP | Type | Status |
|-------------|-----|------|--------|
| **Dev** | 15.134.140.22:3000 | Auto-assigned | ⚠️ Changes on restart |
| **Staging** | 3.107.175.131:3000 | Auto-assigned | ⚠️ Changes on restart |
| **Prod** | 13.239.32.112:3000 | Auto-assigned | ⚠️ Changes on restart |

## 🎯 Why Backend Needs Static IPs

1. **Frontend Configuration**: Frontend hardcodes backend URLs during build
   - If backend IP changes → frontend can't reach backend
   - Frontend rebuild required to pick up new backend IP

2. **Third-party Integrations**: External services that whitelist IPs

3. **DNS/API Gateway**: Unstable URLs

4. **Webhooks**: Services calling back to backend API

## ✅ Quick Fix: Setup Backend Static IPs (5 minutes)

### Option 1: Run Automated Setup Script (Recommended)
```bash
./setup-backend-static-ips.sh
```

This script will:
- ✅ Check available Elastic IPs (1 already allocated for staging)
- ✅ Allocate new IPs for Dev and Prod
- ✅ Associate IPs to backend ECS tasks
- ✅ Display final configuration

### Option 2: Manual Setup
See `BACKEND_IP_CONFIGURATION.md` for step-by-step instructions

## 📊 Available Elastic IPs for Backend

```
IP: 13.54.148.31
  - ID: eipalloc-07e7659182901bfd1
  - Status: Not associated
  - Recommended use: Dev or Prod

IP: 15.134.15.59
  - ID: eipalloc-046e8194209ce0af9
  - Status: Tagged "node-app-eip"
  - Recommended use: Staging (already allocated)
```

## 🚀 Next Steps After Setup

### 1. Update Frontend CI/CD Workflow
Update `.github/workflows/frontend-cicd.yml` to use static backend IPs:

**Current** (auto-assigned - breaks):
```yaml
backend-url: |
  dev: http://3.24.242.50:3000
  staging: http://3.25.70.32:3000
  prod: http://16.176.7.157:3000
```

**After setup** (static - stable):
```yaml
backend-url: |
  dev: http://15.134.15.59:3000        # Example static IP
  staging: http://13.54.148.31:3000    # Example static IP
  prod: http://X.X.X.X:3000            # New static IP (allocated)
```

### 2. Test Connectivity
- Deploy frontend with new backend URLs
- Verify frontend can reach backend
- Check CloudWatch logs for any connection errors

### 3. Update Documentation
- Document the static IPs in README
- Update deployment runbook
- Add to troubleshooting guide

## ⚡ Full Migration Path (Optional)

If you want **guaranteed static IPs + lower costs**:

```
Current Setup (Fargate):
  Frontend: ~$9.46/month
  Backend: ~$9.46/month
  Subtotal: ~$18.92/month

Recommended Setup (EC2 t2.micro):
  Frontend + Backend: FREE Year 1, $25/month Year 2+
  Savings: 100% Year 1, 68% Year 2+
```

See: `START_HERE.md` or `EC2_RDS_SETUP_GUIDE.md`

---

## 📝 Files Created

1. **BACKEND_IP_CONFIGURATION.md** - Detailed configuration guide
2. **setup-backend-static-ips.sh** - Automated setup script
3. **BACKEND_STATIC_IP_SUMMARY.md** - This quick reference

---

## ✅ Recommendation

1. **Immediate**: Run `./setup-backend-static-ips.sh` (5 min)
2. **Short-term**: Update frontend workflow with static IPs (5 min)
3. **Medium-term**: Test end-to-end connectivity (10 min)
4. **Long-term**: Consider EC2 migration for lower costs ($0 Year 1)

