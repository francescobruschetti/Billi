--------------------------------------------------------------------------
-- Function: validate_api_token
create or replace function validate_api_token(
    p_token_hash text
)
returns table (
    user_id uuid,
    token_id uuid
)
language sql
security definer
as $$
    update api_tokens
    set last_used_at = now()
    where token_hash = p_token_hash
      and revoked_at is null
    returning
        api_tokens.user_id,
        api_tokens.id;
$$;

--------------------------------------------------------------------------
-- Function: validate_api_token

