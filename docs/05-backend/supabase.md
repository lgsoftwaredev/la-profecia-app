# Backend Supabase - La Profecia MVP

## 1. Rol de Supabase en el MVP
Supabase es el backend principal para autenticacion, persistencia de progreso clave, contenido administrable y flujo inicial de moderacion.

## 2. Capacidades cubiertas
- Auth (registro/login/sesion)
- Base de datos para progreso y contenido
- Politicas de acceso (RLS)
- Persistencia de sugerencias y estados de moderacion

## 3. Dominios de datos
### A. Usuario y progreso
- perfil basico
- progreso de niveles
- estado premium (si aplica en backend)

### B. Contenido oficial
- catalogo de contenido publicable
- versiones/estados de contenido

### C. Sugerencias y moderacion
- sugerencias creadas por usuarios
- estado pendiente/aprobada/rechazada
- metadatos de revision

## 4. Reglas de seguridad
- Activar RLS en tablas sensibles.
- Permisos por rol minimizados (principio de minimo privilegio).
- Separar permisos de lectura publica vs edicion administrativa.
- Auditar operaciones criticas de publicacion/moderacion.

## 5. Integracion con la app
- UI no consulta Supabase directo.
- Repositorios/servicios de data encapsulan acceso.
- DTOs remotos se mapean a modelos de dominio.
- Manejo explicito de errores de red, auth y permisos.

## 6. Entregables tecnicos esperados
- esquema de tablas MVP
- migraciones versionadas
- politicas RLS revisadas
- contratos de repositorio por feature

## 7. Fuera de alcance de backend en esta fase
- infraestructura para multiplayer realtime complejo
- ranking global de alta concurrencia
- backoffice corporativo completo
