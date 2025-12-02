-- Drop tables if exists
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS event CASCADE;
DROP TABLE IF EXISTS event_registration CASCADE;

CREATE TABLE customer (
                          customer_id           SERIAL PRIMARY KEY,
                          name                  VARCHAR(100) NOT NULL,
                          phone                 VARCHAR(20),
                          email                 VARCHAR(150),
                          join_date             DATE DEFAULT CURRENT_DATE,
                          store_credit_balance  NUMERIC(10,2) DEFAULT 0 CHECK (store_credit_balance >= 0),
                          notes                 TEXT
);

CREATE TABLE staff (
                       staff_id     SERIAL PRIMARY KEY,
                       name         VARCHAR(100) NOT NULL,
                       role         VARCHAR(50) NOT NULL,
                       phone        VARCHAR(20),
                       hire_date    DATE DEFAULT CURRENT_DATE,
                       salary       NUMERIC(10,2) CHECK (salary >= 0)
);

CREATE TABLE product (
                         product_id     SERIAL PRIMARY KEY,
                         name           VARCHAR(150) NOT NULL,
                         game           VARCHAR(50) NOT NULL,        -- MTG, Pokemon, YuGiOh
                         product_type   VARCHAR(50) NOT NULL,        -- Single, Booster, Box, etc.
                         rarity         VARCHAR(50),                 -- optional
                         set_name       VARCHAR(100),
                         condition      VARCHAR(20),                 -- NM, LP, etc.
                         language       VARCHAR(50),
                         unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
                         current_stock  INT NOT NULL CHECK (current_stock >= 0),
                         reorder_level  INT DEFAULT 0 CHECK (reorder_level >= 0),
                         is_active      BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
                        order_id        SERIAL PRIMARY KEY,
                        order_datetime  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        total_amount    NUMERIC(10,2) CHECK (total_amount >= 0),
                        payment_method  VARCHAR(30),
                        status          VARCHAR(20) DEFAULT 'Completed',
                        customer_id     INT NOT NULL REFERENCES customer(customer_id),
                        staff_id        INT NOT NULL REFERENCES staff(staff_id)
);

CREATE TABLE order_item (
                            order_id           INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
                            product_id         INT NOT NULL REFERENCES product(product_id),
                            quantity           INT NOT NULL CHECK (quantity > 0),
                            unit_price_at_sale NUMERIC(10,2) NOT NULL CHECK (unit_price_at_sale >= 0),

                            PRIMARY KEY (order_id, product_id)
);

CREATE TABLE event (
                       event_id          SERIAL PRIMARY KEY,
                       name              VARCHAR(150) NOT NULL,
                       game              VARCHAR(50) NOT NULL,
                       format            VARCHAR(50),
                       event_datetime    TIMESTAMP NOT NULL,
                       entry_fee         NUMERIC(10,2) CHECK (entry_fee >= 0),
                       max_players       INT CHECK (max_players > 0),
                       status            VARCHAR(20) DEFAULT 'Scheduled',
                       prize_description TEXT
);

CREATE TABLE event_registration (
                                    event_id              INT NOT NULL REFERENCES event(event_id) ON DELETE CASCADE,
                                    customer_id           INT NOT NULL REFERENCES customer(customer_id),
                                    registration_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    paid_entry_fee        BOOLEAN DEFAULT FALSE,
                                    standing              INT CHECK (standing >= 1 OR standing IS NULL),
                                    prize_won             TEXT,

                                    PRIMARY KEY (event_id, customer_id)
);
