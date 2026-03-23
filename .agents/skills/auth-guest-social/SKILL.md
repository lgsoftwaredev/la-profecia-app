---
name: auth-guest-social
description: Use this skill when implementing guest mode, email auth, Google auth, Apple auth, and profile-linked progress for La Profecía.
---

# Auth Guest and Social Skill

## Goal
Support guest-first onboarding and optional authentication.

## Product rules
- User must be able to try the app without forced login.
- Authentication becomes important for premium, progress, and account continuity.
- Apple review expectations favor allowing access before mandatory login.

## Flow rules
- Guest access first
- Upgrade to authenticated account later
- Preserve user progress linking strategy if applicable
- Email, Google, and Apple sign-in should remain optional unless product decides otherwise

## Avoid
- hard login wall at first launch
- premium purchase logic mixed directly into login screens
- auth-only architecture for core game flow
