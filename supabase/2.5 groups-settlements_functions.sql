--------------------------------------------------------------------------
-- Auto-update settled_at
create or replace function update_group_settlements_settled_at()
returns trigger as $$
begin
  new.settled_at = now();
  return new;
end;
$$ language plpgsql;

create or replace trigger trg_update_group_settlements
before update on group_settlements
for each row execute function update_group_settlements_settled_at();