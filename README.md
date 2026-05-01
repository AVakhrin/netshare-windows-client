# Auto-proxy configurator for NetShare
### Switches proxy on/off based on Wi-Fi SSID
**Developed by PlayToMind Studio (c) 2026**

This script automates the proxy configuration for Windows clients connecting to Android devices via the **NetShare** app (Wi-Fi Direct).

## 🚀 The Problem it Solves
Standard NetShare instructions require manual proxy entry or running a `.bat` file every time you connect. If you forget to disable it when switching to home Wi-Fi, your internet stops working. 

**This script makes it "set it and forget it".**

## ✨ Key Features
- **Auto-Detect**: Activates proxy (192.168.49.1:8282) ONLY when connected to `DIRECT-NS-*` networks.
- **Auto-Disable**: Instantly turns off proxy settings when you disconnect or switch to another Wi-Fi.
- **Background Operation**: Uses Windows Event Viewer (Task Scheduler) to trigger changes silently.
- **Portable**: Single PowerShell script to set up any Windows machine.

## 🛠 Installation
1. Download `NetShare_Auto.ps1`.
2. Right-click the file and select **"Run with PowerShell"**.
3. **IMPORTANT**: The script will ask for **Administrator privileges**. You must allow it to create system tasks and modify proxy settings.
4. Done! The script creates tiny helper files in `%APPDATA%\NetShareAuto` and registers system tasks.

## 📄 License
This project is licensed under the **Creative Commons Attribution-NoDerivs 4.0 International (CC BY-ND 4.0)**.
- **You are free to**: Share, copy, and redistribute the material in any medium or format for any purpose, even commercially.
- **Under the following terms**: You must give appropriate credit to **PlayToMind Studio (c) 2026**. If you remix, transform, or build upon the material, you may not distribute the modified material.

---
*Created for the community to make tethering easier.*
