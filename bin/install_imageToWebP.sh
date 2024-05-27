#!/bin/bash
current_version="0.4.0"

# Notify the user that sudo might be needed
echo "This script will require sudo permissions. Please ensure you have the necessary rights."

# Ensure ~/.bin directory exists
mkdir -p ~/.bin || { echo "Failed to create ~/.bin directory"; exit 1; }

# Download and unzip the script
curl -L -o /tmp/image2WebP.zip "https://github.com/TheBluWiz/image2WebP/archive/refs/tags/v$current_version.zip" || { echo "Failed to download the script"; exit 1; }
unzip /tmp/image2WebP.zip -d /tmp || { echo "Failed to unzip the script"; exit 1; }

# Copy the script to ~/.bin and make it executable
cp /tmp/image2WebP-$current_version/bin/image2WebP.sh ~/.bin/image2WebP || { echo "Failed to copy the script to ~/.bin"; exit 1; }
chmod +x ~/.bin/image2WebP || { echo "Failed to make the script executable"; exit 1; }

# Install man page
sudo mkdir -p /usr/local/share/man/man1 || { echo "Failed to create man directory"; exit 1; }
sudo cp /tmp/image2WebP-$current_version/man/image2WebP.1 /usr/local/share/man/man1/image2WebP.1 || { echo "Failed to copy the man page"; exit 1; }
sudo gzip /usr/local/share/man/man1/image2WebP.1 || { echo "Failed to gzip the man page"; exit 1; }
sudo /usr/libexec/makewhatis /usr/local/share/man/man1 || { echo "Failed to update man database"; exit 1; }
echo "Man page installed and database updated successfully."

# Clean up temporary files
rm -rf /tmp/image2WebP.zip /tmp/image2WebP-0.1.0 || { echo "Failed to clean up temporary files"; exit 1; }

# Add ~/.bin to PATH in .bashrc or .zshrc if not already present
if [[ $SHELL == *"bash"* ]]; then
  if ! grep -qxF 'export PATH="$HOME/.bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.bin:$PATH"' >>~/.bashrc
  fi
  echo "Please restart your terminal or run 'source ~/.bashrc'"
elif [[ $SHELL == *"zsh"* ]]; then
  if ! grep -qxF 'export PATH="$HOME/.bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.bin:$PATH"' >>~/.zshrc
  fi
  echo "Please restart your terminal or run 'source ~/.zshrc'"
else
  echo "Unsupported shell: $SHELL"
  exit 1
fi

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "Failed to install Homebrew"; exit 1; }
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install ffmpeg if not installed
if ! command -v ffmpeg &>/dev/null; then
  echo "ffmpeg not found. Installing ffmpeg..."
  brew install ffmpeg || { echo "Failed to install ffmpeg"; exit 1; }
fi

# Prompt to remove the installer file
read -p "Do you want to remove the installer file? [y/n]: " remove
if [[ "$remove" == "y" ]]; then
  rm -- "$0" || { echo "Failed to remove the installer file"; exit 1; }
fi

# update zsh/bash source
source ~/.zshrc || source ~/.bashrc
echo "Installation completed successfully."
