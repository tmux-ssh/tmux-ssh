# tmux-ssh

[![Test](https://github.com/tmux-ssh/tmux-ssh/actions/workflows/test.yml/badge.svg)](https://github.com/tmux-ssh/tmux-ssh/actions/workflows/test.yml)

A command-line tool that spawns multiple synchronized SSH sessions inside a tmux session. Type once, execute everywhere.

## What Problem Does This Solve?

When managing multiple servers, you often need to run the same commands across several hosts simultaneously. Traditional approaches involve:

- Running commands one server at a time (slow and error-prone)
- Using configuration management tools (overkill for ad-hoc tasks)
- Using ClusterSSH (requires X11/GUI)

`tmux-ssh` provides a terminal-based solution that:

- Opens SSH connections to multiple hosts in synchronized tmux panes
- Mirrors your keystrokes to all panes simultaneously
- Works over pure SSH (no GUI required)
- Supports grouping hosts in a config file for quick access

## Requirements

- **tmux** 2.4 or later (tested with tmux 3.x)
- **bash** 4.0 or later
- **awk** (for config file parsing)
- **ssh** (or any SSH-compatible client)

### Check Your tmux Version

```bash
tmux -V
```

## Installation

### Manual Installation

1. Download the script:
   ```bash
   curl -o ~/.local/bin/tmux-ssh https://raw.githubusercontent.com/tmux-ssh/tmux-ssh/main/tmux-ssh
   ```

2. Make it executable:
   ```bash
   chmod +x ~/.local/bin/tmux-ssh
   ```

3. Ensure `~/.local/bin` is in your PATH:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

### From Source

```bash
git clone https://github.com/tmux-ssh/tmux-ssh.git
cd tmux-ssh
cp tmux-ssh ~/.local/bin/
chmod +x ~/.local/bin/tmux-ssh
```

## Usage

### Basic Usage

Connect to multiple hosts:

```bash
tmux-ssh host1.example.com host2.example.com host3.example.com
```

This opens a new tmux session with synchronized panes, one for each host.

### Command-Line Options

```
Usage: tmux-ssh [options] host [host ...]

Options:
  -h                  Show help
  -l                  List available groups from config file
  -d                  Detached mode - create session but don't attach
  -p <program>        Use a different program instead of ssh
  -c                  Use the current tmux session and spawn a new window
  -n <name>           Name of the tmux session or window (default: tmux-ssh)
  -o <ssh args>       Additional SSH arguments
```

### Examples

```bash
# Connect to multiple hosts
tmux-ssh web01 web02 web03

# Connect to a predefined group (see Configuration section)
tmux-ssh production-web

# Use a custom session name
tmux-ssh -n webservers web01 web02

# Add SSH options (e.g., specific user or key)
tmux-ssh -o "-l admin -i ~/.ssh/prod_key" host1 host2

# Create session without attaching (useful for scripting)
tmux-ssh -d -n background-task host1 host2

# Open in current tmux session as a new window
tmux-ssh -c host1 host2

# List configured groups
tmux-ssh -l

# Use a different program (e.g., mosh)
tmux-ssh -p mosh host1 host2
```

## Configuration File

Define groups of hosts in a configuration file for quick access. The script checks for config files in this order:

1. `~/.tmux-ssh.conf`
2. `~/.config/tmux-ssh/tmux-ssh.conf`

### Config File Format

The config file uses an INI-style format:

```ini
[group-name]
hostname1
hostname2
hostname3

[another-group]
server-a
server-b
```

### Example Configuration

```ini
# Production web servers
[production-web]
prod-web-01.example.com
prod-web-02.example.com
prod-web-03.example.com

# Production API servers
[production-api]
prod-api-01.example.com
prod-api-02.example.com

# Staging environment
[staging]
staging-web-01.example.com
staging-api-01.example.com

# Database servers (be careful!)
[production-db]
prod-db-primary.example.com
prod-db-replica-01.example.com
prod-db-replica-02.example.com
```

### Using Groups

```bash
# List all available groups
tmux-ssh -l

# Connect to all production web servers
tmux-ssh production-web

# Connect to staging with a custom session name
tmux-ssh -n staging-debug staging
```

## Working with Synchronized Panes

Once connected, all your keystrokes are mirrored to every pane. This is controlled by tmux's `synchronize-panes` option.

### Useful tmux Commands

| Action | Keys |
|--------|------|
| Toggle pane sync on/off | `Ctrl+b :` then `setw synchronize-panes` |
| Switch to specific pane | `Ctrl+b q` then pane number |
| Zoom into one pane | `Ctrl+b z` |
| Kill current pane | `Ctrl+b x` |
| Detach from session | `Ctrl+b d` |
| Reattach to session | `tmux attach -t tmux-ssh` |

### Recommended: Add a Keybinding for Toggling Sync

Add this to your `~/.tmux.conf` to toggle pane synchronization with `Ctrl+b =`:

```bash
bind-key = set-window-option synchronize-panes
```

Then reload your tmux config:

```bash
tmux source-file ~/.tmux.conf
```

Now you can quickly toggle sync on/off with `Ctrl+b =` instead of typing the full command.

## Testing

### Run the Test Suite

```bash
git clone https://github.com/tmux-ssh/tmux-ssh.git
cd tmux-ssh
./test.sh
```

The test suite includes 13 tests covering:

- Argument parsing and help output
- Config file parsing and group expansion
- tmux session and window creation
- Session name collision handling
- Multiple host pane creation
- Pane synchronization

### Run Shellcheck

```bash
shellcheck tmux-ssh
```

## Troubleshooting

### "No config file found"

Create a config file at `~/.tmux-ssh.conf` or `~/.config/tmux-ssh/tmux-ssh.conf`.

### Session name conflicts

If a session with the same name exists, tmux-ssh automatically appends a number (e.g., `tmux-ssh-1`, `tmux-ssh-2`).

### Panes are too small

With many hosts, panes may become too small. Consider:

- Using a larger terminal window
- Connecting to fewer hosts at once
- Using `Ctrl+b z` to zoom into individual panes

## Credits

This project is based on [tmux-cssh](https://github.com/peikk0/tmux-cssh) by Pierre Guinoiseau, licensed under the MIT License.

### Original tmux-cssh License

```
MIT License

Copyright (c) 2012-2019 Pierre Guinoiseau

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## License

MIT License - See [LICENSE](LICENSE) for details.
