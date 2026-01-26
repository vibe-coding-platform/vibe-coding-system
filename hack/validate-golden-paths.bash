#!/bin/bash
# Golden Path validation for pre-commit hooks (Ch 23)
# Fast: ~2s vs run-all-checks.sh (~30s)

set -e

echo "🔍 Validating golden paths (pre-commit)..."

# 1. YAML syntax (pipeline + observability)
find golden-paths/ -name "*.yml" -o -name "*.yaml" | xargs yamllint -s || {
    echo "❌ YAML syntax invalid"
    exit 1
}

# 2. Maven compile (no tests - keep it fast)
if [ -f "golden-paths/service/pom.xml" ]; then
    cd golden-paths/service/
    mvn compile -q -DskipTests || {
        echo "❌ Service template won't compile"
        exit 1
    }
    cd ../..
fi

# 3. Check required golden path files exist
REQUIRED_FILES=(
    "golden-paths/service/pom.xml"
    "golden-paths/pipeline/.gitlab-ci.yml"
    "golden-paths/observability/application-observability.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing golden path file: $file"
        exit 1
    fi
done

echo "✅ Golden paths VALIDATED (pre-commit)"
exit 0
