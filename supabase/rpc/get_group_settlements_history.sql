CREATE OR REPLACE FUNCTION get_group_settlements_history(
  p_group_id UUID,
  p_from INT,
  p_to INT,
  p_date_start TIMESTAMPTZ DEFAULT NULL,
  p_date_end TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_settlements JSON;
  v_totals JSON;
BEGIN
  -- Pagina di settlements con dati payer e receiver
  SELECT JSON_AGG(s) INTO v_settlements
  FROM (
    SELECT
      gs.*,
      JSON_BUILD_OBJECT(
        'id', payer.id,
        'username', payer.username,
        'name', payer.name
      ) 
      AS payer,
      JSON_BUILD_OBJECT(
        'id', receiver.id,
        'username', receiver.username,
        'name', receiver.name
      )
      AS receiver
    FROM group_settlements gs
    LEFT JOIN profiles payer ON gs.payer_id = payer.id
    LEFT JOIN profiles receiver ON gs.receiver_id = receiver.id
    WHERE gs.group_id = p_group_id
      AND (p_date_start IS NULL OR gs.settled_at >= p_date_start)
      AND (p_date_end IS NULL OR gs.settled_at <= p_date_end)
    ORDER BY gs.settled_at DESC
    LIMIT  (p_to - p_from + 1)
    OFFSET p_from
  ) s;

  -- Totali sull'intero intervallo
  SELECT JSON_BUILD_OBJECT(
    'total_settled', COALESCE(SUM(amount), 0),
    'count', COUNT(*)
  ) INTO v_totals
  FROM group_settlements
  WHERE group_id = p_group_id
    AND (p_date_start IS NULL OR settled_at >= p_date_start)
    AND (p_date_end IS NULL OR settled_at <= p_date_end);

  RETURN JSON_BUILD_OBJECT(
    'settlements', COALESCE(v_settlements, '[]'::JSON),
    'totals', v_totals
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;