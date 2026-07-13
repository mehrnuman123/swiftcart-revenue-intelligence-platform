with fact as (

    select *
    from {{ ref('fact_order_items') }}

),

products as (

    select *
    from {{ ref('dim_products') }}

)

select
    p.product_key,
    p.product_id,
    p.product_category,

    count(distinct f.order_id) as total_orders,
    sum(f.item_quantity) as units_sold,
    sum(f.product_revenue) as product_revenue,
    sum(f.freight_value) as freight_value,
    sum(f.gross_item_value) as gross_revenue,

    avg(f.product_revenue) as average_selling_price,
    avg(f.delivery_days) as average_delivery_days,
    count_if(f.is_late_delivery) as late_delivery_items

from fact f

inner join products p
    on f.product_key = p.product_key

group by
    p.product_key,
    p.product_id,
    p.product_category