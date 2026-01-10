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
  auth.uid() = creator_id
);

create policy "Creator can view own expenses"
on expenses
for select
using (
  creator_id = auth.uid()
);

create policy "Only creator can update expenses"
on expenses
for update
using (creator_id = auth.uid());

create policy "Only creator can delete expenses"
on expenses
for delete
using (creator_id = auth.uid());

--------------------------------------------------------------------------
-- Incomes table
drop policy if exists "Authenticated users can create incomes" on incomes;
create policy "Authenticated users can create incomes"
on incomes
for insert
with check (
  auth.uid() = creator_id
);

create policy "Creator can view own incomes"
on incomes
for select
using (
  creator_id = auth.uid()
);

create policy "Only creator can update incomes"
on incomes
for update
using (creator_id = auth.uid());

create policy "Only creator can delete incomes"
on incomes
for delete
using (creator_id = auth.uid());

--------------------------------------------------------------------------
-- Categories table
drop policy if exists "Authenticated users can create categories" on categories;
create policy "Authenticated users can create categories"
on categories
for insert
with check (
  auth.uid() = creator_id
);

create policy "Creator can view own categories"
on categories
for select
using (
  creator_id = auth.uid()
);

create policy "Only creator can update categories"
on categories
for update
using (creator_id = auth.uid());

create policy "Only creator can delete categories"
on categories
for delete
using (creator_id = auth.uid());

--------------------------------------------------------------------------
-- Merchants table
drop policy if exists "Authenticated users can create merchants" on merchants;
create policy "Authenticated users can create merchants"
on merchants
for insert
with check (
  auth.uid() = creator_id
);

create policy "Creator can view own merchants"
on merchants
for select
using (
  creator_id = auth.uid()
);

create policy "Only creator can update merchants"
on merchants
for update
using (creator_id = auth.uid());

create policy "Only creator can delete merchants"
on merchants
for delete
using (creator_id = auth.uid());

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