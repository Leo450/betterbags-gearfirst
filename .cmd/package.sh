#!/bin/bash

FILES="BetterBags_GearFirst.toc BetterBags_GearFirst_Vanilla.toc BetterBags_GearFirst_Wrath.toc i18n.lua main.lua LICENSE README.md"

# Read the version from the .toc file
VERSION=$(grep -oP '## Version: \K.*' BetterBags_GearFirst.toc)

# Add files to a folder in dist
mkdir -p "dist/BetterBags_GearFirst"

# Copy files to dist folder
cp $FILES "dist/BetterBags_GearFirst"

# Zip the folder
cd dist && zip -r "BetterBags_GearFirst_$VERSION.zip" "BetterBags_GearFirst" && cd ..

# Remove the folder
rm -r "dist/BetterBags_GearFirst"

# Echo the version
echo "Packaged version $VERSION"