--------------------------------------------------------------------------
-- Tables: List of real settlements between users in a group
create table group_settlements (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade, -- FK automatica alla cancellazione del gruppo, elimino anche i settlements associati
  
  payer_id uuid not null references profiles(id),   -- chi paga (salda il debito)
  receiver_id uuid not null references profiles(id), -- chi riceve
  
  amount numeric(10,2) not null check (amount > 0),
  
  note text,
  settled_at timestamp with time zone default now(),
  created_at timestamp with time zone default now()
);

--------------------------------------------------------------------------
-- Indexes
create index idx_group_settlements_group_id on group_settlements(group_id);
create index idx_group_settlements_payer_id on group_settlements(payer_id);
create index idx_group_settlements_receiver_id on group_settlements(receiver_id);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table group_settlements enable row level security;
