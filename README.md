# eduardoteles17/homebrew-tap

Homebrew tap with formulae for packages that have been removed from homebrew-core, lack official distribution, or are my own projects.

## Installation

```bash
brew tap eduardoteles17/tap
```

## Available Formulae

| Formula | Version | Platforms | Description |
|---------|---------|-----------|-------------|
| `ai` | 1.0.0 | macOS (ARM/x64), Linux (ARM/x64) | CLI tool for interacting with multiple AI providers |
| `postgresql@11` | 11.22 | macOS (ARM), Linux (x64) | PostgreSQL 11, patched for modern toolchains |
| `postgresql@10` | 10.23 | macOS (ARM), Linux (x64) | PostgreSQL 10, patched for modern toolchains |
| `postgresql@9.6` | 9.6.24 | macOS (ARM), Linux (x64) | PostgreSQL 9.6, patched for modern toolchains |
| `postgresql@9.5` | 9.5.25 | macOS (ARM), Linux (x64) | PostgreSQL 9.5, patched for modern toolchains |
| `postgresql@9.4` | 9.4.26 | Linux (x64) | PostgreSQL 9.4, patched for modern toolchains |

### ai

```bash
brew install eduardoteles17/tap/ai
```

Includes shell completions for bash, zsh, and fish.

### PostgreSQL

```bash
brew install eduardoteles17/tap/postgresql@11
brew install eduardoteles17/tap/postgresql@10
brew install eduardoteles17/tap/postgresql@9.6
brew install eduardoteles17/tap/postgresql@9.5
brew install eduardoteles17/tap/postgresql@9.4
```

All binaries include a version suffix for side-by-side installation:

```bash
psql-11 --version
psql-10 --version
psql-9.6 --version
psql-9.5 --version
psql-9.4 --version
```

The alias `postgresql@9` points to the latest 9.x release (9.6.24).
