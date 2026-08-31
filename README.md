# LensMatch

A Flutter project that provides an Augmented Reality (AR) try-on experience for virtual glasses and lenses, utilizing on-device machine learning for face detection and shape analysis.

## Core Directories & Files

The project follows a standard Flutter structure, with the main application code located in the `lib` directory.

### 1. Application Entry Points
*   [`lib/main.dart`](lib/main.dart): The entry point of the Flutter application. It initializes core services (like Firebase) and sets up the root widget of the app.
*   [`lib/main_screen.dart`](lib/main_screen.dart): Likely the main navigational shell or the first screen presented to the user after successful initialization.

### 2. Views (`lib/views/`)
This directory contains all the user interface (UI) screens.
*   **Authentication**: `login_view.dart`, `signup_view.dart`, and `sign_up_screen.dart` handle user registration and login.
*   **Core Functionality**:
    *   `camera_view.dart`: Manages the device camera feed.
    *   `ar_tryon_view.dart`: Handles the Augmented Reality (AR) try-on experience for virtual glasses/lenses.
    *   `result_view.dart`: Displays the results of face scans or matching.
    *   `frame_view.dart` & `frame_detail_view.dart`: Displays the inventory or details of glasses frames.
*   **User Management**: `profile_view.dart`, `account_details_view.dart`, `complete_profile_screen.dart`.
*   **Other UI**: `home_view.dart`, `notifications_view.dart`, `help_support_view.dart`, etc.

### 3. Utilities & Logic (`lib/utils/`)
This directory handles the core business logic, machine learning integrations, and app state.
*   `app_state.dart`: Manages the global state of the application.
*   `face_shape_detector.dart`: Contains the logic for analyzing facial features to determine face shapes.
*   `tflite_face_detector.dart`: Integrates with TensorFlow Lite to perform custom on-device face detection tasks.

## Required Packages and Dependencies

The project relies on several important packages defined in `pubspec.yaml`.

> [!NOTE]
> Run `flutter pub get` in your terminal to download and install all these required packages.

### Machine Learning & Camera
*   **`camera`**: For accessing the device's camera hardware.
*   **`google_mlkit_face_detection`** & **`google_mlkit_face_mesh_detection`**: Google's ML Kit for robust, on-device face and facial mesh detection.
*   **`tflite_flutter`**: For running custom TensorFlow Lite machine learning models directly on the device.
*   **`google_generative_ai`**: For integrating with Google's Gemini models.

### Backend (Firebase)
*   **`firebase_core`**, **`firebase_auth`**, **`cloud_firestore`**, **`google_sign_in`**: For user authentication, database, and backend services.

### Utilities
*   **`flutter_dotenv`**: For securely loading environment variables from a `.env` file.
*   **`device_preview`**: For previewing UI across different devices during development.

## Setup Requirements
1.  **Firebase Setup**: Because this uses Firebase, you must have the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) configured in the respective native directories.
2.  **Environment Variables**: The project expects a `.env` file in the root directory (as it is included in the assets in `pubspec.yaml`). Ensure you create this file and add necessary keys (e.g., Gemini API keys).
3.  **TFLite Models**: The `assets/models/` directory is registered. Ensure your custom TFLite models are placed there for the `tflite_face_detector.dart` to work properly.
