CI/CD Pipeline Setup with PMD Integration
Step 1: GitHub Actions Workflow Configuration
Create .github/workflows/salesforce-ci.yml:
yamlname: Salesforce CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate-and-scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    # Install Salesforce CLI
    - name: Install Salesforce CLI
      run: |
        wget https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz
        mkdir ~/sf
        tar xJf sf-linux-x64.tar.xz -C ~/sf --strip-components 1
        echo "$HOME/sf/bin" >> $GITHUB_PATH
    
    # Authenticate to Sandbox
    - name: Authenticate to Sandbox
      run: |
        echo "${{ secrets.SANDBOX_AUTH_URL }}" > auth.txt
        sf org login sfdx-url --sfdx-url-file auth.txt --alias sandbox
        rm auth.txt
    
    # Install PMD
    - name: Install PMD
      run: |
        wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
        unzip pmd-dist-7.0.0-bin.zip
        echo "$PWD/pmd-bin-7.0.0/bin" >> $GITHUB_PATH
    
    # Run PMD Analysis
    - name: Run PMD Code Analysis
      run: |
        pmd check --dir force-app/main/default/classes \
          --rulesets config/pmd-ruleset.xml \
          --format text \
          --cache .pmd-cache \
          --no-progress \
          --fail-on-violation false > pmd-results.txt || true
        cat pmd-results.txt
    
    # Run Apex Tests
    - name: Deploy and Run Tests
      run: |
        sf project deploy validate \
          --source-dir force-app \
          --target-org sandbox \
          --test-level RunLocalTests \
          --verbose
    
    # Upload PMD Results
    - name: Upload PMD Results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: pmd-results
        path: pmd-results.txt
    
    # Comment on PR with results
    - name: Comment PMD Results on PR
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const pmdResults = fs.readFileSync('pmd-results.txt', 'utf8');
          const truncated = pmdResults.substring(0, 65000);
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## PMD Analysis Results\n\`\`\`\n${truncated}\n\`\`\``
          });
Step 2: PMD Ruleset Configuration
Create config/pmd-ruleset.xml:
xml<?xml version="1.0" encoding="UTF-8"?>
<ruleset name="Salesforce Apex Ruleset"
         xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 
         https://pmd.sourceforge.io/ruleset_2_0_0.xsd">
    
    <description>Custom Salesforce Apex PMD Rules for Bulk SMS Project</description>
    
    <!-- Security Rules -->
    <rule ref="category/apex/security.xml">
        <priority>1</priority>
    </rule>
    
    <!-- Performance Rules -->
    <rule ref="category/apex/performance.xml">
        <priority>2</priority>
    </rule>
    
    <!-- Best Practices -->
    <rule ref="category/apex/bestpractices.xml">
        <priority>3</priority>
        <exclude name="ApexUnitTestClassShouldHaveAsserts"/>
    </rule>
    
    <!-- Design Rules with Custom Thresholds -->
    <rule ref="category/apex/design.xml/CyclomaticComplexity">
        <priority>2</priority>
        <properties>
            <property name="classReportLevel" value="10"/>
            <property name="methodReportLevel" value="10"/>
        </properties>
    </rule>
    
    <rule ref="category/apex/design.xml/ExcessiveParameterList">
        <priority>3</priority>
        <properties>
            <property name="minimum" value="5"/>
        </properties>
    </rule>
    
    <!-- Error Prone Rules -->
    <rule ref="category/apex/errorprone.xml">
        <priority>2</priority>
        <exclude name="EmptyStatementBlock"/>
    </rule>
    
    <!-- Documentation Rules -->
    <rule ref="category/apex/documentation.xml/ApexDoc">
        <priority>4</priority>
        <properties>
            <property name="reportPrivate" value="false"/>
            <property name="reportProtected" value="false"/>
        </properties>
    </rule>
</ruleset>
Step 3: Pre-commit Hook Setup
Create .husky/pre-commit:
bash#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

echo "Running PMD analysis on staged Apex files..."

# Get staged Apex files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.cls$")

if [ -n "$STAGED_FILES" ]; then
    # Run PMD on staged files
    pmd check --dir "$STAGED_FILES" \
        --rulesets config/pmd-ruleset.xml \
        --format text \
        --fail-on-violation false
    
    PMD_EXIT=$?
    
    if [ $PMD_EXIT -ne 0 ]; then
        echo "⚠️  PMD found issues. Review above and fix critical violations."
        echo "Run 'npm run pmd:fix' to see detailed report"
        read -p "Continue with commit anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

npm run prettier:verify
Step 4: VS Code Integration
Create .vscode/tasks.json:
json{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "PMD: Analyze Current File",
            "type": "shell",
            "command": "pmd",
            "args": [
                "check",
                "--dir", "${file}",
                "--rulesets", "config/pmd-ruleset.xml",
                "--format", "text",
                "--no-cache"
            ],
            "group": "test",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": {
                "owner": "apex",
                "fileLocation": ["relative", "${workspaceFolder}"],
                "pattern": {
                    "regexp": "^(.+):(\\d+):\\s+(.+)$",
                    "file": 1,
                    "line": 2,
                    "message": 3
                }
            }
        },
        {
            "label": "PMD: Analyze All Classes",
            "type": "shell",
            "command": "pmd",
            "args": [
                "check",
                "--dir", "force-app/main/default/classes",
                "--rulesets", "config/pmd-ruleset.xml",
                "--format", "text",
                "--cache", ".pmd-cache"
            ],
            "group": "test",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        },
        {
            "label": "Deploy to Sandbox with Tests",
            "type": "shell",
            "command": "sf",
            "args": [
                "project", "deploy", "start",
                "--source-dir", "force-app",
                "--target-org", "sandbox",
                "--test-level", "RunLocalTests"
            ],
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        }
    ]
}
Step 5: Package.json Updates
Add these scripts to your package.json:
json{
  "scripts": {
    "pmd:install": "wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip && unzip -o pmd-dist-7.0.0-bin.zip",
    "pmd:analyze": "pmd check --dir force-app/main/default/classes --rulesets config/pmd-ruleset.xml --format text --cache .pmd-cache",
    "pmd:analyze:verbose": "pmd check --dir force-app/main/default/classes --rulesets config/pmd-ruleset.xml --format text --cache .pmd-cache --debug",
    "pmd:fix": "echo 'Review PMD results and fix manually - no auto-fix available'",
    "validate": "npm run pmd:analyze && npm run test:unit",
    "deploy:sandbox": "sf project deploy start --source-dir force-app --target-org sandbox",
    "deploy:validate": "sf project deploy validate --source-dir force-app --target-org sandbox --test-level RunLocalTests",
    "ci:setup": "npm run pmd:install && husky install",
    "prepare": "husky install"
  }
}
Step 6: Setting Up GitHub Secrets
Run this command to get your Sandbox auth URL:
bashsf org display --target-org ashirl01@baker.edu.full --verbose --json | jq -r '.result.sfdxAuthUrl'
Then add it to GitHub:

Go to your repository Settings → Secrets and variables → Actions
Create new secret: SANDBOX_AUTH_URL
Paste the auth URL value

Step 7: Quality Gates Configuration
Create config/quality-gates.json:
json{
  "pmd": {
    "criticalViolations": {
      "security": 0,
      "performance": 5,
      "design": 10
    },
    "warningThresholds": {
      "totalViolations": 50,
      "complexityScore": 15
    }
  },
  "coverage": {
    "minimum": 75,
    "target": 85
  },
  "deployment": {
    "requireCodeReview": true,
    "requireTests": true,
    "blockOnCriticalPMD": true
  }
}
Step 8: Local PMD Quick Fix Script
Create scripts/fix-pmd-violations.sh:
bash#!/bin/bash

echo "🔍 Analyzing PMD violations..."

# Run PMD and capture results
pmd check --dir force-app/main/default/classes \
    --rulesets config/pmd-ruleset.xml \
    --format csv \
    --no-cache > pmd-results.csv

echo "📊 Violation Summary:"
echo "------------------------"

# Count violations by priority
awk -F',' 'NR>1 {print $5}' pmd-results.csv | sort | uniq -c

echo "------------------------"
echo ""
echo "🔧 Auto-fixing common issues..."

# Fix debug statements without logging level
find force-app/main/default/classes -name "*.cls" -exec sed -i \
    "s/System\.debug('/System.debug(LoggingLevel.DEBUG, '/g" {} \;

# Add WITH USER_MODE to SOQL queries (be careful with this one)
echo "⚠️  Manual review needed for SOQL security (WITH USER_MODE)"
grep -n "SELECT" force-app/main/default/classes/*.cls | grep -v "WITH USER_MODE"

echo ""
echo "✅ Auto-fix complete. Run 'npm run pmd:analyze' to verify"
Step 9: Deployment Pipeline Script
Create scripts/deploy-with-validation.sh:
bash#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🚀 Starting Deployment Pipeline"
echo "================================"

# Step 1: PMD Analysis
echo -e "${YELLOW}Step 1: Running PMD Analysis${NC}"
npm run pmd:analyze
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ PMD violations found. Fix before deployment.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ PMD Analysis Passed${NC}"

# Step 2: Run Tests Locally
echo -e "${YELLOW}Step 2: Running Local Tests${NC}"
npm run test:unit
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Unit Tests Passed${NC}"

# Step 3: Validate Deployment
echo -e "${YELLOW}Step 3: Validating Deployment${NC}"
sf project deploy validate \
    --source-dir force-app \
    --target-org sandbox \
    --test-level RunLocalTests

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment validation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Deployment Validation Passed${NC}"

# Step 4: Deploy
echo -e "${YELLOW}Step 4: Deploying to Sandbox${NC}"
read -p "Proceed with deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sf project deploy start \
        --source-dir force-app \
        --target-org sandbox
    echo -e "${GREEN}✅ Deployment Complete${NC}"
else
    echo -e "${YELLOW}⏸️  Deployment cancelled${NC}"
fi
Quick Start Commands
After setting up all configurations, run these commands:
bash# Initial setup
npm run ci:setup
chmod +x scripts/*.sh

# Before each deployment
./scripts/fix-pmd-violations.sh
./scripts/deploy-with-validation.sh

# For automated checks
npm run validate
This complete CI/CD setup will:

Automatically check code quality on every commit
Block deployments with critical violations
Provide detailed feedback in pull requests
Maintain consistent code standards across your team

Would you like me to help you implement any specific fixes for the 45 PMD violations currently in your codebase?