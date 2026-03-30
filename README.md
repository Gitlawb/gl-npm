# gl-npm

npm distribution for the [gitlawb](https://gitlawb.com) CLI.

## Packages

| Package | Description |
|---------|-------------|
| `@gitlawb/gl` | Main wrapper — auto-selects the correct binary |
| `@gitlawb/gl-darwin-arm64` | macOS Apple Silicon binary |
| `@gitlawb/gl-darwin-x64` | macOS Intel binary |
| `@gitlawb/gl-linux-arm64` | Linux ARM binary |
| `@gitlawb/gl-linux-x64` | Linux x64 binary |

## Publishing

After a gitlawb release is tagged and binaries are uploaded to GitHub:

```bash
./scripts/publish.sh 0.3.7
```

This downloads the release binaries, copies them into platform packages, and publishes all 5 packages to npm.

## How it works

1. User runs `npm install -g @gitlawb/gl`
2. npm resolves `optionalDependencies` — only installs the matching platform package (via `os`/`cpu` fields)
3. `postinstall` runs `install.js` which copies binaries from the platform package into `bin/`
4. `gl` and `git-remote-gitlawb` are now available in PATH

## Adding to CI

Add this step after the Homebrew dispatch in your release workflow:

```yaml
- name: Publish to npm
  env:
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
  run: |
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
    cd gl-npm
    ./scripts/publish.sh ${{ github.ref_name }}
```
