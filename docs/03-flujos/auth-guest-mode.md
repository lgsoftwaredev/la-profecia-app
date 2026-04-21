# Guest y Autenticacion - La Profecia MVP

## 1. Objetivo
Permitir adopcion inmediata mediante guest mode y ofrecer autenticacion como paso de continuidad, no como bloqueo inicial.

## 2. Principio de producto
Primero jugar, luego registrar.

## 3. Flujo recomendado
1. Usuario abre app.
2. Puede iniciar como invitado sin friccion.
3. Juega tutorial y flujo base completo.
4. Se sugiere registro en momentos de valor (guardar progreso, premium, recuperacion).
5. Si decide registrarse, se vincula su progreso permitido.

## 4. Reglas de guest mode
- Tutorial y partida base siempre disponibles.
- No exigir login al abrir la app.
- Mostrar beneficios claros de registro, sin bloquear experiencia central.
- Mantener estado local de partida aislado de autenticacion.

## 5. Reglas de autenticacion
- Supabase Auth como base principal.
- Login social/email segun backlog priorizado.
- Manejo explicito de errores de login y recuperacion.
- Migracion guest -> cuenta con criterios de consistencia de datos.

## 6. Trigger points sugeridos para registro
- Al intentar guardar progreso persistente.
- Al querer restaurar progreso en otro dispositivo.
- Al comprar premium y querer asociar compra.
- Al enviar sugerencias con trazabilidad de usuario.

## 7. Riesgos y mitigacion
- Riesgo: friccion temprana por muro de login.
  Mitigacion: guest first por defecto.
- Riesgo: perdida de datos en transicion guest -> cuenta.
  Mitigacion: reglas de merge y pruebas de migracion.
- Riesgo: flujo inconsistente entre plataformas.
  Mitigacion: casos de uso comunes y validacion QA cruzada.
