with fact as (

    select *
    from {{ ref('fact_order_items') }}

),

sellers as (

    select *
    from {{ ref('dim_sellers') }}

)

select
    s.seller_key,
    s.seller_id,
    s.seller_city,
    s.seller_state,

    count(distinct f.order_id) as total_orders,
    count(distinct f.product_key) as unique_products_sold,
    sum(f.item_quantity) as total_items_sold,
    sum(f.product_revenue) as product_revenue,
    sum(f.freight_value) as freight_value,
    sum(f.gross_item_value) as gross_revenue,

    avg(f.delivery_days) as average_delivery_days,
    count_if(f.is_late_delivery) as late_delivery_items,

    count_if(f.is_late_delivery)
        / nullif(count(*), 0)::float as late_delivery_rate

from fact f

inner join sellers s
    on f.seller_key = s.seller_key

group by
    s.seller_key,
    s.seller_id,
    s.seller_city,
    s.seller_state