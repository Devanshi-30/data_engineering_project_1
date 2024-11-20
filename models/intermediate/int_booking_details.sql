

{{
    config(
        materialized='incremental',  
        unique_key='booking_id', 
        incremental_strategy='merge', 
        updated_at='updated_at',
        pre_hook=[
            "insert into TRAVEL_DB.dbt_dagarwal.model_run_log (model_name, run_time, status) values ('int_booking_details', current_timestamp(), 'start')"
        ],
        post_hook=[
            "insert into TRAVEL_DB.dbt_dagarwal.model_run_log (model_name, run_time, status) values ('int_booking_details', current_timestamp(), 'success')"
        ]
         
    )

    
  }}

  


-- SQL for the model
with booking as (
    select
        b.booking_id as booking_id,
        b.customer_id,
        b.destination_type,
        d.description as destination_type_description,
        b.booking_date,
        b.booking_time,
        b.amount_spent,
        b.currency_code,
        b.status,
        b.segment_id,
        s.segment_name as customer_segment_name,
        co.country_name,
        b.booking_time as updated_at, 
        case 
            when b.currency_code = 'EUR' then b.amount_spent / coalesce(dur.exchange_rate_to_usd, 1)
            when b.currency_code = 'CAD' then b.amount_spent / coalesce(dur.exchange_rate_to_usd, 1)
            when b.currency_code = 'INR' then b.amount_spent / coalesce(dur.exchange_rate_to_usd, 1)
            else b.amount_spent 
        end as amount_spent_usd,
    from 
        {{ ref('stg_booking_details') }} b
    left join 
        {{ ref('destination_types') }} d on b.destination_type = d.destination_type
    left join 
        {{ ref('customer_segments') }} s on b.segment_id = s.segment_id
    left join
        {{ ref('country_codes') }} co on b.country_code = co.country_code
    left join
        {{ ref('currency_exchange_rates') }} dur on b.currency_code = dur.currency_code
)

select * from booking
{% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})  -- Only select records that have been updated since the last run
{% endif %}


