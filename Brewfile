# Install with: brew bundle --file=Brewfile
#
# Top-level packages only (from `brew leaves`) -- Homebrew resolves the
# ~50 transitive dependencies itself.

# Shell / terminal
brew "tmux"
brew "tree"

# Git / GitHub
brew "gh"

# Runtime version management
brew "asdf"

# JSON / XML on the command line. jq ships with recent macOS at /usr/bin/jq,
# but install.sh needs it to merge Claude settings, so pin it here for
# machines that predate that.
brew "jq"
brew "xq"

# Local HTTPS certificates for development
brew "mkcert"

# PDF/document tooling (pdftotext et al)
brew "poppler"
brew "shared-mime-info"

cask "ghostty"
cask "1password-cli"
