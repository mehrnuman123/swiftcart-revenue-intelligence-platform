with customers as (

    select *
    from {{ ref('stg_customers') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['customer_unique_id']) }}
        as customer_key,

    customer_unique_id,
    max(customer_city) as customer_city,
    max(customer_state) as customer_state,
    max(customer_zip_code_prefix) as customer_zip_code_prefix

from customers

group by customer_unique_id