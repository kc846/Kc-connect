-- KC CONNECT: esquema inicial Supabase/PostgreSQL
-- Execute no SQL Editor do seu projeto Supabase depois de criar o projeto.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references auth.users(id) on delete set null,
  order_code text unique not null,
  business_name text not null,
  customer_phone text not null,
  selected_functions jsonb not null default '[]'::jsonb,
  plaque_model text not null default 'classic',
  amount_cents integer not null check (amount_cents >= 0),
  status text not null default 'new',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.digital_pages (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references auth.users(id) on delete cascade,
  order_id uuid references public.orders(id) on delete set null,
  slug text unique not null,
  business_name text not null,
  headline text,
  enabled boolean not null default true,
  links jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  id integer primary key default 1 check (id = 1),
  base_price_cents integer not null default 4990,
  included_functions integer not null default 4,
  extra_function_cents integer not null default 800,
  transparent_model_cents integer not null default 1000,
  updated_at timestamptz not null default now()
);
insert into public.site_settings(id) values (1) on conflict do nothing;

create table if not exists public.support_requests (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references auth.users(id) on delete cascade,
  page_id uuid references public.digital_pages(id) on delete set null,
  subject text not null,
  message text not null,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.orders enable row level security;
alter table public.digital_pages enable row level security;
alter table public.site_settings enable row level security;
alter table public.support_requests enable row level security;

-- Função auxiliar: somente administradores cadastrados em profiles.
create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

create policy "profile owner or admin reads profiles" on public.profiles
for select using (id = auth.uid() or public.is_admin());
create policy "profile owner updates own profile" on public.profiles
for update using (id = auth.uid()) with check (id = auth.uid());
create policy "admin manages profiles" on public.profiles
for all using (public.is_admin()) with check (public.is_admin());

create policy "customer reads own orders or admin reads all" on public.orders
for select using (customer_id = auth.uid() or public.is_admin());
create policy "customer creates own order" on public.orders
for insert with check (customer_id = auth.uid());
create policy "admin manages orders" on public.orders
for all using (public.is_admin()) with check (public.is_admin());

create policy "public reads enabled pages" on public.digital_pages
for select using (enabled = true or customer_id = auth.uid() or public.is_admin());
create policy "customer creates own page" on public.digital_pages
for insert with check (customer_id = auth.uid());
create policy "customer updates own page" on public.digital_pages
for update using (customer_id = auth.uid() or public.is_admin())
with check (customer_id = auth.uid() or public.is_admin());
create policy "admin manages pages" on public.digital_pages
for all using (public.is_admin()) with check (public.is_admin());

create policy "public reads pricing" on public.site_settings
for select using (true);
create policy "admin updates pricing" on public.site_settings
for all using (public.is_admin()) with check (public.is_admin());

create policy "customer reads own support requests" on public.support_requests
for select using (customer_id = auth.uid() or public.is_admin());
create policy "customer creates own support requests" on public.support_requests
for insert with check (customer_id = auth.uid());
create policy "admin manages support requests" on public.support_requests
for all using (public.is_admin()) with check (public.is_admin());

-- IMPORTANTE:
-- 1) Crie o primeiro usuário no Supabase Auth.
-- 2) Cadastre manualmente esse UUID em profiles e altere role para 'admin'.
-- 3) Nunca coloque a service_role key no navegador.
-- 4) Revise políticas e teste com contas distintas antes de receber pedidos reais.
