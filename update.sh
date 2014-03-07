#/bin/sh -e

# return 0 if program version is equal or greater than minimum version
# based on http://fitnr.com/bash-comparing-version-strings.html
check_version()
{
    version=$1 minimum=$2
    # This uses --key instead of --version-sort, since OSX sort (and probably
    # older gnu versions) don't support --version-sort. This only checks the first
    # four version components (so the minimum version must not have more
    # than 3 components).
    winner=$( (echo "$version"; echo "$minimum") | sort --field-separator . --key 1,1nr --key 2,2nr --key 3,3nr --key 4,4nr | head -1)
    [ "$winner" = "$version" ] && return 0
    return 1
}

GIT_VERSION=$(git --version | sed 's/^[^.0-9]*//')
GIT_REQUIRED=1.8.4
if ! check_version "$GIT_VERSION" "$GIT_REQUIRED"; then
	echo "Git version too old. Found: $GIT_VERSION. Required: $GIT_REQUIRED"
	exit 1;
fi

echo "Updating..."

# Resync submodule urls in case .submodules changed (.git/config
# contains a copy of them)
git submodule --quiet sync

# Update all submodules, using the latest version from the remote
# repository (--remote). Instead of creating a detached HEAD
# (--checkout), rebase the remote changes into the local branch
# (--rebase). If you don't have any local changes, this will just do a
# fast-forward. Finally, if the submodule wasn't initialized yet, do
# that now (--init).
git submodule update --init --remote --rebase

echo "Done, current status is:"

git submodule status
