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
grant select, insert, update, delete on table groups to authenticated;
grant select, insert, update, delete on table group_participants to authenticated;
grant select, insert, update, delete on table group_transactions to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Groups table
drop policy if exists "Authenticated users can create groups" on groups;
create policy "Authenticated users can create groups"
on groups
for insert
with check (
  auth.uid() = user_id
);

create policy "Creator can view own groups"
on groups
for select
using (
  user_id = auth.uid()
);

create policy "Participants can select their groups"
on groups
for select
using (
  EXISTS (
    SELECT 1 FROM group_participants
    WHERE group_participants.group_id = groups.id
      AND group_participants.user_id = auth.uid()
  )
);

-- Policy ottimizzata: ogni partecipante e il creator vedono tutti i membri del gruppo
drop policy if exists "User can view participants of own groups" on group_participants;
create policy "User can view participants of own groups"
on group_participants
for select
using (
  auth.uid() = user_id OR auth.uid() = group_user_id
);

create policy "Only creator can update groups"
on groups
for update
using (user_id = auth.uid());

create policy "Only creator can delete groups"
on groups
for delete
using (user_id = auth.uid());

--------------------------------------------------------------------------
-- Group Participants table
-- Policy: il creator può eliminare ogni partecipante tranne se stesso
drop policy if exists "Creator can delete any participant except self" on group_participants;
create policy "Creator can delete any participant except self"
on group_participants
for delete
using (
  group_user_id = auth.uid() and user_id <> auth.uid()
);

-- Policy: ogni utente può eliminare se stesso dal gruppo
drop policy if exists "User can remove self from group" on group_participants;
create policy "User can remove self from group"
on group_participants
for delete
using (
  user_id = auth.uid()
  AND role <> 'CREATOR'
);

-- Policy: each participant can see other participants of their groups (including themselves)
drop policy if exists "Participants can view members of their groups" on group_participants;
create policy "Participants can view members of their groups"
on group_participants
for select
using (
  public.is_user_in_group(group_participants.group_id)
);

drop policy if exists "Only creator can add group participants" on group_participants;
create policy "Only creator can add group participants"
on group_participants
for insert
with check (
  (select user_id from groups where id = group_participants.group_id) = auth.uid()
);

drop policy if exists "Only creator can update group participants" on group_participants;
create policy "Only creator can update group participants"
on group_participants
for update
with check (
  (select user_id from groups where id = group_participants.group_id) = auth.uid()
);

--------------------------------------------------------------------------
-- Group Transactions table
drop policy if exists "User can view group transactions" on group_transactions;
create policy "User can view group transactions"
on group_transactions
for select
using (
  exists (
    select 1 from group_participants gp
    where gp.group_id = group_transactions.group_id
      and gp.user_id = auth.uid()
      and gp.is_enabled = true
  )
);

create policy "Participants can insert group transactions"
on group_transactions
for insert
with check (
  exists (
    select 1 from group_participants gp
    where gp.group_id = group_transactions.group_id
      and gp.user_id = auth.uid()
      and gp.is_enabled = true
  )
);

create policy "Only creator can update group transactions"
on group_transactions
for update
using (user_id = auth.uid());

create policy "Only creator can delete group transactions"
on group_transactions
for delete
using (user_id = auth.uid());



