---
name: flutter-feature
description: Use this skill when implementing or refactoring Flutter screens, widgets, navigation, forms, and feature modules for the La Profecía mobile MVP.
---

# Flutter Feature Skill

## Goal
Implement mobile features in Flutter while preserving architecture, guest mode, and MVP scope.

## Project assumptions
- The app is local-first for gameplay.
- Authentication is secondary to initial app access.
- Gameplay state should not require an online connection to function.
- UI should remain simple and quick.

## Expected workflow
1. Read existing feature structure.
2. Identify presentation, domain, and data boundaries.
3. Implement the smallest complete change.
4. Preserve loading, error, empty, and success states.
5. Validate navigation and game flow manually.

## UI rules
- Keep widgets small and composable.
- Reuse theme and shared components.
- Do not bury gameplay rules inside widget trees.
- Preserve responsive layout for normal phone sizes.

## Deliverable format
Always report:
- files changed
- assumptions made
- risks
- manual verification steps
