# Supabase setup

The app now uses Supabase Auth, Postgres, and Realtime. Start it with your
project URL and anon key:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Create these tables in Supabase and enable Realtime for `shoes`, `cart_items`,
`wishlist`, and `orders`:

- `profiles`: `id` (uuid primary key), `email`, `name`, `photo_url`
- `shoes`: `id`, `name`, `price`, `brand`, `image_url`, `images`, `category`, `rating`, `description`, `sizes`, `color_image_map`, `is_featured`, `created_at`
- `cart_items`: `id`, `user_id`, `shoe_id`, `size`, `color`, `quantity`
- `wishlist`: `user_id`, `shoe_id`
- `orders`: `id`, `user_id`, `items` (jsonb), `total`, `address`, `status`, `created_at`

Row Level Security policies should restrict profiles, cart items, wishlist,
and orders to the authenticated user's `auth.uid()`. The implementation is in
`lib/model/services/supabase_service.dart`.
# shoe_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
