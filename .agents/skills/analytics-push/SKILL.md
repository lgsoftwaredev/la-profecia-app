---
name: analytics-push
description: Use this skill when adding Firebase Cloud Messaging, analytics events, conversion tracking, and basic engagement reminders for La Profecía.
---

# Analytics and Push Skill

## Goal
Add only the minimum useful instrumentation for the MVP.

## Product rules
- Push notifications are basic reminders.
- Analytics is basic and focused on adoption and conversion.
- Avoid over-instrumenting the MVP.

## Suggested events
- tutorial_started
- tutorial_completed
- match_started
- match_finished
- premium_paywall_viewed
- premium_purchase_started
- premium_purchase_completed
- suggestion_submitted

## Push guidance
- reminders in strategic days and times
- no complex segmentation in MVP
- keep opt-in and permission handling clean

## Avoid
- event spam
- adding analytics to every tiny interaction
