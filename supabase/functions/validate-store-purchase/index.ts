import { createClient } from "npm:@supabase/supabase-js@2";

type PurchasePayload = {
  userId?: string;
  platform?: "APP_STORE" | "PLAY_STORE" | "MANUAL";
  productId?: string;
  purchaseId?: string | null;
  transactionDate?: string | null;
  verificationData?: string;
  source?: "PURCHASE" | "RESTORE";
};

type ValidationResult = {
  valid: boolean;
  expiresAt: string | null;
  transactionId: string | null;
  reason?: string;
};

function logInfo(requestId: string, step: string, meta: Record<string, unknown> = {}) {
  console.log(JSON.stringify({ level: "info", requestId, step, ...meta }));
}

function logWarn(requestId: string, step: string, meta: Record<string, unknown> = {}) {
  console.warn(JSON.stringify({ level: "warn", requestId, step, ...meta }));
}

function logError(requestId: string, step: string, meta: Record<string, unknown> = {}) {
  console.error(JSON.stringify({ level: "error", requestId, step, ...meta }));
}

function safePayloadLog(payload: PurchasePayload): Record<string, unknown> {
  return {
    userId: payload.userId ?? null,
    platform: payload.platform ?? null,
    productId: payload.productId ?? null,
    purchaseId: payload.purchaseId ?? null,
    transactionDate: payload.transactionDate ?? null,
    source: payload.source ?? null,
    verificationDataLength: payload.verificationData?.length ?? 0,
  };
}

function badRequest(message: string) {
  return new Response(JSON.stringify({ success: false, error: message }), {
    status: 400,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (request: Request) => {
  const requestId = request.headers.get("x-request-id") ?? crypto.randomUUID();
  const startedAt = Date.now();
  logInfo(requestId, "request_received", {
    method: request.method,
    pathname: new URL(request.url).pathname,
    hasAuthorization: Boolean(request.headers.get("Authorization")),
    hasApiKey: Boolean(request.headers.get("apikey")),
    userAgent: request.headers.get("user-agent") ?? null,
    xClientInfo: request.headers.get("x-client-info") ?? null,
  });

  if (request.method != "POST") {
    logWarn(requestId, "invalid_method", { method: request.method });
    return new Response("Method Not Allowed", { status: 405 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !supabaseServiceRoleKey) {
    logError(requestId, "missing_server_secrets", {
      hasSupabaseUrl: Boolean(supabaseUrl),
      hasServiceRole: Boolean(supabaseServiceRoleKey),
    });
    return new Response(
      JSON.stringify({
        success: false,
        error: "Supabase secrets are not configured on function environment.",
      }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  const requestApiKey = request.headers.get("apikey") ??
    Deno.env.get("SB_PUBLISHABLE_KEY") ??
    Deno.env.get("SUPABASE_ANON_KEY") ??
    "";
  if (!requestApiKey) {
    logWarn(requestId, "missing_apikey");
    return new Response(
      JSON.stringify({ success: false, error: "Missing API key." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  const authClient = createClient(supabaseUrl, requestApiKey, {
    global: { headers: { Authorization: request.headers.get("Authorization") ?? "" } },
  });
  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  const authHeader = request.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!jwt) {
    logWarn(requestId, "missing_bearer_token");
    return new Response(
      JSON.stringify({ success: false, error: "Unauthorized" }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  let authUserId: string | null = null;
  try {
    const { data: authData, error: authError } = await authClient.auth.getUser(jwt);
    if (authError != null || !authData.user) {
      logWarn(requestId, "auth_get_user_failed", {
        authError: authError?.message ?? "unknown_auth_error",
      });
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }
    authUserId = authData.user.id;
    logInfo(requestId, "auth_user_resolved", { authUserId });
  } catch (_) {
    logError(requestId, "auth_get_user_exception");
    return new Response(
      JSON.stringify({ success: false, error: "Unauthorized" }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }
  if (!authUserId) {
    logWarn(requestId, "auth_user_missing_after_get_user");
    return new Response(
      JSON.stringify({ success: false, error: "Unauthorized" }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  let payload: PurchasePayload;
  try {
    payload = (await request.json()) as PurchasePayload;
  } catch (_) {
    logWarn(requestId, "invalid_json_body");
    return badRequest("Invalid JSON body.");
  }
  logInfo(requestId, "payload_parsed", safePayloadLog(payload));
  if (!payload.platform || !payload.productId || !payload.verificationData) {
    logWarn(requestId, "payload_missing_required_fields", safePayloadLog(payload));
    return badRequest("platform, productId and verificationData are required.");
  }
  if (payload.userId && payload.userId != authUserId) {
    logWarn(requestId, "payload_user_mismatch", {
      payloadUserId: payload.userId,
      authUserId,
    });
    return badRequest("payload user does not match authenticated user.");
  }

  const validation = await validateWithStore(payload);
  logInfo(requestId, "store_validation_result", {
    valid: validation.valid,
    reason: validation.reason ?? null,
    expiresAt: validation.expiresAt,
    transactionId: validation.transactionId,
  });
  if (!validation.valid) {
    logWarn(requestId, "store_validation_failed", {
      reason: validation.reason ?? null,
    });
    return new Response(
      JSON.stringify({
        success: false,
        error: validation.reason ?? "Store validation failed.",
      }),
      { status: 422, headers: { "Content-Type": "application/json" } },
    );
  }

  const { data: productRows } = await adminClient
    .from("PremiumProduct")
    .select("id")
    .eq("storeProductId", payload.productId)
    .eq("platform", payload.platform)
    .limit(1);

  const productId = productRows != null && productRows.length > 0
    ? productRows[0]["id"] as string
    : null;
  logInfo(requestId, "product_lookup_done", {
    hasMatchedProduct: productId != null,
    productId,
  });

  await adminClient.from("PremiumAccess").insert({
    userId: authUserId,
    productId,
    platform: payload.platform,
    status: "ACTIVE",
    startedAt: new Date().toISOString(),
    expiresAt: validation.expiresAt,
    originalTransactionId: validation.transactionId,
  });
  logInfo(requestId, "premium_access_inserted", {
    authUserId,
    productId,
    platform: payload.platform,
    elapsedMs: Date.now() - startedAt,
  });

  return new Response(
    JSON.stringify({
      success: true,
      premium: true,
      expiresAt: validation.expiresAt,
    }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});

async function validateWithStore(payload: PurchasePayload): Promise<ValidationResult> {
  const allowTestBypass = Deno.env.get("IAP_VALIDATION_ALLOW_TEST") == "true";
  if (allowTestBypass) {
    return {
      valid: true,
      expiresAt: addDaysUtc(30).toISOString(),
      transactionId: payload.purchaseId ?? null,
    };
  }

  if (payload.platform == "APP_STORE") {
    return await validateAppStore(payload);
  }

  if (payload.platform == "PLAY_STORE") {
    return {
      valid: false,
      expiresAt: null,
      transactionId: payload.purchaseId ?? null,
      reason:
        "Google Play validation is not configured yet. Set IAP_VALIDATION_ALLOW_TEST=true for non-production testing.",
    };
  }

  return {
    valid: false,
    expiresAt: null,
    transactionId: payload.purchaseId ?? null,
    reason: "Unsupported platform.",
  };
}

async function validateAppStore(payload: PurchasePayload): Promise<ValidationResult> {
  const sharedSecret = Deno.env.get("APPLE_SHARED_SECRET") ?? "";
  if (!sharedSecret) {
    return {
      valid: false,
      expiresAt: null,
      transactionId: payload.purchaseId ?? null,
      reason: "APPLE_SHARED_SECRET is not configured.",
    };
  }

  const verificationData = payload.verificationData ?? "";
  const body = {
    "receipt-data": verificationData,
    "password": sharedSecret,
    "exclude-old-transactions": true,
  };

  const production = await fetch("https://buy.itunes.apple.com/verifyReceipt", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const productionJson = await production.json();
  
  logInfo('requestId',"apple_validation_response", {
    status: productionJson.status ?? null,
    hasLatestReceiptInfo: Array.isArray(productionJson.latest_receipt_info,
    ),
    bodys:body

  });
  if (productionJson.status == 21007) {
    return await validateAppStoreAgainstSandbox(body, payload);
  }
  return parseAppleValidation(productionJson, payload);
}

async function validateAppStoreAgainstSandbox(
  body: Record<string, unknown>,
  payload: PurchasePayload,
): Promise<ValidationResult> {
  const response = await fetch("https://sandbox.itunes.apple.com/verifyReceipt", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const json = await response.json();
  return parseAppleValidation(json, payload);
}

function parseAppleValidation(
  appleResponse: Record<string, unknown>,
  payload: PurchasePayload,
): ValidationResult {
  const status = Number(appleResponse.status ?? -1);
  if (status != 0) {
    return {
      valid: false,
      expiresAt: null,
      transactionId: payload.purchaseId ?? null,
      reason: `Apple returned status ${status}.`,
    };
  }

  const latest = Array.isArray(appleResponse.latest_receipt_info)
    ? appleResponse.latest_receipt_info
    : [];
  const matched = latest.find((entry) =>
    typeof entry == "object" &&
    entry != null &&
    (entry as Record<string, unknown>).product_id == payload.productId
  ) as Record<string, unknown> | undefined;

  if (!matched) {
    return {
      valid: false,
      expiresAt: null,
      transactionId: payload.purchaseId ?? null,
      reason: "No matching product found in Apple receipt.",
    };
  }

  const expiresMsRaw = matched.expires_date_ms;
  const expiresMs = Number(expiresMsRaw ?? "0");
  if (!expiresMs || Number.isNaN(expiresMs)) {
    return {
      valid: false,
      expiresAt: null,
      transactionId: String(matched.original_transaction_id ?? payload.purchaseId ?? ""),
      reason: "Apple receipt does not contain expires_date_ms.",
    };
  }

  const expiresAt = new Date(expiresMs);
  if (expiresAt.getTime() <= Date.now()) {
    return {
      valid: false,
      expiresAt: expiresAt.toISOString(),
      transactionId: String(matched.original_transaction_id ?? payload.purchaseId ?? ""),
      reason: "Subscription is expired.",
    };
  }

  return {
    valid: true,
    expiresAt: expiresAt.toISOString(),
    transactionId: String(matched.original_transaction_id ?? payload.purchaseId ?? ""),
  };
}

function addDaysUtc(days: number): Date {
  const now = new Date();
  now.setUTCDate(now.getUTCDate() + days);
  return now;
}
