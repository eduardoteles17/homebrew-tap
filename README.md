# eduardoteles17/homebrew-tap

Homebrew tap with formulae for packages that have been removed from homebrew-core, lack official distribution, or are my own projects.

## Installation

```bash
brew tap eduardoteles17/tap
```

## Available Formulae

| Formula | Version | Platforms | Description |
|---------|---------|-----------|-------------|
| `postgresql@9.6` | 9.6.24 | macOS (ARM), Linux (x64) | PostgreSQL 9.6, patched for modern toolchains |
| `postgresql@9.5` | 9.5.25 | macOS (ARM), Linux (x64) | PostgreSQL 9.5, patched for modern toolchains |
| `postgresql@9.4` | 9.4.26 | Linux (x64) | PostgreSQL 9.4, patched for modern toolchains |

### postgresql@9.6

```bash
brew install eduardoteles17/tap/postgresql@9.6
```

### postgresql@9.5

```bash
brew install eduardoteles17/tap/postgresql@9.5
```

### postgresql@9.4 (Linux only)

```bash
brew install eduardoteles17/tap/postgresql@9.4
```

All binaries include a version suffix for side-by-side installation:

```bash
psql-9.6 --version
psql-9.5 --version
psql-9.4 --version
```
