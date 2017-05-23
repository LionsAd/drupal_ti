#!/bin/bash
# @file
# Functionalities for GIT usage.

# Ensures that the git settings are set.
function drupal_ti_ensure_git() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-git-settings-added" ]
	then
		return
	fi
  cd $HOME

  # Check if the e-mail address and the name are specified.
  : ${DRUPAL_TI_GITHUB_EMAIL?"Need to set DRUPAL_TI_GITHUB_EMAIL"}
  : ${DRUPAL_TI_GITHUB_NAME?"Need to set DRUPAL_TI_GITHUB_NAME"}

  git config --global user.email "${DRUPAL_TI_GITHUB_EMAIL}"
  git config --global user.name "${DRUPAL_TI_GITHUB_NAME}"
  git config --global push.default simple

  touch "$TRAVIS_BUILD_DIR/../drupal_ti-git-settings-added"
}

#
# Ensures that the reports branch exists.
#
function drupal_ci_git_ensure_reports_branch() {
  BRANCH=$1
  git fetch
  if [[ $(git ls-remote --heads https://github.com/$TRAVIS_REPO_SLUG.git $BRANCH | wc -l) == *"1"* ]]; then
    echo "$BRANCH exists, deleting the remote branch and re-creating."
    git push origin --delete $BRANCH
    git branch -D $BRANCH
  fi
    git checkout -b $BRANCH
}

#
# Adds the credentials to the current repository.
#
function drupal_ci_git_add_credentials() {
  # Check if the current directory has a git repository.
  if [ -d ".git" ]; then
    : ${DRUPAL_TI_GITHUB_TOKEN?"Need to set DRUPAL_TI_GITHUB_TOKEN"}
    git config credential.helper "store --file=.git/credentials"
    echo "https://${DRUPAL_TI_GITHUB_TOKEN}:x-oauth-basic@github.com" > .git/credentials
  else
    echo "Error in drupal_ci_git_add_credentials(): directory is not a git repository";
  fi
}
