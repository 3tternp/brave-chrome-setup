#!/bin/bash

# ============================================================
# Browser Installer for Kali Linux
# Installs / Repairs:
#   1. Google Chrome
#   2. Brave Browser
#   3. Both
#
# Tested for Debian-based systems such as Kali Linux.
# ============================================================

set -e

# ---------------- Colors ----------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"

# ---------------- Functions ----------------

print_banner() {
    echo -e "${BLUE}"
    echo "============================================================"
    echo "        Kali Linux Browser Installer"
    echo "        Google Chrome + Brave Browser"
    echo "============================================================"
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}[!] You are running as root. This is okay, but sudo is not required.${NC}"
    fi
}

check_architecture() {
    ARCH=$(dpkg --print-architecture)

    if [[ "$ARCH" != "amd64" ]]; then
        echo -e "${RED}[!] Unsupported architecture: $ARCH${NC}"
        echo -e "${YELLOW}[!] Google Chrome official .deb is mainly available for amd64 systems.${NC}"
        echo -e "${YELLOW}[!] For ARM systems, consider Chromium instead.${NC}"
        exit 1
    fi

    echo -e "${GREEN}[+] Architecture check passed: $ARCH${NC}"
}

update_system() {
    echo -e "${BLUE}[*] Updating package index...${NC}"
    sudo apt update
}

install_required_packages() {
    echo -e "${BLUE}[*] Installing required packages...${NC}"
    sudo apt install -y wget curl ca-certificates gnupg apt-transport-https
}

fix_broken_packages() {
    echo -e "${BLUE}[*] Checking and fixing broken dependencies...${NC}"
    sudo apt --fix-broken install -y
    sudo dpkg --configure -a
}

install_google_chrome() {
    echo -e "${BLUE}[*] Checking Google Chrome installation...${NC}"

    if command -v google-chrome >/dev/null 2>&1 || command -v google-chrome-stable >/dev/null 2>&1; then
        echo -e "${YELLOW}[!] Google Chrome is already installed.${NC}"
        google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null || true

        read -p "Do you want to reinstall/repair Google Chrome? [y/N]: " reinstall_chrome

        if [[ ! "$reinstall_chrome" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}[+] Skipping Google Chrome installation.${NC}"
            return
        fi
    fi

    echo -e "${BLUE}[*] Downloading Google Chrome stable .deb package...${NC}"

    cd /tmp
    rm -f google-chrome-stable_current_amd64.deb

    wget -q --show-progress https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

    echo -e "${BLUE}[*] Installing Google Chrome...${NC}"

    # apt install local .deb is preferred because it resolves dependencies better than dpkg alone.
    sudo apt install -y ./google-chrome-stable_current_amd64.deb

    fix_broken_packages

    echo -e "${GREEN}[+] Google Chrome installation completed.${NC}"
    google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null || true
}

install_brave_browser() {
    echo -e "${BLUE}[*] Checking Brave Browser installation...${NC}"

    if command -v brave-browser >/dev/null 2>&1; then
        echo -e "${YELLOW}[!] Brave Browser is already installed.${NC}"
        brave-browser --version 2>/dev/null || true

        read -p "Do you want to reinstall/repair Brave Browser? [y/N]: " reinstall_brave

        if [[ ! "$reinstall_brave" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}[+] Skipping Brave Browser installation.${NC}"
            return
        fi
    fi

    echo -e "${BLUE}[*] Adding Brave Browser official APT keyring...${NC}"

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    echo -e "${BLUE}[*] Adding Brave Browser official APT repository...${NC}"

    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

    echo -e "${BLUE}[*] Updating package index after adding Brave repository...${NC}"
    sudo apt update

    echo -e "${BLUE}[*] Installing Brave Browser...${NC}"
    sudo apt install -y brave-browser

    fix_broken_packages

    echo -e "${GREEN}[+] Brave Browser installation completed.${NC}"
    brave-browser --version 2>/dev/null || true
}

show_menu() {
    echo
    echo "Select an option:"
    echo "1) Install / Repair Google Chrome"
    echo "2) Install / Repair Brave Browser"
    echo "3) Install / Repair Both Google Chrome and Brave Browser"
    echo "4) Check Installed Browser Versions"
    echo "5) Exit"
    echo
}

check_versions() {
    echo -e "${BLUE}[*] Checking installed browser versions...${NC}"

    echo
    if command -v google-chrome >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Google Chrome:${NC}"
        google-chrome --version
    elif command -v google-chrome-stable >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Google Chrome Stable:${NC}"
        google-chrome-stable --version
    else
        echo -e "${RED}[-] Google Chrome is not installed.${NC}"
    fi

    echo
    if command -v brave-browser >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Brave Browser:${NC}"
        brave-browser --version
    else
        echo -e "${RED}[-] Brave Browser is not installed.${NC}"
    fi
}

main() {
    print_banner
    check_root
    check_architecture
    update_system
    install_required_packages
    fix_broken_packages

    while true; do
        show_menu
        read -p "Enter your choice [1-5]: " choice

        case "$choice" in
            1)
                install_google_chrome
                ;;
            2)
                install_brave_browser
                ;;
            3)
                install_google_chrome
                install_brave_browser
                ;;
            4)
                check_versions
                ;;
            5)
                echo -e "${GREEN}[+] Exiting installer. Done.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option. Please select 1 to 5.${NC}"
                ;;
        esac
    done
}

main
