---
name: game-flow-la-profecia
description: Use this skill when working on La Profecía gameplay flows such as tutorial, game mode setup, rounds, turns, points, level unlocking, final judgment, and local match state.
---

# La Profecía Game Flow Skill

## Goal
Implement the gameplay exactly according to the kickoff MVP, avoiding online multiplayer assumptions.

## Product rules
- The game is local/presential in a single device.
- Main modes:
  - amigos
  - parejas
- Friends mode supports up to 12 friends.
- Couples mode supports 1 or 2 competing couples, up to 4 couples total if the product definition confirms that configuration.
- Levels:
  - Cielo: free
  - Tierra: premium
  - Infierno: premium, unlocks after one round
  - Inframundo: premium, unlocks after two rounds
- Inframundo special rule:
  - if the player does not complete the challenge, they are removed and lose points
- Match flow:
  - select player or pair
  - choose level random or manual
  - show question or challenge
  - validate completion
  - add or subtract points
  - move to next turn
- End of game:
  - final judgment
  - winner and loser
  - final punishment from platform or from group text

## State modeling guidance
Distinguish clearly between:
- session setup state
- round progression state
- score state
- unlock progression within the active match
- final result state

## Avoid
- network dependency for gameplay
- online room logic
- chat systems
- realtime sync between devices

## When editing logic
Always verify:
- free vs premium level access
- unlock timing
- penalty rules
- turn progression
- end-game flow
