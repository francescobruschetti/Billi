-- PRINCIPIO CHIAVE (importantissimo)
-- Per evitare infinite recursion e problemi futuri:
-- 🔑 Una policy può leggere SOLO una tabella “più semplice”
-- groups → group_expense_participants → group_transactions
-- (mai il contrario)

--------------------------------------------------------------------------
-- IMPORTANTISSIMO! GRANT PERMISSIONS to authenticated users. 
-- GRANTs are necessary for Flutter clients to access the tables.
-- Data security is still maintained as long as your RLS policies are correct.
-- Do not rely on GRANT alone — RLS is the only thing protecting row-level access.
--------------------------------------------------------------------------
grant select, insert, update, delete on table group_expense_participants to authenticated;
--------------------------------------------------------------------------

-- TODO: da implementare: policies per group_expense_participants (ruoli, visibilità partecipanti, ecc.)
--------------------------------------------------------------------------
-- -- Group Expense Participants table
create policy "Group participants can view expense participants"
on group_expense_participants
for select
to authenticated
using (
  exists (
    select 1
    from group_transactions gt
    where gt.id = transaction_id
      and gt.group_id in (
        select group_id
        from group_participants gp
        where gp.user_id = auth.uid()
      )
  )
);

--------------------------------------------------------------------------
-- Auto-update updated_at
create trigger trg_update_group_expense_participants
before update on group_expense_participants
for each row execute function update_timestamp();

