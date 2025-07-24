#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/ooluwgb/nebctl"
INSTALL_DIR="$HOME/.nebctl"
BIN_DIR="$HOME/.local/bin"
NEBCTL_BIN="$BIN_DIR/nebctl"

print_step() {
    echo -e "\n$1"
}

find_any_python() {
    for py in python3 python python2; do
        if command -v "$py" >/dev/null 2>&1; then
            echo "$py"
            return
        fi
    done
    echo ""
}

get_python_version() {
    "$@" -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'
}

# Returns true if version $1 is greater than or equal to version $2 (e.g., "3.8" >= "3.7").
# It sorts both versions and checks if $2 is the smallest; if so, $1 >= $2.
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

detect_distro() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

install_python3_for_env() {
    DISTRO=$(detect_distro)
    print_step "Installing Python 3 for $DISTRO..."

    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update -y
            sudo apt-get install -y python3 python3-pip
            ;;
        amzn|centos|rhel)
            sudo yum install -y python3 python3-pip
            ;;
        fedora)
            sudo dnf install -y python3 python3-pip
            ;;
        macos)
            if command -v brew >/dev/null 2>&1; then
                brew install python
            else
                echo "Homebrew not found. Please install Python manually." >&2
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS. Please install Python 3 manually." >&2
            exit 1
            ;;
    esac
}

ensure_python_ready() {
    PY_CMD=$(find_any_python)

    if [[ -z "$PY_CMD" ]]; then
        echo "No Python found. Installing Python 3..."
        install_python3_for_env
        PY_CMD="python3"
    else
        PY_VER=$(get_python_version "$PY_CMD")
        if version_ge "$PY_VER" "3.8"; then
            echo "Using $PY_CMD (version $PY_VER)"
        else
            echo "Found $PY_CMD (version $PY_VER), but version 3.8+ is required."
            read -r -p "Do you want to install Python 3 now? [Y/n]: " choice
            if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
                install_python3_for_env
                PY_CMD="python3"
            else
                echo "Proceeding with older Python. Some features may not work correctly."
            fi
        fi
    fi

    echo "$PY_CMD"
}

clone_or_update_repo() {
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        print_step "Updating existing nebctl installation..."
        git -C "$INSTALL_DIR" pull
    else
        print_step "Cloning nebctl repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
}

create_symlink() {
    mkdir -p "$BIN_DIR"
    chmod +x "$INSTALL_DIR/nebctl"
    ln -sf "$INSTALL_DIR/nebctl" "$NEBCTL_BIN"
    if [[ "$(id -u)" -eq 0 ]]; then
        ln -sf "$NEBCTL_BIN" /usr/local/bin/nebctl
        echo "Also linked to /usr/local/bin/nebctl (as root)"
    elif command -v sudo >/dev/null 2>&1 && [[ -w /usr/local/bin ]]; then
        sudo ln -sf "$NEBCTL_BIN" /usr/local/bin/nebctl
        echo "Also linked to /usr/local/bin/nebctl"
    fi
        echo "Also linked to /usr/local/bin/nebctl"
    fi

    for rcfile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [[ -f "$rcfile" ]]; then
            if ! grep -Fq "$BIN_DIR" "$rcfile"; then
                echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$rcfile"
                echo "Added $BIN_DIR to PATH in $rcfile"
            else
                echo "$rcfile already contains $BIN_DIR in PATH"
            fi
        fi
    done
}

install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        echo "kubectl already installed"
        return
    fi

    DISTRO=$(detect_distro)
    echo "Installing kubectl for $DISTRO..."

    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update -y
            sudo apt-get install -y apt-transport-https ca-certificates curl
            curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
            echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
            sudo apt-get update -y
            sudo apt-get install -y kubectl
            ;;
        amzn)
            sudo yum install -y curl
            curl -LO "https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.3/2023-09-14/bin/linux/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/kubectl
            ;;
        fedora|centos|rhel)
            sudo dnf install -y kubectl || sudo yum install -y kubectl
            ;;
        macos)
            if command -v brew >/dev/null 2>&1; then
                brew install kubectl
            else
                echo "Homebrew not found. Please install kubectl manually."
            fi
            ;;
        *)
            echo "Unsupported OS. Please install kubectl manually."
            ;;
    esac
}

install_npc() {
    if command -v npc >/dev/null 2>&1; then
        echo "npc already installed"
    else
        echo "Installing npc..."
        curl -sSL https://artifactory.nebius.dev/artifactory/npc/install.sh | bash
    fi
}

check_prod_sa() {
    if [[ ! -f "$HOME/.config/nebctl/profiles/prod-sa.yaml" ]]; then
        read -r -p "prod-sa profile not found. Would you like to set it up? [Y/n]: " choice
        if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
            echo "Future feature coming soon"
        else
            echo "Continuing without prod-sa. You can pass --profile manually later."
        fi
install_requirements() {
    if [[ -f "$INSTALL_DIR/requirements.txt" ]]; then
        "$PY_CMD" -m pip install --user -r "$INSTALL_DIR/requirements.txt"
    fi
}
        python3 -m pip install --user -r "$INSTALL_DIR/requirements.txt"
    fi
}

main() {
    PY_CMD=$(ensure_python_ready)
    clone_or_update_repo
    create_symlink
    install_kubectl
    install_npc
    check_prod_sa
    install_requirements
    echo "nebctl installed successfully. Restart your terminal or run 'source ~/.bashrc', 'source ~/.zshrc', or 'source ~/.profile' depending on your shell."
}

main "$@"
