# AGENTS.md

## Propósito
Este directorio contiene schema, migraciones, seeds y políticas de Supabase para La Profecía.

## Reglas
- Modelar primero el MVP local actual, no la fase futura online.
- Preferir tablas relacionales claras.
- Mantener trazabilidad para contenido y moderación.
- Usar Row Level Security cuando aplique.
- No exponer contenido premium sin checks explícitos.
- Mantener seeds reproducibles para preguntas, retos y niveles.

## Entidades esperadas
- profiles
- game_modes
- levels
- challenge_categories
- challenges
- questions
- user_submissions
- submission_reviews
- purchases o premium_access
- user_stats
- game_history_summary

## Evitar
- esquema sobrepensado para tiempo real
- triggers innecesarios
- policies demasiado abiertas
