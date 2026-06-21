--------------------------------------------------------------------------
-- IMPORTANTISSIMO! GRANT PERMISSIONS to authenticated users. 
-- GRANTs are necessary for Flutter clients to access the tables.
-- Data security is still maintained as long as your RLS policies are correct.
-- Do not rely on GRANT alone — RLS is the only thing protecting row-level access.
--------------------------------------------------------------------------
grant select, insert, update, delete on table profiles to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Policies
create policy "Authenticated can read profiles"
on profiles
for select
using (TRUE);

create policy "User can view own profile"
on profiles
for select
using (id = auth.uid());

create policy "User can update own profile"
on profiles
for update
using (id = auth.uid());
