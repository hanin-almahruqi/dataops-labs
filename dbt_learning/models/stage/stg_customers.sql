with source as (
    select * from {{ ref('raw_customers') }}
),

cleaned as (
    select
        customer_id::text                             as customer_id,

        trim(first_name)::text                        as first_name,
        trim(last_name)::text                         as last_name,

        trim(first_name || ' ' || last_name)::text    as customer_name,

        lower(trim(email))::text                      as email,
        trim(phone)::text                             as phone,

        signup_date::date                             as signup_date,

        trim(country)::text                           as country,
        trim(city)::text                              as city

    from source
)

select * from cleaned