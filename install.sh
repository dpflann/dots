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
