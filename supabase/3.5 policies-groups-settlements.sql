-- PRINCIPIO CHIAVE (importantissimo)
-- Per evitare infinite recursion e problemi futuri:
-- 🔑 Una policy può leggere SOLO una tabella “più semplice”
-- groups → group_settlements → group_transactions
-- (mai il contrario)

--------------------------------------------------------------------------
-- IMPORTANTISSIMO! GRANT PERMISSIONS to authenticated users. 
-- GRANTs are necessary for Flutter clients to access the tables.
-- Data security is still maintained as long as your RLS policies are correct.
-- Do not rely on GRANT alone — RLS is the only thing protecting row-level access.
--------------------------------------------------------------------------
grant select, insert, update, delete on table group_settlements to authenticated;
--------------------------------------------------------------------------

-- TODO: da implementare: policies per group_settlements (ruoli, visibilità partecipanti, ecc.)
--------------------------------------------------------------------------
-- -- Group Settlements table
create policy "Group participants can view settlements"
on group_settlements
for select
to authenticated
using (
  exists (
    select 1 from group_participants
    where group_participants.group_id = group_settlements.group_id
      and group_participants.user_id = auth.uid()
      and group_participants.is_enabled = true
  )
);

create policy "Group participants can insert settlements"
on group_settlements
for insert
to authenticated
with check (
  payer_id = auth.uid()
  and exists (
    select 1 from group_participants
    where group_participants.group_id = group_settlements.group_id
      and group_participants.user_id = auth.uid()
      and group_participants.is_enabled = true
  )
);

create policy "Payer can delete own settlements"
on group_settlements
for delete
to authenticated
using (
  payer_id = auth.uid()
);

--------------------------------------------------------------------------
-- Auto-update settled_at
create or replace function update_group_settlements_settled_at()
returns trigger as $$
begin
  new.settled_at = now();
  return new;
end;
$$ language plpgsql;

create or replace trigger trg_update_group_settlements
before update on group_settlements
for each row execute function update_group_settlements_settled_at();

