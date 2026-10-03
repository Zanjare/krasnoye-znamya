# Publishing to GitHub

1. Create an empty repository named `krasnoye-znamya` on github.com (no README, no license, no .gitignore).
2. Make sure git knows who you are (once per computer):

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

3. From the project folder run:

   ```bash
   ./publish.sh YOUR_GITHUB_USERNAME
   ```

The script fills in your username, commits everything, pushes to `main` and pushes the tag `v1.0.0`.
The release workflow then builds `krasnoye-znamya.vsix` and attaches it to a GitHub release.

If you use the GitHub CLI (`gh auth login`), step 1 is not needed: the script creates the repository for you.

## Releasing a new version

Edit `version` in `package.json`, add a section to `CHANGELOG.md`, commit, then:

```bash
git tag v1.0.1
git push origin main v1.0.1
```
