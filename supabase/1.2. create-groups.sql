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

  creator_id uuid not null default auth.uid() references auth.users(id),

  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table group_participants (
  user_id uuid default auth.uid() references auth.users(id) on delete cascade,
  group_id uuid references groups(id) on delete cascade,
  group_creator_id uuid not null,
  role group_role not null default 'member',

  has_confirmed boolean default false,
  is_enabled boolean default true,

  joined_at timestamp with time zone default now(),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  primary key (group_id, user_id)
);

create table group_expenses (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paid_amount numeric(10,2) not null check (paid_amount >= 0),
  note text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
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

--------------------------------------------------------------------------
-- Trigger function to set group_creator_id in group_participants
create or replace function set_group_creator_id()
returns trigger as $$
begin
  select creator_id
  into new.group_creator_id
  from groups
  where id = new.group_id;

  return new;
end;
$$ language plpgsql;

create trigger trg_set_group_creator_id
before insert on group_participants
for each row
execute function set_group_creator_id();