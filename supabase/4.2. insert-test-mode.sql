insert into profiles (id, username, name) values 
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', 'f', 'Francesca'),
('d8df3d10-5dbe-41b4-b4f8-c0de7fa5eaa2', 'm', 'Marco'),
('4f3507a5-51f7-45dd-95da-8ed6ed6a4ebb', 'i', 'Ilaa'),
('8e4def9e-c1c5-409c-8fc0-50d7a6d2c983', 'q', 'Quinto');

insert into groups (name, link, user_id) values
('Famiglia', 'qwerty12', (select id from profiles where username = 'm')),
('Amici', 'asdfgh45', (select id from profiles where username = 'i')),
('Vacanza', 'zxcvbn78', (select id from profiles where username = 'f')),
('Regalo', 'wertyu78', (select id from profiles where username = 'i'));

insert into group_participants (user_id, group_id, role, has_confirmed, is_enabled) values
((select id from profiles where username = 'f'), (select id from groups where name = 'Famiglia'), 'member', false, true),
((select id from profiles where username = 'f'), (select id from groups where name = 'Amici'), 'member', false, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Amici'), 'member', false, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Vacanza'), 'member', false, true);

insert into group_expenses (group_id, user_id, paid_amount, note) values
((select id from groups where name = 'Famiglia'), (select id from profiles where username = 'f'), 150.00, 'Spesa settimanale'),
((select id from groups where name = 'Famiglia'), (select id from profiles where username = 'm'), 75.50, 'Cena fuori'),
((select id from groups where name = 'Amici'), (select id from profiles where username = 'i'), 200.00, 'Biglietti concerto'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'm'), 500.00, 'Acconto hotel');