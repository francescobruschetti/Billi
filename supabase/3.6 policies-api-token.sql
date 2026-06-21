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
grant select, insert, update, delete on table api_tokens to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
create policy "Users can view own tokens"
on public.api_tokens
for select
to authenticated
using (
    auth.uid() = user_id
);

--------------------------------------------------------------------------
create policy "Users can create own tokens"
on public.api_tokens
for insert
to authenticated
with check (
    auth.uid() = user_id
);

--------------------------------------------------------------------------
create policy "Users can update own tokens"
on public.api_tokens
for update
to authenticated
using (
    auth.uid() = user_id
);
