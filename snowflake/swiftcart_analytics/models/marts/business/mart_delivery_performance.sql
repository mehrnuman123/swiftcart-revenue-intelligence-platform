with fact as (

    select *
    from {{ ref('fact_order_items') }}

),

customers as (

    select *
    from {{ ref('dim_customers') }}

)

select
    c.customer_state,

    count(distinct f.order_id) as total_orders,
    count(*) as total_order_items,

    avg(f.delivery_days) as average_delivery_days,
    min(f.delivery_days) as minimum_delivery_days,
    max(f.delivery_days) as maximum_delivery_days,

    count_if(f.is_late_delivery) as late_delivery_items,

    count_if(f.is_late_delivery)
        / nullif(count(*), 0)::float as late_delivery_rate,

    avg(f.freight_value) as average_freight_value,
    sum(f.freight_value) as total_freight_value

from fact f

inner join customers c
    on f.customer_key = c.customer_key

where f.order_delivered_customer_date is not null

group by c.customer_state