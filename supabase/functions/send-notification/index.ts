// Supabase Edge Function: send-notification
//
// Invoked by the admin portal (`supabase.functions.invoke('send-notification', ...)`)
// whenever an admin sends a notification. It authenticates to Firebase Cloud
// Messaging with a service account and publishes the message to an FCM **topic**,
// so the mobile app receives it without this backend tracking individual devices.
//
// Topic mapping (the mobile app must subscribe to the matching topic):
//   target = all   -> topic "all"
//   target = group -> topic "group_<target_value>"
//   target = user  -> topic "user_<target_value>"
//
// Required secret (set once):
//   supabase secrets set FCM_SERVICE_ACCOUNT="$(cat service-account.json)"
//
// Deploy with:
//   supabase functions deploy send-notification

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

interface Payload {
  title: string;
  body: string;
  target: "all" | "user" | "group";
  target_value?: string;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id: string;
  token_uri: string;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// FCM topic names allow [a-zA-Z0-9-_.~%]; replace anything else.
function sanitizeTopic(value: string): string {
  return value.trim().replace(/[^a-zA-Z0-9-_.~%]/g, "_");
}

function topicFor(target: string, value: string): string {
  if (target === "user" && value) return `user_${sanitizeTopic(value)}`;
  if (target === "group" && value) return `group_${sanitizeTopic(value)}`;
  return "all";
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

function base64url(input: string | Uint8Array): string {
  const bin = typeof input === "string"
    ? input
    : String.fromCharCode(...input);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// Mint a short-lived OAuth access token for the FCM API from the service account.
async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = base64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: sa.token_uri,
    iat: now,
    exp: now + 3600,
  }));
  const unsigned = `${header}.${claim}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = new Uint8Array(
    await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      new TextEncoder().encode(unsigned),
    ),
  );
  const jwt = `${unsigned}.${base64url(sig)}`;

  const res = await fetch(sa.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!res.ok) {
    throw new Error(`token exchange failed: ${JSON.stringify(data)}`);
  }
  return data.access_token as string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { title, body, target, target_value = "" } =
      (await req.json()) as Payload;

    if (!title || !body) {
      return json({ error: "title and body are required" }, 400);
    }

    const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
    if (!raw) {
      return json({ error: "FCM_SERVICE_ACCOUNT secret is not set" }, 500);
    }
    const sa = JSON.parse(raw) as ServiceAccount;

    const accessToken = await getAccessToken(sa);
    const topic = topicFor(target, target_value);

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            topic,
            notification: { title, body },
            android: { priority: "HIGH" },
            // Extra context for the app if it wants to route on tap.
            data: { target, target_value, title, body },
          },
        }),
      },
    );

    const fcmData = await fcmRes.json();
    if (!fcmRes.ok) {
      return json({ error: "fcm send failed", topic, detail: fcmData }, 502);
    }

    return json({ ok: true, topic, message_id: fcmData.name });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});
