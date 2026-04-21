# Supabase para Desarrollo (MVP)

## 1. Contexto actual
El MVP consume Supabase remoto mediante `SUPABASE_URL` y `SUPABASE_ANON_KEY` desde `apps/mobile/.env`.

## 2. Objetivo de este documento
Definir como preparar y validar la capa de base de datos para desarrollo, aplicando migraciones y seed de contenido.

## 3. Prerrequisitos
- Node.js `>=20.19.0` (segun `supabase/package.json`).
- Acceso a un proyecto Supabase.
- `DATABASE_URL` directa (puerto `5432`, no pooler) para Prisma.

## 4. Preparar carpeta `supabase`
```bash
cd /ruta/al/proyecto/la-profecia-app/supabase
npm install
cp .env.example .env
```

Completar `DATABASE_URL` en `supabase/.env`.

## 5. Aplicar migraciones
```bash
cd /ruta/al/proyecto/la-profecia-app/supabase
npm run prisma:migrate:deploy
```

## 6. Cargar contenido base
```bash
cd /ruta/al/proyecto/la-profecia-app/supabase
npm run prisma:seed:content
```

## 7. Conectar la app movil
En `apps/mobile/.env` configurar:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Luego ejecutar la app (`fvm flutter run`) y validar login/lectura de contenido.

## 8. Verificacion funcional minima
- La app inicia sin error de Supabase.
- Guest mode funciona aunque no haya sesion autenticada.
- Si hay login, la sesion queda activa sin errores de permisos.
- Flujos de sugerencias/contenido no fallan por RLS mal configurada.

## 9. Nota sobre stack local completo
Actualmente el repo no incluye `supabase/config.toml` para `supabase start`.
Por eso, en MVP se recomienda trabajar contra proyecto Supabase remoto de desarrollo y manejar esquema con Prisma/migraciones.
