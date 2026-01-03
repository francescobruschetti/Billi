-- Tables
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table merchants (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table expenses (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null default auth.uid() references auth.users(id),
  merchant_id uuid references merchants(id),
  category_id uuid references categories(id),
  note text not null,
  total_amount numeric(10,2) not null check (total_amount > 0),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table income (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null default auth.uid() references auth.users(id),
  category_id uuid references categories(id),
  note text not null,
  total_amount numeric(10,2) not null check (total_amount > 0),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

--------------------------------------------------------------------------
-- Indexs
create index idx_expenses_user on expenses(creator_id);
create index idx_expenses_category on expenses(category_id);
create index idx_expenses_merchant on expenses(merchant_id);
create index idx_income_user on income(creator_id);
create index idx_income_category on income(category_id);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table expenses enable row level security;
alter table income enable row level security;