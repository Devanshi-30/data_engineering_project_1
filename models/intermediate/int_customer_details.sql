-- models/intermediate/int_customer_details.sql

with customer as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.phone_number,
        c.address,
        c.segment_id,
        c.country,
        -- Join with customer_segments to add segment name
        s.segment_name as customer_segment_name,
        -- Join with country_codes to add country name
        co.country_name as country_name
    from 
        {{ ref('stg_customer_details') }} c
    left join 
        {{ ref('customer_segments') }} s on c.segment_id = s.segment_id
    left join 
        {{ ref('country_codes') }} co on c.country = co.country_name
)

select * from customer
