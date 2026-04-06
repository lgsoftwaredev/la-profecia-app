# Prisma + Supabase

## 1) Instalar dependencias

```bash
cd supabase
npm install
```

## 2) Configurar conexión

```bash
cp .env.example .env
```

Completa `DATABASE_URL` con la conexión directa de Supabase (puerto `5432`, no pooler).

## 3) Aplicar migraciones a Supabase

```bash
cd supabase
npx prisma migrate deploy
```

## 4) (Opcional) Crear una nueva migración

```bash
cd supabase
npx prisma migrate dev --name <nombre_migracion>
```

## 5) Cargar banco oficial de preguntas y retos

```bash
cd supabase
npm run prisma:seed:content
```
