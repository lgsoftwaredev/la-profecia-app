# La Profecia - Documentacion del MVP

Este repositorio contiene la base del MVP movil de **La Profecia**.

## Objetivo del MVP
Entregar una app Flutter para Android e iOS enfocada en juego local/presencial en un solo dispositivo, con base freemium, backend en Supabase y publicacion en tiendas.

## Paquete de documentos para cliente

1. [Quickstart Local](docs/00-setup/quickstart-local.md)
2. [Variables y Entorno](docs/00-setup/variables-entorno.md)
3. [Supabase para Desarrollo](docs/00-setup/supabase-local.md)
4. [Troubleshooting de Arranque](docs/00-setup/troubleshooting.md)
5. [Alcance MVP](docs/01-producto/alcance-mvp.md)
6. [Arquitectura General](docs/02-arquitectura/arquitectura-general.md)
7. [Estado y Persistencia](docs/02-arquitectura/estado-y-persistencia.md)
8. [Game Flow](docs/03-flujos/game-flow.md)
9. [Guest y Autenticacion](docs/03-flujos/auth-guest-mode.md)
10. [Freemium, IAP y Ads](docs/04-monetizacion/freemium-iap-ads.md)
11. [Backend Supabase](docs/05-backend/supabase.md)
12. [Analytics y Push](docs/06-observabilidad/analytics-push.md)
13. [Checklist QA MVP](docs/07-qa/checklist-mvp.md)
14. [Publicacion en Tiendas](docs/08-release/publicacion-tiendas.md)

## Resumen ejecutivo
- Plataforma: Flutter (Android/iOS).
- Modalidad principal: juego local/presencial.
- Modelo: freemium con premium por in-app purchases.
- Backend: Supabase (auth + persistencia + moderacion inicial).
- Integraciones: FCM (push), Google Analytics (eventos basicos), AdMob (ads en plan free).

## Fuera de alcance en esta fase
- Multiplayer online en tiempo real.
- Matchmaking abierto entre desconocidos.
- Sistemas complejos de sincronizacion entre dispositivos.
- Plataforma administrativa extensa fuera de necesidades MVP.

## Estado del documento
Version 1.0 - preparado para presentacion a cliente.
