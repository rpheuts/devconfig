#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to add a line to a file if it doesn't already exist
add_line_if_missing() {
    local line="$1"
    local file="$2"
    if [ -f "$file" ] && ! grep -qF -- "$line" "$file"; then
        echo "Adding '$line' to $file"
        echo "$line" >> "$file"
    elif [ ! -f "$file" ]; then
        echo "Warning: $file not found. Skipping adding line: $line"
    else
         echo "'$line' already found in $file. Skipping."
    fi
}

# --- Configuration ---

# Get the directory where the script is located, which should also contain nvim/ and ghostty/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_DIR="$HOME/.config"
NVIM_CONFIG_SRC="$SCRIPT_DIR/nvim"
GHOSTTY_CONFIG_SRC="$SCRIPT_DIR/ghostty"

# --- OS Detection ---

OS=""
DISTRO=""

if [[ "$(uname)" == "Darwin" ]]; then
    OS="macOS"
elif [[ "$(uname)" == "Linux" ]]; then
    OS="Linux"
    if [ -f /etc/os-release ]; then
        # Source the os-release file safely
        . /etc/os-release
        DISTRO=$ID # Common IDs: ubuntu, fedora, debian, centos, etc.
        if [[ -z "$DISTRO" ]]; then
             DISTRO=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        fi
        # Handle distributions similar to Fedora or Ubuntu/Debian
        if [[ "$DISTRO" == "fedora" ]]; then
            DISTRO="Fedora"
        elif [[ "$DISTRO" == "ubuntu" || "$ID_LIKE" == *"debian"* || "$ID_LIKE" == *"ubuntu"* ]]; then
             DISTRO="Ubuntu" # Treat Debian-based systems like Ubuntu for this script
        fi
    else
        echo "Warning: Cannot determine Linux distribution. /etc/os-release not found."
        # Attempt fallback or exit? For now, just warn.
    fi
else
    echo "Unsupported OS: $(uname)"
    exit 1
fi

echo "Detected OS: $OS ($DISTRO)"

# --- Package Installation ---

echo "--- Installing Packages ---"

if [[ "$OS" == "macOS" ]]; then
    echo "Using Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew not found. Please install it first."
        exit 1
    fi
    # Ensure cask-fonts tap is available
    brew tap homebrew/cask-fonts || echo "Warning: Failed to tap homebrew/cask-fonts. Font installation might fail."
    # Install packages
    brew install fzf ghostty starship neovim font-cousine-nerd-font || echo "Warning: Some packages might not have installed correctly."

elif [[ "$OS" == "Linux" ]]; then
    if [[ "$DISTRO" == "Fedora" ]]; then
        echo "Using DNF (Fedora)..."
        sudo dnf install -y fzf starship neovim curl util-linux-user # util-linux-user for chsh if needed later
        echo "Info: Ghostty might need manual installation on Fedora (e.g., AppImage or build from source)."
        echo "Info: Nerd Fonts might need manual installation (download .ttf/.otf to ~/.local/share/fonts/ and run fc-cache -fv)."
        # Attempt to install a common Nerd Font package if available (example name)
        sudo dnf install -y fira-code-nerd-fonts-fonts || echo "Warning: Could not install Fira Code Nerd Fonts via DNF. Manual installation recommended."


    elif [[ "$DISTRO" == "Ubuntu" ]]; then
        echo "Using APT (Ubuntu/Debian)..."
        sudo apt update
        # Add Neovim PPA for potentially newer versions
        echo "Adding Neovim PPA..."
        sudo apt install -y software-properties-common
        sudo add-apt-repository ppa:neovim-ppa/unstable -y
        sudo apt update
        # Install packages
        sudo apt install -y fzf neovim curl fonts-firacode # FiraCode is common, Cousine might not be packaged directly as Nerd Font
        # Install Starship using their script
        echo "Installing Starship via official script..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y

        echo "Info: Ghostty might need manual installation on Ubuntu (e.g., AppImage or build from source)."
        echo "Info: Cousine Nerd Font might need manual installation (download .ttf/.otf to ~/.local/share/fonts/ and run fc-cache -fv)."
        # You could try installing a package like fonts-hack-nerd if available, but Cousine specifically is less common.

    else
        echo "Unsupported Linux distribution: $DISTRO. Skipping package installation."
        echo "Please install manually: fzf, ghostty, starship, neovim, Cousine Nerd Font"
    fi
else
    echo "OS not recognized for package installation."
fi

echo "--- Package installation attempted. ---"

# --- Configuration File Copying ---

echo "--- Copying Configuration Files ---"

# Create ~/.config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"
echo "Ensured $CONFIG_DIR exists."

# Copy nvim config
if [ -d "$NVIM_CONFIG_SRC" ]; then
    echo "Copying nvim configuration from $NVIM_CONFIG_SRC to $CONFIG_DIR/nvim..."
    cp -r "$NVIM_CONFIG_SRC" "$CONFIG_DIR/"
else
    echo "Warning: Neovim config directory not found at $NVIM_CONFIG_SRC. Skipping copy."
fi

# Copy ghostty config
if [ -d "$GHOSTTY_CONFIG_SRC" ]; then
    echo "Copying ghostty configuration from $GHOSTTY_CONFIG_SRC to $CONFIG_DIR/ghostty..."
    cp -r "$GHOSTTY_CONFIG_SRC" "$CONFIG_DIR/"
else
    echo "Warning: Ghostty config directory not found at $GHOSTTY_CONFIG_SRC. Skipping copy."
fi

echo "--- Configuration files copied (if found). ---"


# --- Shell Configuration ---

echo "--- Configuring Shell (Bash/Zsh) ---"

BASHRC_FILE="$HOME/.bashrc"
ZSHRC_FILE="$HOME/.zshrc"

# Starship init
STARSHIP_BASH_INIT='eval "$(starship init bash)"'
STARSHIP_ZSH_INIT='eval "$(starship init zsh)"'

add_line_if_missing "$STARSHIP_BASH_INIT" "$BASHRC_FILE"
add_line_if_missing "$STARSHIP_ZSH_INIT" "$ZSHRC_FILE"

# Vi to Nvim alias
VI_ALIAS="alias vi=nvim"
add_line_if_missing "$VI_ALIAS" "$BASHRC_FILE"
add_line_if_missing "$VI_ALIAS" "$ZSHRC_FILE"

# macOS specific history alias
if [[ "$OS" == "macOS" ]]; then
    HISTORY_ALIAS="alias history='history 1'"
    add_line_if_missing "$HISTORY_ALIAS" "$BASHRC_FILE"
    add_line_if_missing "$HISTORY_ALIAS" "$ZSHRC_FILE"
    echo "Added macOS specific history alias."
fi

echo "--- Shell configuration updated. ---"

# --- Final Instructions ---

echo ""
echo "Setup script finished!"
echo "Please restart your shell or source your configuration file (e.g., 'source ~/.bashrc' or 'source ~/.zshrc') for changes to take effect."
if [[ "$OS" == "Linux" ]]; then
  echo "Remember: On Linux, Ghostty and specific Nerd Fonts (like Cousine) might require manual download and installation if they weren't available in the package repositories."
  echo "For fonts, download the .ttf or .otf files and place them in ~/.local/share/fonts/, then run 'fc-cache -fv'."
fi

exit 0
