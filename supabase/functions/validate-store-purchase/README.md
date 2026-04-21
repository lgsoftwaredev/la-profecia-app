# validate-store-purchase

Edge Function that validates store purchases and writes entitlement rows into `PremiumAccess`.

## Required secrets

- `SUPABASE_URL`
- `SB_PUBLISHABLE_KEY` (recommended) or `SUPABASE_ANON_KEY` (legacy)
- `SUPABASE_SERVICE_ROLE_KEY`

For App Store real validation:

- `APPLE_SHARED_SECRET`

Optional for local/non-production testing only:

- `IAP_VALIDATION_ALLOW_TEST=true`

When `IAP_VALIDATION_ALLOW_TEST` is enabled, the function trusts the payload and grants a 30-day entitlement. Keep this disabled in production.

## Request payload

```json
{
  "userId": "<uuid>",
  "platform": "APP_STORE|PLAY_STORE",
  "productId": "monthly_premium_id",
  "purchaseId": "optional",
  "transactionDate": "optional",
  "verificationData": "store verification payload",
  "source": "PURCHASE|RESTORE"
}
```
deployar edge functions
supabase secrets set --env-file .env --project-ref hphzjqaesxfnnkulffho

este comando ejecutarlo en la raiz del proyecto "la-profecia-app"
supabase functions deploy validate-store-purchase --project-ref hphzjqaesxfnnkulffho --no-verify-jwt

`--no-verify-jwt` is required when your project uses JWT Signing Keys (ES256), otherwise the
Edge gateway can reject valid tokens with `UNAUTHORIZED_UNSUPPORTED_TOKEN_ALGORITHM` before
your function code runs.

