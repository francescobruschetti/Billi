-- Give all privileges to the service_role user on the public schema
grant usage on schema public to service_role;

-- Give all privileges to the service_role user on the public transactions table (to allow edge function to interact with it)
grant all privileges
on table public.transactions
to service_role;