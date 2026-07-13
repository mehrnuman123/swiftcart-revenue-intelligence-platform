with date_bounds as (

    select
        min(cast(order_purchase_timestamp as date)) as min_date,
        max(cast(order_estimated_delivery_date as date)) as max_date

    from {{ ref('stg_orders') }}

),

numbers as (

    select
        row_number() over (order by seq4()) - 1 as day_number

    from table(generator(rowcount => 5000))

),

dates as (

    select
        dateadd(day, n.day_number, b.min_date)::date as full_date

    from numbers n
    cross join date_bounds b

    where dateadd(day, n.day_number, b.min_date)::date <= b.max_date

)

select
    to_number(to_char(full_date, 'YYYYMMDD')) as date_key,
    full_date,
    year(full_date) as year,
    quarter(full_date) as quarter,
    month(full_date) as month_number,
    monthname(full_date) as month_name,
    weekofyear(full_date) as week_of_year,
    day(full_date) as day_of_month,
    dayofweekiso(full_date) as day_of_week,
    dayname(full_date) as day_name,

    case
        when dayofweekiso(full_date) in (6, 7) then true
        else false
    end as is_weekend

from dates