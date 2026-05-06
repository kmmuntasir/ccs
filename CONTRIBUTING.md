# Contributing to CCS

Thanks for your interest in contributing! This guide covers how to submit bugs, suggest features, and open pull requests.

## Reporting Bugs

Open a [bug report](https://github.com/kmmuntasir/ccs/issues/new?template=bug_report.yml) and include:

- Steps to reproduce
- Expected vs actual behavior
- Your OS, shell, and CCS version (`ccs --version`)

## Suggesting Features

Open a [feature request](https://github.com/kmmuntasir/ccs/issues/new?template=feature_request.yml) and describe:

- The problem you're trying to solve
- Your proposed solution
- Any alternatives you've considered

## Development Setup

```bash
git clone https://github.com/kmmuntasir/ccs.git
cd ccs
```

Test changes locally by running the script directly:

```bash
./ccs.sh
```

Or copy it to your `~/.ccs/` for a full integration test:

```bash
cp ccs.sh ~/.ccs/ccs.sh
```

## Pull Request Process

1. **Fork** the repository and create a branch from `main`
2. **One change per PR** — keep it focused
3. **Test your changes** — run the affected commands and verify behavior
4. **Write clear commit messages** — describe what and why
5. **Open a pull request** — fill out the PR template

## Code Style

- Run [ShellCheck](https://www.shellcheck.net/) on your changes before submitting
- Follow the existing formatting conventions in the codebase
- Use descriptive variable names
- Keep functions focused and readable

## Adding a New Provider

To add a provider to the default template:

1. Edit `config.template.json`
2. Add a new entry in the `providers` object with all required fields:
   - `label`, `enabled` (set to `false`), `auth_token` (placeholder), `base_url`, `haiku_model`, `sonnet_model`, `opus_model`, `default_model`
3. Update the provider table in `README.md`
4. Submit a PR

## Questions?

Open an [issue](https://github.com/kmmuntasir/ccs/issues/new) and ask away.
