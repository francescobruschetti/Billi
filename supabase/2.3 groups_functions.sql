--------------------------------------------------------------------------
-- Auto-update updated_at
create or replace function update_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_update_groups
before update on groups
for each row execute function update_timestamp();

create trigger trg_update_group_participants
before update on group_participants
for each row execute function update_timestamp();

create trigger trg_update_group_transactions
before update on group_transactions
for each row execute function update_timestamp();