# Checklist QA MVP - La Profecia

## 1. Objetivo
Asegurar una validacion minima estandar antes de cerrar tareas o generar builds para cliente/stores.

## 2. Validaciones tecnicas obligatorias
- Ejecutar `dart format .`
- Ejecutar `flutter analyze`
- Corregir errores criticos de analisis antes de cierre

## 3. Validaciones funcionales criticas
- Guest mode funciona de punta a punta.
- Tutorial y flujo base jugables sin login obligatorio.
- Transiciones de rondas/turnos no rompen estado.
- Puntajes y cierre de partida consistentes.

## 4. Validaciones de monetizacion
- Contenido premium no visible ni accesible en plan free.
- Compra premium desbloquea correctamente.
- Restaurar compra funciona donde aplique.
- Ads no se muestran a usuarios premium.

## 5. Validaciones de backend
- Auth y sesiones estables en Supabase.
- Persistencia de progreso en escenarios definidos.
- Flujo de sugerencias/moderacion registra estados correctos.
- RLS bloquea operaciones no autorizadas.

## 6. Validaciones de observabilidad
- Eventos clave de analytics se disparan una sola vez por accion esperada.
- Parametros de evento llegan completos.
- Push se recibe en escenarios objetivo sin duplicaciones excesivas.

## 7. Criterio de salida
Una tarea MVP se considera lista cuando cumple validaciones tecnicas, funcionales y de monetizacion sin regresiones en guest mode.
