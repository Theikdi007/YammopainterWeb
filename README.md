# Yammo Admin Portal (Flutter Web)

A Flutter **web** admin portal for managing the **AR Drawing**, **Painting** and
**Puzzle** mobile apps: SVG assets, users, notifications, rewards and the
community feed. Built per `docs/Detailed Flutter Admin Portal Website
Development Workflow.md`.

- **State management:** GetX (`Get.put`, `Rx`/`Obx`, `Get.snackbar`, routing)
- **Backend:** Supabase (Auth, Postgres, Storage, Edge Functions)
- **Design system:** Google Fonts (Poppins) + light/dark `ThemeData`
- **Responsive:** Desktop / Tablet / Mobile via `MediaQuery` breakpoints

## Demo mode

The app runs **without a backend** out of the box. When `.env` has no real
Supabase credentials it serves in-memory mock data so every screen is browsable.

> Demo login: **admin@yammo.app** / **admin123**

## Quick start

```bash
flutter pub get
flutter run -d chrome          # or: flutter run -d web-server
```

## Connecting Supabase

1. Create a project at https://supabase.com.
2. Run `supabase/schema.sql` in the SQL editor (creates tables, the
   `svg_assets` storage bucket and RLS policies).
3. (Optional) Deploy the notification function:
   `supabase functions deploy send-notification`.
4. Put your credentials in `.env` (copy from `.env.example`):

   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

   Credentials can also be passed at build time:
   `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

Once real credentials are present the demo banner disappears and all CRUD runs
against Supabase.

## Features (per workflow)

| Workflow section | Where |
|---|---|
| 3.1 Admin Login & Dashboard | `screens/auth/`, `screens/dashboard_screen.dart` |
| 3.2 SVG Asset Management (upload/list/search/edit/delete/preview) | `screens/svg/` |
| 3.3 User Management (CRUD, roles) | `screens/users/` |
| 3.4 Notification System (create/send/history) | `screens/notifications/` |
| 3.5 Rewards System (CRUD, on/off, user tracking) | `screens/rewards/` |
| 3.6 Community Post Management (moderation, detail) | `screens/posts/` |

## Project structure

```
lib/
  app/            routes, bindings, middlewares, sidebar nav items
  core/           Supabase config, mock data store, UI helpers
  models/         data models (fromMap/toInsert)
  services/       Supabase + demo-mode data access (one per feature)
  controllers/    GetX controllers (one per feature)
  screens/        auth, dashboard shell, and feature screens
  widgets/        reusable UI (text fields, cards, tables, chips…)
  theme/          colors, fonts, light/dark ThemeData, theme controller
  layout/         responsive breakpoints
supabase/         schema.sql + edge function
```

## Testing

```bash
flutter analyze
flutter test
```

## Build & deploy (Firebase Hosting)

`firebase.json` and `.firebaserc` are included. SPA rewrites send all routes to
`index.html`; hashed assets are cached for a year while `index.html` and the
service worker are never cached.

One-time setup:

```bash
npm install -g firebase-tools     # if not installed
firebase login
# put your project id in .firebaserc, or run:
firebase use --add
```

Build and deploy:

```bash
flutter build web --release
firebase deploy --only hosting
```

Add a custom domain from the Firebase console → Hosting → Add custom domain.
If you serve from a sub-path instead, build with `--base-href=/your-path/`.

> Other hosts (Netlify, Vercel, Supabase static hosting) also work — just point
> them at `build/web/` with an SPA fallback to `index.html`.
