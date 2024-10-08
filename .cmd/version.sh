﻿#!/bin/bash

# Read the version from the .toc file
VERSION=$(grep -oP '## Version: \K.*' BetterBags_GearFirst.toc)

# Increment version last digit
VERSION=$(echo $VERSION | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')

# Ask for version with default
read -p "Enter version [$VERSION]: " NEW_VERSION
NEW_VERSION=${NEW_VERSION:-$VERSION}

# Update the .toc files version
sed -i "s/## Version: .*/## Version: $NEW_VERSION/" BetterBags_GearFirst.toc

# Update the .toc files date
sed -i "s/## X-Date: .*/## X-Date: $(date -u +'%Y-%m-%dT%H:%M:%S')/" BetterBags_GearFirst.toc