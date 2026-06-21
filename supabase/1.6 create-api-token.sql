--------------------------------------------------------------------------
-- Tables: API Tokens to enable programmatic access to the API for users
create table public.api_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    token_hash text not null unique,
    created_at timestamptz not null default now(),
    last_used_at timestamptz,
    revoked_at timestamptz
);

--------------------------------------------------------------------------
-- Indexes
create index idx_api_tokens_user_id on api_tokens(user_id);
create index idx_api_tokens_name on api_tokens(name);
create index idx_api_tokens_token_hash on api_tokens(token_hash);

--------------------------------------------------------------------------
-- Row Level Security (RLS)
alter table public.api_tokens enable row level security;