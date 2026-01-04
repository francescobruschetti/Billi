--------------------------------------------------------------------------
-- Get all groups cotaining the user as participant or creator
create or replace function public.get_user_groups()
returns table (
  id uuid,
  name text,
  link char(8),
  creator_id uuid,
  created_at timestamptz,  -- must match table (timestamp with time zone)
  updated_at timestamptz   -- must match table (timestamp with time zone)
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
    g.creator_id,
    g.created_at,
    g.updated_at
  from groups g
  left join group_participants gp
    on gp.group_id = g.id
  where
    g.creator_id = auth.uid()
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

grant execute on function public.get_user_by_email_or_username(text, text) to authenticated;
--------------------------------------------------------------------------