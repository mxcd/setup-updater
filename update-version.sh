#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a version as argument${NC}"
    echo "Usage: $0 <version>"
    echo "Example: $0 v0.2.3"
    exit 1
fi

NEW_VERSION=$1

# Validate version format (should start with 'v')
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${YELLOW}Warning: Version should follow format vX.Y.Z (e.g., v0.2.3)${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}Updating default version to ${NEW_VERSION}${NC}"

# Update the default version in action.yml
sed -i.bak "s/default: 'v[0-9]*\.[0-9]*\.[0-9]*'/default: '${NEW_VERSION}'/" action.yml
rm -f action.yml.bak
echo -e "${GREEN}✓ Updated action.yml${NC}"

# Update all version references in README.md
sed -i.bak "s/default version (v[0-9]*\.[0-9]*\.[0-9]*)/default version (${NEW_VERSION})/g" README.md
sed -i.bak "s/version: 'v[0-9]*\.[0-9]*\.[0-9]*'/version: '${NEW_VERSION}'/g" README.md
sed -i.bak "s/| \`version\` | Version of mxcd\/updater to install | No | \`v[0-9]*\.[0-9]*\.[0-9]*\` |/| \`version\` | Version of mxcd\/updater to install | No | \`${NEW_VERSION}\` |/" README.md
rm -f README.md.bak
echo -e "${GREEN}✓ Updated README.md${NC}"

# Update version in .github/workflows/test.yml
sed -i.bak "s/version: \"v[0-9]*\.[0-9]*\.[0-9]*\"/version: \"${NEW_VERSION}\"/" .github/workflows/test.yml
rm -f .github/workflows/test.yml.bak
echo -e "${GREEN}✓ Updated .github/workflows/test.yml${NC}"

# Update version in src/index.js
sed -i.bak "s/const version = core.getInput('version') || 'v[0-9]*\.[0-9]*\.[0-9]*';/const version = core.getInput('version') || '${NEW_VERSION}';/" src/index.js
rm -f src/index.js.bak
echo -e "${GREEN}✓ Updated src/index.js${NC}"

# Rebuild the dist/index.js
echo -e "${YELLOW}Rebuilding dist/index.js...${NC}"
npm run build
echo -e "${GREEN}✓ Rebuilt dist/index.js${NC}"

# Commit all changes
git add action.yml README.md .github/workflows/test.yml src/index.js dist/index.js dist/index.js.map
git commit -m "Update default version to ${NEW_VERSION}"
echo -e "${GREEN}✓ Committed changes${NC}"

# Push to main
git push origin main
echo -e "${GREEN}✓ Pushed to main${NC}"

# Delete local v1 tag if it exists
if git tag -l | grep -q "^v1$"; then
    git tag -d v1
    echo -e "${GREEN}✓ Deleted local v1 tag${NC}"
else
    echo -e "${YELLOW}⚠ No local v1 tag found${NC}"
fi

# Delete remote v1 tag if it exists
if git ls-remote --tags origin | grep -q "refs/tags/v1$"; then
    git push origin :refs/tags/v1
    echo -e "${GREEN}✓ Deleted remote v1 tag${NC}"
else
    echo -e "${YELLOW}⚠ No remote v1 tag found${NC}"
fi

# Create new v1 tag
git tag v1
echo -e "${GREEN}✓ Created new v1 tag${NC}"

# Push the new v1 tag
git push origin v1
echo -e "${GREEN}✓ Pushed v1 tag${NC}"

echo -e "${GREEN}✅ Version update complete!${NC}"
echo -e "Default version is now: ${NEW_VERSION}"
echo -e "v1 tag has been updated and pushed"