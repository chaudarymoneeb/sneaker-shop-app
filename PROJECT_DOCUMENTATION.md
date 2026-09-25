# Shoe App Project Documentation

## 1. Project Overview
This project is a Flutter shopping app focused on shoe products. It follows a Model-View-Controller (MVC)-style structure with separate folders for models, controllers, and view screens.

The current app setup includes:
- Multi-provider state management using `provider`
- MVC-based organization in `lib/model`, `lib/controller`, and `lib/view`
- Product data models and service layer for Supabase-related logic
- App theme management
- Asset image support under `assets/images`

---

## 2. Project Structure

### Root
- `lib/` – application source code
- `assets/` – app assets
- `test/` – widget tests
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` – platform project folders
- `pubspec.yaml` – package and dependency configuration

### MVC Modules

#### Model
- `lib/model/shoe_model.dart` – product model
- `lib/model/cart_item_model.dart` – cart item structure
- `lib/model/user_model.dart` – user profile model
- `lib/model/services/auth_service.dart` – auth logic/service layer
- `lib/model/services/supabase_service.dart` – Supabase data service layer

#### Controller
- `lib/controller/auth_provider.dart` – authentication state and user session
- `lib/controller/shoe_provider.dart` – shoe/product state
- `lib/controller/cart_provider.dart` – cart state management
- `lib/controller/wishlist_provider.dart` – wishlist state management
- `lib/controller/theme_provider.dart` – dark/light mode state

#### View
- `lib/view/splash/splash_screen.dart`
- `lib/view/onboarding/onboarding_screen.dart`
- `lib/view/auth/auth_screen.dart`
- `lib/view/home/home_screen.dart`
- `lib/view/product/product_screen.dart`
- `lib/view/cart/cart_screen.dart`
- `lib/view/wishlist/wishlist_screen.dart`
- `lib/view/profile/profile_screen.dart`
- `lib/view/widgets/shoe_card.dart`
- `lib/view/widgets/custom_text_field.dart`
- `lib/view/widgets/animated_primary_button.dart`

---

## 3. App Entry
The app entry point is:
- `lib/main.dart`

It sets up the app providers using `MultiProvider` and provides application-level state for:
- auth
- shoes
- cart
- wishlist
- theme

---

## 4. State and Architecture

### Model layer
The model layer holds the data objects:
- `ShoeModel`
- `CartItemModel`
- `UserModel`

This layer is intended to represent the data structure and service contracts, not UI behavior.

### Controller layer
The controller layer is responsible for logic and state change handling. It uses `ChangeNotifier` classes and updates UI through provider listeners.

### View layer
The view layer contains screens and UI widgets. It reads state from providers and calls controller methods on user interaction.

This separation keeps UI code separate from data/service logic.

---

## 5. Assets and Images
The project contains an assets folder with image files used for app content, likely e-commerce or shoe product images.

### Asset folder
- `assets/images/`

### Available images
The image set includes numbered product shots such as:
- `0.jpg`
- `01.jpg`
- `02.jpg`
- `03.jpg`
- `04.jpg`
- `05.jpg`
- `06.jpg`
- `07.jpg`
- `08.jpg`
- `09.jpg`
- `1.jpg`
- `10.jpg`
- `11.jpg`
- `12.jpg`
- `13.jpg`
- `14.jpg`
- `15.jpg`
- `16.jpg`
- `2.jpg`
- `21.jpg`
- `3.jpg`
- `4.jpg`
- `5.jpg`
- `6.jpg`
- `7.jpg`
- `8.jpg`
- `9.jpg`

### Asset configuration note
The `pubspec.yaml` file currently has the asset declaration commented out, so these images are not yet registered with Flutter.

To use them, add something like this to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

If you want to load only specific files:

```yaml
flutter:
  assets:
    - assets/images/0.jpg
    - assets/images/1.jpg
    - assets/images/2.jpg
```

---

## 6. Dependencies
Current dependencies in `pubspec.yaml` include:
- `flutter`
- `provider: ^6.1.2`
- `cupertino_icons: ^1.0.8`

Development dependencies:
- `flutter_test`
- `flutter_lints`

---

## 7. Current State of the Project
The codebase has already been organized into the requested MVC-style structure and follows the expected folders:
- `lib/model`
- `lib/controller`
- `lib/view`

The structure is ready for further expansion with feature-specific screens, services, and reusable UI widgets.

---

## 8. Suggested Next Improvements
1. Register all images under `assets/images` in `pubspec.yaml`.
2. Configure Supabase Auth, Postgres tables, RLS policies, and Realtime before going live.
3. Replace the demo app shell in `lib/main.dart` with full splash/auth/home navigation.
4. Move reusable product card and form components into concrete screen implementations.
5. Add unit tests for providers and model logic.

---

## 9. Summary
This project is a Flutter shoe app with a clear MVC-based code organization, provider-driven state, and a rich set of product images already placed in the assets folder. The next critical step for full UI functionality is to register the images in the Flutter asset list and continue wiring the screens to the providers and real product data.
