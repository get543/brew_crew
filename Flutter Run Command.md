### 1. View Connected Devices

Open your terminal in your Flutter project directory and run:

```bash
flutter devices

```

This will list all currently connected physical devices, emulators, and web/desktop targets along with their **Device ID**.

**Example Output:**

```text
Found 3 connected devices:
  Pixel 7 (mobile)     • 24151FDF6000CQ • android-arm64  • Android 14 (API 34)
  iPhone (mobile)      • 00008110-001A  • ios            • iOS 17.2
  Chrome (web)         • chrome         • web-javascript • Google Chrome

```

---

### 2. Run Flutter Code on Your Physical Device

#### Option A: Run on a specific device (Recommended)

Pass the **Device ID** or device name using the `-d` flag:

```bash
flutter run -d <device_id>

```

**Examples:**

```bash
# Using the device ID
flutter run -d 24151FDF6000CQ

# Using the platform name (if only one Android/iOS device is connected)
flutter run -d android
flutter run -d ios

```

#### Option B: Run on all connected devices simultaneously

```bash
flutter run -d all

```

---

### 3. Prerequisites for Physical Devices

If your physical device does not show up when running `flutter devices`, check the following:

#### For Android:

1. Enable **Developer Options** on your phone (Tap *Build Number* 7 times in Settings).
2. Enable **USB Debugging** under *Settings > Developer Options*.
3. Connect via USB and accept the **"Allow USB Debugging?"** prompt on your phone screen.

#### For iOS:

1. Connect via USB and tap **Trust This Computer** on your iPhone.
2. Enable **Developer Mode** on your iPhone (*Settings > Privacy & Security > Developer Mode* on iOS 16+).
3. Open the `ios/Runner.xcworkspace` folder in Xcode once to set up your **Development Team / Signing Profile**.

---

### Useful Commands While App is Running

Once `flutter run` launches your app on the physical device, press these keys in your terminal:

* **`r`** – Perform Hot Reload (updates code instantly without losing state).
* **`R`** – Perform Hot Restart (restarts app state).
* **`q`** – Quit and stop the application.