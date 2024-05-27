#!/bin/bash

# Ensure ~/.bin directory exists
mkdir -p ~/.bin

# Download and unzip the script
curl -L -o /tmp/image2WebP.zip "https://github.com/TheBluWiz/image2WebP/archive/refs/tags/v0.1.0.zip"
unzip /tmp/image2WebP.zip -d /tmp

# Copy the script to ~/.bin and make it executable
cp /tmp/image2WebP-0.1.0/image2WebP.sh ~/.bin/image2WebP
chmod +x ~/.bin/image2WebP

# Clean up temporary files
rm -rf /tmp/image2WebP.zip /tmp/image2WebP-0.1.0

# Add ~/.bin to PATH in .bashrc or .zshrc if not already present
if [[ $SHELL == *"bash"* ]]; then
  if ! grep -qxF 'export PATH="$HOME/.bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.bin:$PATH"' >>~/.bashrc
  fi
  # Inform the user to restart their terminal or source the .bashrc manually
  echo "Please restart your terminal or run 'source ~/.bashrc'"
elif [[ $SHELL == *"zsh"* ]]; then
  if ! grep -qxF 'export PATH="$HOME/.bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.bin:$PATH"' >>~/.zshrc
  fi
  # Inform the user to restart their terminal or source the .zshrc manually
  echo "Please restart your terminal or run 'source ~/.zshrc'"
fi

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install ffmpeg if not installed
if ! command -v ffmpeg &>/dev/null; then
  brew install ffmpeg
fi

# Prompt to remove the installer file
read -p "Do you want to remove the installer file? [y/n]: " remove
if [[ "$remove" == "y" ]]; then
  rm -- "$0"
fi