# Enable GitHub Actions Guide

## Current Status
âœ… **GitHub Actions workflow already configured!**

Your repository already has the complete CI/CD workflow at:
- `.github/workflows/salesforce-ci.yml`

## How to Enable GitHub Actions

### Option 1: Automatic Activation (Recommended)
GitHub Actions will automatically activate when you:

1. **Push code to GitHub** (any branch)
2. **Create a Pull Request**
3. **Merge to main branch**

### Option 2: Manual Trigger
You can also manually trigger the workflow:

1. Go to your GitHub repository
2. Click the **Actions** tab
3. Select **Salesforce CI/CD Pipeline** workflow
4. Click **Run workflow** button
5. Choose the branch and click **Run workflow**

## Workflow Triggers

Your CI/CD pipeline will automatically run on:

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Manual trigger
```

## What Happens When GitHub Actions Runs

### 1. Code Quality Check (PMD)
- Downloads and installs PMD 7.0.0
- Runs static analysis on all Apex classes
- Reports code quality violations
- Fails pipeline if critical issues found

### 2. Deployment Validation  
- Authenticates to Salesforce using SFDX_AUTH_URL
- Validates metadata deployment
- Runs local tests
- Reports deployment status

### 3. Results & Notifications
- âœ… **Success**: Green checkmark, deployment ready
- âŒ **Failure**: Red X, blocks merge, shows errors
- í³Š **Reports**: Detailed logs and PMD results

## Repository Setup Requirements

### âœ… Already Completed:
- [x] Workflow file created
- [x] PMD configuration ready
- [x] Local scripts functional
- [x] Documentation complete

### í´² Still Needed:
- [ ] Add GitHub repository secrets (see GITHUB_SECRETS_SETUP.md)
- [ ] Push code to GitHub repository
- [ ] Verify first workflow run

## Testing GitHub Actions

After adding secrets, test the workflow:

1. **Make a small change** to any file
2. **Commit and push** to GitHub:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```
3. **Check Actions tab** in GitHub
4. **Review workflow logs** for any issues

## Workflow Permissions

Ensure your repository has proper permissions:
- **Actions**: Enabled (check Repository Settings > Actions)
- **Workflow permissions**: Read and write permissions
- **Branch protection**: Consider requiring status checks

## Troubleshooting

### Common Issues:
1. **Missing secrets**: Add SFDX_AUTH_URL to repository secrets
2. **Permission errors**: Check Salesforce user permissions
3. **PMD failures**: Address code quality violations first
4. **Timeout errors**: Large deployments may need timeout adjustments

### Getting Help:
- Check workflow logs in GitHub Actions tab
- Review PMD results for specific violations
- Verify Salesforce CLI authentication locally

---

**Ready to activate!** Add your secrets and push code to GitHub.
