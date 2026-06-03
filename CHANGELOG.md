# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `the_local` companion: registers anvil's `info` / `install` / `operate` locals
  (Claude Code subagents) when `the_local` is present in the host app.
- `Anvil::Reference` — single source of truth for anvil's user-facing API.
- Project metadata: real gemspec summary/description/homepage, a `LICENSE`, and
  this changelog — so anvil passes its own audit.

## [0.1.0]

### Added
- Initial audit CLI: checks a gem directory for a Ruby version constraint, a
  `LICENSE`, and a `CHANGELOG.md`, reporting `✓`/`✗` and exiting non-zero on
  failure.
