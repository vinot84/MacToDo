#!/bin/bash

# MacTodoApp Installer Script
# This script bypasses macOS Gatekeeper restrictions

echo "🚀 MacTodoApp v1.4 Enhanced Installer"
echo "======================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$SCRIPT_DIR/MacTodoApp.app"

echo "📦 Installing MacTodoApp..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ MacTodoApp.app not found in the same directory as this installer"
    exit 1
fi

# Remove quarantine attributes
echo "🔓 Removing quarantine attributes..."
xattr -cr "$APP_PATH"

# Copy to Applications
echo "📂 Copying to Applications folder..."
if [ -w "/Applications" ]; then
    cp -R "$APP_PATH" "/Applications/"
    echo "✅ MacTodoApp installed to /Applications/MacTodoApp.app"
else
    echo "⚠️  Need admin privileges to install to /Applications"
    sudo cp -R "$APP_PATH" "/Applications/"
    echo "✅ MacTodoApp installed to /Applications/MacTodoApp.app"
fi

# Set execute permissions
echo "🔧 Setting permissions..."
chmod +x "/Applications/MacTodoApp.app/Contents/MacOS/MacTodoApp"

echo ""
echo "🎉 Installation Complete!"
echo ""
echo "📱 You can now find MacTodoApp in your Applications folder"
echo "🚀 Launch it from Launchpad or Spotlight"
echo ""
echo "💡 Features:"
echo "   • Automatic todos from Slack mentions"
echo "   • Integration with Quip & Chorus"
echo "   • Calendar sync capabilities"
echo ""
echo "⚙️  Configure integrations in Settings > Integrations"
echo ""

# Ask if user wants to launch the app
read -p "🚀 Launch MacTodoApp now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 Launching MacTodoApp..."
    open "/Applications/MacTodoApp.app"
fi

echo "✨ Enjoy your enhanced todo management!"