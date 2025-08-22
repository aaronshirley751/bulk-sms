#!/bin/bash

echo "Ì¥ç Analyzing PMD violations..."

# Set PMD path
PMD_CMD="$(pwd)/pmd-bin-7.0.0/bin/pmd"

# Run PMD and capture results
"$PMD_CMD" check --dir force-app/main/default/classes \
    --rulesets config/pmd-ruleset.xml \
    --format csv \
    --no-cache > pmd-results.csv

echo "Ì≥ä Violation Summary:"
echo "------------------------"

# Count violations by priority
if [ -f pmd-results.csv ]; then
    awk -F',' 'NR>1 {print $5}' pmd-results.csv | sort | uniq -c
else
    echo "No PMD results file found"
fi

echo "------------------------"
echo ""
echo "Ì¥ß Auto-fixing common issues..."

# Fix debug statements without logging level (show what would change)
echo "Debug statements found:"
grep -n "System\.debug('" force-app/main/default/classes/*.cls | head -5

echo ""
echo "‚ö†Ô∏è  Manual review needed for SOQL security (WITH USER_MODE)"
grep -n "SELECT" force-app/main/default/classes/*.cls | grep -v "WITH USER_MODE" | head -10

echo ""
echo "‚úÖ Analysis complete. Review above results."
