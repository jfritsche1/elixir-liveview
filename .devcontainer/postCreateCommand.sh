#!/usr/bin/env bash
set -e

echo "Running postCreateCommand..."
alias ll="ls -lh"

echo "Configuring Red Hat repos..."

# For Ubi uninstall subscription-manager
dnf remove -y subscription-manager
# Enable Ubi repos
dnf config-manager --set-enabled ubi-9-baseos && dnf config-manager --set-enabled ubi-9-appstream && dnf config-manager --set-enabled ubi-9-codeready-builder

echo "Installing packages"
# Example setup (customize for your needs)
dnf install -y git wget vim unzip openssl

# Download erlang binary rpm.
# rpm -Uvh packages/esl-erlang_28.1_1~centos~8_x86_64.rpm
cd /workspaces/airgap_app/packages/erlang-build/
./install-erlang.sh

# Install Elixir
mkdir -m 755 /elixir
unzip /workspaces/airgap_app/packages/elixir-otp-28.zip -d /elixir/
export PATH="$PATH:/elixir/bin/"

echo "postCreateCommand complete."