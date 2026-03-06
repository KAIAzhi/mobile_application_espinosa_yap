# Google Maps Setup Guide

## 🚨 IMPORTANT: You need a Google Maps API key for maps to work!

### Step 1: Get a Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Maps SDK for Android** and **Maps SDK for iOS** APIs
4. Create credentials (API Key)
5. **Restrict the API key** for security:
   - For Android: Add package name and SHA-1 fingerprint
   - For iOS: Add bundle identifier

### Step 2: Configure Android
1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

### Step 3: Configure iOS
1. **First, build the iOS project** to generate the Podfile:
   ```bash
   flutter build ios
   ```
2. Open `ios/Podfile` and add this line inside the `target 'Runner' do` block:
   ```ruby
   pod 'GoogleMaps', '8.4.0'
   ```
3. Run `pod install` in the ios directory
4. Open `ios/Runner/AppDelegate.swift`
5. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

### Step 4: Test the App
- Run the app on Android/iOS emulator or device
- Navigate to the hazard details page to see the map

## Troubleshooting
- If maps don't load, check the console for API key errors
- Make sure you've enabled the correct APIs in Google Cloud Console
- Verify your API key restrictions match your app's package/bundle ID
- For iOS, ensure you've run `pod install` after modifying the Podfile

## Note
The maps will show a blank screen or error until you add a valid API key.