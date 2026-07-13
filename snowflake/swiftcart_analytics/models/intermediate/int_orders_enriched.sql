with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

payments as (

    select
        order_id,
        sum(payment_value) as total_payment,
        max(payment_type) as payment_type,
        sum(payment_installments) as total_installments
    from {{ ref('stg_payments') }}
    group by order_id

),

order_items as (

    select
        order_id,
        count(*) as total_items,
        sum(price) as total_product_value,
        sum(freight_value) as total_freight
    from {{ ref('stg_order_items') }}
    group by order_id

)

select

    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    o.order_status,

    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_customer_date,

    oi.total_items,
    oi.total_product_value,
    oi.total_freight,

    p.total_payment,
    p.payment_type,
    p.total_installments

from orders o

left join customers c
    on o.customer_id = c.customer_id

left join order_items oi
    on o.order_id = oi.order_id

left join payments p
    on o.order_id = p.order_id