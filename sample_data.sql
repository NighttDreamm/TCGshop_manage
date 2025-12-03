INSERT INTO customer (name, phone, email, join_date, store_credit_balance, notes) VALUES
    ('Kittipong Tan', '0812345678', 'kittipong@example.com', '2023-05-12', 120.00, 'Loves Pokemon singles'),
    ('Nicha Phrom', '0821122334', 'nicha@example.com', '2022-11-19', 0.00, NULL),
    ('Wirote S.', '0895566778', 'wirote@example.com', '2024-01-04', 50.00, 'Prefers MTG Draft'),
    ('Kamolchai R.', '0801112223', 'kamolchai@example.com', '2023-06-01', 0.00, NULL),
    ('Arisa M.', '0857778889', 'arisa@example.com', '2023-02-14', 15.00, 'VIP customer'),
    ('Thiti R.', '0839988776', 'thiti@example.com', '2024-02-01', 0.00, NULL),
    ('Manat C.', '0819988776', 'manat@example.com', '2023-09-10', 30.00, NULL),
    ('Patcharaporn J.', '0864433221', 'patcha@example.com', '2023-03-05', 80.00, 'Redeems credit often'),
    ('Chanon K.', '0817776665', 'chanon@example.com', '2022-12-31', 0.00, NULL),
    ('Ratchada T.', '0893332221', 'ratchada@example.com', '2024-01-18', 10.00, NULL);

INSERT INTO staff (name, role, phone, hire_date, salary) VALUES
    ('Jane Somchai', 'Cashier', '0811112222', '2022-10-10', 18000),
    ('Pramote Sirisak', 'Manager', '0893334445', '2021-07-01', 30000),
    ('Siriporn A.', 'Judge', '0825556667', '2023-03-11', 20000),
    ('Thanakorn L.', 'Cashier', '0813322455', '2022-05-14', 18000),
    ('Jirapat Mee', 'Sales', '0824455667', '2023-01-10', 17000),
    ('Wanwisa R.', 'Inventory Manager', '0835566778', '2021-12-20', 26000),
    ('Nattapong K.', 'Cashier', '0846677889', '2023-04-02', 17500),
    ('Sirirat P.', 'Sales', '0812233445', '2022-08-18', 18500),
    ('Kornkanok T.', 'Judge', '0869876543', '2023-09-01', 20000),
    ('Nathawat J.', 'Assistant', '0823344556', '2024-01-05', 15000);

INSERT INTO product (name, game, product_type, rarity, set_name, condition, language, unit_price, current_stock, reorder_level) VALUES
    ('Pikachu V', 'Pokemon', 'Single', 'Ultra Rare', 'Vivid Voltage', 'NM', 'English', 150.00, 12, 5),
    ('Charizard VSTAR', 'Pokemon', 'Single', 'Secret Rare', 'Brilliant Stars', 'NM', 'English', 850.00, 3, 2),
    ('Booster Pack - Scarlet & Violet', 'Pokemon', 'Booster', NULL, 'Scarlet & Violet', 'New', 'English', 120.00, 50, 10),
    ('Booster Box - Astral Radiance', 'Pokemon', 'Box', NULL, 'Astral Radiance', 'New', 'English', 3900.00, 8, 2),
    ('Ultra Ball (Gold)', 'Pokemon', 'Single', 'Secret Rare', 'Ultra Prism', 'LP', 'English', 450.00, 1, 1),
    ('Sol Ring', 'MTG', 'Single', 'Uncommon', 'Commander Legends', 'NM', 'English', 250.00, 14, 5),
    ('Mana Crypt', 'MTG', 'Single', 'Mythic', 'Double Masters', 'NM', 'English', 5200.00, 2, 1),
    ('MTG Draft Booster Pack', 'MTG', 'Booster', NULL, 'Wilds of Eldraine', 'New', 'English', 160.00, 40, 10),
    ('MTG Commander Deck - Fae Dominion', 'MTG', 'Deck', NULL, 'Wilds of Eldraine', 'New', 'English', 1800.00, 6, 2),
    ('Sleeves - Dragon Shield Matte Black (100)', 'Accessories', 'Sleeves', NULL, NULL, 'New', 'English', 380.00, 25, 10),
    ('Sleeves - Dragon Shield Clear (100)', 'Accessories', 'Sleeves', NULL, NULL, 'New', 'English', 380.00, 30, 10),
    ('Deck Box - Ultra Pro Plastic', 'Accessories', 'Deck Box', NULL, NULL, 'New', 'English', 120.00, 20, 5),
    ('YuGiOh Booster Pack - Photon Hypernova', 'YuGiOh', 'Booster', NULL, 'Photon Hypernova', 'New', 'English', 90.00, 36, 10),
    ('Dark Magician', 'YuGiOh', 'Single', 'Ultra Rare', 'Legendary Collection', 'NM', 'English', 700.00, 4, 1),
    ('Blue-Eyes White Dragon', 'YuGiOh', 'Single', 'Ultra Rare', 'LC01', 'NM', 'English', 900.00, 2, 1);

INSERT INTO orders (order_datetime, total_amount, payment_method, status, customer_id, staff_id) VALUES
    ('2024-01-10 14:25', 270.00, 'Cash', 'Completed', 1, 1),
    ('2024-01-10 16:10', 850.00, 'Card', 'Completed', 3, 2),
    ('2024-01-11 12:05', 120.00, 'Cash', 'Completed', 5, 1),
    ('2024-01-12 18:40', 5200.00, 'Card', 'Completed', 2, 2),
    ('2024-01-13 11:20', 3900.00, 'Card', 'Completed', 4, 1),
    ('2024-01-14 15:55', 300.00, 'Cash', 'Completed', 6, 3),
    ('2024-01-15 10:30', 380.00, 'Cash', 'Completed', 7, 1),
    ('2024-01-15 17:20', 160.00, 'Card', 'Completed', 9, 3),
    ('2024-01-16 13:45', 700.00, 'Cash', 'Completed', 8, 4),
    ('2024-01-17 17:55', 240.00, 'Card', 'Completed', 10, 6);

INSERT INTO order_item (order_id, product_id, quantity, unit_price_at_sale) VALUES
-- Order 1
(1, 1, 1, 150.00),
(1, 10, 1, 120.00),

-- Order 2
(2, 2, 1, 850.00),

-- Order 3
(3, 3, 1, 120.00),

-- Order 4
(4, 7, 1, 5200.00),

-- Order 5
(5, 4, 1, 3900.00),

-- Order 6
(6, 10, 1, 120.00),
(6, 11, 1, 180.00),

-- Order 7
(7, 10, 1, 380.00),

-- Order 8
(8, 8, 1, 160.00),

-- Order 9
(9, 14, 1, 90.00),
(9, 10, 1, 380.00),
(9, 1, 1, 150.00),

-- Order 10
(10, 3, 2, 120.00);


INSERT INTO event (name, game, format, event_datetime, entry_fee, max_players, status, prize_description) VALUES
    ('Pokemon League Night', 'Pokemon', 'Standard', '2024-02-01 18:00', 100.00, 32, 'Scheduled', 'Booster packs & playmats'),
    ('MTG Commander Meetup', 'MTG', 'Commander', '2024-02-03 17:00', 150.00, 24, 'Scheduled', 'Promo cards'),
    ('YuGiOh Tournament', 'YuGiOh', 'Advanced Format', '2024-02-05 13:00', 120.00, 32, 'Scheduled', 'Store credit prizes'),
    ('Pokemon Prerelease', 'Pokemon', 'Limited', '2024-02-10 15:00', 130.00, 48, 'Scheduled', 'Build & Battle Kit'),
    ('MTG Draft Friday', 'MTG', 'Draft', '2024-02-02 19:00', 450.00, 16, 'Scheduled', 'Draft boosters'),
    ('Pokemon Weekly Cup', 'Pokemon', 'Standard', '2024-02-15 18:00', 150.00, 32, 'Scheduled', 'Booster Box for winner'),
    ('MTG Modern Night', 'MTG', 'Modern', '2024-02-18 17:00', 200.00, 24, 'Scheduled', 'Promo pack'),
    ('YuGiOh Locals #2', 'YuGiOh', 'Advanced', '2024-02-20 14:00', 120.00, 32, 'Scheduled', 'Store Credit'),
    ('Pokemon GO League Challenge', 'Pokemon', 'GO Format', '2024-02-21 16:00', 100.00, 40, 'Scheduled', 'Exclusive promo'),
    ('MTG Sealed League', 'MTG', 'Sealed', '2024-02-22 19:00', 550.00, 20, 'Scheduled', 'Draft boosters + promos');

INSERT INTO event_registration (event_id, customer_id, paid_entry_fee) VALUES
-- Event 1 (Pokemon League Night)
    (1, 1, true),
    (1, 5, true),
    (1, 8, true),

-- Event 2 (MTG Commander Meetup)
    (2, 3, true),
    (2, 9, true),

-- Event 3 (YuGiOh Tournament)
    (3, 4, true),
    (3, 10, true),

-- Event 4 (Pokemon Prerelease)
    (4, 2, true),
    (4, 7, true),

-- Event 5 (MTG Draft Friday)
    (5, 1, true),
    (5, 6, true),
    (5, 3, true),

-- Event 6 (Pokemon Weekly Cup)
    (6, 1, true),
    (6, 4, true),
    (6, 7, true),

-- Event 7 (MTG Modern Night)
    (7, 3, true),
    (7, 6, true),
    (7, 2, true),

-- Event 8 (YuGiOh Locals #2)
    (8, 9, true),
    (8, 10, true),
    (8, 5, true),

-- Event 9 (Pokemon GO League Challenge)
    (9, 1, true),
    (9, 8, true),
    (9, 3, true),

-- Event 10 (MTG Sealed League)
    (10, 7, true),
    (10, 4, true),
    (10, 2, true);
