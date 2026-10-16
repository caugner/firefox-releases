#!/bin/bash

# Prefer a multi-connection downloader, falling back to curl (single connection, but preinstalled everywhere)
if command -v aria2c >/dev/null 2>&1; then
  downloader="aria2c -x 16 -s 16 --quiet=true --file-allocation=none -o"
elif command -v axel >/dev/null 2>&1; then
  downloader="axel -n 16 -o"
else
  downloader="curl -fsSL --retry 3 -o"
fi

# Without an argument, start after the newest major version tagged in the published releases repository.
RELEASES_REMOTE="${RELEASES_REMOTE:-https://github.com/caugner/firefox-releases.git}"

MIN_VERSION="${1:-}"
MAX_VERSION="${2:-}"
if [ -z "$MIN_VERSION" ]; then
  latest=$(git ls-remote --tags "$RELEASES_REMOTE" | sed -n 's|.*refs/tags/v\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -n 1)
  [ -n "$latest" ] && MIN_VERSION=$(( ${latest%%.*} + 1 ))
fi

# Compare the download against the archive's SHA512SUMS entry for its release.
verify_checksum() {
  local file=$1 try_version=$2 name=$3
  local expected actual
  expected=$(curl -s --fail --retry 3 "https://archive.mozilla.org/pub/firefox/releases/${try_version}/SHA512SUMS" | awk -v f="source/${name}" '$2 == f { print $1 }')
  actual=$(shasum -a 512 "$file" | awk '{ print $1 }')
  if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
    echo "❌ SHA512 mismatch for $file"
    return 1
  fi
}

# Fetch and sort the list of Firefox versions naturally from MDN browser-compat-data, excluding beta, nightly, and planned
versions=$(curl -s https://raw.githubusercontent.com/mdn/browser-compat-data/refs/heads/main/browsers/firefox.json | \
  jq -r '.browsers.firefox.releases | to_entries[] | select(.value.status != "beta" and .value.status != "nightly" and .value.status != "planned") | .key' | sort -V)

# Download source code for each version
for version in $versions; do
  # Determine file extension based on major version
  version_major=$(echo $version | cut -d. -f1)
  if [ -n "$MIN_VERSION" ] && (( version_major < MIN_VERSION )); then
    continue
  fi
  if [ -n "$MAX_VERSION" ] && (( version_major > MAX_VERSION )); then
    continue
  fi
  if (( version_major >= 41 )); then
    ext="tar.xz"
  else
    ext="tar.bz2"
  fi

  output_file="firefox-${version}-source.${ext}"

  if [ -f "$output_file" ]; then
    echo "✅ $output_file already exists, skipping."
    continue
  fi

  echo "⬇️  Trying to download $output_file..."

  # Build list of version candidates to try
  version_candidates=()
  if [[ $version =~ ^[0-9]+$ ]]; then
    version_candidates+=("${version}.0" "${version}.0.1")
  else
    version_candidates+=("${version}" "${version}.1")
  fi

  success=false

  # Try downloading using different filename formats
  for try_version in "${version_candidates[@]}"; do
    for suffix in ".source" "-source"; do
      filename="firefox-${try_version}${suffix}.${ext}"
      url="https://archive.mozilla.org/pub/firefox/releases/${try_version}/source/${filename}"
      if $downloader "$output_file" "$url"; then
        if ! verify_checksum "$output_file" "$try_version" "$filename"; then
          rm -f "$output_file"
          exit 1
        fi
        echo "✅ Downloaded $output_file"
        success=true
        break 2
      else
        echo "❌ Failed: $url"
      fi
    done
  done

  if [ "$success" = false ]; then
    echo "❌ Failed to download for version $version"
    rm -f "$output_file"
  fi

done
