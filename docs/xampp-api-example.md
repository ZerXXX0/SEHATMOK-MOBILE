# XAMPP Local API Example

This example is a small PHP backend for XAMPP that matches the Flutter app's current API calls.

The runnable files live in [examples/xampp-api](../examples/xampp-api).

## What it covers

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/profile`
- `PUT /api/profile`
- `GET /api/fridge`
- `POST /api/fridge`
- `PUT /api/fridge/{id}`
- `DELETE /api/fridge/{id}`
- `GET /api/recipes`
- `GET /api/recipes/{id}`
- `POST /api/recommendations`
- `POST /api/ai/generate-recipe`
- `GET /health`

## Setup

1. Copy the files from [examples/xampp-api](../examples/xampp-api) into your XAMPP web root, for example `C:\xampp\htdocs\sehatmok-api`.
2. Import [schema.sql](../examples/xampp-api/schema.sql) into phpMyAdmin.
3. Import [seed.sql](../examples/xampp-api/seed.sql) if you want demo users, fridge items, and recipes.
4. Start Apache and MySQL in XAMPP.
5. Open `http://localhost/sehatmok-api/health` to verify the API is running.

## Flutter emulator URL

For an Android emulator, use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2
```

If your Apache uses a custom port, include it, for example:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Notes

- The example API uses a single PHP front controller plus `.htaccess` rewrite rules.
- The `generate-recipe` and `recommendations` endpoints are sample implementations that return local data from the `recipes` table.
- The current Flutter app expects `user`, `token`, `recipes`, and fridge item shapes that match the models in `lib/models`.
- User IDs are stored as strings so seeded rows and newly registered users use the same shape.
- The demo account from `seed.sql` uses `demo@example.com` and `password123`.
