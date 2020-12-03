#!/usr/bin/env bash

# This script initializes a repository deployed from this template.

function update_package_json() {
  local -r package_name="$1"
  echo "Enter a short description for the repository (package.json):"
  read -r description
  sed -i "s/template-terraform-package/$package_name/" package.json
  sed -i "s/{{package_description}}/$description/" package.json
  npm install
}

function update_readme() {
  local -r package_name="$1"
  echo "Enter a long description for the repository (README.md):"
  read -r description
  sed -i "s/template-terraform-package/$package_name/" README.md
  sed -i "s/{{package_description}}/$description/" README.md
}

function main() {
  local -r repository_name=$(git remote -v | grep push | sed -e 's|.*/||' | sed -e 's/.git.*//')

  echo "Initializing repository from template..."
  echo

  update_package_json "$repository_name"
  update_readme "$repository_name"

  rm -rf .init-template.sh

  echo
  echo "Initialization complete. Committing to source control..."
  git add -A
  git commit -m "Initialize repository from template"
  git push -u origin master
}

main "$@"
