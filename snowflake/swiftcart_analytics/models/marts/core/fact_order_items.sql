{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='order_item_key',
        on_schema_change='sync_all_columns'
    )
}}


with order_items as (

    select *
    from {{ ref('stg_order_items') }}

    {% if is_incremental() %}

        where shipping_limit_date >= (
            select dateadd(day, -3, max(shipping_limit_date))
            from {{ this }}
        )

    {% endif %}

),

orders as (

    select *
    from {{ ref('stg_orders') }}

),

customers as (

    select *
    from {{ ref('stg_customers') }}

),

payments_by_order as (

    select
        order_id,
        sum(payment_value) as order_payment_value

    from {{ ref('stg_payments') }}

    group by order_id

),

order_item_totals as (

    select
        order_id,
        sum(price + freight_value) as order_items_gross_value

    from order_items

    group by order_id

),

joined as (

    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,

        c.customer_unique_id,

        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        oi.shipping_limit_date,
        oi.price,
        oi.freight_value,

        p.order_payment_value,
        oit.order_items_gross_value

    from order_items oi

    inner join orders o
        on oi.order_id = o.order_id

    left join customers c
        on o.customer_id = c.customer_id

    left join payments_by_order p
        on oi.order_id = p.order_id

    left join order_item_totals oit
        on oi.order_id = oit.order_id

)

select
    {{ dbt_utils.generate_surrogate_key([
        'order_id',
        'order_item_id'
    ]) }} as order_item_key,

    order_id,
    order_item_id,

    {{ dbt_utils.generate_surrogate_key(['customer_unique_id']) }}
        as customer_key,

    {{ dbt_utils.generate_surrogate_key(['product_id']) }}
        as product_key,

    {{ dbt_utils.generate_surrogate_key(['seller_id']) }}
        as seller_key,

    to_number(to_char(order_purchase_timestamp, 'YYYYMMDD'))
        as purchase_date_key,

    product_id,
    seller_id,
    customer_unique_id,

    order_status,

    order_purchase_timestamp,
    order_approved_at,
    shipping_limit_date,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    1 as item_quantity,

    price as product_revenue,
    freight_value,
    price + freight_value as gross_item_value,

    case
        when order_items_gross_value > 0 then
            order_payment_value
            * ((price + freight_value) / order_items_gross_value)
        else 0
    end as allocated_payment_value,

    datediff(
        day,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) as delivery_days,

    case
        when order_delivered_customer_date
             > order_estimated_delivery_date
        then true
        else false
    end as is_late_delivery

from joined