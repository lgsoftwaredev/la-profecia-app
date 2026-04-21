# Alcance MVP - La Profecia

## 1. Objetivo de negocio
Lanzar una primera version comercialmente valida que permita jugar de forma local/presencial, medir uso real y habilitar monetizacion basica sin bloquear la adopcion inicial.

## 2. Objetivo de producto
Construir una experiencia de juego fluida en un unico dispositivo, con onboarding rapido, guest mode y camino gradual hacia registro y compra premium.

## 3. Prioridades del MVP
1. Experiencia local de juego fluida.
2. Estructura tecnica escalable.
3. Monetizacion basica (premium + anuncios).
4. Publicacion en tiendas.

## 4. Incluye en esta fase
- App Flutter para Android e iOS.
- Juego local/presencial para grupos en un dispositivo.
- Modos base de juego definidos en kickoff.
- Flujo de tutorial y juego completo (rondas, turnos, puntajes, juicio final).
- Guest mode para iniciar sin login.
- Registro opcional para guardar progreso y recuperar cuenta.
- Backend Supabase para auth y persistencia clave.
- Contenido administrable y flujo inicial de sugerencias/moderacion.
- Integracion de Analytics basico, FCM y monetizacion freemium.
- Preparacion y checklist para publicacion en stores.

## 5. No incluye en esta fase
- Multiplayer online en tiempo real.
- Matchmaking entre jugadores desconocidos.
- Chat, ranking global complejo o features sociales avanzadas.
- Sincronizacion en vivo entre multiples dispositivos durante la partida.
- Backoffice grande con workflows empresariales complejos.

## 6. Criterios de exito
- Un grupo puede iniciar y completar partidas sin friccion alta.
- El flujo guest funciona de punta a punta.
- El contenido premium no queda expuesto por error en cuentas free.
- Eventos basicos permiten medir onboarding, retencion inicial y conversion.
- El build pasa validaciones tecnicas minimas para release.

## 7. Riesgos controlados
- Riesgo de alcance: mitigado limitando online realtime para fase 2.
- Riesgo de arquitectura: mitigado con separacion feature-first y capas.
- Riesgo de monetizacion: mitigado con reglas claras de gating.
- Riesgo de adopcion: mitigado con ingreso sin login obligatorio.

## 8. Entregables cliente
- Documento de alcance.
- Documento de arquitectura.
- Documento de flujos de juego y autenticacion.
- Documento de monetizacion.
- Documento de backend e integraciones.
- Checklist de QA y release.
