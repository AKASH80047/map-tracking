# Live GPS Map Tracking UI & Navigation (Flutter)

A modern, production-quality live map tracking screen inspired by premium ride-hailing & delivery navigation interfaces (Uber, Grab, Pathao). Built with Flutter, Google Maps Flutter, Geolocator, and Material 3 design.

---

## 🚀 Features

### 1. Interactive Map & Live Navigation
- **Interactive Google Map**: Supports panning, zooming, tilt, and rotating gestures.
- **Dynamic Vehicle Marker**: Animated marker representing **Motorcycle** or **Car** with smooth coordinate interpolation and live travel bearing rotation.
- **Route Visualization**: Dual-layer road polyline (vibrant `#1D4ED8` blue core with translucent casing glow).
- **Start & Destination Pins**: Custom high-resolution vector markers for origin beacon and destination teardrop pin.
- **Auto-Follow Mode**: Camera automatically pans and rotates to follow the vehicle during active navigation.
- **Map Styles**: One-touch toggle between Standard Vector and Satellite imagery.
- **Fit Full Route**: One-tap camera fitting that encompasses the entire route bounds with generous padding.

### 2. Live GPS & Device Sensors
- **Hardware GPS Stream**: Connects to the device's location sensor via `geolocator`.
- **Permission & Service Handling**: Automated checks for location services enabled, `denied`, and `deniedForever` statuses.
- **Jitter & Teleportation Rejection**: Discards noise (< 1.5m) and unrealistic GPS speed anomalies (> 200 km/h).
- **Bearing Calculation**: Derives true vehicle heading using spherical forward azimuth math between consecutive GPS coordinates.
- **Demo / Simulation Mode**: Built-in toggle to test-drive smoothly along the route at realistic city speeds on emulators or desktops without physical driving.

### 3. Trip Metrics & Progress
- **Dynamic ETA**: Continuously recalculated from remaining road distance and instantaneous/average speed.
- **Remaining Time & Distance**: Formatted prominently (e.g. `5 min (1.8 km)`).
- **Speedometer**: Live speed indicator badge in `km/h`.
- **Horizontal Route Progress Bar**:
  - Green completed segment.
  - Light grey remaining segment.
  - Moving vehicle icon matching current progress %.
  - Destination marker at the finish line.
- **Statistical Breakdown**:
  - Distance travelled (e.g., `3.2 km`).
  - Distance remaining (e.g., `1.8 km`).
  - Total planned distance (e.g., `5.0 km`).
  - Live status (`On Track` / `Arrived`).

### 4. Interactive Destination Management
- **Destination Card**: Shows destination name, address, and a "Change" button.
- **Change Destination Modal**: Search or pick from preset landmarks; automatically recalculates road polylines, distances, and camera bounds.

### 5. Safety & Trip Completion
- **Emergency SOS Button**: Confirmation dialog offering one-tap emergency calling (`tel:911`) and location sharing with exact coordinates and Google Maps URL.
- **End Trip Flow**: Confirmation prompt, followed by a complete **Trip Summary Dialog** detailing total distance, elapsed duration, average speed, top speed, and start/finish timestamps.

---

## 📁 Project Architecture

```
lib/
├── constants/
│   ├── app_colors.dart             # Dark navy (#0F1B2B), route blue, SOS red
│   └── app_constants.dart          # Default coordinates, API keys, presets
├── models/
│   ├── location_point.dart         # Position, heading, speed, timestamp
│   ├── trip_model.dart             # Full trip state, progress %, ETA, metrics
│   └── vehicle_type.dart           # Bike (Motorcycle) vs Car
├── services/
│   ├── directions_service.dart     # Google Directions API + Fallback Road Network
│   ├── location_service.dart       # Geolocator stream, permissions, bearing math
│   └── trip_tracking_service.dart  # Trip state machine, distance accumulation, simulation
├── utils/
│   └── marker_generator.dart       # High-definition custom Canvas/Bitmap markers
├── widgets/
│   ├── destination_card.dart       # Destination address card with Change button
│   ├── destination_picker_sheet.dart # Landmark search and selection bottom sheet
│   ├── end_trip_dialog.dart        # Confirmation dialog before stopping
│   ├── sos_dialog.dart             # Emergency call (911) & location sharing
│   ├── trip_bottom_sheet.dart      # Rounded bottom sheet with metrics & controls
│   ├── trip_floating_controls.dart # Recenter, Follow, Layers, Zoom, Fit, Sim toggle
│   ├── trip_map_view.dart          # GoogleMap, custom animated markers, polylines
│   ├── trip_progress_bar.dart      # Visual progress bar with moving vehicle icon
│   ├── trip_summary_dialog.dart    # Post-trip stats report
│   └── trip_top_app_bar.dart       # Dark navy header with pulsing live dot & SOS
├── screens/
│   └── trip_tracking_screen.dart   # Main screen coordinating map, top bar & sheet
└── main.dart                       # App entrypoint and Material 3 theme
```

---

## 🔑 Google Maps API Configuration

To render Google Maps on physical devices and query the Directions API:

### 1. Android Configuration
In `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```
*(Or specify `MAPS_API_KEY=YOUR_KEY` in `android/gradle.properties`)*

### 2. iOS Configuration
In `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 3. Directions API (Dart runtime)
Pass your API key when building or running:
```bash
flutter run --dart-define=MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```
*Note: If no API key is supplied, the app automatically activates its built-in realistic multi-turn road network engine so routes, turns, distances, and driving simulations work out of the box without crashing.*

---

## 🛠️ Commands

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run Static Analysis
```bash
flutter analyze
```

### 3. Run Unit and Widget Tests
```bash
flutter test
```

### 4. Run the Application
```bash
# Debug mode on connected device / emulator
flutter run

# With Maps API key defined
flutter run --dart-define=MAPS_API_KEY=YOUR_KEY
```
