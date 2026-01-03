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
grant select, insert, update, delete on table groups to authenticated;
grant select, insert, update, delete on table group_participants to authenticated;
grant select, insert, update, delete on table group_expenses to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Groups table
drop policy if exists "User can view own or joined groups" on groups;
create policy "User can view own or joined groups"
on groups
for select
using (
  creator_id = auth.uid()
  OR
  exists (
    select 1
    from group_participants gp
    where gp.group_id = groups.id
      and gp.user_id = auth.uid()
      and gp.is_enabled = true
  )
);

create policy "Only creator can update groups"
on groups
for update
using (creator_id = auth.uid());

create policy "Only creator can delete groups"
on groups
for delete
using (creator_id = auth.uid());

--------------------------------------------------------------------------
-- Group Participants table
drop policy if exists "User can view participants of own groups" on group_participants;
create policy "User can view participants of own groups"
on group_participants
for select
using (
  user_id = auth.uid() 
  OR group_creator_id = auth.uid()
);

create policy "Only creator can add participants"
on group_participants
for insert
with check (group_creator_id = auth.uid());

create policy "Only creator can update participants"
on group_participants
for update
using (group_creator_id = auth.uid());

create policy "Only creator can delete participants"
on group_participants
for delete
using (group_creator_id = auth.uid());


--------------------------------------------------------------------------
-- Group Expenses table
drop policy if exists "User can view expenses" on group_expenses;
create policy "User can view expenses"
on group_expenses
for select
using (
  exists (
    select 1 from group_participants gp
    where gp.group_id = group_expenses.group_id
      and gp.user_id = auth.uid()
      and gp.is_enabled = true
  )
);

create policy "Participants can insert expenses"
on group_expenses
for insert
with check (
  exists (
    select 1 from group_participants gp
    where gp.group_id = group_expenses.group_id
      and gp.user_id = auth.uid()
      and gp.is_enabled = true
  )
);

create policy "Only creator can update expenses"
on group_expenses
for update
using (user_id = auth.uid());

create policy "Only creator can delete expenses"
on group_expenses
for delete
using (user_id = auth.uid());


--------------------------------------------------------------------------
-- Auto-set group_creator_id in participants
create or replace function set_group_creator_id()
returns trigger as $$
begin
  select creator_id into new.group_creator_id
  from groups
  where id = new.group_id;
  return new;
end;
$$ language plpgsql;

create trigger trg_set_group_creator_id
before insert on group_participants
for each row
execute function set_group_creator_id();

--------------------------------------------------------------------------
-- Auto-update updated_at
create or replace function update_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_update_groups
before update on groups
for each row execute function update_timestamp();

create trigger trg_update_group_participants
before update on group_participants
for each row execute function update_timestamp();

create trigger trg_update_group_expenses
before update on group_expenses
for each row execute function update_timestamp();

