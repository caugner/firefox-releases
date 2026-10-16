#!/bin/bash
set -e

# This script should be run from the folder containing the Firefox release tarballs.
# It creates a Git repository in the "releases" subfolder and processes all tarballs matching firefox-*.

# Without an argument, start after the newest major version tagged in the published releases repository.
RELEASES_REMOTE="${RELEASES_REMOTE:-https://github.com/caugner/firefox-releases.git}"

# BSD (macOS) and GNU (Linux) stat and date take different flags.
if [ "$(uname)" = "Darwin" ]; then
    stat_flags=(-f %m)
    format_epoch() { date -r "$1" +"%Y-%m-%dT%H:%M:%S%z"; }
else
    stat_flags=(-c %Y)
    format_epoch() { date -d "@$1" +"%Y-%m-%dT%H:%M:%S%z"; }
fi

MIN_VERSION="${1:-}"
if [ -z "$MIN_VERSION" ]; then
    latest=$(git ls-remote --tags "$RELEASES_REMOTE" | sed -n 's|.*refs/tags/v\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -n 1)
    [ -n "$latest" ] && MIN_VERSION=$(( ${latest%%.*} + 1 ))
fi

# Define the git variable to run commands in the releases subfolder.
GIT="git -C releases"

# Create the repository directory if it doesn't exist.
if [ ! -d releases ]; then
    mkdir releases
    $GIT init
    # Disable commit signing for this repository.
    $GIT config commit.gpgSign false
    $GIT commit --allow-empty -m "Initial commit"
fi

# Loop over all tarball files sorted in version order.
for archive in $(ls firefox-* | sort -V); do
    # Extract the version number from the archive filename.
    version=$(basename "$archive" | sed -E 's/^firefox-([0-9.]+)-source.*$/\1/')

    # Skip if version < MIN_VERSION
    if [ -n "$MIN_VERSION" ]; then
        if [ "$(printf '%s\n' "$MIN_VERSION" "$version" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
            echo "Skipping $archive (version $version < $MIN_VERSION)"
            continue
        fi
    fi

    echo "Processing $archive ..."

    # Remove all tracked files from the previous commit.
    $GIT rm -rf . > /dev/null 2>&1 || true
    $GIT clean -fdx > /dev/null 2>&1

    # Extract the archive into the releases folder.
    # The --strip-components=1 flag removes the top-level directory.
    tar xf "$archive" -C releases --strip-components=1

    # Stage all extracted files.
    $GIT add .


    # Use $GIT ls-files to list tracked files, filter out any paths that contain a slash 
    # (i.e. keep only files in the repository root), then prefix each with "releases/" for the correct path.
    latest_epoch=$(for f in $($GIT ls-files | grep -v '/'); do echo "releases/$f"; done | xargs stat "${stat_flags[@]}" | sort -n | tail -n 1)

    if [ -z "$latest_epoch" ]; then
        commit_date=$(date +"%Y-%m-%dT%H:%M:%S%z")
    else
        commit_date=$(format_epoch "$latest_epoch")
    fi

    # Commit with the commit date set to the latest file modification time among files in the repository root.
    GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" $GIT commit -m "Firefox $version"
    $GIT tag "v$version" HEAD
done

echo "All releases have been imported into the releases repository."
