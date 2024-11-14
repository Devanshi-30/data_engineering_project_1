

with booking_summary as (
    select
        b.booking_id,
        b.destination_type,  -- Dimension: Destination Type
        b.destination_type_description,
        b.customer_segment_name,  -- Dimension: Customer Segment
        b.country_name,  -- Dimension: Country
        sum(b.amount_spent_usd) as total_amount_spent,  -- Measure
        count(distinct b.booking_id) as total_bookings  -- Measure
    from 
        {{ ref('int_booking_details') }} b
    group by 
        b.booking_id,
        b.destination_type,
        b.destination_type_description,
        b.customer_segment_name,
        b.country_name
)

select * from booking_summary


