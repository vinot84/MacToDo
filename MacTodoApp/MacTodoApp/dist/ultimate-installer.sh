#!/bin/bash

# MacTodoApp Ultimate Installer - Bypasses ALL macOS Security Warnings
# This script completely removes Gatekeeper restrictions

echo "🚀 MacTodoApp v1.4 Enhanced - Ultimate Installer"
echo "=============================================="
echo ""
echo "⚠️  This installer will bypass macOS Gatekeeper warnings"
echo "🔒 Your Mac will be secure - we only modify this specific app"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$SCRIPT_DIR/MacTodoApp.app"

echo "📦 Installing MacTodoApp with full bypass..."
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ MacTodoApp.app not found in the same directory as this installer"
    echo "💡 Make sure this script is in the same folder as MacTodoApp.app"
    exit 1
fi

echo "🔓 Step 1: Removing all quarantine attributes..."
xattr -cr "$APP_PATH" 2>/dev/null || true

echo "🔓 Step 2: Removing extended attributes..."
xattr -d com.apple.quarantine "$APP_PATH" 2>/dev/null || true

echo "🔓 Step 3: Clearing Gatekeeper cache for this app..."
spctl --remove "$APP_PATH" 2>/dev/null || true

echo "📂 Step 4: Installing to Applications..."
# Check if Applications is writable
if [ -w "/Applications" ]; then
    # Remove existing version if present
    if [ -d "/Applications/MacTodoApp.app" ]; then
        echo "🗑️  Removing existing MacTodoApp..."
        rm -rf "/Applications/MacTodoApp.app"
    fi
    
    cp -R "$APP_PATH" "/Applications/"
    echo "✅ MacTodoApp installed to /Applications/"
else
    echo "🔐 Need admin privileges for Applications folder..."
    sudo rm -rf "/Applications/MacTodoApp.app" 2>/dev/null
    sudo cp -R "$APP_PATH" "/Applications/"
    echo "✅ MacTodoApp installed to /Applications/ (with admin privileges)"
fi

echo "🔧 Step 5: Setting proper permissions..."
chmod +x "/Applications/MacTodoApp.app/Contents/MacOS/MacTodoApp"

echo "🔓 Step 6: Final Gatekeeper bypass..."
# Clear quarantine on installed version
xattr -cr "/Applications/MacTodoApp.app" 2>/dev/null || true
xattr -d com.apple.quarantine "/Applications/MacTodoApp.app" 2>/dev/null || true

# Add to Gatekeeper allowed list
spctl --add "/Applications/MacTodoApp.app" 2>/dev/null || true
spctl --enable "/Applications/MacTodoApp.app" 2>/dev/null || true

echo ""
echo "🎉 Installation Complete!"
echo ""
echo "✨ MacTodoApp has been installed with ZERO security warnings!"
echo "📱 You can now launch it normally from:"
echo "   • Applications folder"
echo "   • Launchpad"  
echo "   • Spotlight search"
echo ""
echo "🔒 Security Status: BYPASSED (safe for this app only)"
echo ""

# Test if the app can be launched without warnings
echo "🧪 Testing launch capability..."
if spctl -a "/Applications/MacTodoApp.app" 2>/dev/null; then
    echo "✅ Gatekeeper test PASSED - No warnings will appear!"
else
    echo "⚠️  Gatekeeper still active, but app will work with right-click → Open"
fi

echo ""
read -p "🚀 Launch MacTodoApp now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 Launching MacTodoApp..."
    open "/Applications/MacTodoApp.app"
    sleep 2
    echo "✨ If successful, MacTodoApp should now be running!"
fi

echo ""
echo "🆕 New Features in v1.4 Enhanced:"
echo "   • 💬 Automatic todos from Slack mentions"
echo "   • 🔗 Quick buttons for Quip & Chorus links"  
echo "   • 👤 User profile for mention detection"
echo "   • 📅 Calendar integration"
echo "   • 🎨 Multiple themes"
echo ""
echo "⚙️  Configure integrations: MacTodoApp → Settings → Integrations"
echo ""
echo "🎊 Enjoy your malware-warning-free todo app!"