create or replace function settle_group_movements(
  p_group_id uuid,
  p_movements jsonb  -- [{receiver_id, amount}]
)
returns void
language plpgsql
security definer
as $$
declare
  v_caller_id uuid := auth.uid();
  v_movement  jsonb;
  v_receiver_id uuid;
  v_amount    numeric(10,2);
begin

  -- Validazione: il caller è partecipante attivo del gruppo
  if not exists (
    select 1 from group_participants
    where group_id = p_group_id
      and user_id = v_caller_id
      and is_enabled = true
  ) then
    raise exception 'User % is not an active participant of group %', v_caller_id, p_group_id;
  end if;

  -- Inserisce un settlement per ogni movimento
  for v_movement in select * from jsonb_array_elements(p_movements)
  loop
    v_receiver_id := (v_movement->>'receiver_id')::uuid;
    v_amount      := (v_movement->>'amount')::numeric;

    -- Validazione: amount positivo
    if v_amount <= 0 then
      raise exception 'Settlement amount must be positive, got % for receiver %', v_amount, v_receiver_id;
    end if;

    -- Validazione: receiver è partecipante attivo dello stesso gruppo
    if not exists (
      select 1 from group_participants
      where group_id = p_group_id
        and user_id = v_receiver_id
        and is_enabled = true
    ) then
      raise exception 'Receiver % is not an active participant of group %', v_receiver_id, p_group_id;
    end if;

    -- Validazione: non si può saldare se stessi
    if v_receiver_id = v_caller_id then
      raise exception 'User cannot settle a debt with themselves';
    end if;

    insert into group_settlements (
      group_id,
      payer_id,
      receiver_id,
      amount
    ) values (
      p_group_id,
      v_caller_id,
      v_receiver_id,
      v_amount
    );

  end loop;

end;
$$;

grant execute on function public.settle_group_movements(uuid, jsonb) to authenticated;