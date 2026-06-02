-- IMPORTANT: profiles must be created using the singin page. Then, update their ids
insert into profiles (id, username, name) values 
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', 'f', 'Francesca'),
('d8df3d10-5dbe-41b4-b4f8-c0de7fa5eaa2', 'm', 'Marco'),
('4f3507a5-51f7-45dd-95da-8ed6ed6a4ebb', 'i', 'Ilaa'),
('8e4def9e-c1c5-409c-8fc0-50d7a6d2c983', 'q', 'Quinto'),
('8e4def9e-c1c5-409c-8fc0-50d7a6d2c983', 'empty', 'empty');

insert into groups (name, link, user_id) values
('Famiglia', 'qwerty12', (select id from profiles where username = 'm')),
('Amici', 'asdfgh45', (select id from profiles where username = 'i')),
('Vacanza', 'zxcvbn78', (select id from profiles where username = 'f')),
('Regalo', 'wertyu78', (select id from profiles where username = 'i'));

insert into merchants (name, user_id) values
('Negozio 1', (select id from profiles where username = 'f')),
('Negozio 2', (select id from profiles where username = 'f')),
('Negozio 3', (select id from profiles where username = 'f'));

insert into categories (name, user_id) values
('Categoria 1', (select id from profiles where username = 'f')),
('Categoria 2', (select id from profiles where username = 'f')),
('Categoria 3', (select id from profiles where username = 'f'));

insert into group_participants (user_id, group_id, role, has_confirmed, is_enabled) values
((select id from profiles where username = 'f'), (select id from groups where name = 'Famiglia'), 'MEMBER', false, true),
((select id from profiles where username = 'f'), (select id from groups where name = 'Amici'), 'MEMBER', false, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Amici'), 'MEMBER', false, true),
((select id from profiles where username = 'm'), (select id from groups where name = 'Vacanza'), 'MEMBER', false, true);

insert into group_transactions (group_id, user_id, merchant_id, category_id, total_amount, paid_amount, note, transaction_type) values
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 100.00, 50.00, '1 hotel', 'EXPENSE'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), (select id from merchants where name = 'Negozio 2'), (select id from categories where name = 'Categoria 2'), 200.00, 100.00, '2 hotel', 'EXPENSE'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), (select id from merchants where name = 'Negozio 3'), (select id from categories where name = 'Categoria 3'), 300.00, 150.00, '3 hotel', 'EXPENSE'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 400.00, 200.00, '4 hotel', 'EXPENSE'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), (select id from merchants where name = 'Negozio 2'), (select id from categories where name = 'Categoria 2'), 500.00, 250.00, '5 hotel', 'EXPENSE'),
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), (select id from merchants where name = 'Negozio 3'), (select id from categories where name = 'Categoria 3'), 600.00, 300.00, '6 hotel', 'EXPENSE');

insert into group_transactions (group_id, user_id, total_amount, paid_amount, note, transaction_type) values
((select id from groups where name = 'Vacanza'), (select id from profiles where username = 'f'), 100.00, 100.00, '1 hotel', 'INCOME');

insert into transactions (user_id, merchant_id, category_id, note, total_amount, transaction_type) values
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 'A', 2.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 2'), (select id from categories where name = 'Categoria 2'), 'B', 3.34, 'INCOME'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 3'), (select id from categories where name = 'Categoria 3'), 'C', 4.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 'D', 5.34, 'INCOME'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 2'), (select id from categories where name = 'Categoria 2'), 'E', 6.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 3'), (select id from categories where name = 'Categoria 3'), 'F', 7.34, 'INCOME'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 'G', 8.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 2'), (select id from categories where name = 'Categoria 2'), 'H', 9.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 3'), (select id from categories where name = 'Categoria 3'), 'I', 10.34, 'INCOME'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 'J', 11.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 2'), (select id from categories where name = 'Categoria 2'), 'K', 12.34, 'EXPENSE'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 3'), (select id from categories where name = 'Categoria 3'), 'L', 13.34, 'INCOME'),
('63e05ec7-7e60-49ff-a68b-04bf2ec3a64b', (select id from merchants where name = 'Negozio 1'), (select id from categories where name = 'Categoria 1'), 'M', 14.34, 'EXPENSE');
