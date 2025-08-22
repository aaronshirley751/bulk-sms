#!/bin/bash

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