#!/bin/bash

# Define branch name patterns
regular_branch_pattern='^DEV-[0-9]{3,}.*$'
hotfix_branch_pattern='^HF-.*$'
release_candidate_branch_pattern='^RC-*$'
develop_branch_pattern='^develop$'
main_branch_pattern='^main$'

# Get the branch name from the argument or use the current branch name
branch_name=${1:-$(git rev-parse --abbrev-ref HEAD)}

# Debugging output
echo "Branch name to check: ${branch_name}"

# Define an array of branch patterns
branch_patterns=(
  "${regular_branch_pattern}"
  "${hotfix_branch_pattern}"
  "${develop_branch_pattern}"
  "${main_branch_pattern}"
  "${release_candidate_branch_pattern}"
)

# Check if the branch name matches any of the patterns
match_found=false
for pattern in "${branch_patterns[@]}"; do
  if [[ ${branch_name} =~ ${pattern} ]]; then
    match_found=true
    break
  fi
done

if ! ${match_found}; then
  echo "Branch name ${branch_name} does not match the required patterns."
  exit 1
fi

echo "Branch name ${branch_name} matches the required patterns."
