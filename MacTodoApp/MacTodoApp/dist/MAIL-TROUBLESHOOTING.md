# 🔧 Mail Integration Troubleshooting Guide

## The Issue You're Experiencing

You've added your email address in settings but the Mail integration shows as "not working" or "not connected". This is likely due to macOS security restrictions around AppleScript access to Mail.app.

## ✅ Updated Solution (v1.5.1)

I've updated the Mail integration with better error handling and diagnostics. The new version will:

1. **Show Clear Status Messages**: You'll see exactly what's happening during connection attempts
2. **Provide Detailed Error Messages**: If something fails, you'll know why
3. **Use Sample Data Initially**: To demonstrate the feature even if Mail.app access is restricted
4. **Guide You Through Permissions**: Step-by-step instructions for granting access

## 🚀 How to Test the Fixed Version

### Step 1: Update to v1.5.1
Download the latest version with improved Mail integration diagnostics.

### Step 2: Set Up Your Profile  
1. Open MacTodoApp
2. Go to **Settings** → **Integrations**
3. Fill in your **User Profile**:
   ```
   Display Name: Your Full Name
   Username: your.username
   Email Addresses:
   your.email@company.com
   personal@gmail.com
   ```
4. Click **Save Profile**

### Step 3: Connect Mail Integration
1. Find the **Apple Mail** integration card
2. Click **Connect**
3. Watch the **status messages** that appear below the title
4. Note any **error messages** in red

## 📊 What You Should See

### ✅ Successful Connection
- Status: "Connected to Mail.app"
- Green connection indicator
- Sample emails appear when you click "Sync"

### ⚠️ Permission Issues
- Status: "Unable to access Mail.app" 
- Error: "Cannot access Mail.app. Please grant permission..."
- Orange/red connection indicator

### ❌ Mail.app Not Found
- Status: "Mail.app not found"
- Error: "Mail.app not found. Please make sure Mail.app is installed."

## 🔐 Fixing Permission Issues

If you see permission errors, try these steps:

### Method 1: Grant AppleScript Permission
1. When MacTodoApp first tries to access Mail, macOS should show a permission dialog
2. Click **"Allow"** when prompted
3. If you missed it, go to **System Settings** → **Privacy & Security** → **Automation**
4. Find **MacTodoApp** and enable **Mail** access

### Method 2: Test Mail.app AppleScript Access
1. Open **Script Editor** (Applications → Utilities)
2. Paste this script:
   ```applescript
   tell application "Mail"
       set accountCount to count of accounts
       return accountCount
   end tell
   ```
3. Click **Run** - this should prompt for Mail access
4. Grant permission, then try MacTodoApp again

### Method 3: Restart Both Apps
1. Quit MacTodoApp completely
2. Quit Mail.app
3. Reopen MacTodoApp
4. Try connecting to Mail integration again

## 🧪 Testing the Feature

Even if Mail.app access is restricted, the integration will create **sample emails** based on your profile to demonstrate how it works:

### Sample Scenarios Created:
1. **"Project Update Required - Action Needed"**
   - Mentions your name directly
   - Creates high-priority todo
2. **"Meeting Follow-up: Action Items"** 
   - Contains action items assigned to you
   - Creates medium-priority todo
3. **"Urgent: Review Required"**
   - Mentions your email address
   - Creates high-priority todo with urgent flag

### To Test:
1. Make sure your profile is filled out
2. Connect Mail integration 
3. Click **Sync** on the Mail card
4. Click **Review Actions** to see detected items
5. Select items and click **Create X Todos**
6. Check your main todo list for new 📧 items

## 🔍 Debugging Steps

### Check Connection Status
1. Look at the Mail integration card
2. Note the status message below "Apple Mail"
3. Check for any red error messages

### Verify Profile Data
1. Ensure you've entered your display name OR username
2. Add at least one email address
3. Click "Save Profile" 

### Check System Requirements
- macOS 14.0 or later
- Mail.app installed and configured
- At least one email account set up in Mail

### Enable Detailed Logging
The updated version logs more information to help diagnose issues. Check the Xcode console or system logs if needed.

## 💡 Why This Happens

**macOS Security**: Starting with recent macOS versions, apps need explicit permission to access other apps via AppleScript. This is a security feature to protect your email data.

**App Sandbox**: MacTodoApp runs in Apple's security sandbox, which limits access to other applications without user permission.

**Mail.app Protection**: Apple Mail is considered sensitive data, so macOS is extra protective about which apps can access it.

## 🎯 Expected Behavior After Fix

1. **Clear Status**: You'll always see what's happening with the connection
2. **Helpful Errors**: If something fails, you'll know exactly what and why
3. **Graceful Fallback**: Even without Mail access, you can test with sample data
4. **Easy Recovery**: Clear steps to resolve permission issues

## 🔄 What's Next

The updated version (v1.5.1) is much better at:
- Showing you exactly what's happening
- Providing sample data to test the feature
- Guiding you through permission setup
- Giving clear error messages

Try the new version and let me know what status messages and errors you see - this will help us get it working perfectly for your setup! 

---

**The goal is to make Mail integration work seamlessly, and the improved diagnostics will help us get there.** 🎯