--------------------------------------------------------------------------
-- Tables
create table group_expense_participants (

  group_id uuid references groups(id), -- Note (2026-05-31): non obbligatorio, posso anche dedurlo dalla group_transaction associata
  transaction_id uuid references group_transactions(id), -- Note (2026-05-31): non obbligatorio, posso anche dedurlo dalla group_id associata

  user_id uuid default auth.uid() references auth.users(id),
  has_paid boolean default false,

  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  paid_at timestamp with time zone, -- TODO: da implementare, da aggiornare quando has_paid diventa true

  primary key (transaction_id, user_id),
  constraint fk_group_expense_participants_profiles 
    foreign key (user_id) references profiles(id)
    on delete cascade, -- delete dei partecipanti associati alla cancellazione di un utente
  constraint fk_group_expense_participants_group_transactions 
    foreign key (transaction_id) references group_transactions(id)
    on delete cascade -- delete dei partecipanti associati alla cancellazione di una transazione
);

--------------------------------------------------------------------------
-- Indexes
create index idx_group_expense_participants_user_id on group_expense_participants(user_id);
create index idx_group_expense_participants_group_id on group_expense_participants(group_id);
create index idx_group_expense_participants_transaction_id on group_expense_participants(transaction_id);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table group_expense_participants enable row level security;