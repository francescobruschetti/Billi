-- Tables
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  user_id uuid not null default auth.uid() references auth.users(id),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table merchants (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  user_id uuid not null default auth.uid() references auth.users(id),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id),
  merchant_id uuid references merchants(id),
  category_id uuid references categories(id),
  note text,
  total_amount numeric(10,2) not null check (total_amount >= 0),
  transaction_type transaction_type not null default 'expense',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()

  -- Constraint to ensure that merchant_id is only required for expenses
  -- constraint merchant_only_for_expense check (
  --   (transaction_type = 'expense' and merchant_id is not null) 
  --   or
  --   (transaction_type = 'income' and merchant_id is null)
  -- )
);

--------------------------------------------------------------------------
-- Indexes
create index idx_transactions_user on transactions(user_id);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table transactions enable row level security;
alter table categories enable row level security;
alter table merchants enable row level security;