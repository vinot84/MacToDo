#!/bin/bash

# FINAL SOLUTION SCRIPT - User Guided Override
# This script helps users understand and perform the manual override

clear
echo "🔒 MacTodoApp Security Warning - SOLUTION GUIDE"
echo "=============================================="
echo ""
echo "🎯 You're seeing the 'Apple could not verify' warning because:"
echo "   • MacTodoApp isn't signed with an Apple Developer certificate"
echo "   • This costs \$99/year - we're an open-source project"
echo "   • The warning is normal and the app is completely safe"
echo ""
echo "✅ EASY SOLUTION (choose one method):"
echo ""
echo "📋 METHOD 1: Right-Click Override (RECOMMENDED)"
echo "   1. Go to Applications folder"
echo "   2. Right-click on MacTodoApp.app"
echo "   3. Select 'Open' from the menu"
echo "   4. Click 'Open' in the dialog"
echo ""
echo "📋 METHOD 2: System Settings Override"
echo "   1. Try to open MacTodoApp (gets blocked)"
echo "   2. Apple Menu → System Settings → Privacy & Security"
echo "   3. Find 'MacTodoApp was blocked' message"
echo "   4. Click 'Open Anyway'"
echo ""
echo "📋 METHOD 3: Terminal Command"
echo "   1. Copy this command:"
echo "      spctl --add /Applications/MacTodoApp.app && open /Applications/MacTodoApp.app"
echo "   2. Paste in Terminal and press Enter"
echo ""

read -p "Press Enter to continue..."
clear

echo "🛠️ Let me help you with the installation and override process:"
echo ""

# Check if MacTodoApp is in Applications
if [ -d "/Applications/MacTodoApp.app" ]; then
    echo "✅ MacTodoApp is installed in Applications folder"
    echo ""
    echo "🎯 Now let's try the right-click method:"
    echo ""
    echo "1. I'll open the Applications folder for you..."
    sleep 2
    open /Applications
    echo ""
    echo "2. Find MacTodoApp in the folder that just opened"
    echo "3. Right-click on MacTodoApp.app"
    echo "4. Select 'Open' from the context menu"
    echo "5. Click 'Open' when asked to confirm"
    echo ""
    read -p "Ready to try? Press Enter and I'll wait..."
    echo ""
    echo "⏳ Waiting for you to right-click and open MacTodoApp..."
    echo "   (This may take a moment)"
    echo ""
    
    # Wait a bit then try to detect if app is running
    sleep 10
    
    if pgrep -f "MacTodoApp" > /dev/null 2>&1; then
        echo "🎉 SUCCESS! MacTodoApp is now running!"
        echo "✅ You've successfully bypassed the security warning"
        echo "🚀 The app will now launch normally from now on"
    else
        echo "🤔 I don't detect MacTodoApp running yet."
        echo ""
        echo "💡 If you're still seeing the warning, try this:"
        echo "   • Apple Menu → System Settings"
        echo "   • Privacy & Security"
        echo "   • Look for 'MacTodoApp was blocked' message"
        echo "   • Click 'Open Anyway'"
        echo ""
        echo "🔄 Or try the Terminal command:"
        echo "   spctl --add /Applications/MacTodoApp.app && open /Applications/MacTodoApp.app"
    fi
else
    echo "❌ MacTodoApp is not in Applications folder yet"
    echo ""
    APP_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/MacTodoApp.app"
    
    if [ -d "$APP_PATH" ]; then
        echo "📦 I found MacTodoApp.app in the current folder"
        echo "🔧 Let me install it to Applications first..."
        
        # Remove quarantine and install
        xattr -cr "$APP_PATH" 2>/dev/null || true
        
        if cp -R "$APP_PATH" "/Applications/" 2>/dev/null; then
            echo "✅ Installed to Applications folder"
        else
            echo "🔐 Need admin privileges..."
            sudo cp -R "$APP_PATH" "/Applications/"
            echo "✅ Installed to Applications folder (with admin)"
        fi
        
        echo ""
        echo "🎯 Now opening Applications folder for the right-click method:"
        open /Applications
        echo ""
        echo "👆 Follow the same steps:"
        echo "1. Right-click on MacTodoApp.app"
        echo "2. Select 'Open'"
        echo "3. Click 'Open' to confirm"
    else
        echo "❌ Can't find MacTodoApp.app"
        echo "💡 Make sure this script is in the same folder as MacTodoApp.app"
    fi
fi

echo ""
echo "🔒 REMEMBER: This warning is normal for unsigned apps"
echo "🛡️ MacTodoApp is completely safe - we just don't pay Apple's \$99/year fee"
echo "✨ After you override once, it works forever like any other app!"
echo ""
echo "🆕 Once running, check out the new features:"
echo "   • Slack mention detection"
echo "   • Quip & Chorus integration buttons"
echo "   • Calendar sync"
echo "   • Multiple themes"
echo ""
echo "⚙️ Configure integrations in: MacTodoApp → Settings → Integrations"