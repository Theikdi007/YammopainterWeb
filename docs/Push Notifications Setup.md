# Push Notifications — Website → Mobile (FCM)

How a notification sent from the **admin portal (website)** reaches the **mobile app**.

## Flow

```
Admin portal (website)                Supabase                    Firebase            Mobile app
  Notifications screen  ──invoke──▶  send-notification   ──FCM v1──▶  Cloud      ──push──▶  (subscribed
  (title/body/target)                edge function                   Messaging              to topic)
                          │
                          └── also inserts a row into `notifications` (history log)
```

The website does **not** talk to Firebase directly. It calls the `send-notification`
edge function, which authenticates to FCM with a service account and publishes to a
**topic**. The mobile app receives it by subscribing to that topic — no device-token
table, no per-device tracking.

### Topic mapping

| Portal target | FCM topic            | Mobile app subscribes to |
| ------------- | -------------------- | ------------------------ |
| `all`         | `all`                | `all`                    |
| `group`       | `group_<value>`      | `group_<value>`          |
| `user`        | `user_<value>`       | `user_<value>`           |

Topic names only allow `a-z A-Z 0-9 - _ . ~ %`; any other character (e.g. a space in a
group name) is replaced with `_`. **The mobile app must sanitize the same way.**

---

## What was changed — status: DONE ✅

**Website repo (`yammopaintingweb`):**
- `supabase/functions/send-notification/index.ts` — signs a Firebase service-account JWT,
  gets an OAuth token, and publishes the message to the right FCM topic (with CORS so the
  browser portal can invoke it). `NotificationService.send()` already invokes it.

**Mobile repo (`yammopatinerapp`):**
- `lib/services/push_notification_service.dart` — subscribes to the `all` topic on startup
  and to `user_<id>` for the signed-in user (and unsubscribes on sign-out). Its existing
  FCM token + foreground/background display logic is unchanged.

**Supabase project `ubeuwwkfcizogyssotzu` (already applied):**
- Secret `FCM_SERVICE_ACCOUNT` set from the `painter-50f64` service-account key.
- `send-notification` function deployed (v2+).
- Verified: OAuth token + FCM publish both return success for project `painter-50f64`.

So nothing else is required to go live. To **re-deploy** after editing the function:
`supabase functions deploy send-notification` (CLI is already linked & logged in).

---

## Caveats

- **target = all** → works (every install subscribes to `all`).
- **target = user** → only works if the portal sends `target_value` = the **Supabase auth
  user id** (the same id the mobile app uses for its `user_<id>` topic). If the portal's
  user picker uses a different id (e.g. a `portal_users` row id), user-targeted sends won't
  match — align the ids first.
- **target = group** → the mobile app has no group concept, so no device subscribes to
  `group_*` topics yet. Add `subscribeToTopic('group_<name>')` on mobile if you introduce
  groups.
- The local service-account JSON in the website repo root is no longer needed (the secret
  lives in Supabase) — you can delete it. It's also `.gitignore`d.

---

## Testing

1. Run the mobile app once so it subscribes to `all` (subscription can take a few seconds).
2. Open the website portal → Notifications → send a notification with target **All**.
3. The phone should show it within a few seconds.

### Troubleshooting

- **Nothing arrives:** check the function logs — `supabase functions logs send-notification`.
- `FCM_SERVICE_ACCOUNT secret is not set` → redo step 2.
- `fcm send failed` with `404 / SENDER_ID_MISMATCH` → the service account belongs to a
  different Firebase project than the mobile app. Use the key from the same project the
  mobile app's `google-services.json` points to.
- Portal shows "sent" but no push → the portal logs the history even if the push fails
  (best-effort by design, see `NotificationService.send`). The function logs show the real
  result.
