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
