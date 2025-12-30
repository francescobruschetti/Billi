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

  creator_id uuid not null references auth.users(id),

  merchant_id uuid references merchants(id),
  category_id uuid references categories(id),

  note text not null,
  total_amount numeric(10,2) not null check (total_amount > 0),

  created_at timestamp with time zone default now()
);

create table expense_participants (
  expense_id uuid references expenses(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,

  paid_amount numeric(10,2) not null default 0 check (paid_amount >= 0),

  primary key (expense_id, user_id)
);

-- Indexs
create index idx_expenses_user on expenses(creator_id);
create index idx_expenses_category on expenses(category_id);
create index idx_expenses_merchant on expenses(merchant_id);

-- Row Level Security (OBBLIGATORIO)
alter table expenses enable row level security;

-- Policies 1: Expenses
create policy "Participants can view expense"
on expenses
for select
using (
  exists (
    select 1
    from expense_participants ep
    where ep.expense_id = expenses.id
      and ep.user_id = auth.uid()
  )
);

-- Policies 2: Expenses (creator only)
create policy "Only creator can update expense"
on expenses
for update
using (auth.uid() = creator_id);

-- Policies 3: Expense Participants
alter table expense_participants enable row level security;

create policy "Participants can view participants"
on expense_participants
for select
using (
  exists (
    select 1
    from expense_participants ep
    where ep.expense_id = expense_participants.expense_id
      and ep.user_id = auth.uid()
  )
);

create policy "Only creator can update payments"
on expense_participants
for update
using (
  exists (
    select 1
    from expenses e
    where e.id = expense_participants.expense_id
      and e.creator_id = auth.uid()
  )
);

create policy "Only creator can add participants"
on expense_participants
for insert
with check (
  exists (
    select 1
    from expenses e
    where e.id = expense_participants.expense_id
      and e.creator_id = auth.uid()
  )
);
