#!/bin/bash

# Ask which action to perform
echo "What do you want to do?"
select action in "Bump version" "Package" "Exit"; do
    case $action in
        "Bump version")
            ./.cmd/version.sh
            break;;
        "Package")
            ./.cmd/package.sh
            break;;
        "Exit")
            break;;
    esac
done
