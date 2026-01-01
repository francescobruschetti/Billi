-- Policies
DROP POLICY IF EXISTS "Creator can view own expenses" ON expenses;
create policy "Creator can view own expenses"
on expenses
for select
using (creator_id = auth.uid());

DROP POLICY IF EXISTS "Participants can view own participation" ON expenses;
create policy "Participants can view own participation"
on expense_participants
for select
using (user_id = auth.uid());

-- Create view
drop view if exists creator_expenses_with_participants;
create view creator_expenses_with_participants as
select
  e.id as expense_id,
  e.note,
  e.total_amount,
  e.created_at,
  m.name as merchant_name,
  c.name as category_name,
  e.creator_id,
  json_agg(
    json_build_object(
      'user_id', ep.user_id,
      'name', u.email, -- o il campo che contiene il nome
      'paid_amount', ep.paid_amount
    )
  ) as participants
from expenses e
    left join merchants m on m.id = e.merchant_id
    left join categories c on c.id = e.category_id
    left join expense_participants ep on ep.expense_id = e.id
    left join auth.users u on u.id = ep.user_id -- Assicurati che la tabella profili abbia il campo username o name
where e.creator_id = auth.uid()
group by e.id, e.note, e.total_amount, e.created_at, m.name, c.name, e.creator_id;



