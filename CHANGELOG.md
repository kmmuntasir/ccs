# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-05-07

### Added

- Interactive menu for switching Claude API providers
- Switch providers by key (`ccs glm`) or menu number (`ccs 2`)
- Toggle provider visibility with `ccs T`
- Add providers interactively with `ccs add`
- Modify providers with `ccs modify [key]`
- Remove providers with `ccs remove [key]`
- Block removal of currently active provider
- Show active provider with `ccs current`
- Help flag (`ccs -h`, `ccs --help`)
- 11 pre-configured providers in template
- Auto-install `jq` via brew, apt-get, yum, or pacman
- Cross-shell support (bash, zsh, fish)
- Quick install via `curl | bash`
- Uninstaller script
- Mask auth tokens in switch output
- GNU GPLv3 license
