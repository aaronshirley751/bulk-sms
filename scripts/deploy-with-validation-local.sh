#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Ì∫Ä Starting Deployment Pipeline"
echo "================================"

# Set PMD path
PMD_CMD="$(pwd)/pmd-bin-7.0.0/bin/pmd"

# Step 1: PMD Analysis
echo -e "${YELLOW}Step 1: Running PMD Analysis${NC}"
"$PMD_CMD" check --dir force-app/main/default/classes \
    --rulesets config/pmd-ruleset.xml \
    --format text \
    --cache .pmd-cache \
    --fail-on-violation false

PMD_EXIT=$?
if [ $PMD_EXIT -ne 0 ]; then
    echo -e "${YELLOW}‚ö†Ô∏è  PMD found violations. Review above.${NC}"
else
    echo -e "${GREEN}‚úÖ PMD Analysis Passed${NC}"
fi

# Step 2: Check if Salesforce CLI is authenticated
echo -e "${YELLOW}Step 2: Checking Salesforce CLI Authentication${NC}"
sf org list --json > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}‚úÖ Salesforce CLI Available${NC}"
    
    # Check for sandbox org
    if sf org display --target-org MySandbox > /dev/null 2>&1; then
        echo -e "${GREEN}‚úÖ MySandbox org found${NC}"
        
        # Step 3: Validate Deployment
        echo -e "${YELLOW}Step 3: Validating Deployment${NC}"
        echo "Running: sf project deploy validate --source-dir force-app --target-org MySandbox --test-level RunLocalTests"
        sf project deploy validate \
            --source-dir force-app \
            --target-org MySandbox \
            --test-level RunLocalTests
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}‚úÖ Deployment Validation Passed${NC}"
        else
            echo -e "${RED}‚ùå Deployment validation failed${NC}"
        fi
    else
        echo -e "${YELLOW}‚ö†Ô∏è  MySandbox org not found. Skipping deployment validation.${NC}"
    fi
else
    echo -e "${YELLOW}‚ö†Ô∏è  Salesforce CLI not authenticated. Skipping deployment validation.${NC}"
fi

echo ""
echo -e "${GREEN}ÌæØ Pipeline analysis complete!${NC}"
echo -e "PMD Status: Found violations - review needed"
echo -e "Next steps: Fix PMD violations and test deployment"
