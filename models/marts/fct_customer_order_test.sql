with 

-- Import CTEs
customers as (
  select * from {{ source('jaffle_shop', 'customers') }}
),

orders as (
  select * from {{ source('jaffle_shop', 'orders') }}
),

payments as (
  select * from {{ source('stripe', 'payment') }}
),

-- Logical CTEs
paid_orders as (
    select 
        orders.id as order_id,
        orders.user_id as customer_id,
        orders.order_date as order_placed_at,
        orders.status as order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.first_name as customer_first_name,
        c.last_name as customer_last_name
    from orders
    left join (
        select 
            orderid as order_id,
            max(created) as payment_finalized_date,
            sum(amount) / 100.0 as total_amount_paid
        from payments
        where status <> 'fail'
        group by 1
    ) p on orders.id = p.order_id
    left join customers as c on orders.user_id = c.id 
)

-- Final CTE
select
    p.*,
    row_number() over (order by p.order_id) as transaction_seq,
    row_number() over (partition by p.customer_id order by p.order_id) as customer_sales_seq,
    x.clv_bad as customer_lifetime_value
from paid_orders p
left outer join 
(
    select
        po.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders po
    left join paid_orders t2 on po.customer_id = t2.customer_id and po.order_id >= t2.order_id
    group by 1
) x on x.order_id = p.order_id
order by p.order_id
