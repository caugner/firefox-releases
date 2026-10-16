# Firefox Releases

This repository keeps a searchable history of Firefox source snapshots for stable releases.

## Branches

- `main` contains this README and the scripts used to maintain the release history.
- `releases` is an orphan history with one commit per stable Firefox major release, beginning with Firefox 1.5. Each commit contains the source snapshot from the release tarball and has a `v<version>` tag. It does not contain this README or the scripts.

To search the snapshots without checking out `releases`, pass the branch name as a revision:

```sh
git grep 'pattern' releases
git log -S'pattern' releases
git blame releases -- path/to/file
```

## Scripts

Run these from a directory that holds the release tarballs. The tarballs are about 12 GB in total and are not stored in this repository.

- `scripts/download.sh [MIN_VERSION]` downloads missing tarballs from `archive.mozilla.org` and checks each one against the archive's `SHA512SUMS`. It takes the version list from MDN Browser Compat Data, skips versions below `MIN_VERSION`, and needs `jq`, `curl`, `shasum`, and `git`. It uses `aria2c` or `axel` for parallel downloads when they are installed. Without an argument, it starts after the newest version tagged on the published `releases` branch.
- `scripts/repo.sh [MIN_VERSION]` extracts each tarball into a `releases/` Git repository, with one commit and tag per version. Pass `MIN_VERSION` to skip older releases.

`repo.sh` uses BSD `stat` and `date` and runs on macOS as written.

## Adding a release

```sh
./scripts/download.sh
./scripts/repo.sh
```

Without an argument, `repo.sh` starts after the newest version tagged on the published `releases` branch. Pass a version to override this, for example `./scripts/repo.sh 143`. It writes into `releases/` and does not push. Review the commits and tags there before pushing them to the `releases` branch.
