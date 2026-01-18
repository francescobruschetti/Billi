-- PRINCIPIO CHIAVE (importantissimo)
-- Per evitare infinite recursion e problemi futuri:
-- 🔑 Una policy può leggere SOLO una tabella “più semplice”
-- groups → group_participants → group_expenses
-- (mai il contrario)

--------------------------------------------------------------------------
-- IMPORTANTISSIMO! GRANT PERMISSIONS to authenticated users. 
-- GRANTs are necessary for Flutter clients to access the tables.
-- Data security is still maintained as long as your RLS policies are correct.
-- Do not rely on GRANT alone — RLS is the only thing protecting row-level access.
--------------------------------------------------------------------------
grant select, insert, update, delete on table categories to authenticated;
grant select, insert, update, delete on table merchants to authenticated;
grant select, insert, update, delete on table expenses to authenticated;
grant select, insert, update, delete on table incomes to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Expenses table
drop policy if exists "Authenticated users can create expenses" on expenses;
create policy "Authenticated users can create expenses"
on expenses
for insert
with check (
  auth.uid() = user_id
);

create policy "Creator can view own expenses"
on expenses
for select
using (
  user_id = auth.uid()
);

create policy "Only creator can update expenses"
on expenses
for update
using (user_id = auth.uid());

create policy "Only creator can delete expenses"
on expenses
for delete
using (user_id = auth.uid());

--------------------------------------------------------------------------
-- Incomes table
drop policy if exists "Authenticated users can create incomes" on incomes;
create policy "Authenticated users can create incomes"
on incomes
for insert
with check (
  auth.uid() = user_id
);

create policy "Creator can view own incomes"
on incomes
for select
using (
  user_id = auth.uid()
);

create policy "Only creator can update incomes"
on incomes
for update
using (user_id = auth.uid());

create policy "Only creator can delete incomes"
on incomes
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

create policy "Creator can view own categories"
on categories
for select
using (
  user_id = auth.uid()
);

create policy "Only creator can update categories"
on categories
for update
using (user_id = auth.uid());

create policy "Only creator can delete categories"
on categories
for delete
using (user_id = auth.uid());

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

--------------------------------------------------------------------------
-- Auto-update updated_at
create or replace function update_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_update_expenses
before update on expenses
for each row execute function update_timestamp();

create trigger trg_update_incomes
before update on incomes
for each row execute function update_timestamp();
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Trigger Insert Expense with default category and merchant
create or replace function insert_expense_with_merchant_category(
  p_user_id uuid,
  p_total_amount numeric,
  p_merchant_name text,
  p_category_name text,
  p_note text
)
returns table (
  expense_id uuid, -- id expense
  user_id uuid, -- id utente
  total_amount numeric,
  merchant_id uuid,
  category_id uuid,
  note text,
  created_at timestamptz
) as $$
declare
  v_merchant_id uuid;
  v_category_id uuid;
begin
  -- Merchant
  select m.id into v_merchant_id from merchants m where lower(m.name) = lower(p_merchant_name) limit 1;
  if v_merchant_id is null then
    insert into merchants (name, user_id) values (p_merchant_name, p_user_id) returning id into v_merchant_id;
  end if;

  -- -- Category
  select c.id into v_category_id from categories c where lower(c.name) = lower(p_category_name) limit 1;
  if v_category_id is null then
    insert into categories (name, user_id) values (p_category_name, p_user_id) returning id into v_category_id;
  end if;

  -- -- Expense
  return query
  insert into expenses (user_id, total_amount, merchant_id, category_id, note)
  values (p_user_id, p_total_amount, v_merchant_id, v_category_id, p_note)
  returning
    expenses.id as expense_id,
    expenses.user_id  as user_id,
    expenses.total_amount as total_amount,
    expenses.merchant_id as merchant_id,
    expenses.category_id as category_id,
    expenses.note        as note,
    expenses.created_at  as created_at;

end;
$$ language plpgsql security definer;
grant execute on function public.insert_expense_with_merchant_category(uuid, numeric, text, text, text) to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Trigger Insert Group Expenses with default category and merchant
create or replace function insert_group_expense_with_merchant_category(
  p_group_id uuid,
  p_user_id uuid,
  p_paid_amount numeric,
  p_total_amount numeric,
  p_split_rate numeric,
  p_merchant_name text,
  p_category_name text,
  p_note text
)
returns table (
  expense_id uuid, -- id expense
  user_id uuid, -- id utente
  paid_amount numeric,
  total_amount numeric,
  split_rate numeric,
  merchant_id uuid,
  category_id uuid,
  note text,
  created_at timestamptz
) as $$
declare
  v_merchant_id uuid;
  v_category_id uuid;
begin
  -- Merchant
  select m.id into v_merchant_id from merchants m where lower(m.name) = lower(p_merchant_name) limit 1;
  if v_merchant_id is null then
    insert into merchants (name, user_id) values (p_merchant_name, p_user_id) returning id into v_merchant_id;
  end if;

  -- -- Category
  select c.id into v_category_id from categories c where lower(c.name) = lower(p_category_name) limit 1;
  if v_category_id is null then
    insert into categories (name, user_id) values (p_category_name, p_user_id) returning id into v_category_id;
  end if;

  -- -- Expense
  return query
  insert into group_expenses (user_id, paid_amount, total_amount, split_rate, merchant_id, category_id, note, group_id)
  values (p_user_id, p_paid_amount, p_total_amount, p_split_rate, v_merchant_id, v_category_id, p_note, p_group_id)
  returning
    group_expenses.id as expense_id,
    group_expenses.user_id  as user_id,
    group_expenses.paid_amount as paid_amount,
    group_expenses.total_amount as total_amount,
    group_expenses.split_rate as split_rate,
    group_expenses.merchant_id as merchant_id,
    group_expenses.category_id as category_id,
    group_expenses.note        as note,
    group_expenses.created_at  as created_at; 
end;
$$ language plpgsql security definer;
grant execute on function public.insert_group_expense_with_merchant_category(
  uuid, uuid, numeric, numeric, numeric, text, text, text
) to authenticated;
--------------------------------------------------------------------------