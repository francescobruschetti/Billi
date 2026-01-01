create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  name text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Indexs
create index idx_profiles_username on profiles(username);

-- Trigger per aggiornare updated_at quando username o name cambiano
create or replace function update_profiles_updated_at()
returns trigger as $$
begin
  if (new.username is distinct from old.username) or (new.name is distinct from old.name) then
    new.updated_at := now();
  end if;
  return new;
end;
$$ language plpgsql;

create or replace trigger set_profiles_updated_at
before update on profiles
for each row execute procedure update_profiles_updated_at();

-- Trigger per creare profilo quando si registra un nuovo utente
create or replace function handle_new_user()
returns trigger as $$
declare
  meta jsonb;
  username text;
begin
  meta := new.raw_user_meta_data;
  username := coalesce(meta->>'username', split_part(new.email, '@', 1));
  raise notice 'NEW USER: id=%, email=%, username=%, name=%', new.id, new.email, username, meta->>'name';
  begin
    insert into profiles (id, username, name)
    values (
      new.id, 
      username,
      meta->>'name'
    );
  exception when unique_violation then
    raise notice 'Username già esistente: %', username;
    -- puoi scegliere di generare un username alternativo o fallire
    return new;
  when others then
    raise notice 'Errore inserimento profilo: %', SQLERRM;
    return new;
  end;
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
after insert on auth.users
for each row execute procedure handle_new_user();

-- Row Level Security (OBBLIGATORIO)
alter table profiles enable row level security;

-- Policies
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
create policy "Users can read own profile"
on profiles
for select
using (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
create policy "Users can update own profile"
on profiles
for update
using (auth.uid() = id);
