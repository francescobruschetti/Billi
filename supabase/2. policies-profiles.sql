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

create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

--------------------------------------------------------------------------
-- Trigger to update 'updated_at' on profile update
create trigger trg_profiles_updated_at
before update on profiles
for each row
execute function update_updated_at();

--------------------------------------------------------------------------
-- Trigger to create profile on new user registration
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, name)
  values (
    new.id,
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'name'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Attach the trigger to auth.users table
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();