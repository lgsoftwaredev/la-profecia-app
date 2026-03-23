---
name: moderation-content
description: Use this skill when building the user suggestion flow, admin review workflow, moderation states, and official-content publishing pipeline for La Profecía.
---

# Moderation and Content Skill

## Goal
Implement a minimal but safe content submission pipeline.

## Product rules
- Users can propose new questions or challenges.
- User proposals do not become public automatically.
- Content goes through a review/moderation process in backend.

## Workflow
1. User submits suggestion.
2. Submission stored with pending status.
3. Moderator reviews.
4. Approved items can be transformed into official content.
5. Rejected items remain hidden from players.

## Data guidance
Track:
- author
- mode
- content type
- text
- status
- moderation notes
- timestamps

## Avoid
- direct publish from app
- editing official content from public user flows
