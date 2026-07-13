with fact as (

    select *
    from {{ ref('fact_order_items') }}

)

select
    purchase_date_key,

    count(distinct order_id) as total_orders,
    sum(item_quantity) as total_items,
    sum(product_revenue) as product_revenue,
    sum(freight_value) as freight_revenue,
    sum(gross_item_value) as gross_revenue,
    sum(allocated_payment_value) as total_payments,

   sum(product_revenue)
    / nullif(count(distinct order_id), 0) as average_order_value

from fact

group by purchase_date_key