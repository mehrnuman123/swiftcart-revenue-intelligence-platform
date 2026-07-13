with products as (

    select *
    from {{ ref('stg_products') }}

),

category_translation as (

    select *
    from {{ ref('stg_product_category_translation') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }}
        as product_key,

    p.product_id,

    coalesce(
        ct.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) as product_category,

    p.product_name_lenght as product_name_length,
    p.product_description_lenght as product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

from products p

left join category_translation ct
    on p.product_category_name = ct.product_category_name