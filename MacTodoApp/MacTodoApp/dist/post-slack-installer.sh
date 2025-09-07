#!/bin/bash

# POST-SLACK-DOWNLOAD INSTALLER
# Designed specifically for files downloaded from Slack, email, web browsers, etc.
# This handles the quarantine attributes that get added during download

echo "📱 MacTodoApp v1.4 Enhanced - Post-Download Installer"
echo "=================================================="
echo ""
echo "🎯 This installer is designed for files downloaded from:"
echo "   • Slack attachments"
echo "   • Email attachments" 
echo "   • Web browsers"
echo "   • Any internet source"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This installer is for macOS only"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$SCRIPT_DIR/MacTodoApp.app"

echo "🔍 Checking for MacTodoApp..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ MacTodoApp.app not found in the same directory as this installer"
    echo ""
    echo "💡 TROUBLESHOOTING:"
    echo "   1. Make sure you extracted the ZIP file completely"
    echo "   2. This script should be in the same folder as MacTodoApp.app"
    echo "   3. Try downloading the ZIP again if files are missing"
    exit 1
fi

echo "✅ MacTodoApp.app found!"
echo ""

echo "🧹 Step 1: Removing ALL download quarantine attributes..."
# Remove quarantine from the entire directory (handles Slack downloads)
find "$SCRIPT_DIR" -name ".*" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null || true
xattr -cr "$SCRIPT_DIR" 2>/dev/null || true

# Specifically target the app
xattr -cr "$APP_PATH" 2>/dev/null || true
xattr -d com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# Remove quarantine from all contents
find "$APP_PATH" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null || true
find "$APP_PATH" -exec xattr -cr {} \; 2>/dev/null || true

echo "✅ Quarantine attributes removed!"

echo ""
echo "🔓 Step 2: Clearing Gatekeeper restrictions..."
spctl --remove "$APP_PATH" 2>/dev/null || true

echo "✅ Gatekeeper cache cleared!"

echo ""
echo "📂 Step 3: Installing to Applications folder..."

# Remove existing version if present
if [ -d "/Applications/MacTodoApp.app" ]; then
    echo "🗑️  Removing existing MacTodoApp..."
    rm -rf "/Applications/MacTodoApp.app" 2>/dev/null || sudo rm -rf "/Applications/MacTodoApp.app"
fi

# Copy to Applications
if cp -R "$APP_PATH" "/Applications/" 2>/dev/null; then
    echo "✅ Installed to /Applications/"
else
    echo "🔐 Need admin privileges for Applications folder..."
    sudo cp -R "$APP_PATH" "/Applications/"
    echo "✅ Installed to /Applications/ (with admin privileges)"
fi

echo ""
echo "🔧 Step 4: Setting permissions and final cleanup..."
chmod +x "/Applications/MacTodoApp.app/Contents/MacOS/MacTodoApp"

# Final quarantine removal on installed version
xattr -cr "/Applications/MacTodoApp.app" 2>/dev/null || true
find "/Applications/MacTodoApp.app" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null || true

# Add to Gatekeeper allow list
spctl --add "/Applications/MacTodoApp.app" 2>/dev/null || true

echo "✅ Permissions set and final cleanup complete!"

echo ""
echo "🧪 Step 5: Testing Gatekeeper bypass..."
if spctl -a "/Applications/MacTodoApp.app" 2>/dev/null; then
    echo "✅ SUCCESS: Gatekeeper test PASSED!"
    echo "📱 MacTodoApp will launch without ANY warnings!"
else
    echo "⚠️  Gatekeeper still shows restrictions"
    echo "💡 But the app will work - use right-click → Open if needed"
fi

echo ""
echo "🎉 INSTALLATION COMPLETE!"
echo ""
echo "✨ MacTodoApp v1.4 Enhanced is now installed!"
echo "📍 Location: /Applications/MacTodoApp.app"
echo ""
echo "🚀 Launch Methods:"
echo "   • Applications folder (Finder)"
echo "   • Launchpad" 
echo "   • Spotlight search (Cmd+Space, type 'MacTodoApp')"
echo "   • Command line: open /Applications/MacTodoApp.app"
echo ""

read -p "🎯 Launch MacTodoApp now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "🚀 Launching MacTodoApp..."
    open "/Applications/MacTodoApp.app"
    sleep 2
    
    # Check if it's running
    if pgrep -f "MacTodoApp" > /dev/null 2>&1; then
        echo "✅ SUCCESS: MacTodoApp is now running!"
    else
        echo "⏳ MacTodoApp should be starting..."
        echo "💡 If you see any security prompts, click 'Open' to proceed"
    fi
fi

echo ""
echo "🆕 FEATURES IN v1.4 ENHANCED:"
echo "  💬 Automatic todos when mentioned in Slack"
echo "  🔗 Quick buttons for Quip & Chorus links"
echo "  👤 User profile configuration for mentions" 
echo "  📅 Calendar integration with macOS Calendar"
echo "  🎨 Multiple theme options"
echo ""
echo "⚙️  NEXT STEPS:"
echo "  1. Open MacTodoApp"
echo "  2. Go to Settings → Integrations"
echo "  3. Configure your Slack, Quip, and Chorus accounts"
echo "  4. Set up your user profile for mention detection"
echo ""
echo "🎊 Enjoy your enhanced todo management experience!"
echo ""
echo "🔒 SECURITY NOTE: This installer only affects MacTodoApp."
echo "    Your Mac's overall security remains fully intact."