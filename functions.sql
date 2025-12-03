CREATE OR REPLACE FUNCTION fn_search_products(
    p_keyword      text,
    p_game         text DEFAULT NULL,
    p_product_type text DEFAULT NULL
)
    RETURNS TABLE (
                      product_id    int,
                      name          text,
                      game          text,
                      product_type  text,
                      unit_price    numeric,
                      current_stock int
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.product_id,
            p.name::text,
            p.game::text,
            p.product_type::text,
            p.unit_price,
            p.current_stock
        FROM product p
        WHERE p.is_active = TRUE
          AND (
            p_keyword IS NULL OR p_keyword = ''
                OR p.name ILIKE '%' || p_keyword || '%'
                OR p.set_name ILIKE '%' || p_keyword || '%'
            )
          AND (p_game IS NULL OR p.game = p_game)
          AND (p_product_type IS NULL OR p.product_type = p_product_type)
        ORDER BY p.game, p.name;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_low_stock_products(
    p_limit int
)
    RETURNS TABLE (
                      product_id    int,
                      name          text,
                      game          text,
                      current_stock int,
                      reorder_level int
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.product_id,
            p.name::text,
            p.game::text,
            p.current_stock,
            p.reorder_level
        FROM product p
        WHERE p.current_stock <= p.reorder_level
        ORDER BY p.current_stock
        LIMIT p_limit;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_product_detail(
    p_product_id int
)
    RETURNS TABLE (
                      product_id     int,
                      name           text,
                      game           text,
                      product_type   text,
                      rarity         text,
                      set_name       text,
                      condition      text,
                      language       text,
                      unit_price     numeric,
                      current_stock  int,
                      reorder_level  int,
                      is_active      boolean
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.product_id,
            p.name::text,
            p.game::text,
            p.product_type::text,
            p.rarity::text,
            p.set_name::text,
            p.condition::text,
            p.language::text,
            p.unit_price,
            p.current_stock,
            p.reorder_level,
            p.is_active
        FROM product p
        WHERE p.product_id = p_product_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_search_customers(
    p_keyword text
)
    RETURNS TABLE (
                      customer_id int,
                      name        text,
                      phone       text,
                      email       text
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            c.customer_id,
            c.name::text,
            c.phone::text,
            c.email::text
        FROM customer c
        WHERE p_keyword IS NULL OR p_keyword = ''
           OR c.name ILIKE '%' || p_keyword || '%'
           OR c.phone ILIKE '%' || p_keyword || '%'
           OR c.email ILIKE '%' || p_keyword || '%'
        ORDER BY c.name;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_customer_overview(
    p_customer_id int
)
    RETURNS TABLE (
                      customer_id        int,
                      name               text,
                      phone              text,
                      email              text,
                      join_date          date,
                      store_credit       numeric,
                      total_orders       int,
                      total_amount_spent numeric
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            c.customer_id,
            c.name::text,
            c.phone::text,
            c.email::text,
            c.join_date,
            c.store_credit_balance,
            COALESCE(COUNT(o.order_id), 0)::int AS total_orders,
            COALESCE(SUM(o.total_amount), 0)::numeric AS total_amount_spent
        FROM customer c
                 LEFT JOIN orders o ON o.customer_id = c.customer_id
        WHERE c.customer_id = p_customer_id
        GROUP BY c.customer_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_create_order(
    p_customer_id    int,
    p_staff_id       int,
    p_payment_method text,
    p_product_ids    int[],
    p_quantities     int[],
    p_unit_prices    numeric[]
)
    RETURNS int
    LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id   int;
    v_total      numeric := 0;
    i            int;
    v_len        int;
    v_stock      int;
BEGIN
    v_len := array_length(p_product_ids, 1);
    IF v_len IS NULL
        OR v_len <> array_length(p_quantities, 1)
        OR v_len <> array_length(p_unit_prices, 1)
    THEN
        RAISE EXCEPTION 'Array lengths mismatch';
    END IF;

    FOR i IN 1..v_len LOOP
            SELECT current_stock INTO v_stock
            FROM product
            WHERE product_id = p_product_ids[i];

            IF v_stock < p_quantities[i] THEN
                RAISE EXCEPTION 'Not enough stock for product %', p_product_ids[i];
            END IF;

            v_total := v_total + (p_quantities[i] * p_unit_prices[i]);
        END LOOP;

    INSERT INTO orders (order_datetime, total_amount, payment_method, status, customer_id, staff_id)
    VALUES (NOW(), v_total, p_payment_method, 'Completed', p_customer_id, p_staff_id)
    RETURNING order_id INTO v_order_id;

    FOR i IN 1..v_len LOOP
            INSERT INTO order_item (order_id, product_id, quantity, unit_price_at_sale)
            VALUES (v_order_id, p_product_ids[i], p_quantities[i], p_unit_prices[i]);

            UPDATE product
            SET current_stock = current_stock - p_quantities[i]
            WHERE product_id = p_product_ids[i];
        END LOOP;

    RETURN v_order_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_order_summary(
    p_order_id int
)
    RETURNS TABLE (
                      order_id       int,
                      order_datetime timestamp,
                      customer_name  text,
                      staff_name     text,
                      payment_method text,
                      status         text,
                      total_amount   numeric
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            o.order_id,
            o.order_datetime,
            c.name::text,
            s.name::text,
            o.payment_method::text,
            o.status::text,
            o.total_amount
        FROM orders o
                 JOIN customer c ON c.customer_id = o.customer_id
                 JOIN staff s ON s.staff_id = o.staff_id
        WHERE o.order_id = p_order_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_order_items(
    p_order_id int
)
    RETURNS TABLE (
                      product_name text,
                      quantity     int,
                      unit_price   numeric,
                      line_total   numeric
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.name::text,
            oi.quantity,
            oi.unit_price_at_sale,
            oi.quantity * oi.unit_price_at_sale
        FROM order_item oi
                 JOIN product p ON p.product_id = oi.product_id
        WHERE oi.order_id = p_order_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_orders_by_date_range(
    p_from date,
    p_to   date
)
    RETURNS TABLE (
                      order_id       int,
                      order_datetime timestamp,
                      customer_name  text,
                      staff_name     text,
                      total_amount   numeric,
                      payment_method text,
                      status         text
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            o.order_id,
            o.order_datetime,
            c.name::text,
            s.name::text,
            o.total_amount,
            o.payment_method::text,
            o.status::text
        FROM orders o
                 JOIN customer c ON c.customer_id = o.customer_id
                 JOIN staff s ON s.staff_id = o.staff_id
        WHERE o.order_datetime::date BETWEEN p_from AND p_to
        ORDER BY o.order_datetime;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_daily_sales_summary(
    p_date date
)
    RETURNS TABLE (
                      sales_date       date,
                      total_orders     int,
                      total_revenue    numeric,
                      avg_order_value  numeric
                  )
    LANGUAGE plpgsql
AS $$
DECLARE
    v_count int;
    v_sum   numeric;
BEGIN
    SELECT COUNT(*), COALESCE(SUM(total_amount), 0)
    INTO v_count, v_sum
    FROM orders
    WHERE order_datetime::date = p_date AND status = 'Completed';

    RETURN QUERY
        SELECT
            p_date,
            v_count,
            v_sum,
            CASE WHEN v_count > 0 THEN v_sum / v_count ELSE 0 END;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_top_selling_products(
    p_from  date,
    p_to    date,
    p_limit int
)
    RETURNS TABLE (
                      product_id     int,
                      product_name   text,
                      total_quantity int,
                      total_revenue  numeric
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.product_id,
            p.name::text AS product_name,
            SUM(oi.quantity)::int AS total_quantity,
            SUM(oi.quantity * oi.unit_price_at_sale) AS total_revenue
        FROM orders o
                 JOIN order_item oi ON oi.order_id = o.order_id
                 JOIN product p ON p.product_id = oi.product_id
        WHERE o.order_datetime::date BETWEEN p_from AND p_to
        GROUP BY p.product_id, p.name
        ORDER BY total_quantity DESC, total_revenue DESC
        LIMIT p_limit;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_revenue_by_game(
    p_from date,
    p_to   date
)
    RETURNS TABLE (
                      game          text,
                      total_revenue numeric
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.game::text,
            SUM(oi.quantity * oi.unit_price_at_sale)
        FROM orders o
                 JOIN order_item oi ON oi.order_id = o.order_id
                 JOIN product p ON p.product_id = oi.product_id
        WHERE o.order_datetime::date BETWEEN p_from AND p_to
        GROUP BY p.game
        ORDER BY total_revenue DESC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_upcoming_events(
    p_from timestamp,
    p_to   timestamp
)
    RETURNS TABLE (
                      event_id       int,
                      name           text,
                      game           text,
                      format         text,
                      event_datetime timestamp,
                      entry_fee      numeric,
                      max_players    int,
                      status         text
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            e.event_id,
            e.name::text,
            e.game::text,
            e.format::text,
            e.event_datetime,
            e.entry_fee,
            e.max_players,
            e.status::text
        FROM event e
        WHERE e.event_datetime BETWEEN p_from AND p_to
        ORDER BY e.event_datetime;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_event_participants(
    p_event_id int
)
    RETURNS TABLE (
                      customer_id int,
                      customer_name text,
                      paid_entry_fee boolean,
                      registration_datetime timestamp
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            c.customer_id,
            c.name::text,
            er.paid_entry_fee,
            er.registration_datetime
        FROM event_registration er
                 JOIN customer c ON c.customer_id = er.customer_id
        WHERE er.event_id = p_event_id
        ORDER BY er.registration_datetime;
END;
$$;

CREATE OR REPLACE FUNCTION fn_register_event_participant(
    p_event_id    int,
    p_customer_id int,
    p_paid        boolean
)
    RETURNS void
    LANGUAGE plpgsql
AS $$
DECLARE
    v_max int;
    v_count int;
BEGIN
    SELECT max_players INTO v_max
    FROM event WHERE event_id = p_event_id;

    IF v_max IS NULL THEN
        RAISE EXCEPTION 'Event % not found', p_event_id;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM event_registration
    WHERE event_id = p_event_id;

    IF v_count >= v_max THEN
        RAISE EXCEPTION 'Event % is full', p_event_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM event_registration
        WHERE event_id = p_event_id AND customer_id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Customer already registered';
    END IF;

    INSERT INTO event_registration (event_id, customer_id, registration_datetime, paid_entry_fee)
    VALUES (p_event_id, p_customer_id, NOW(), p_paid);
END;
$$;
