with fact as (

    select *
    from {{ ref('fact_order_items') }}

),

customers as (

    select *
    from {{ ref('dim_customers') }}

),

customer_orders as (

    select
        customer_key,
        count(distinct order_id) as total_orders,
        min(order_purchase_timestamp) as first_purchase_timestamp,
        max(order_purchase_timestamp) as last_purchase_timestamp,
        sum(product_revenue) as lifetime_product_revenue,
        sum(gross_item_value) as lifetime_gross_revenue,
        sum(allocated_payment_value) as lifetime_payment_value

    from fact

    group by customer_key

)

select
    c.customer_key,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    co.total_orders,
    co.first_purchase_timestamp,
    co.last_purchase_timestamp,
    co.lifetime_product_revenue,
    co.lifetime_gross_revenue,
    co.lifetime_payment_value,

    datediff(
        day,
        co.first_purchase_timestamp,
        co.last_purchase_timestamp
    ) as customer_lifetime_days,

    case
        when co.total_orders > 1 then true
        else false
    end as is_repeat_customer

from customer_orders co

inner join customers c
    on co.customer_key = c.customer_key