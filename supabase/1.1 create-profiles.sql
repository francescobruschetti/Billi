create table profiles (
  id uuid primary key
    default auth.uid()
    references auth.users(id) on delete cascade,

  username text unique not null,
  name text,

  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table profiles enable row level security;

--------------------------------------------------------------------------
-- GroupRoles (ENUMS)
create type group_role as enum ('admin', 'creator', 'member');

-- TransactionTypes (ENUMS)
create type transaction_type as enum ('income', 'expense');