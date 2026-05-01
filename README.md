# Auto-proxy configurator for NetShare
### Switches proxy on/off based on Wi-Fi SSID
**Developed by PlayToMind Studio (c) 2026**

This script automates the proxy configuration for Windows clients connecting to Android devices via the **NetShare** app (Wi-Fi Direct).

## 🚀 Key Features
- **Auto-Detect**: Activates proxy (192.168.49.1:8282) ONLY when connected to `DIRECT-NS-*` networks.
- **Auto-Disable**: Instantly turns off proxy settings when you disconnect or switch to another Wi-Fi.
- **Background Operation**: Works silently using Windows Task Scheduler events.

## 🛠 Step-by-Step Installation
Windows restricts script execution by default. Follow these steps exactly:

1. **Download** the `NetShare_Auto.ps1` file.
2. **Open PowerShell as Admin**:
   - Press the `Win` key, type **PowerShell**.
   - Right-click it and select **"Run as Administrator"**.
3. **Unlock Scripting**: Copy and paste this command into the blue window, then press **Enter**:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
   ```
4. **Run the Script**: 
   - Type `& ` (ampersand and a space).
   - **Drag and drop** your downloaded `NetShare_Auto.ps1` file directly into the PowerShell window.
   - Press **Enter**.
5. **Done!** You can close the window. The automation is now active.

## 📄 License
Distributed under **CC BY-ND 4.0**. 
Free to share and use, provided original authorship is maintained (**PlayToMind Studio (c) 2026**).
