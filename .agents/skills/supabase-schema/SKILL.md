---
name: supabase-schema
description: Use this skill when designing or editing Supabase tables, migrations, RLS policies, seeds, and admin-facing content persistence for La Profecía.
---

# Supabase Schema Skill

## Goal
Create a minimal but scalable relational model for the MVP.

## Domain priorities
The schema must support:
- user profile and progress
- premium entitlements
- administrable questions and challenges
- separation by mode (amigos vs parejas)
- level metadata
- user suggestions and moderation

## Suggested MVP schema
Core tables:
- profiles
- levels
- content_items
- content_mode_map
- user_submissions
- submission_reviews
- premium_entitlements
- user_stats
- game_results_summary

## Modeling rules
- Keep gameplay session persistence optional if the match is mostly local.
- Persist only what is valuable for history, premium, moderation, and analytics support.
- Separate official content from user-submitted content.
- Use enum-like constraints or lookup tables for mode, level, type, and moderation status.

## RLS guidance
- Users can read active public content.
- Users can insert their own submissions.
- Users cannot auto-publish submissions.
- Admin/moderator roles control approval.
- Premium access checks must be explicit.

## Avoid
- storing everything as JSON blobs
- premature optimization for phase 2 online multiplayer
