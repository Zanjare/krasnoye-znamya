#!/usr/bin/env bash
# One-command GitHub publish for Krasnoye Znamya.
#
# Usage:   ./publish.sh YOUR_GITHUB_USERNAME [repo-name]
# Example: ./publish.sh amir krasnoye-znamya
#
# What it does:
#   1. replaces the YOUR_GITHUB_USERNAME placeholder in package.json and README.md
#   2. creates a git repository and the first commit
#   3. creates the GitHub repository (if the GitHub CLI "gh" is installed and logged in)
#      or pushes to an empty repository that you created on github.com
#   4. pushes the tag v<version>, which makes GitHub build and attach the .vsix automatically
set -euo pipefail

USER_NAME="${1:-}"
REPO="${2:-krasnoye-znamya}"

if [ -z "$USER_NAME" ]; then
  echo "Usage: ./publish.sh YOUR_GITHUB_USERNAME [repo-name]"
  exit 1
fi
command -v git >/dev/null 2>&1 || { echo "git is not installed. Install it first: sudo apt install git"; exit 1; }

cd "$(dirname "$0")"
VERSION="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' package.json | head -1)"
REMOTE_URL="${REMOTE_URL:-https://github.com/$USER_NAME/$REPO.git}"

echo "==> Setting your GitHub username in package.json and README.md"
sed -i "s/YOUR_GITHUB_USERNAME/$USER_NAME/g" package.json README.md
if [ "$REPO" != "krasnoye-znamya" ]; then
  sed -i "s#github.com/$USER_NAME/krasnoye-znamya#github.com/$USER_NAME/$REPO#g" package.json README.md
fi

if [ ! -d .git ]; then
  echo "==> Creating the git repository"
  git init -q -b main 2>/dev/null || { git init -q; git checkout -q -b main; }
fi

if [ -z "$(git config user.name || true)" ] || [ -z "$(git config user.email || true)" ]; then
  echo "git does not know who you are yet. Run these two commands once, then run ./publish.sh again:"
  echo '  git config --global user.name "Your Name"'
  echo '  git config --global user.email "you@example.com"'
  exit 1
fi

git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "Release $VERSION: Krasnoye Znamya, 23 themes"
fi

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && [ "$REMOTE_URL" = "https://github.com/$USER_NAME/$REPO.git" ]; then
  echo "==> Creating the GitHub repository with gh and pushing"
  gh repo create "$USER_NAME/$REPO" --public --source=. --remote=origin --push \
    --description "23 hand-tuned VS Code themes inspired by poster art. No italics, bold marks structure."
else
  echo "==> Pushing to $REMOTE_URL"
  echo "    (the repository must already exist on GitHub and be empty)"
  git remote remove origin 2>/dev/null || true
  git remote add origin "$REMOTE_URL"
  git push -u origin main
fi

echo "==> Pushing tag v$VERSION (GitHub will build the .vsix and create the release)"
git tag -a "v$VERSION" -m "Krasnoye Znamya $VERSION" 2>/dev/null || echo "    tag v$VERSION already exists, skipping"
git push origin "v$VERSION"

echo
echo "Done."
echo "  Repository: https://github.com/$USER_NAME/$REPO"
echo "  Releases:   https://github.com/$USER_NAME/$REPO/releases  (the .vsix appears after about a minute)"
