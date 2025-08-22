# Automated Development Workflow Guide

## Overview
Your CI/CD pipeline is now active and ready for daily development. This guide shows how to use the automated workflows effectively.

## Daily Development Workflow

### 1. Before You Start Coding
```bash
# Pull latest changes
git pull origin main

# Verify local environment
npm run pmd:analyze
npm run validate
```

### 2. During Development
```bash
# Regular code quality checks
npm run pmd:analyze          # Check code quality
npm run validate            # Validate deployment

# Quick fixes
npm run deploy:sandbox      # Deploy and test changes
```

### 3. Before Committing
```bash
# Final quality check
npm run pmd:analyze
npm run validate

# Commit with meaningful messages
git add .
git commit -m "feat: add new SMS template feature"
git push origin feature-branch
```

### 4. Pull Request Process
1. **Create PR** - GitHub Actions automatically runs
2. **Review PMD Results** - Check workflow logs
3. **Fix Issues** - Address any violations found
4. **Merge** - After approval and green checks

## Available Commands

### Code Quality
```bash
npm run pmd:analyze          # Run PMD static analysis
npm run pmd:fix             # Auto-fix simple violations (if configured)
```

### Deployment
```bash
npm run validate            # Validate deployment (no tests)
npm run deploy:sandbox      # Deploy to sandbox
npm run deploy:production   # Deploy to production (when ready)
```

### CI/CD Setup
```bash
npm run ci:setup           # Complete CI/CD configuration
npm run test:unit          # Run unit tests locally
npm run test:integration   # Run integration tests
```

## Automated Quality Gates

### GitHub Actions Triggers
- **Push to main/develop** → Full CI/CD pipeline
- **Pull Request** → Validation and PMD check
- **Manual trigger** → On-demand pipeline run

### Quality Checks
1. **PMD Analysis** (automatic)
   - Code complexity validation
   - Best practices enforcement
   - Performance issue detection

2. **Deployment Validation** (automatic)
   - Metadata structure check
   - Salesforce CLI validation
   - Test execution

3. **Branch Protection** (recommended)
   - Require PR reviews
   - Require status checks
   - Block direct pushes to main

## Monitoring & Reporting

### PMD Results
```bash
# View latest PMD report
cat pmd-results.csv

# Count violations by type
grep "CyclomaticComplexity" pmd-results.csv | wc -l
grep "AvoidDebugStatements" pmd-results.csv | wc -l
```

### Deployment Status
```bash
# Check last deployment
sf org display --target-org MySandbox

# View deployment history
sf project deploy report --target-org MySandbox
```

### GitHub Actions Logs
1. Go to repository **Actions** tab
2. Click on latest workflow run
3. Review **PMD Analysis** and **Deploy** steps
4. Download artifacts if needed

## Best Practices

### ✅ Do This
- Run PMD before every commit
- Fix violations as you code
- Use meaningful commit messages
- Test in sandbox before production
- Review PR feedback carefully

### ❌ Avoid This
- Ignoring PMD violations
- Skipping validation steps
- Large commits without testing
- Direct pushes to main branch
- Deploying without code review

## Troubleshooting Common Issues

### PMD Analysis Fails
```bash
# Check Java installation
java --version

# Verify PMD installation
./pmd-bin-7.0.0/bin/pmd --version

# Re-run with verbose output
./pmd-bin-7.0.0/bin/pmd check --dir force-app --rulesets config/pmd-ruleset.xml --format text --verbose
```

### Deployment Validation Fails
```bash
# Check Salesforce authentication
sf org display --target-org MySandbox

# Re-authenticate if needed
sf auth web login --alias MySandbox

# Test simple deployment
sf project deploy validate --source-dir force-app --target-org MySandbox
```

### GitHub Actions Fails
1. **Check secrets** - Verify SFDX_AUTH_URL is set
2. **Review logs** - Look for specific error messages
3. **Test locally** - Reproduce issue in local environment
4. **Update secrets** - Re-authenticate if tokens expired

## Continuous Improvement

### Weekly Reviews
- Check PMD trend reports
- Review deployment success rates
- Update quality rules as needed
- Team retrospectives on CI/CD effectiveness

### Monthly Maintenance  
- Update PMD rules
- Review and clean up debug statements
- Optimize complex methods
- Update documentation

---

## Quick Reference Card

### Emergency Commands
```bash
npm run pmd:analyze         # Quality check
npm run validate           # Deployment check
sf org display             # Auth status
git status                 # Code status
```

### Status Checks
- **GitHub Actions**: Repository → Actions tab
- **PMD Report**: `cat pmd-results.csv`
- **Deployment**: `sf org display --target-org MySandbox`
- **Code Quality**: Run `npm run pmd:analyze`

**Your CI/CD pipeline is ready! Start coding with confidence!** ���
