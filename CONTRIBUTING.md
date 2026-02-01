# Contributing to tmux-ssh

Thank you for your interest in contributing to tmux-ssh! This document provides guidelines and instructions for contributing.

## Ways to Contribute

There are many ways to contribute to this project:

- Report bugs or suggest features by opening an issue
- Help triage and clean up existing issues
- Improve documentation
- Submit pull requests with bug fixes or new features
- Review open pull requests
- Share the project with others

## Submitting an Issue

Issues are tracked on [GitHub Issues](https://github.com/tmux-ssh/tmux-ssh/issues).

### Before Submitting

1. Search existing issues to avoid duplicates
2. Check if the issue has already been fixed in the latest version

### Bug Reports

When reporting a bug, please include:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your environment:
  - Operating system and version
  - tmux version (`tmux -V`)
  - bash version (`bash --version`)
- Any relevant configuration (sanitized of sensitive data)
- Error messages or terminal output

### Feature Requests

When suggesting a feature:

- Describe the problem you're trying to solve
- Explain your proposed solution
- Consider alternatives you've thought about
- Note if you're willing to submit a pull request

## Helping Clean Up Issues

You can help maintain the issue tracker by:

- Reproducing bug reports and confirming they're valid
- Adding missing information to incomplete issues
- Suggesting labels for uncategorized issues
- Linking related issues together
- Closing issues that have been resolved or are no longer relevant

Issues that receive no response from the submitter may be closed after 30 days. If an issue was closed prematurely, feel free to comment and we'll consider reopening it.

## Submitting a Pull Request

### Before You Start

1. Check if there's an existing issue or pull request for your change
2. For major changes, open an issue first to discuss the approach

### Development Setup

1. Fork the repository on GitHub

2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/tmux-ssh.git
   cd tmux-ssh
   ```

3. Make the scripts executable:
   ```bash
   chmod +x tmux-ssh test.sh
   ```

4. Run the tests to ensure everything works:
   ```bash
   ./test.sh
   ```

### Making Changes

1. Create a topic branch from `master`:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. Make your changes

3. Run the tests and ensure they pass:
   ```bash
   ./test.sh
   ```

4. Run shellcheck to ensure code quality:
   ```bash
   shellcheck tmux-ssh
   ```

5. Commit your changes using semantic commit messages (see below)

6. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

7. Open a pull request against the `master` branch

### Semantic Commit Messages

We use semantic commit messages to maintain a clear and meaningful git history. Each commit message should follow this format:

```
<type>: <subject>

[optional body]
```

#### Commit Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes only |
| `style` | Code style changes (formatting, missing semicolons, etc.) |
| `refactor` | Code changes that neither fix a bug nor add a feature |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks (updating dependencies, etc.) |
| `ci` | Changes to CI configuration files and scripts |

#### Examples

```bash
feat: add support for SSH config file integration

fix: handle spaces in hostnames correctly

docs: update installation instructions for Alpine Linux

refactor: simplify config file parsing logic

test: add tests for session name collision handling

ci: add Rocky Linux 9 to test matrix
```

#### Guidelines

- Use the imperative mood ("add feature" not "added feature")
- Keep the subject line under 72 characters
- Do not end the subject line with a period
- Separate subject from body with a blank line
- Use the body to explain *what* and *why*, not *how*

### Pull Request Requirements

Before submitting your pull request:

- [ ] All tests pass (`./test.sh`)
- [ ] shellcheck passes with no errors (`shellcheck tmux-ssh`)
- [ ] Commits follow semantic commit message format
- [ ] Documentation is updated if needed
- [ ] The PR description clearly explains the changes

### After Submitting

- A maintainer will review your pull request
- You may be asked to make changes
- Once approved, your pull request will be merged

## Testing

The test suite uses bash and tmux to verify functionality.

### Running Tests

```bash
# Run the full test suite
./test.sh

# Run shellcheck
shellcheck tmux-ssh
```

### Writing Tests

If you're adding a new feature or fixing a bug, please add corresponding tests. Tests are located in `test.sh`. Look at existing tests for patterns to follow.

## Questions?

If you have questions about contributing, feel free to open an issue with the "question" label.

Thank you for contributing!
