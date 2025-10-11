# GitHub Actions CI/CD Setup

This repository uses GitHub Actions for automated testing and package deployment.

## Workflow Diagram

```
   Pull Request Created
        ↓
   PR Validation
        ↓
   Tests Pass → Merge PR
        ↓
   Push to main
        ↓
   Package Release
        ↓
   New Version
        ↓
   GitHub Release
```

---

## Local Development

```bash
# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a local-test

# Deploy
sf project deploy start --source-dir force-app

# Run tests
sf apex run test --test-level RunLocalTests --code-coverage
```
