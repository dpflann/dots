# dots

Personal macOS development configuration: shell, terminal multiplexer,
editor, and tooling.

## Install

```sh
git clone git@github.com:dpflann/dots.git
cd dots
./install.sh --dry-run    # see what it would do
./install.sh              # do it
```

Per-tool, if you only want some of it:

```sh
./install.sh tmux claude
./install.sh --list       # available targets
```

Files are **copied, never appended**, so re-running is safe and converges to
the same state. Anything replaced is first copied to
`~/.dots-backup-<timestamp>/`.

## What's here

| Target   | Installs to                              | Contents |
|----------|------------------------------------------|----------|
| `brew`   | —                                        | `brew bundle` over the [Brewfile](Brewfile): tmux, tree, gh, asdf, jq, xq, mkcert, poppler + ghostty, 1password-cli |
| `zsh`    | `~/.zshrc`                               | oh-my-zsh skeleton, atuin/nvm/asdf init, color helpers, aliases, vim-session and reload functions |
| `tmux`   | `~/.tmux.conf`, `~/.local/bin/`          | `C-a` prefix, truecolor, top status bar, heavy pane borders, and the animated-UI bindings + `tmux-pulse-border` script |
| `vim`    | `~/.vimrc`, `~/.vim/`                    | config plus `slatedpf` colorscheme and go syntax/ftdetect |
| `git`    | `~/.gitconfig`                           | aliases, `core.editor = vim` |
| `claude` | `~/.claude/`                             | UI settings (merged, see below) + 6 custom themes |
| `vscode` | `~/Library/Application Support/Code/User/` | settings + extension list |
| `atuin`  | `~/.config/atuin/config.toml`            | `enter_accept` |
| `gh`     | `~/.config/gh/config.yml`                | https protocol, `co` alias |

### Claude settings are merged, not overwritten

`~/.claude/settings.json` mixes UI preferences with auth and model
environment config. Only the UI keys are tracked here
([`claude/settings.ui.json`](claude/settings.ui.json)); install `jq`-merges
them in, leaving everything else on the target machine untouched.

The `modelPicker` entries use `us.anthropic.*` inference profile IDs, which
assume Bedrock. On a direct-API machine, swap them for plain `claude-*` IDs.

### tmux needs its companion script

`.tmux.conf` calls `~/.local/bin/tmux-pulse-border` by absolute path and the
animated UI is inert without it — `install.sh tmux` places and `chmod +x`'s
it. The config's own `PORTING TO ANOTHER MACHINE` section has the details.
After installing, confirm the terminal does truecolor:

```sh
tmux display -p '#{client_termfeatures}'   # expect RGB in the list
```

## Machine-local overrides

Anything machine- or employer-specific stays out of this repo and goes in
`.local` files, which are gitignored:

| File                 | Sourced by          | For |
|----------------------|---------------------|-----|
| `~/.zshrc.local`     | `.zshrc` (last line)| work functions, account IDs, client helpers |
| `~/.gitconfig.local` | `.gitconfig` `[include]` | `user.name` / `user.email` |

Set your git identity after installing:

```sh
git config --file ~/.gitconfig.local user.name  "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

## Not tracked here

Secrets and machine state, deliberately: `~/.ssh`, `~/.aws`, shell and atuin
history (plus atuin's encryption key), `gh`'s `hosts.yml`, `~/.claude.json`
and Claude session/history files, and `~/.claude/{agents,skills,hooks}`.

## Installed separately

These have their own installers; `install.sh` reports which are missing and
prints the command, but never runs them:

```sh
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# atuin  (then `atuin login` to sync existing history)
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# claude code
npm install -g @anthropic-ai/claude-code
```

VS Code's `code` CLI is not on `PATH` by default — enable it with
<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> → *Shell Command: Install 'code'
command in PATH*, then re-run `./install.sh vscode` to install extensions.

`bash_profile/` predates the move to zsh. It is kept for reference and is not
installed by `install.sh`.
