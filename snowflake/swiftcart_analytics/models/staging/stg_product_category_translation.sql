with source as (

    select *
    from {{ source('raw', 'PRODUCT_CATEGORY_TRANSLATION') }}

)

select
    product_category_name,
    product_category_name_english

from source