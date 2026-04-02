# eduardoteles17/homebrew-tap

Homebrew tap with formulae for packages that have been removed from homebrew-core, lack official distribution, or are my own projects.

## Installation

```bash
brew tap eduardoteles17/tap
```

## Available Formulae

| Formula | Version | Description |
|---------|---------|-------------|
| `postgresql@9.6` | 9.6.24 | PostgreSQL 9.6, patched for modern toolchains (GCC 15, libxml2 >= 2.13) |

### postgresql@9.6

```bash
brew install eduardoteles17/tap/postgresql@9.6
```

Pre-built bottles available for:

| Platform | Architecture |
|----------|-------------|
| macOS Tahoe (26) | Apple Silicon |
| macOS Sequoia (15) | Apple Silicon |
| macOS Sonoma (14) | Apple Silicon |
| Linux | x86_64 |

All binaries include a `-9.6` suffix for side-by-side installation with other PostgreSQL versions:

```bash
psql-9.6 --version
pg_dump-9.6 --version
```
