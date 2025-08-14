#!/bin/bash

# Azure SQL Managed Identity Setup Script for Neovim
# This script helps set up Azure authentication for use with nvim-dbee
# Compatible with Windows (Git Bash/WSL), macOS, and Linux

set -e

echo "🔐 Azure SQL Managed Identity Setup for Neovim"
echo "=============================================="

# Detect operating system
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -q Microsoft /proc/version 2>/dev/null; then
        OS="wsl"
    else
        OS="linux"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
    OS="windows"
else
    OS="unknown"
fi

echo "Detected OS: $OS"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install it first:"
    case $OS in
        "macos")
            echo "   macOS: brew install azure-cli"
            ;;
        "linux"|"wsl")
            echo "   Linux/WSL: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
            echo "   Or: pip install azure-cli"
            ;;
        "windows")
            echo "   Windows: Download from https://aka.ms/installazurecliwindows"
            echo "   Or use winget: winget install Microsoft.AzureCLI"
            ;;
        *)
            echo "   Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
            ;;
    esac
    exit 1
fi

echo "✅ Azure CLI found"

# Check if logged in
if ! az account show &> /dev/null; then
    echo "🔑 Not logged in to Azure. Starting login process..."
    az login
else
    echo "✅ Already logged in to Azure"
    echo "Current account: $(az account show --query 'user.name' -o tsv)"
fi

# Verify token can be obtained
echo "🔍 Testing Azure SQL token retrieval..."
if TOKEN=$(az account get-access-token --resource="https://database.windows.net" --query accessToken --output tsv 2>/dev/null) && [ -n "$TOKEN" ]; then
    echo "✅ Successfully obtained Azure SQL access token"
else
    echo "❌ Failed to obtain Azure SQL access token"
    echo "This could be due to:"
    echo "  - Insufficient permissions on Azure subscription"
    echo "  - Network connectivity issues"
    echo "  - Azure CLI authentication problems"
    if [[ "$OS" == "wsl" ]]; then
        echo "  - WSL-specific: Try running 'az login' with --use-device-code flag"
    fi
    exit 1
fi

echo ""
echo "🎉 Setup complete! You can now use Azure SQL Managed Identity in Neovim."
echo ""
echo "Usage in Neovim:"
echo "  <leader>Da  - Add new Azure SQL MI connection (interactive)"
echo "  <leader>Dq  - Quick connect using environment variables"
echo "  <leader>D   - Toggle database UI"
echo ""
echo "Environment variables (optional for quick connect):"
echo "  export AZURE_SQL_SERVER='myserver.database.windows.net'"
echo "  export AZURE_SQL_DATABASE='mydatabase'"
echo "  export AZURE_SQL_USER_ID='client-id-for-user-assigned-mi'  # Optional"
echo ""
echo "Note: Make sure your Azure account has access to the target databases"
echo "      and that Managed Identity is properly configured on Azure SQL."