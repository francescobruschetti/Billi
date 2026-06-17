-- PRINCIPIO CHIAVE (importantissimo)
-- Per evitare infinite recursion e problemi futuri:
-- 🔑 Una policy può leggere SOLO una tabella “più semplice”
-- groups → group_participants → group_transactions
-- (mai il contrario)

--------------------------------------------------------------------------
-- IMPORTANTISSIMO! GRANT PERMISSIONS to authenticated users. 
-- GRANTs are necessary for Flutter clients to access the tables.
-- Data security is still maintained as long as your RLS policies are correct.
-- Do not rely on GRANT alone — RLS is the only thing protecting row-level access.
--------------------------------------------------------------------------
grant select, insert, update, delete on table categories to authenticated;
grant select, insert, update, delete on table merchants to authenticated;
grant select, insert, update, delete on table transactions to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Transactions table
drop policy if exists "Authenticated users can create transactions" on transactions;
create policy "Authenticated users can create transactions"
on transactions
for insert
with check (
  auth.uid() = user_id
);

create policy "Creator can view own transactions"
on transactions
for select
using (
  user_id = auth.uid()
);

create policy "Only creator can update transactions"
on transactions
for update
using (user_id = auth.uid());

create policy "Only creator can delete transactions"
on transactions
for delete
using (user_id = auth.uid());

--------------------------------------------------------------------------
-- Categories table
drop policy if exists "Authenticated users can create categories" on categories;
create policy "Authenticated users can create categories"
on categories
for insert
with check (
  auth.uid() = user_id
);

drop policy if exists "Creator can view own categories" on categories;
create policy "Creator can view own categories and default categories"
on categories
for select
using (
  user_id = auth.uid() or user_id is null
);

create policy "Only creator can update categories"
on categories
for update
using (user_id = auth.uid());

create policy "Only creator can delete categories"
on categories
for delete
using (user_id = auth.uid());

drop policy if exists "Group participants can view categories linked to their group transactions" on categories;
create policy "Group participants can view categories linked to their group transactions"
on categories
for select
using (
  EXISTS (
    SELECT 1 FROM group_transactions
    JOIN group_participants ON group_transactions.group_id = group_participants.group_id
    WHERE group_transactions.category_id = categories.id
      AND group_participants.user_id = auth.uid()
  )
);

--------------------------------------------------------------------------
-- Merchants table
drop policy if exists "Authenticated users can create merchants" on merchants;
create policy "Authenticated users can create merchants"
on merchants
for insert
with check (
  auth.uid() = user_id
);

create policy "Creator can view own merchants"
on merchants
for select
using (
  user_id = auth.uid()
);

create policy "Only creator can update merchants"
on merchants
for update
using (user_id = auth.uid());

create policy "Only creator can delete merchants"
on merchants
for delete
using (user_id = auth.uid());

drop policy if exists "Group participants can view merchants linked to their group transactions" on merchants;
create policy "Group participants can view merchants linked to their group transactions"
on merchants
for select
using (
  EXISTS (
    SELECT 1 FROM group_transactions
    JOIN group_participants ON group_transactions.group_id = group_participants.group_id
    WHERE group_transactions.merchant_id = merchants.id
      AND group_participants.user_id = auth.uid()
  )
);

--------------------------------------------------------------------------
-- Auto-update updated_at (note: also used by group tables)
create or replace function update_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_update_transactions
before update on transactions
for each row execute function update_timestamp();
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Trigger Insert Transaction with default category and merchant
create or replace function insert_transaction_with_merchant_category(
  p_user_id uuid,
  p_total_amount numeric,
  p_merchant_name text,
  p_category_name text,
  p_note text,
  p_transaction_type transaction_type_enum
)
returns table (
  transaction_id uuid, -- id transaction
  user_id uuid, -- id utente
  total_amount numeric,
  merchant_id uuid,
  category_id uuid,
  note text,
  transaction_type transaction_type_enum,
  created_at timestamptz
) as $$
declare
  v_merchant_id uuid;
  v_category_id uuid;
begin
  -- Merchant -- TODO: gestire (m.name is not null and m.name <> '' and lower(m.name) = lower(p_merchant_name))
  if p_transaction_type = 'INCOME' then
    v_merchant_id := null;
  else
    select m.id into v_merchant_id from merchants m where lower(m.name) = lower(p_merchant_name) and m.user_id = p_user_id limit 1;
    if v_merchant_id is null then
      insert into merchants (name, user_id) values (p_merchant_name, p_user_id) returning id into v_merchant_id;
    end if;
  end if;

  -- TODO: gestire (m.name is not null and m.name <> '' and lower(m.name) = lower(p_merchant_name))
  -- Category -- Se viene scelta una categoria predefinita, non deve essere possibile modificarla, e non devo crearla per l'utente
  select c.id into v_category_id from categories c where lower(c.name) = lower(p_category_name) and (c.user_id = p_user_id or c.user_id is null) limit 1;
  if v_category_id is null then
    insert into categories (name, user_id) values (p_category_name, p_user_id) returning id into v_category_id;
  end if;

  -- Transaction
  return query
  insert into transactions (user_id, total_amount, merchant_id, category_id, note, transaction_type)
  values (p_user_id, p_total_amount, v_merchant_id, v_category_id, p_note, p_transaction_type)
  returning
    transactions.id as transaction_id,
    transactions.user_id  as user_id,
    transactions.total_amount as total_amount,
    transactions.merchant_id as merchant_id,
    transactions.category_id as category_id,
    transactions.note as note,
    transactions.transaction_type as transaction_type,
    transactions.created_at  as created_at;

end;
$$ language plpgsql security definer;
grant execute on function public.insert_transaction_with_merchant_category(uuid, numeric, text, text, text, transaction_type_enum) to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Trigger Insert Group Transactions with default category and merchant
drop function if exists insert_group_transaction_with_merchant_category(
  p_group_id uuid,
  p_user_id uuid,
  p_paid_amount numeric,
  p_total_amount numeric,
  p_split_rate split_rate_enum,
  p_merchant_name text,
  p_category_name text,
  p_note text,
  p_transaction_type transaction_type_enum
);
create or replace function insert_group_transaction_with_merchant_category(
  p_group_id uuid,
  p_user_id uuid,
  p_paid_amount numeric,
  p_total_amount numeric,
  p_split_rate split_rate_enum,
  p_merchant_name text,
  p_category_name text,
  p_note text,
  p_transaction_type transaction_type_enum
)
returns table (
  transaction_id uuid, -- id transaction
  user_id uuid, -- id utente
  paid_amount numeric,
  total_amount numeric,
  split_rate split_rate_enum,
  merchant_id uuid,
  category_id uuid,
  note text,
  transaction_type transaction_type_enum,
  created_at timestamptz
) as $$
declare
  v_merchant_id uuid;
  v_category_id uuid;
  v_transaction_id uuid;
begin
  -- Merchant -- TODO: gestire (m.name is not null and m.name <> '' and lower(m.name) = lower(p_merchant_name))
  if p_transaction_type = 'INCOME' then
    v_merchant_id := null;
  else
    select m.id into v_merchant_id from merchants m where lower(m.name) = lower(p_merchant_name) and m.user_id = p_user_id limit 1;
    if v_merchant_id is null then
      insert into merchants (name, user_id) values (p_merchant_name, p_user_id) returning id into v_merchant_id;
    end if;
  end if;

  -- TODO: gestire (m.name is not null and m.name <> '' and lower(m.name) = lower(p_merchant_name))
  -- Category -- Se viene scelta una categoria predefinita, non deve essere possibile modificarla, e non devo crearla per l'utente
  select c.id into v_category_id from categories c where lower(c.name) = lower(p_category_name) and (c.user_id = p_user_id or c.user_id is null) limit 1;
  if v_category_id is null then
    insert into categories (name, user_id) values (p_category_name, p_user_id) returning id into v_category_id;
  end if;

  -- Transaction v1:
  -- return query
  -- insert into group_transactions (user_id, paid_amount, total_amount, split_rate, merchant_id, category_id, note, transaction_type, group_id)
  -- values (p_user_id, p_paid_amount, p_total_amount, p_split_rate, v_merchant_id, v_category_id, p_note, p_transaction_type, p_group_id)
  -- returning
  --   group_transactions.id as transaction_id,
  --   group_transactions.user_id  as user_id,
  --   group_transactions.paid_amount as paid_amount,
  --   group_transactions.total_amount as total_amount,
  --   group_transactions.split_rate as split_rate,
  --   group_transactions.merchant_id as merchant_id,
  --   group_transactions.category_id as category_id,
  --   group_transactions.note as note,
  --   group_transactions.transaction_type as transaction_type,
  --   group_transactions.created_at as created_at;

  -------------------------------------------------------------------------------------------------
  -- Transaction v2: crea transazione e aggiungi in group_expense_participants tutti i partecipanti al gruppo (con left_at null)
  insert into group_transactions (user_id, paid_amount, total_amount, split_rate, merchant_id, category_id, note, transaction_type, group_id)
  values (p_user_id, p_paid_amount, p_total_amount, p_split_rate, v_merchant_id, v_category_id, p_note, p_transaction_type, p_group_id)
  returning id into v_transaction_id;

  -- Add all active group participants to the expense, except its creator and those who have left the group (left_at is not null)
  insert into group_expense_participants (group_id, transaction_id, user_id)
  select gp.group_id, v_transaction_id, gp.user_id
  from group_participants gp
  where gp.group_id = p_group_id and gp.left_at is null and gp.user_id <> p_user_id;

  -- Return created transaction
  return query
  select
    gt.id as transaction_id,
    gt.user_id,
    gt.paid_amount,
    gt.total_amount,
    gt.split_rate,
    gt.merchant_id,
    gt.category_id,
    gt.note,
    gt.transaction_type,
    gt.created_at
  from group_transactions gt
  where gt.id = v_transaction_id;
  -------------------------------------------------------------------------------------------------

end;
$$ language plpgsql security definer;
grant execute on function public.insert_group_transaction_with_merchant_category(
  uuid, uuid, numeric, numeric, split_rate_enum, text, text, text, transaction_type_enum
) to authenticated;
--------------------------------------------------------------------------