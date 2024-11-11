#!/bin/bash

# Define branch name patterns
regular_branch_pattern='^DEV-[0-9]{3,}.*$'
hotfix_branch_pattern='^HF-.*$'
develop_branch_pattern='^develop$'
main_branch_pattern='^main$'

# Get the branch name from the argument or use the current branch name
branch_name=${1:-$(git rev-parse --abbrev-ref HEAD)}

# Debugging output
echo "Branch name to check: ${branch_name}"

# Check if the branch name matches any of the patterns
if [[ ! ${branch_name} =~ ${regular_branch_pattern} && ! ${branch_name} =~ ${hotfix_branch_pattern} && ! ${branch_name} =~ ${develop_branch_pattern} && ! ${branch_name} =~ ${main_branch_pattern} ]]; then
  echo "Branch name ${branch_name} does not match the required patterns."
  exit 1
fi

echo "Branch name ${branch_name} matches the required patterns."
