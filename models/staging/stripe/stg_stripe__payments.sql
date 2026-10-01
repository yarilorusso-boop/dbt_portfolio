with source as (

    select * from {{ source('stripe', 'payment') }}

),

renamed as (

    select
        id as payment_id,
        orderid as order_id,
        paymentmethod as  payment_method,
        status,
        ----amount is stored in cents, so we need to convert it to dollars
        {{ cent_to_dollar('amount', 4) }} as amount,
        CREATED as created_at,
        _batched_at

    from source

)

select * from renamed