grant usage on schema public to authenticated;

--------------------------------------------------------------------------
-- GroupRoles (ENUMS)
create type group_role_enum as enum ('ADMIN', 'CREATOR', 'MEMBER');

-- TransactionTypes (ENUMS)
create type transaction_type_enum as enum ('INCOME', 'EXPENSE');

-- SplitRateEnum (ENUMS)
create type split_rate_enum as enum ('ONE_QUARTER', 'HALF', 'THREE_QUARTERS', 'EVENLY', 'ZERO', 'CUSTOM_PERCENTAGE', 'FIXED_1', 'FIXED_2', 'FIXED_3', 'FIXED_4', 'CUSTOM_FIXED', 'FIXED_AMOUNT');