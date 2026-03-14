--------------------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------------------
--------------------------------------------------------------------------
-- Get all groups cotaining the user as participant or creator, and the total amount of each group
DROP FUNCTION get_user_groups();
create or replace function public.get_user_groups()
returns table (
  id uuid,
  name text,
  link char(8),
  user_id uuid,
  created_at timestamptz,  -- must match table (timestamp with time zone)
  updated_at timestamptz,  -- must match table (timestamp with time zone)
  total_amount numeric -- somma di tutte le spese del gruppo
)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  select distinct
    g.id,
    g.name,
    g.link,
    g.user_id,
    g.created_at,
    g.updated_at,
    coalesce((
      select sum(
        case
          when e.transaction_type = 'income' then e.total_amount
          else -e.total_amount
        end
      )
      from group_transactions e
      where e.group_id = g.id
    ), 0) as total_amount
  from groups g
  left join group_participants gp
    on gp.group_id = g.id
  where
    g.user_id = auth.uid()
    or (
      gp.user_id = auth.uid()
      and gp.is_enabled = true
    )
  order by g.created_at desc;
end;
$$;

grant execute on function public.get_user_groups() to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Check if user is participant of a group
create or replace function public.is_user_in_group(p_group_id uuid)
returns boolean
language sql
security definer
as $$
  select exists (
    select 1
    from group_participants gp
    where gp.group_id = p_group_id
      and gp.user_id = auth.uid()
      and gp.is_enabled = true
  );
$$;

grant execute on function public.is_user_in_group(uuid) to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Funzione custom per ottenere tutti i membri del gruppo solo se abilitato
create or replace function get_group_members(p_group_id uuid)
returns table (
  user_id uuid,
  username text,
  email text
)
as $$
begin
  if exists (
    select 1 from group_participants
    where group_id = p_group_id
      and user_id = auth.uid()
      and is_enabled = true
  ) then
    return query
      select gp.user_id, p.username, p.email
      from group_participants gp
      left join profiles p on p.id = gp.user_id
      where gp.group_id = p_group_id;
  end if;
end;
$$ language plpgsql security definer;
grant execute on function public.get_group_members(uuid) to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Get user by email or username
create or replace function public.get_user_by_email_or_username(
  p_email varchar(255),
  p_username text
)
returns table (
  id uuid,
  email varchar(255),
  username text,
  name text
)
as $$
begin
  return query
  select u.id, u.email, p.username, p.name
  from auth.users u
  left join profiles p on p.id = u.id
  where u.email = p_email or p.username = p_username;
end;
$$ language plpgsql security definer;

grant execute on function public.get_user_by_email_or_username(varchar, text) to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Update group details and participants
drop function if exists update_group_and_participants(uuid, text, text, uuid[], uuid[]);
create or replace function update_group_and_participants(
  p_group_id uuid,
  p_name text,
  p_description text,
  p_participants_to_add uuid[],
  p_participants_to_remove uuid[]
)
returns uuid as $$
begin
  -- Aggiorna i dettagli del gruppo
  update groups
    set name = p_name,
        description = p_description
    where id = p_group_id;

  -- Aggiungi nuovi partecipanti
  if array_length(p_participants_to_add, 1) > 0 then
    insert into group_participants (group_id, user_id)
    select p_group_id, unnest(p_participants_to_add)
    on conflict do nothing;
  end if;

  -- Rimuovi partecipanti
  if array_length(p_participants_to_remove, 1) > 0 then
    delete from group_participants
    where group_id = p_group_id
      and user_id = any(p_participants_to_remove);
  end if;

  return p_group_id;
end;
$$ language plpgsql;

grant execute on function public.update_group_and_participants(uuid, text, text, uuid[], uuid[]) to authenticated;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- TRIGGERS --------------------------------------------------------------
--------------------------------------------------------------------------
-- Trigger per propagare user_id da groups a group_participants
create or replace function set_group_user_id()
returns trigger as $$
begin
  select user_id into new.group_user_id
  from groups where id = new.group_id;
  return new;
end;
$$ language plpgsql;

create trigger trg_set_group_user_id
before insert on group_participants
for each row execute function set_group_user_id();
--------------------------------------------------------------------------

-- Trigger: aggiungi automaticamente il creator come partecipante
create or replace function add_creator_as_participant()
returns trigger as $$
begin
  insert into group_participants (
    user_id,
    group_id,
    group_user_id,
    role,
    has_confirmed,
    is_enabled,
    joined_at,
    created_at,
    updated_at
  ) values (
    new.user_id,
    new.id,
    new.user_id,
    'creator',
    true,
    true,
    now(),
    now(),
    now()
  );
  return new;
end;
$$ language plpgsql;

create trigger trg_add_creator_as_participant
after insert on groups
for each row execute function add_creator_as_participant();
--------------------------------------------------------------------------
