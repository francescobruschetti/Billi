--------------------------------------------------------------------------
-- Types (ENUMS)
create type group_role as enum ('admin', 'creator', 'member');

--------------------------------------------------------------------------
-- Tables
create table groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  link char(8) not null unique default substr(encode(gen_random_bytes(6), 'base64'), 1, 8),

  user_id uuid not null default auth.uid() references auth.users(id),

  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table group_participants (
  user_id uuid default auth.uid() references auth.users(id) on delete cascade,
  group_id uuid references groups(id) on delete cascade,
  group_user_id uuid not null, -- campo aggiuntivo per ottimizzare le policy di accesso ai partecipanti
  role group_role not null default 'member',

  has_confirmed boolean default false,
  is_enabled boolean default true,

  joined_at timestamp with time zone default now(),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  primary key (group_id, user_id),
  constraint fk_group_participants_profiles foreign key (user_id) references profiles(id) on delete cascade
);

-- ENUM per split_rate
create table group_expenses (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  merchant_id uuid references merchants(id),
  category_id uuid references categories(id),
  paid_amount numeric(10,2) check (paid_amount >= 0),
  total_amount numeric(10,2) not null check (total_amount > 0),
  split_rate text,
  note text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  constraint fk_group_expenses_profiles foreign key (user_id) references profiles(id) on delete cascade,
  constraint chk_paid_or_split_only check (
    (paid_amount is not null and split_rate is null) or (paid_amount is null and split_rate is not null)
  )
);

--------------------------------------------------------------------------
-- Indexes
create index idx_groups_name on groups(name);
create index idx_groups_link on groups(link);
create index idx_group_participants_name on group_participants(user_id);
create index idx_group_participants_group_id on group_participants(group_id);
create index idx_group_expenses_group_user_id on group_expenses(user_id);
create index idx_group_expenses_group_id on group_expenses(group_id);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table groups enable row level security;
alter table group_participants enable row level security;
alter table group_expenses enable row level security;