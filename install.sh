#!/usr/bin/env bash

set -e

echo "🔥 Welcome to the Flamelex installer"
echo "This will set up Flamelex on your machine from scratch."
echo ""

# Determine platform and OS details
PLATFORM="$(uname)"
echo "Detected platform: $PLATFORM"

# Get Linux distribution if applicable
if [[ "$PLATFORM" == "Linux" ]]; then
  if command -v lsb_release &>/dev/null; then
    DISTRO=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    echo "Linux distribution: $DISTRO $VERSION"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO=$NAME
    VERSION=$VERSION_ID
    echo "Linux distribution: $DISTRO $VERSION"
  else
    echo "Warning: Could not detect Linux distribution"
    DISTRO="Unknown"
  fi
fi

echo ""

# ------------------------------
# 1. Check for git and install if missing
# ------------------------------
echo "📦 Checking for git..."
if ! command -v git &>/dev/null; then
  echo "Git not found. Installing git..."
  
  if [[ "$PLATFORM" == "Darwin" ]]; then
    # On macOS, git comes with Xcode Command Line Tools
    echo "Installing Xcode Command Line Tools (includes git)..."
    xcode-select --install || true
    echo "Please run this script again after Xcode Command Line Tools installation completes."
    exit 1
  elif [[ "$PLATFORM" == "Linux" ]]; then
    if [[ "$DISTRO" =~ "Ubuntu" ]] || [[ "$DISTRO" =~ "Debian" ]]; then
      sudo apt-get update
      sudo apt-get install -y git
    elif [[ "$DISTRO" =~ "Fedora" ]] || [[ "$DISTRO" =~ "Red Hat" ]] || [[ "$DISTRO" =~ "CentOS" ]]; then
      sudo dnf install -y git || sudo yum install -y git
    elif [[ "$DISTRO" =~ "Arch" ]]; then
      sudo pacman -S --noconfirm git
    else
      echo "Unsupported Linux distribution for automatic git installation."
      echo "Please install git manually and re-run this script."
      exit 1
    fi
  else
    echo "Unsupported platform for automatic git installation."
    echo "Please install git manually and re-run this script."
    exit 1
  fi
else
  echo "✅ Git found."
fi

# ------------------------------
# 2. Install Elixir via asdf if missing
# ------------------------------
echo "📦 Checking for Elixir..."
if ! command -v elixir &>/dev/null; then
  echo "Elixir not found. Installing asdf and Elixir..."

  # Install asdf
  if [ ! -d "$HOME/.asdf" ]; then
    echo "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  else
    echo "asdf already installed."
  fi

  # Determine shell RC file
  SHELL_RC=""
  if [[ "$SHELL" == */zsh ]] || [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
    COMPLETION_FILE="$HOME/.asdf/completions/asdf.bash"
  elif [[ "$SHELL" == */bash ]] || [[ -n "$BASH_VERSION" ]]; then
    SHELL_RC="$HOME/.bashrc"
    COMPLETION_FILE="$HOME/.asdf/completions/asdf.bash"
  else
    echo "Warning: Unknown shell. Defaulting to .bashrc"
    SHELL_RC="$HOME/.bashrc"
    COMPLETION_FILE="$HOME/.asdf/completions/asdf.bash"
  fi

  # Add asdf to shell if not already present
  if ! grep -q ".asdf/asdf.sh" "$SHELL_RC" 2>/dev/null; then
    echo "Adding asdf to $SHELL_RC..."
    echo -e '\n# asdf' >> "$SHELL_RC"
    echo '. "$HOME/.asdf/asdf.sh"' >> "$SHELL_RC"
    echo '. "$HOME/.asdf/completions/asdf.bash"' >> "$SHELL_RC"
  fi

  # Source asdf for current session
  . "$HOME/.asdf/asdf.sh"

  # Install build dependencies for Erlang
  echo "Installing build dependencies for Erlang/Elixir..."
  if [[ "$PLATFORM" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add Homebrew to PATH for current session
      if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi
    brew install autoconf openssl wxwidgets libxslt fop
  elif [[ "$PLATFORM" == "Linux" ]]; then
    if [[ "$DISTRO" =~ "Ubuntu" ]] || [[ "$DISTRO" =~ "Debian" ]]; then
      sudo apt-get update
      sudo apt-get install -y build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk
    elif [[ "$DISTRO" =~ "Fedora" ]] || [[ "$DISTRO" =~ "Red Hat" ]] || [[ "$DISTRO" =~ "CentOS" ]]; then
      sudo dnf install -y gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf wxGTK3-devel wxBase3 mesa-libGL-devel mesa-libGLU-devel libpng-devel libssh-devel unixODBC-devel libxslt java-11-openjdk-devel || sudo yum install -y gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf wxGTK3-devel wxBase3 mesa-libGL-devel mesa-libGLU-devel libpng-devel libssh-devel unixODBC-devel libxslt java-11-openjdk-devel
    elif [[ "$DISTRO" =~ "Arch" ]]; then
      sudo pacman -S --noconfirm base-devel ncurses openssl wxgtk3 libpng libssh unixodbc libxslt fop jdk11-openjdk
    fi
  fi

  # Add plugins & install Erlang/Elixir
  echo "Adding asdf plugins..."
  asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git || true
  asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git || true

  echo "Installing Erlang (this may take a while)..."
  asdf install erlang latest
  asdf global erlang latest

  echo "Installing Elixir..."
  asdf install elixir latest
  asdf global elixir latest

  echo "✅ Elixir installed successfully!"
else
  echo "✅ Elixir found."
fi

# ------------------------------
# 3. Install Scenic system dependencies
# ------------------------------
echo "📦 Installing Scenic system dependencies..."

if [[ "$PLATFORM" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  echo "Installing macOS dependencies via Homebrew..."
  brew update
  brew install glfw3 glew pkg-config

elif [[ "$PLATFORM" == "Linux" ]]; then
  if [[ "$DISTRO" =~ "Ubuntu" ]] || [[ "$DISTRO" =~ "Debian" ]]; then
    echo "Installing Ubuntu/Debian dependencies..."
    sudo apt-get update
    
    # Check Ubuntu version for correct GLEW package
    if [[ "$VERSION" =~ "16." ]]; then
      sudo apt-get install -y pkgconf libglfw3 libglfw3-dev libglew1.13 libglew-dev
    else
      # Ubuntu 18+ and Debian
      sudo apt-get install -y pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev
    fi
    
  elif [[ "$DISTRO" =~ "Fedora" ]] || [[ "$DISTRO" =~ "Red Hat" ]] || [[ "$DISTRO" =~ "CentOS" ]]; then
    echo "Installing Fedora/RHEL dependencies..."
    sudo dnf install -y glfw glfw-devel pkgconf glew glew-devel || sudo yum install -y glfw glfw-devel pkgconf glew glew-devel
    
  elif [[ "$DISTRO" =~ "Arch" ]]; then
    echo "Installing Arch Linux dependencies..."
    sudo pacman -S --noconfirm glfw-x11 glew
    
  else
    echo "⚠️  Unsupported Linux distribution: $DISTRO"
    echo "Please install the following packages manually:"
    echo "  - GLFW3 development libraries"
    echo "  - GLEW development libraries"
    echo "  - pkg-config"
    echo ""
    echo "Then re-run this script."
    exit 1
  fi

else
  echo "⚠️  Unsupported platform: $PLATFORM"
  echo "Scenic requires OpenGL libraries (GLFW3, GLEW) to be installed."
  echo "Please install them manually for your platform."
  echo ""
  echo "For Windows, consider using WSL (Windows Subsystem for Linux)."
  exit 1
fi

echo "✅ Scenic dependencies installed."

# ------------------------------
# 4. Install additional useful tools
# ------------------------------
echo "📦 Installing additional tools..."

if [[ "$PLATFORM" == "Darwin" ]]; then
  # Install ripgrep for better search
  brew install ripgrep || true
elif [[ "$PLATFORM" == "Linux" ]]; then
  if [[ "$DISTRO" =~ "Ubuntu" ]] || [[ "$DISTRO" =~ "Debian" ]]; then
    sudo apt-get install -y ripgrep || true
  elif [[ "$DISTRO" =~ "Fedora" ]] || [[ "$DISTRO" =~ "Red Hat" ]] || [[ "$DISTRO" =~ "CentOS" ]]; then
    sudo dnf install -y ripgrep || sudo yum install -y ripgrep || true
  elif [[ "$DISTRO" =~ "Arch" ]]; then
    sudo pacman -S --noconfirm ripgrep || true
  fi
fi

# ------------------------------
# 5. Build the project
# ------------------------------
echo ""
echo "🔨 Building Flamelex..."

# Ensure we're in the flamelex directory
if [[ ! -f "mix.exs" ]]; then
  echo "Error: Not in a Mix project directory. Please run this script from the flamelex directory."
  exit 1
fi

# Source the appropriate shell configuration to ensure Elixir is available
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  . "$HOME/.asdf/asdf.sh"
fi

# Check if mix is available
if ! command -v mix &>/dev/null; then
  echo "Error: mix command not found. Please ensure Elixir is properly installed."
  echo "You may need to:"
  echo "  1. Restart your terminal, or"
  echo "  2. Run: source ~/.zshrc (or ~/.bashrc)"
  echo "  3. Then re-run this script"
  exit 1
fi

echo "Fetching dependencies..."
mix deps.get

echo "Compiling dependencies only..."
mix deps.compile

echo "✅ Dependencies ready!"

echo "Compiling Flamelex..."
mix compile

# ------------------------------
# 6. Create flx launcher command
# ------------------------------
echo ""
echo "🚀 Setting up flx global command..."

# Make flx script executable (it should be in the current directory)
FLX_SCRIPT="$PWD/flx"
if [[ -f "$FLX_SCRIPT" ]]; then
  chmod +x "$FLX_SCRIPT"
  echo "Made flx script executable at $FLX_SCRIPT"
  
  # Add to PATH if not already there
  BIN_DIR="$PWD"
  
  # Determine shell RC file (reuse logic from earlier)
  SHELL_RC=""
  if [[ "$SHELL" == */zsh ]] || [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ "$SHELL" == */bash ]] || [[ -n "$BASH_VERSION" ]]; then
    SHELL_RC="$HOME/.bashrc"
  else
    echo "Warning: Unknown shell. Defaulting to .bashrc"
    SHELL_RC="$HOME/.bashrc"
  fi
  
  if ! grep -q "export PATH.*$BIN_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "Added $BIN_DIR to PATH in $SHELL_RC"
  else
    echo "PATH already configured for flx command"
  fi
else
  echo "Warning: flx script not found at $FLX_SCRIPT"
  echo "You may need to create it manually or run this script from the correct directory."
fi

# Source the shell configuration to make flx available immediately
if [[ -n "$SHELL_RC" ]] && [[ -f "$SHELL_RC" ]]; then
  echo "Sourcing $SHELL_RC to make flx command available immediately..."
  source "$SHELL_RC"
fi

# ------------------------------
# 7. Final message and instructions
# ------------------------------
# Installation complete
echo ""
echo "✨ Base materials transmuted successfully! ✨"
echo "🧪 The apparatus is prepared. The Great Work begins..."
sleep 0.5

# ── colour helpers ────────────────────────────────────────────────
GREEN='\033[1;32m'   # bright green
RESET='\033[0m'

# ── small centering helper (assumes 64-char interior width) ──────
WIDTH=64

center () {
  local s="$1"

  # Detect emojis / CJK / other double-width glyphs you care about
  local wide_extra=0
  [[ "$s" == *"🍾"* ]] && (( wide_extra+=1 ))   # each 🍾 counts as one extra column
  # Add more patterns if needed, e.g. 🜁🜂🜃🜄: [[ "$s" =~ [🜁🜂🜃🜄] ]] && (( wide_extra+=${#BASH_REMATCH[@]} ))

  local visual_len=$(( ${#s} + wide_extra ))
  local pad=$(( (WIDTH - visual_len) / 2 ))

  printf '║%*s%s%*s║\n' "$pad" "" "$s" "$(( WIDTH - visual_len - pad ))" ""
}

# ── Hermetic scroll ───────────────────────────────────────────────
echo "${GREEN}"
echo
echo "╔════════════════════════════════════════════════════════════════╗"
center "🜁   🜂   🜃   🜄   ☿"
center ""
center "Eval conjures apply, and apply folds back into eval—"
center "the primal pulse animating creation itself. In that"
center "recursive beat, code and cosmos mirror one another,"
center "as the ancients gifted us - *as above, so below*."
center ""
center "☿   🜄   🜃   🜂   🜁"
echo "╚════════════════════════════════════════════════════════════════╝"
echo "${RESET}"


# Terminal usage example
echo "╭──────────────────────────────────────╮"
echo "│ 🖥️  Terminal Usage                    │"
echo "├──────────────────────────────────────┤"
echo "│                                      │"
echo "│  \$ flx                               │"
echo "│  # Starts Flamelex                   │"
echo "│                                      │"
echo "╰──────────────────────────────────────╯"
echo ""

echo "🔥 Flamelex is ready to use. The Athanor awais your command 🌟"
echo "📖 Troubleshooting: https://hexdocs.pm/scenic/install_dependencies.html"
echo ""
echo ""