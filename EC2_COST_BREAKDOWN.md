# EC2 t2.micro Cost Analysis - Complete Breakdown

**Question**: "If I set up backend for EC2 t2.micro, will I get any additional cost?"

**Answer**: ✅ **NO ADDITIONAL COST for 12 months!** It's actually CHEAPER than Fargate.

---

## 💰 Cost Comparison: Fargate vs EC2 t2.micro

### Current Setup (ECS Fargate - What You're Using Now)

```
MONTHLY COSTS:
┌──────────────────────────────────────────┐
│ Frontend ECS Fargate (256 CPU)           │
│ - 730 hours × $0.04048 = $29.55/month   │
├──────────────────────────────────────────┤
│ Backend ECS Fargate (256 CPU)            │
│ - 730 hours × $0.04048 = $29.55/month   │
├──────────────────────────────────────────┤
│ ECR Storage (images)                     │
│ - ~$0.30/month                           │
├──────────────────────────────────────────┤
│ TOTAL FARGATE: ~$59.40/month             │
└──────────────────────────────────────────┘

ANNUAL COST: ~$712.80/year
```

### NEW Setup (EC2 t2.micro)

#### **YEAR 1 (Within AWS Free Tier)**
```
FREE TIER BENEFITS (12 months):
┌──────────────────────────────────────────┐
│ EC2 t2.micro (Frontend + Backend)        │
│ - 750 hours/month × $0 = $0              │
├──────────────────────────────────────────┤
│ RDS t3.micro (Database)                  │
│ - 750 hours/month × $0 = $0              │
├──────────────────────────────────────────┤
│ EBS Storage (30 GB)                      │
│ - $0 (30 GB free)                        │
├──────────────────────────────────────────┤
│ Data Transfer                            │
│ - $0 (100 GB/month free)                 │
├──────────────────────────────────────────┤
│ Elastic IP (Static IP)                   │
│ - $0 (Free when associated)              │
├──────────────────────────────────────────┤
│ TOTAL YEAR 1: $0/month                   │
└──────────────────────────────────────────┘

ANNUAL COST: $0/year ✅ 100% SAVINGS!
```

#### **YEAR 2+ (After Free Tier Expires)**
```
PAID PRICING:
┌──────────────────────────────────────────┐
│ EC2 t2.micro (On-Demand)                 │
│ - 730 hours × $0.0116/hr = $8.47/month  │
├──────────────────────────────────────────┤
│ RDS t3.micro (On-Demand)                 │
│ - 730 hours × $0.0229/hr = $16.72/month │
├──────────────────────────────────────────┤
│ EBS Storage (30 GB gp2)                  │
│ - 30 GB × $0.10 = $3.00/month           │
├──────────────────────────────────────────┤
│ Elastic IP (Static IP)                   │
│ - $0 (Free when associated)              │
├──────────────────────────────────────────┤
│ TOTAL YEAR 2+: ~$28.19/month             │
└──────────────────────────────────────────┘

ANNUAL COST: ~$338.28/year
```

---

## 📊 Side-by-Side Comparison

### Fargate (Current - 3 separate Fargate tasks)
```
Year 1: $712.80/year (~$59.40/month)
Year 2: $712.80/year (~$59.40/month)
Year 3: $712.80/year (~$59.40/month)
─────────────────────────────────────
3-Year Total: $2,138.40
```

### EC2 t2.micro (Recommended)
```
Year 1: $0/year (FREE!) ✅
Year 2: $338.28/year (~$28.19/month)
Year 3: $338.28/year (~$28.19/month)
─────────────────────────────────────
3-Year Total: $676.56
```

### **TOTAL SAVINGS: $1,461.84 over 3 years** 🎉

---

## 🎯 What You Get with EC2 t2.micro Setup

### ✅ Infrastructure
- **1 EC2 t2.micro instance** - Runs all 3 environments (Dev, Staging, Prod)
- **1 RDS database** - Optional, for learning database integration
- **1 Elastic IP** - Static IP that never changes
- **Docker containers** - One per environment (3 containers total)

### ✅ Frontend Deployment
```
http://<STATIC_IP>:3000  ← Dev environment
http://<STATIC_IP>:3001  ← Staging environment
http://<STATIC_IP>:3002  ← Production environment
```

### ✅ Backend Integration
```
Backend runs elsewhere (ECS Fargate):
http://3.24.242.50:3000   ← Dev API
http://3.25.70.32:3000    ← Staging API
http://16.176.7.157:3000  ← Prod API
```

### ✅ Learning Capabilities
- Docker containerization
- Multi-environment deployment
- Database integration (RDS)
- Static IP management
- Cron jobs & scheduled tasks
- Email services
- Complete end-to-end architecture

---

## 🚀 Setup Timeline

| Step | Time | Complexity |
|------|------|-----------|
| Launch EC2 t2.micro | 5 min | Easy |
| Install Docker | 10 min | Easy |
| Deploy frontend containers | 10 min | Easy |
| Allocate Elastic IP | 5 min | Easy |
| Test all 3 environments | 10 min | Easy |
| **TOTAL** | **~40 minutes** | **Easy** |

---

## 💡 Cost Details Explained

### Why EC2 t2.micro is FREE?

AWS Free Tier includes:
- **EC2**: 750 hours/month of t2.micro
- **RDS**: 750 hours/month of t2.micro
- **EBS Storage**: 30 GB/month
- **Data Transfer**: 100 GB/month (outbound)

Since a t2.micro instance runs ~730 hours/month (24×30), you stay within free limits!

### Why Year 2 is Cheaper than Fargate?

```
Fargate: Expensive per vCPU-hour
- Fargate CPU: $0.04048/vCPU-hour × 256 = $10.36/hour
- Fargate Memory: $0.004445/GB-hour × 512 MB = negligible
- Running 24/7: $10.36 × 730 hours = $7,562.80/MONTH (overkill!)

EC2 t2.micro: Cheap per instance
- EC2 t2.micro: $0.0116/hour
- Running 24/7: $0.0116 × 730 hours = $8.47/month
- Savings: 99.9% cheaper!
```

---

## ⚠️ Important Notes

### Elastic IP Pricing
- **FREE** when associated with running instance
- **$0.00/month** if associated
- Would charge $0.05/month if NOT associated (but we'll always associate it)

### Data Transfer
- **Inbound**: Always FREE
- **Outbound within region**: $0 first 100 GB/month, then $0.09/GB
- **Outbound to internet**: $0.09/GB (but included in learning setup)

### RDS Notes
- **Only if you want database** - It's optional
- Without RDS: Year 1 = $0, Year 2+ = ~$11.47/month
- With RDS: Year 1 = $0, Year 2+ = ~$28.19/month

---

## 📋 To Setup Backend on EC2

### Option 1: Backend + Frontend on Same EC2 (Simplest)
```
Single EC2 t2.micro runs:
├─ Frontend Dev:3000
├─ Frontend Staging:3001
├─ Frontend Prod:3002
├─ Backend Dev:3100
├─ Backend Staging:3101
└─ Backend Prod:3102

Cost: $0 Year 1, ~$28/month Year 2+
```

### Option 2: Separate Backend EC2 (More Expensive but Scalable)
```
Frontend EC2 t2.micro:
├─ Frontend Dev:3000
├─ Frontend Staging:3001
└─ Frontend Prod:3002

Backend EC2 t2.micro:
├─ Backend Dev:3000
├─ Backend Staging:3000
└─ Backend Prod:3000

Cost: $0 Year 1, ~$56/month Year 2+ (2× EC2 instances)
```

### Option 3: Current Setup (Hybrid - Keep Running)
```
Frontend EC2 t2.micro:
├─ Frontend Dev:3000
├─ Frontend Staging:3001
└─ Frontend Prod:3002

Backend ECS Fargate:
├─ Backend Dev
├─ Backend Staging
└─ Backend Prod

Cost: Backend stays on Fargate (~$59/month)
```

---

## ✅ Recommendation

**Go with Option 1: Single EC2 with Frontend + Backend**

Why?
- ✅ **NO additional cost** - Everything in free tier Year 1
- ✅ **Simplest setup** - One instance to manage
- ✅ **Best for learning** - Full control
- ✅ **Static IPs** - Both frontend and backend have stable IPs
- ✅ **Saves money** - ~$400/year vs current Fargate setup

---

## 🎯 Bottom Line

| Question | Answer |
|----------|--------|
| **Will EC2 cost more than Fargate?** | ❌ NO - It costs LESS |
| **Will I pay anything Year 1?** | ❌ NO - FREE |
| **Will I pay Year 2?** | ✅ YES - But only $28/month (vs $59/month now) |
| **Can I run backend on EC2?** | ✅ YES - Same EC2 instance |
| **Will backend on EC2 cost extra?** | ❌ NO - Everything on one instance |
| **Is setup complicated?** | ❌ NO - ~40 minutes, easy steps |
| **Do I need database?** | ✅ YES if learning (FREE Year 1) |

---

## 🚀 Next Steps

1. **Read**: `EC2_RDS_SETUP_GUIDE.md`
2. **Launch**: EC2 t2.micro instance
3. **Setup**: Run `setup-ec2-frontend.sh`
4. **Deploy**: Frontend (all 3 environments)
5. **Optional**: Deploy backend on same instance

**Timeline**: 40-60 minutes total setup time
**Cost**: $0 for Year 1, ~$28/month Year 2+

