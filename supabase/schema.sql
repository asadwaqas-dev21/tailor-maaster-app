-- =============================================================================
-- Darzi — Supabase schema (single-shop tailor management)
-- Run this in the Supabase SQL Editor (Dashboard → SQL → New query)
-- =============================================================================

-- Extensions
create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- Enums
-- -----------------------------------------------------------------------------
do $$ begin
  create type gender_type as enum ('male', 'female');
exception when duplicate_object then null; end $$;

do $$ begin
  create type order_status as enum (
    'pending', 'cutting', 'stitching', 'ready', 'delivered'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_status as enum ('unpaid', 'partial', 'paid');
exception when duplicate_object then null; end $$;

do $$ begin
  create type staff_role as enum (
    'cutter', 'stitcher', 'finisher', 'delivery'
  );
exception when duplicate_object then null; end $$;

-- -----------------------------------------------------------------------------
-- Shops (multi-tenant ready; one row per dukaan)
-- -----------------------------------------------------------------------------
create table if not exists shops (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid references auth.users(id) on delete set null,
  name          text not null,
  name_ur       text,
  phone         text,
  address       text,
  city          text default 'Pakistan',
  currency_code text not null default 'PKR',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Profiles (links auth.users → shop + role)
-- -----------------------------------------------------------------------------
create table if not exists profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  shop_id     uuid references shops(id) on delete set null,
  full_name   text,
  phone       text,
  role        text not null default 'owner'
                check (role in ('owner', 'stitcher', 'staff')),
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Staff
-- -----------------------------------------------------------------------------
create table if not exists staff (
  id          uuid primary key default gen_random_uuid(),
  shop_id     uuid not null references shops(id) on delete cascade,
  name        text not null,
  phone       text not null,
  role        staff_role not null default 'stitcher',
  is_active   boolean not null default true,
  image_url   text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists staff_shop_idx on staff(shop_id);

-- -----------------------------------------------------------------------------
-- Customers (Grahak)
-- -----------------------------------------------------------------------------
create table if not exists customers (
  id          uuid primary key default gen_random_uuid(),
  shop_id     uuid not null references shops(id) on delete cascade,
  name        text not null,
  phone       text not null,
  email       text,
  address     text,
  gender      gender_type not null default 'male',
  notes       text,
  image_url   text,
  is_regular  boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists customers_shop_idx on customers(shop_id);
create index if not exists customers_phone_idx on customers(shop_id, phone);
create index if not exists customers_name_idx on customers(shop_id, name);

-- -----------------------------------------------------------------------------
-- Measurements (Naap Book)
-- fields: jsonb map of key → numeric inches, e.g. {"lambai": 42, "baazu": 24.5}
-- -----------------------------------------------------------------------------
create table if not exists measurements (
  id           uuid primary key default gen_random_uuid(),
  shop_id      uuid not null references shops(id) on delete cascade,
  customer_id  uuid not null references customers(id) on delete cascade,
  category     text not null,
  fields       jsonb not null default '{}'::jsonb,
  photo_urls   text[] not null default '{}',
  notes        text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists measurements_customer_idx
  on measurements(customer_id);
create index if not exists measurements_shop_idx
  on measurements(shop_id);

-- Optional audit trail for naap changes (history dekhein)
create table if not exists measurement_history (
  id              uuid primary key default gen_random_uuid(),
  measurement_id  uuid not null references measurements(id) on delete cascade,
  shop_id         uuid not null references shops(id) on delete cascade,
  customer_id     uuid not null references customers(id) on delete cascade,
  category        text not null,
  change_summary  text not null,
  fields_before   jsonb,
  fields_after    jsonb,
  created_at      timestamptz not null default now()
);

create index if not exists measurement_history_customer_idx
  on measurement_history(customer_id);

-- -----------------------------------------------------------------------------
-- Orders
-- token_code: human slip id e.g. DZ-1042
-- -----------------------------------------------------------------------------
create table if not exists orders (
  id                    uuid primary key default gen_random_uuid(),
  shop_id               uuid not null references shops(id) on delete cascade,
  customer_id           uuid not null references customers(id) on delete restrict,
  measurement_id        uuid references measurements(id) on delete set null,
  token_code            text not null,
  garment_type          text not null,
  fabric_details        text,
  design_notes          text,
  quantity              int not null default 1 check (quantity > 0),
  total_amount          numeric(12,2) not null default 0,
  advance_amount        numeric(12,2) not null default 0,
  status                order_status not null default 'pending',
  payment_status        payment_status not null default 'unpaid',
  is_rush               boolean not null default false,
  order_date            date not null default current_date,
  delivery_date         date not null,
  photo_urls            text[] not null default '{}',
  assigned_staff_id     uuid references staff(id) on delete set null,
  stitching_cost        numeric(12,2) not null default 0,
  is_stitcher_paid      boolean not null default false,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint orders_advance_lte_total check (advance_amount <= total_amount)
);

create unique index if not exists orders_token_shop_uidx
  on orders(shop_id, token_code);
create index if not exists orders_shop_status_idx on orders(shop_id, status);
create index if not exists orders_customer_idx on orders(customer_id);
create index if not exists orders_delivery_idx on orders(shop_id, delivery_date);

-- Auto token: DZ-1001, DZ-1002, …
create or replace function generate_order_token()
returns trigger
language plpgsql
as $$
declare
  next_n int;
begin
  if new.token_code is null or new.token_code = '' then
    select coalesce(max(
      nullif(regexp_replace(token_code, '\D', '', 'g'), '')::int
    ), 1000) + 1
    into next_n
    from orders
    where shop_id = new.shop_id;

    new.token_code := 'DZ-' || next_n::text;
  end if;
  return new;
end;
$$;

drop trigger if exists orders_token_trg on orders;
create trigger orders_token_trg
  before insert on orders
  for each row execute function generate_order_token();

-- Keep payment_status in sync with amounts
create or replace function sync_payment_status()
returns trigger
language plpgsql
as $$
begin
  if new.advance_amount <= 0 then
    new.payment_status := 'unpaid';
  elsif new.advance_amount >= new.total_amount then
    new.payment_status := 'paid';
  else
    new.payment_status := 'partial';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists orders_payment_trg on orders;
create trigger orders_payment_trg
  before insert or update of total_amount, advance_amount on orders
  for each row execute function sync_payment_status();

-- -----------------------------------------------------------------------------
-- Payments ledger (khata)
-- -----------------------------------------------------------------------------
create table if not exists payments (
  id           uuid primary key default gen_random_uuid(),
  shop_id      uuid not null references shops(id) on delete cascade,
  order_id     uuid not null references orders(id) on delete cascade,
  customer_id  uuid not null references customers(id) on delete cascade,
  amount       numeric(12,2) not null check (amount > 0),
  method       text default 'cash',
  note         text,
  paid_at      timestamptz not null default now(),
  created_at   timestamptz not null default now()
);

create index if not exists payments_order_idx on payments(order_id);
create index if not exists payments_shop_idx on payments(shop_id);

-- When a payment is inserted, bump order.advance_amount
create or replace function apply_payment_to_order()
returns trigger
language plpgsql
as $$
begin
  update orders
  set advance_amount = least(total_amount, advance_amount + new.amount),
      updated_at = now()
  where id = new.order_id;
  return new;
end;
$$;

drop trigger if exists payments_apply_trg on payments;
create trigger payments_apply_trg
  after insert on payments
  for each row execute function apply_payment_to_order();

-- -----------------------------------------------------------------------------
-- Shop settings (SMTP, locale, etc.)
-- -----------------------------------------------------------------------------
create table if not exists shop_settings (
  shop_id                    uuid primary key references shops(id) on delete cascade,
  language_code              text not null default 'ur',
  is_dark_mode               boolean not null default false,
  smtp_host                  text,
  smtp_port                  int,
  sender_email               text,
  smtp_app_password          text,
  send_emails_automatically  boolean not null default false,
  updated_at                 timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- updated_at helper
-- -----------------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array[
    'shops', 'profiles', 'staff', 'customers',
    'measurements', 'orders', 'shop_settings'
  ]
  loop
    execute format(
      'drop trigger if exists %I_updated_at on %I;
       create trigger %I_updated_at
         before update on %I
         for each row execute function set_updated_at();',
      t, t, t, t
    );
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Useful views
-- -----------------------------------------------------------------------------
create or replace view order_balances as
select
  o.id,
  o.shop_id,
  o.token_code,
  o.customer_id,
  o.status,
  o.payment_status,
  o.total_amount,
  o.advance_amount,
  (o.total_amount - o.advance_amount) as remaining_amount,
  o.delivery_date,
  o.is_rush
from orders o;

create or replace view customer_stats as
select
  c.id as customer_id,
  c.shop_id,
  count(distinct o.id) as total_orders,
  count(distinct m.category) as garment_types,
  coalesce(sum(o.total_amount - o.advance_amount)
    filter (where o.status <> 'delivered' or o.payment_status <> 'paid'), 0)
    as baqaya
from customers c
left join orders o on o.customer_id = c.id
left join measurements m on m.customer_id = c.id
group by c.id, c.shop_id;

-- -----------------------------------------------------------------------------
-- Row Level Security
-- -----------------------------------------------------------------------------
alter table shops enable row level security;
alter table profiles enable row level security;
alter table staff enable row level security;
alter table customers enable row level security;
alter table measurements enable row level security;
alter table measurement_history enable row level security;
alter table orders enable row level security;
alter table payments enable row level security;
alter table shop_settings enable row level security;

-- Helper: shop ids the current user belongs to
create or replace function auth_shop_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select shop_id from profiles where id = auth.uid() and shop_id is not null
  union
  select id from shops where owner_id = auth.uid();
$$;

-- Profiles: users see / update themselves
create policy profiles_select_own on profiles
  for select using (id = auth.uid());
create policy profiles_update_own on profiles
  for update using (id = auth.uid());
create policy profiles_insert_own on profiles
  for insert with check (id = auth.uid());

-- Shops
create policy shops_select on shops
  for select using (id in (select auth_shop_ids()));
create policy shops_insert on shops
  for insert with check (owner_id = auth.uid());
create policy shops_update on shops
  for update using (owner_id = auth.uid());

-- Generic shop-scoped CRUD policies
create policy staff_all on staff
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

create policy customers_all on customers
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

create policy measurements_all on measurements
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

create policy measurement_history_all on measurement_history
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

create policy orders_all on orders
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

create policy payments_all on payments
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

create policy shop_settings_all on shop_settings
  for all using (shop_id in (select auth_shop_ids()))
  with check (shop_id in (select auth_shop_ids()));

-- -----------------------------------------------------------------------------
-- Storage buckets (run once; adjust CORS in Dashboard if needed)
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values
  ('customer-photos', 'customer-photos', true),
  ('order-photos', 'order-photos', true),
  ('measurement-photos', 'measurement-photos', true)
on conflict (id) do nothing;

create policy storage_shop_read on storage.objects
  for select using (bucket_id in (
    'customer-photos', 'order-photos', 'measurement-photos'
  ));

create policy storage_shop_write on storage.objects
  for insert with check (
    bucket_id in ('customer-photos', 'order-photos', 'measurement-photos')
    and auth.role() = 'authenticated'
  );

create policy storage_shop_update on storage.objects
  for update using (
    bucket_id in ('customer-photos', 'order-photos', 'measurement-photos')
    and auth.role() = 'authenticated'
  );

create policy storage_shop_delete on storage.objects
  for delete using (
    bucket_id in ('customer-photos', 'order-photos', 'measurement-photos')
    and auth.role() = 'authenticated'
  );
