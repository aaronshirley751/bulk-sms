# GitHub Repository Secrets Setup Guide

## Required Secrets for CI/CD Pipeline

### 1. SFDX_AUTH_URL (Required)
This is the most critical secret for Salesforce authentication.

**To obtain your SFDX_AUTH_URL:**
```bash
# Run this command in your terminal (already authenticated to MySandbox)
sf org display --target-org MySandbox --verbose --json
```

**Or use this simpler command:**
```bash
sf org display --target-org MySandbox --verbose | grep "Sfdx Auth Url"
```

### 2. Additional Recommended Secrets

#### SALESFORCE_USERNAME
- **Value**: Your Salesforce username (ashirl01@baker.edu.full)
- **Purpose**: For logging and debugging

#### SALESFORCE_INSTANCE_URL  
- **Value**: Your Salesforce instance URL
- **Purpose**: API connections and logging

#### PMD_VERSION (Optional)
- **Value**: `7.0.0`
- **Purpose**: Pin PMD version for consistency

## How to Add Secrets to GitHub Repository

### Step 1: Navigate to Repository Settings
1. Go to your GitHub repository
2. Click **Settings** tab
3. In the left sidebar, click **Secrets and variables**
4. Click **Actions**

### Step 2: Add Each Secret
1. Click **New repository secret**
2. Enter secret name (e.g., `SFDX_AUTH_URL`)
3. Paste the secret value
4. Click **Add secret**

### Step 3: Verify Secrets
Required secrets list:
- [ ] `SFDX_AUTH_URL` - Salesforce authentication URL
- [ ] `SALESFORCE_USERNAME` - Your Salesforce username  
- [ ] `SALESFORCE_INSTANCE_URL` - Your org's instance URL
- [ ] `PMD_VERSION` - PMD version (optional, defaults to 7.0.0)

## Security Best Practices

### ✅ Do This:
- Never commit secrets to code
- Use GitHub repository secrets for sensitive data
- Rotate secrets periodically
- Limit access to secrets to necessary team members

### ❌ Never Do This:
- Put secrets in code files
- Share secrets in chat/email
- Use production org credentials in CI/CD (use dedicated CI org)
- Log secret values in CI output

## Testing Secret Setup

After adding secrets, you can test them by:

1. **Trigger GitHub Actions workflow** (push to main branch)
2. **Check workflow logs** for authentication success
3. **Verify PMD analysis** runs without errors
4. **Confirm deployment validation** works

---

**Next Step**: Run the commands below to get your SFDX_AUTH_URL, then add it to GitHub secrets.
