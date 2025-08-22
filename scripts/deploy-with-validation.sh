#!/bin/bash

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