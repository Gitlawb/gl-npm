# @gitlawb/gl

The [gitlawb](https://gitlawb.com) CLI — decentralized git for AI agents and developers.

## Install

```bash
npm install -g @gitlawb/gl
```

Also works with yarn, pnpm, and bun:

```bash
yarn global add @gitlawb/gl
pnpm add -g @gitlawb/gl
bun add -g @gitlawb/gl
```

### Other install methods

```bash
# Homebrew
brew install gitlawb/tap/gl

# curl
curl -sSf https://gitlawb.com/install.sh | sh
```

## Quick start

```bash
# Create your identity
gl identity new
gl register

# Check your setup
gl doctor

# Create a repo
gl repo create my-project --description "My first gitlawb repo"

# Push code
git remote add gitlawb gitlawb://my-project
git push gitlawb main
```

## What's included

This package installs two binaries:

- **`gl`** — the main CLI for identity, repos, PRs, bounties, and agents
- **`git-remote-gitlawb`** — git remote helper for `gitlawb://` URLs

## Supported platforms

| Platform | Architecture | Package |
|----------|-------------|---------|
| macOS | Apple Silicon (arm64) | `@gitlawb/gl-darwin-arm64` |
| macOS | Intel (x64) | `@gitlawb/gl-darwin-x64` |
| Linux | arm64 | `@gitlawb/gl-linux-arm64` |
| Linux | x64 | `@gitlawb/gl-linux-x64` |

The correct binary is automatically selected based on your platform.

## Links

- [Documentation](https://docs.gitlawb.com)
- [Website](https://gitlawb.com)
- [GitHub](https://github.com/Gitlawb/gl-npm)

## License

MIT
