CREATE OR REPLACE FUNCTION get_personal_transactions(
  p_user_id UUID,
  p_from INT, -- Indice di partenza (pagination offset)
  p_to INT, -- Indice di fine (pagination offset + limit)
  p_date_start TIMESTAMPTZ DEFAULT NULL,
  p_date_end TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_transactions JSON;
  v_totals JSON;
BEGIN
  -- Pagina di transazioni
  SELECT JSON_AGG(t) INTO v_transactions
  FROM (
    SELECT
      tx.*,
      TO_JSON(m.*) AS merchant,
      TO_JSON(c.*) AS category
    FROM transactions tx
    LEFT JOIN merchants m ON tx.merchant_id = m.id
    LEFT JOIN categories c ON tx.category_id = c.id
    WHERE tx.user_id = p_user_id
      AND (p_date_start IS NULL OR tx.created_at >= p_date_start)
      AND (p_date_end IS NULL OR tx.created_at <= p_date_end)
    ORDER BY tx.created_at DESC -- Ordina per data più recente
    LIMIT (p_to - p_from + 1) -- Numero di transazioni da restituire
    OFFSET p_from
  ) t;

  -- Totali sull'intero intervallo (non solo la pagina)
  SELECT JSON_BUILD_OBJECT(
    'total_incomes', COALESCE(SUM(CASE WHEN transaction_type = 'INCOME' THEN total_amount ELSE 0 END), 0),
    'total_expenses', COALESCE(SUM(CASE WHEN transaction_type = 'EXPENSE' THEN total_amount ELSE 0 END), 0),
    'balance', COALESCE(SUM(
      CASE 
        WHEN transaction_type = 'INCOME' THEN total_amount 
        WHEN transaction_type = 'EXPENSE' THEN -total_amount 
        ELSE 0 
      END
    ), 0)
  ) INTO v_totals
  FROM transactions
  WHERE user_id = p_user_id
    AND (p_date_start IS NULL OR created_at >= p_date_start)
    AND (p_date_end IS NULL OR created_at <= p_date_end);

  RETURN JSON_BUILD_OBJECT(
    'transactions', COALESCE(v_transactions, '[]'::JSON),
    'totals', v_totals
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;