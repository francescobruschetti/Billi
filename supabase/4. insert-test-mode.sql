insert into expenses (creator_id, merchant_id, category_id, note, total_amount) values
('059187fc-16eb-4119-bba7-bc1e63d0dae0', 'a201f2d4-a7db-47c9-a949-28256ead3986', '6306c264-0ac1-4d06-b531-6de645f178ae', 'Groceries at Supermarket', 75.50),
('954fbba7-ba7a-4496-a809-6ce768e58047', 'a201f2d4-a7db-47c9-a949-28256ead3986', '6306c264-0ac1-4d06-b531-6de645f178ae', 'Monthly Bus Pass', 50.00),
('059187fc-16eb-4119-bba7-bc1e63d0dae0', 'a201f2d4-a7db-47c9-a949-28256ead3986', '6306c264-0ac1-4d06-b531-6de645f178ae', 'June Rent Payment', 1200.00),
('059187fc-16eb-4119-bba7-bc1e63d0dae0', 'a201f2d4-a7db-47c9-a949-28256ead3986', '6306c264-0ac1-4d06-b531-6de645f178ae', 'Streaming Service Subscription', 15.99);

insert into expense_participants (expense_id, user_id, paid_amount) values
('99b4a0b4-870d-4d46-9350-36168af203b9', '059187fc-16eb-4119-bba7-bc1e63d0dae0', 25.50),
('99b4a0b4-870d-4d46-9350-36168af203b9', '954fbba7-ba7a-4496-a809-6ce768e58047', 50.00),
('a7d8898c-0759-415a-a6ca-81efb8b1ac50', '059187fc-16eb-4119-bba7-bc1e63d0dae0', 600.00),
('a7d8898c-0759-415a-a6ca-81efb8b1ac50', '954fbba7-ba7a-4496-a809-6ce768e58047', 600.00);