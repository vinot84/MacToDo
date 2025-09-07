#!/bin/bash

# Apple Developer Program Setup Script
# This script helps prepare MacTodoApp for proper Apple code signing

echo "🍎 Apple-Compliant Distribution Setup for MacTodoApp"
echo "=================================================="
echo ""

# Check if user has Xcode and developer tools
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode from the App Store first."
    exit 1
fi

# Check if user has Apple Developer account
echo "📋 Apple Developer Program Requirements:"
echo ""
echo "   1. ✅ Xcode installed (detected)"
echo "   2. 🔄 Apple Developer Program membership (\$99/year)"
echo "   3. 🔄 Developer ID certificates"
echo "   4. 🔄 Team ID configured"
echo ""

read -p "Do you have an Apple Developer Program membership? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📝 To eliminate security warnings, you need to:"
    echo ""
    echo "   1. Enroll at: https://developer.apple.com/programs/"
    echo "   2. Pay \$99 annual fee"
    echo "   3. Wait for approval (1-2 days)"
    echo "   4. Download certificates in Xcode"
    echo "   5. Return to this script"
    echo ""
    echo "💡 This is the ONLY way to eliminate macOS security warnings."
    echo "   Without it, users will always need to right-click → Open."
    echo ""
    exit 0
fi

echo ""
echo "🔧 Checking for Developer certificates..."

# List available signing identities
IDENTITIES=$(security find-identity -v -p codesigning | grep "Developer ID Application")

if [ -z "$IDENTITIES" ]; then
    echo "❌ No Developer ID certificates found"
    echo ""
    echo "📥 To get certificates:"
    echo "   1. Open Xcode → Preferences → Accounts"
    echo "   2. Add your Apple ID"
    echo "   3. Select your team"
    echo "   4. Click 'Download Manual Profiles'"
    echo "   5. Certificates will be installed automatically"
    echo ""
    echo "🔗 Or download manually from:"
    echo "   https://developer.apple.com/certificates/"
    echo ""
    exit 0
fi

echo "✅ Found Developer ID certificates:"
echo "$IDENTITIES"
echo ""

# Get the first certificate name
CERT_NAME=$(echo "$IDENTITIES" | head -1 | sed 's/.*"\(.*\)"/\1/')
echo "🎯 Will use certificate: $CERT_NAME"
echo ""

read -p "Continue with code signing? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "🔨 Building and signing MacTodoApp..."

# Check if we have the source project
if [ ! -f "MacTodoApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ MacTodoApp.xcodeproj not found"
    echo "💡 Make sure you run this script from the project root directory"
    exit 1
fi

# Clean and build
echo "🧹 Cleaning previous builds..."
rm -rf build/

echo "🏗️  Building MacTodoApp for distribution..."
xcodebuild -project MacTodoApp.xcodeproj \
           -scheme MacTodoApp \
           -configuration Release \
           -derivedDataPath build \
           -archivePath build/MacTodoApp.xcarchive \
           archive

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Export the archive
echo "📦 Exporting signed app..."

# Create export options plist
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
           -archivePath build/MacTodoApp.xcarchive \
           -exportOptionsPlist build/ExportOptions.plist \
           -exportPath build/

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

echo "✅ Export successful"
echo ""

# Find the exported app
SIGNED_APP=$(find build/ -name "MacTodoApp.app" -type d | head -1)

if [ ! -d "$SIGNED_APP" ]; then
    echo "❌ Signed app not found"
    exit 1
fi

echo "🔍 Verifying code signature..."
codesign --verify --verbose "$SIGNED_APP"
if [ $? -eq 0 ]; then
    echo "✅ Code signature valid"
else
    echo "❌ Code signature verification failed"
    exit 1
fi

echo ""
echo "🔐 Testing Gatekeeper compliance..."
spctl --assess --verbose "$SIGNED_APP"
if [ $? -eq 0 ]; then
    echo "✅ Gatekeeper assessment PASSED"
    echo "🎉 This app will install without security warnings!"
else
    echo "⚠️  Gatekeeper assessment failed"
    echo "💡 You may need to notarize the app for full compliance"
fi

echo ""
echo "📦 Creating distribution packages..."

# Create dist directory
mkdir -p dist/

# Copy signed app
cp -R "$SIGNED_APP" dist/

# Create signed DMG
hdiutil create -volname "MacTodoApp v1.4 Enhanced" \
               -srcfolder "$SIGNED_APP" \
               -ov -format UDZO \
               dist/MacTodoApp-Signed.dmg

# Sign the DMG
codesign --force --sign "$CERT_NAME" dist/MacTodoApp-Signed.dmg

# Create signed ZIP
cd dist/
zip -r MacTodoApp-Signed.zip MacTodoApp.app
cd ..

echo ""
echo "🎊 SUCCESS! Apple-compliant packages created:"
echo ""
echo "   📁 dist/MacTodoApp.app (signed)"
echo "   💿 dist/MacTodoApp-Signed.dmg"
echo "   📦 dist/MacTodoApp-Signed.zip"
echo ""
echo "✨ These packages will install on any Mac without security warnings!"
echo ""
echo "📋 Next steps for full compliance:"
echo "   1. Submit for notarization: xcrun notarytool submit"
echo "   2. Staple notarization: xcrun stapler staple"
echo "   3. Distribute through your preferred channels"
echo ""
echo "🎯 Users can now install by simply double-clicking - no warnings!"
echo ""

# Test the signed app
read -p "🚀 Test launch the signed app now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 Launching signed MacTodoApp..."
    open "$SIGNED_APP"
    echo "✨ If successful, the app should launch without any warnings!"
fi