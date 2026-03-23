---
name: freemium-iap-ads
description: Use this skill when implementing premium gating, in-app purchases, ad visibility rules, and free-versus-premium access in La Profecía.
---

# Freemium, IAP and Ads Skill

## Goal
Implement monetization without breaking gameplay clarity.

## Product rules
- Free users access Cielo only.
- Premium users access all levels.
- Premium users do not see ads.
- Premium entitlements must be validated reliably.
- App should be prepared for launch promo pricing and future subscription changes.

## Implementation rules
- Keep entitlement checks centralized.
- Do not duplicate premium logic across many widgets.
- Ads should be shown only at approved interruption points.
- Never show ads to premium users.
- Treat store purchase state and local UI state separately.

## Validation checklist
- free user cannot enter locked premium content
- premium unlock state is respected
- ad suppression works for premium
- purchase restore flow is handled where applicable
