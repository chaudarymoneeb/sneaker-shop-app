-- Run this entire file in Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null default '',
  name text not null default '',
  photo_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.shoes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price numeric(10, 2) not null check (price >= 0),
  brand text not null default 'Shoe App',
  image_url text,
  images jsonb not null default '[]'::jsonb,
  category text not null default 'Lifestyle',
  rating numeric(2, 1) not null default 0,
  description text not null default '',
  sizes jsonb not null default '[]'::jsonb,
  color_image_map jsonb not null default '{}'::jsonb,
  is_featured boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  shoe_id uuid not null references public.shoes(id) on delete cascade,
  size text not null default '',
  color text not null default '',
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  unique (user_id, shoe_id, size, color)
);

create table if not exists public.wishlist (
  user_id uuid not null references auth.users(id) on delete cascade,
  shoe_id uuid not null references public.shoes(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, shoe_id)
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  items jsonb not null default '[]'::jsonb,
  total numeric(10, 2) not null default 0 check (total >= 0),
  address text not null default '',
  status text not null default 'Processing',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.shoes enable row level security;
alter table public.cart_items enable row level security;
alter table public.wishlist enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Public can view shoes" on public.shoes;
create policy "Public can view shoes" on public.shoes
  for select using (true);

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users can manage own cart" on public.cart_items;
create policy "Users can manage own cart" on public.cart_items
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can manage own wishlist" on public.wishlist;
create policy "Users can manage own wishlist" on public.wishlist
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can view own orders" on public.orders;
create policy "Users can view own orders" on public.orders
  for select using (auth.uid() = user_id);

drop policy if exists "Users can create own orders" on public.orders;
create policy "Users can create own orders" on public.orders
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own orders" on public.orders;
create policy "Users can update own orders" on public.orders
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into public.shoes (
  name, price, brand, image_url, images, category, rating,
  description, sizes, is_featured
)
select
  'Street Runner ' || (n + 1),
  79 + (n * 13.5),
  'Shoe App',
  'assets/images/' || n || '.jpg',
  jsonb_build_array('assets/images/' || n || '.jpg'),
  (array['Running', 'Basketball', 'Lifestyle', 'Training'])[(n % 4) + 1],
  4.2 + ((n % 5) * 0.1),
  'Comfortable everyday sneakers with a lightweight design.',
  '["7", "8", "9", "10", "11"]'::jsonb,
  n < 4
from generate_series(0, 17) as n
where not exists (select 1 from public.shoes);

-- Enable Realtime for the streams used by the Flutter app.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'shoes'
  ) then
    alter publication supabase_realtime add table public.shoes;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'cart_items'
  ) then
    alter publication supabase_realtime add table public.cart_items;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'wishlist'
  ) then
    alter publication supabase_realtime add table public.wishlist;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'orders'
  ) then
    alter publication supabase_realtime add table public.orders;
  end if;
end $$;
