#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() { echo -e "${GREEN}[*]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[x]${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================
# INSTALL ZSH
# ============================================
install_zsh() {
    if command -v zsh &> /dev/null; then
        print_status "zsh is already installed"
    else
        print_status "Installing zsh..."
        sudo apt update && sudo apt install -y zsh
    fi
}

# ============================================
# INSTALL OH MY ZSH
# ============================================
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_status "Oh My Zsh is already installed"
    else
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# ============================================
# INSTALL POWERLEVEL10K THEME
# ============================================
install_powerlevel10k() {
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        print_status "Powerlevel10k is already installed"
    else
        print_status "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi
}

# ============================================
# INSTALL ZSH PLUGINS
# ============================================
install_zsh_plugins() {
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"

    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
        ["zsh-z"]="https://github.com/agkozak/zsh-z"
    )

    for plugin in "${!plugins[@]}"; do
        if [ -d "$plugins_dir/$plugin" ]; then
            print_status "$plugin is already installed"
        else
            print_status "Installing $plugin..."
            git clone --depth=1 "${plugins[$plugin]}" "$plugins_dir/$plugin"
        fi
    done
}

# ============================================
# INSTALL CLI TOOLS
# ============================================
install_cli_tools() {
    print_status "Updating apt package list..."
    sudo apt update

    # Tools available in standard repos
    local apt_tools=("fzf" "bat" "zoxide")

    for tool in "${apt_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_status "$tool is already installed"
        else
            print_status "Installing $tool..."
            sudo apt install -y "$tool"
        fi
    done

    # bat is installed as 'batcat' on Ubuntu/Debian
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        print_status "Creating bat symlink (Ubuntu installs it as batcat)..."
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    fi

    # git-delta
    if command -v delta &> /dev/null; then
        print_status "delta is already installed"
    else
        print_status "Installing git-delta..."
        sudo apt install -y git-delta || print_warning "git-delta not in apt, trying manual install..."
        if ! command -v delta &> /dev/null; then
            # Download latest release
            local delta_url=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep "browser_download_url.*amd64.deb" | head -1 | cut -d '"' -f 4)
            if [ -n "$delta_url" ]; then
                curl -Lo /tmp/delta.deb "$delta_url"
                sudo dpkg -i /tmp/delta.deb
                rm /tmp/delta.deb
            fi
        fi
    fi

    # eza (not in standard repos)
    if command -v eza &> /dev/null; then
        print_status "eza is already installed"
    else
        print_status "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update && sudo apt install -y eza
    fi
}

# ============================================
# CREATE SYMLINKS
# ============================================
create_symlinks() {
    print_status "Creating symlinks..."

    # Backup existing files if they're not symlinks
    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        print_warning "Backing up existing .zshrc to .zshrc.backup"
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
    fi

    # Remove existing symlinks
    [ -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
    [ -L "$HOME/.config/zsh" ] && rm "$HOME/.config/zsh"

    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Create symlinks
    ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -s "$DOTFILES_DIR/zsh" "$HOME/.config/zsh"

    print_status "Symlinks created:"
    echo "  ~/.zshrc -> $DOTFILES_DIR/.zshrc"
    echo "  ~/.config/zsh -> $DOTFILES_DIR/zsh"
}

# ============================================
# SET ZSH AS DEFAULT SHELL
# ============================================
set_default_shell() {
    if [ "$SHELL" = "$(which zsh)" ]; then
        print_status "zsh is already the default shell"
    else
        print_status "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
        print_warning "Please log out and back in for the shell change to take effect"
    fi
}

# ============================================
# MAIN
# ============================================
main() {
    echo ""
    echo "========================================"
    echo "   Dotfiles Installation Script"
    echo "========================================"
    echo ""

    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    install_cli_tools
    create_symlinks
    set_default_shell

    source ~/.zshrc
    p10k configure

    echo ""
    print_status "Installation complete!"
    echo ""
}

main "$@"
