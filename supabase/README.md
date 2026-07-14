# Darzi + Supabase setup

## 1. Remove Firebase (done)
Firebase packages and config have been removed from the project.

## 2. Create a Supabase project
1. Go to https://supabase.com and create a project
2. Open **SQL Editor** → paste and run [`supabase/schema.sql`](../supabase/schema.sql)
3. Copy **Project URL** and **anon public** key from **Settings → API**

## 3. Configure the Flutter app
Edit `.env` in the project root:

```
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

Then restart the app (`flutter run`).

Until keys are set, the app keeps working **offline with Hive**.

## 4. Schema overview

| Table | Purpose |
|-------|---------|
| `shops` | Single dukaan (multi-tenant ready) |
| `profiles` | Auth user → shop + role |
| `staff` | Cutters / stitchers |
| `customers` | Grahak |
| `measurements` | Naap book (`fields` jsonb) |
| `measurement_history` | Naap change log |
| `orders` | Orders + auto `DZ-####` token |
| `payments` | Khata ledger |
| `shop_settings` | Locale / SMTP |

Storage buckets: `customer-photos`, `order-photos`, `measurement-photos`.

RLS policies scope all data to the user's shop via `auth_shop_ids()`.
