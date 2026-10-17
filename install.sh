#!/usr/bin/env bash

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
    echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
    echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
    exit 1
}

warning() {
    echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
    echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
    echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

setup_packages() {
    title "Installing packages"

    packages="fish neovim vim tmux git curl fzf fd ripgrep starship wl-clipboard ttf-nerd-fonts-symbols-mono texlab"
    if command -v pacman >/dev/null; then
        sudo pacman -S --needed $packages
    else
        warning "Manual install needed: $packages"
    fi
}

setup_symlinks() {
    title "Creating symlinks"

    info "installing to ~/.config"
    if [ ! -d "$HOME/.config" ]; then
        info "Creating ~/.config"
        mkdir -p "$HOME/.config"
    fi

    config_files=$(find "$DOTFILES/config" -maxdepth 1 -mindepth 1 2>/dev/null)
    for config in $config_files; do
        target="$HOME/.config/$(basename "$config")"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists... Skipping."
        else
            info "Creating symlink for $config"
            ln -s "$config" "$target"
        fi
    done

    # vim shares the nvim config
    if [ -e "$HOME/.vimrc" ]; then
        info "~/.vimrc already exists... Skipping."
    else
        info "Creating symlink for ~/.vimrc"
        ln -s "$DOTFILES/config/nvim/init.vim" "$HOME/.vimrc"
    fi
}

setup_plugins() {
    title "Installing plugins"

    # fish_plugins is the plugin list; fisher installs the files
    if command -v fish >/dev/null; then
        info "fish plugins"
        fish -c '
            if not contains jorgebucaran/fisher $_fisher_plugins
                rm -f $__fish_config_dir/functions/fisher.fish $__fish_config_dir/completions/fisher.fish
                curl -fsSL --max-time 60 https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
            end
            if not type -q fisher
                echo "Could not download fisher, check your connection and rerun" >&2
                exit 1
            end
            fisher update'
    fi

    if command -v nvim >/dev/null; then
        info "nvim plugins"
        nvim --headless "+PlugInstall --sync" +qa
    fi

    if command -v vim >/dev/null; then
        info "vim plugins"
        vim -es -i NONE -u "$HOME/.vimrc" "+PlugInstall --sync" +qa
    fi
}

setup_gogh(){
    info "Setting color scheme using Gogh"
    git -C "$DOTFILES" submodule update --init gogh
    cd "$DOTFILES/gogh/installs"
    sh catppuccin-frappe.sh
    info "Remember to switch profile!"
}

case "$1" in
    packages)
        setup_packages
        ;;
	link)
		setup_symlinks
		;;
    plugins)
        setup_plugins
        ;;
    gogh)
        setup_gogh
        ;;
	all)
        setup_packages
		setup_symlinks
        setup_plugins
        setup_gogh
		;;
	*)
		echo -e "\nUsage: $(basename "$0") {packages|link|plugins|gogh|all}\n"
		exit 1
		;;
esac

echo -e
success "Done."
