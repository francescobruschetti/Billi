insert into groups (name, link, creator_id) values
('Famiglia', 'qwerty12', (select id from profiles where username = 'm')),
('Amici', 'asdfgh45', (select id from profiles where username = 'i')),
('Vacanza', 'zxcvbn78', (select id from profiles where username = 'f')),
('Regalo', 'wertyu78', (select id from profiles where username = 'i'));

insert into group_participants (user_id, group_id, role, has_confirmed, is_enabled) values
((select id from profiles where username = 'f'), (select id from groups where name = 'Famiglia'), 'creator', true, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Famiglia'), 'member', false, true),
((select id from profiles where username = 'f'), (select id from groups where name = 'Amici'), 'member', true, true),
((select id from profiles where username = 'i'), (select id from groups where name = 'Amici'), 'creator', true, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Amici'), 'member', false, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Vacanza'), 'member', false, true),
((select id from profiles where username = 'i'), (select id from groups where name = 'Vacanza'), 'creator', true, true),
((select id from profiles where username = 'i'), (select id from groups where name = 'Regalo'), 'creator', true, true);

insert into group_expenses (group_id, user_id, paid_amount, note) values
((select id from groups where name = 'Famiglia'), (select id from profiles where username = 'f'), 150.00, 'Spesa settimanale'),
((select id from groups where name = 'Famiglia'), (select id from profiles where username = 'm'), 75.50, 'Cena fuori'),
((select id from groups where name = 'Amici'), (select id from profiles where username = 'i'), 200.00, 'Biglietti concerto'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'm'), 500.00, 'Acconto hotel');