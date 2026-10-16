#!/usr/bin/env bash
#
# Install these dotfiles onto a macOS machine.
#
#   ./install.sh                  # install everything
#   ./install.sh tmux claude      # install only these
#   ./install.sh --dry-run        # print what would happen, touch nothing
#   ./install.sh --list           # show installable targets
#
# Copies files rather than symlinking, and NEVER appends: re-running is safe
# and converges to the same state. Anything about to be overwritten is first
# copied to ~/.dots-backup-<timestamp>/.

set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dots-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
DID_BACKUP=0

TOOLS=(brew zsh tmux vim git claude vscode atuin gh)

# ---------------------------------------------------------------- output

if [ -t 1 ]; then
  C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'
  C_BLUE=$'\033[1;34m';  C_OFF=$'\033[m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''; C_OFF=''
fi

step() { printf '%s==>%s %s\n' "$C_BLUE" "$C_OFF" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_OFF" "$*"; }
err()  { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; }

# ---------------------------------------------------------------- file ops

# Echo the command in dry-run mode, otherwise run it.
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  would: %s\n' "$*"
  else
    "$@"
  fi
}

# Preserve an existing file before we overwrite it. Keeps the path layout so
# the backup directory is self-explanatory a month later.
backup() {
  local dest=$1
  [ -e "$dest" ] || return 0

  local rel=${dest#"$HOME"/}
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  would: back up %s -> %s/%s\n' "$dest" "$BACKUP_DIR" "$rel"
    return 0
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  cp -R "$dest" "$BACKUP_DIR/$rel"
  DID_BACKUP=1
}

# backup + copy a single file, creating the destination directory.
install_file() {
  local src=$1 dest=$2

  if [ ! -e "$src" ]; then
    err "missing from repo: $src"
    return 1
  fi

  run mkdir -p "$(dirname "$dest")"
  backup "$dest"
  run cp "$src" "$dest"
  [ "$DRY_RUN" -eq 1 ] || ok "${dest/#$HOME/~}"
}

# ---------------------------------------------------------------- tools

install_zsh() {
  step "zsh"
  install_file "$DOTS/zsh/.zshrc" "$HOME/.zshrc"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    warn "oh-my-zsh is not installed; .zshrc will error until it is:"
    warn '  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    warn "  (decline its offer to replace .zshrc, or re-run: ./install.sh zsh)"
  fi

  if [ ! -e "$HOME/.zshrc.local" ]; then
    warn "no ~/.zshrc.local -- machine-specific functions go there (untracked)"
  fi
}

install_tmux() {
  step "tmux"
  install_file "$DOTS/tmux/.tmux.conf" "$HOME/.tmux.conf"

  # .tmux.conf calls this by absolute path and is inert without it; see the
  # PORTING TO ANOTHER MACHINE section in that file.
  install_file "$DOTS/tmux/bin/tmux-pulse-border" "$HOME/.local/bin/tmux-pulse-border"
  run chmod +x "$HOME/.local/bin/tmux-pulse-border"

  if ! command -v tmux >/dev/null 2>&1; then
    warn "tmux not installed yet (brew bundle will handle it)"
  fi
}

install_vim() {
  step "vim"
  install_file "$DOTS/vim/.vimrc" "$HOME/.vimrc"

  local sub
  for sub in colors syntax ftdetect; do
    local f
    for f in "$DOTS/vim/$sub"/*; do
      [ -e "$f" ] || continue
      install_file "$f" "$HOME/.vim/$sub/$(basename "$f")"
    done
  done

  # vss / vso / vsls in .zshrc expect this to exist.
  run mkdir -p "$HOME/.vim/sessions"
}

install_git() {
  step "git"
  install_file "$DOTS/git/.gitconfig" "$HOME/.gitconfig"

  if [ ! -e "$HOME/.gitconfig.local" ]; then
    warn "no ~/.gitconfig.local -- set your identity there:"
    warn '  git config --file ~/.gitconfig.local user.name  "Your Name"'
    warn '  git config --file ~/.gitconfig.local user.email "you@example.com"'
  fi
}

install_claude() {
  step "claude"
  local dir="$HOME/.claude"
  local settings="$dir/settings.json"
  local ui="$DOTS/claude/settings.ui.json"

  if [ -L "$dir" ]; then
    warn "~/.claude is a symlink to $(readlink "$dir")"
    warn "writing through it will modify that repo, not just this machine"
  fi

  local f
  for f in "$DOTS"/claude/themes/*.json; do
    [ -e "$f" ] || continue
    install_file "$f" "$dir/themes/$(basename "$f")"
  done

  # Merge rather than overwrite: settings.json also holds auth and model
  # environment config that is deliberately not tracked here, and clobbering
  # it would break Claude Code on the target machine.
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found -- skipped settings merge"
    warn "  brew bundle installs it, then re-run: ./install.sh claude"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  would: merge %s into %s\n' "settings.ui.json" "${settings/#$HOME/~}"
    return 0
  fi

  run mkdir -p "$dir"
  backup "$settings"

  local tmp
  tmp=$(mktemp)
  if [ -s "$settings" ]; then
    jq -s '.[0] * .[1]' "$settings" "$ui" > "$tmp"
  else
    cp "$ui" "$tmp"
  fi
  mv "$tmp" "$settings"
  ok "${settings/#$HOME/~} (merged, existing keys preserved)"
}

install_vscode() {
  step "vscode"
  local dir="$HOME/Library/Application Support/Code/User"
  install_file "$DOTS/vscode/settings.json" "$dir/settings.json"

  local list="$DOTS/vscode/extensions.txt"
  [ -e "$list" ] || return 0

  if command -v code >/dev/null 2>&1; then
    local ext
    while read -r ext; do
      [ -n "$ext" ] || continue
      run code --install-extension "$ext" --force
    done < "$list"
  else
    # Printing beats silently doing nothing: there is no code CLI until you
    # run VS Code's "Shell Command: Install 'code' command in PATH".
    warn "no 'code' CLI on PATH -- install extensions manually:"
    local ext
    while read -r ext; do
      [ -n "$ext" ] || continue
      printf '      code --install-extension %s\n' "$ext"
    done < "$list"
  fi
}

install_atuin() {
  step "atuin"
  install_file "$DOTS/atuin/config.toml" "$HOME/.config/atuin/config.toml"

  if ! command -v atuin >/dev/null 2>&1 && [ ! -x "$HOME/.atuin/bin/atuin" ]; then
    warn "atuin is not installed; .zshrc sources it and will error until it is:"
    warn "  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
    warn "  then: atuin login   (to sync existing history)"
  fi
}

install_gh() {
  step "gh"
  install_file "$DOTS/gh/config.yml" "$HOME/.config/gh/config.yml"

  # Skipped on dry runs: `gh auth status` is not read-only, it writes a
  # device-id into ~/.local/state/gh.
  if [ "$DRY_RUN" -eq 0 ] && command -v gh >/dev/null 2>&1 \
     && ! gh auth status >/dev/null 2>&1; then
    warn "gh is not authenticated -- run: gh auth login"
  fi
}

install_brew() {
  step "homebrew packages"

  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew is not installed:"
    warn '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    warn "  then re-run: ./install.sh brew"
    return 0
  fi

  run brew bundle --file="$DOTS/Brewfile"
  [ "$DRY_RUN" -eq 1 ] || ok "Brewfile applied"
}

# Tools installed by their own scripts rather than brew. Reported, never
# auto-run: piping curl into sh is the caller's decision, not the script's.
check_prereqs() {
  local missing=()
  [ -d "$HOME/.oh-my-zsh" ] || missing+=("oh-my-zsh")
  { command -v atuin >/dev/null 2>&1 || [ -x "$HOME/.atuin/bin/atuin" ]; } || missing+=("atuin")
  [ -s "$HOME/.nvm/nvm.sh" ] || missing+=("nvm")
  command -v claude >/dev/null 2>&1 || missing+=("claude-code")

  [ ${#missing[@]} -eq 0 ] && return 0

  echo
  step "not installed (each has its own installer)"
  local m
  for m in "${missing[@]}"; do
    case $m in
      oh-my-zsh)   warn 'oh-my-zsh   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"' ;;
      atuin)       warn "atuin       curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh" ;;
      nvm)         warn "nvm         curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash" ;;
      claude-code) warn "claude-code npm install -g @anthropic-ai/claude-code" ;;
    esac
  done
}

# ---------------------------------------------------------------- main

usage() {
  cat <<'EOF'
Install these dotfiles onto a macOS machine.

  ./install.sh                  install everything
  ./install.sh tmux claude      install only these
  ./install.sh --dry-run, -n    print what would happen, touch nothing
  ./install.sh --list, -l       show installable targets
  ./install.sh --help, -h       this message

Copies files rather than symlinking, and never appends: re-running is safe
and converges to the same state. Anything about to be overwritten is first
copied to ~/.dots-backup-<timestamp>/.
EOF
}

main() {
  local requested=()

  while [ $# -gt 0 ]; do
    case $1 in
      --dry-run|-n) DRY_RUN=1 ;;
      --list|-l)    printf '%s\n' "${TOOLS[@]}"; return 0 ;;
      --help|-h)    usage; return 0 ;;
      -*)           err "unknown option: $1"; usage >&2; return 2 ;;
      *)
        if ! printf '%s\n' "${TOOLS[@]}" | grep -qx -- "$1"; then
          err "unknown target: $1 (see --list)"
          return 2
        fi
        requested+=("$1")
        ;;
    esac
    shift
  done

  [ ${#requested[@]} -eq 0 ] && requested=("${TOOLS[@]}")

  [ "$DRY_RUN" -eq 1 ] && step "dry run -- nothing will be modified"

  local t
  for t in "${requested[@]}"; do
    if ! declare -f "install_$t" >/dev/null; then
      warn "skipping $t (not implemented yet)"
      continue
    fi
    "install_$t"
  done

  check_prereqs

  echo
  if [ "$DRY_RUN" -eq 1 ]; then
    step "dry run complete"
  else
    step "done"
    [ "$DID_BACKUP" -eq 1 ] && ok "replaced files backed up to ${BACKUP_DIR/#$HOME/~}"
    ok "open a new shell, or: source ~/.zshrc"
  fi
}

main "$@"
