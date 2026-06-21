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
