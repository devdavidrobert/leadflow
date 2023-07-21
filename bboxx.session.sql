select distinct 
    c.unique_account_id AS unique_customer_id,
    o.shop_name AS shop,
    cpd.customer_name AS client_name,
    c.current_customer_status AS customer_status,
    cpd.customer_phone_1 AS phone_1,
    cpd.customer_phone_2 AS phone_2,
    cpd.customer_home_address AS nearest_landmark,
    cpd.home_address_4 AS ward,
    cpd.home_address_3 AS constituency,
    cpd.home_address_2 AS county,
    sa.username AS agent_id,
    sa.sales_agent_name AS sales_agent_name,
    TO_CHAR(c.customer_active_start_date, 'YYYY-MM-DD')  AS install_date,
    t.username AS installer_id,
    t.technician_name AS installer,
    TO_CHAR(c.customer_active_end_date, 'YYYY-MM-DD')  AS repossession_date,
    rpcl.serial_number AS serial_number,
--    count(c.unique_account_id)as total,
    rpcl.current_system
--    t2.technician_name ,
--    t2.username ,
--    dcs.daily_rate 
--    c.account_id --,
--    min(ccu.record_active_start_date) 
--    ccu.control_unit_id ,
--    cu.control_unit_id 
--    i.installation_type --,
--    i.installation_date ,
--    i.installation_status ,
--    i.order_write_date ,
--    i.sales_order_id ,
--    ccu.record_active_start_date 
FROM 
    kenya.customer c
left JOIN 
    kenya.customer_personal_details cpd 
ON 
    c.unique_account_id = cpd.unique_account_id 
left JOIN 
    kenya.rp_portfolio_customer_lookup rpcl  
ON 
    c.unique_account_id  = rpcl.unique_customer_id 
left JOIN 
    kenya.organisation o 
ON 
    c.shop_erp_id = o.shop_erp_id 
left JOIN 
    kenya.installations i 
ON 
    c.customer_id = i.customer_id 
left JOIN 
    kenya.technician t 
ON 
    i.technician_id = t.technician_id 
left JOIN 
    kenya.sales_agent sa 
ON 
   c.sign_up_sales_agent_id = sa.sales_agent_id
left join 
	kenya.sales s 
	on 
	c.unique_account_id = s.unique_account_id 
left join 
kenya.repossession r 
on 
c.account_id = r.account_id 
left join 
kenya.technician t2 
on 
r.technician_id = t2.technician_id 
left join 
kenya.daily_customer_snapshot dcs 
on 
c.account_id =dcs.account_id 
--where 
--	c.customer_active_start_date notnull 
--	and
--	rpcl.current_system = 'nuovopay'
--	c.customer_active_start_date >= '2023-07-11 00:00:00'
--	and 
--	c.customer_active_end_date < '2023-07-01 00:00:00'
--	and 
--	c.customer_active_start_date notnull 
--	and 
--	c.current_customer_status like '%repo%'
--	and 
--	t.technician_id isnull 
--	and 
--	c.unique_account_id = 'BXCK67909195'
--	and 
--	c.unique_account_id = 'BXCK67960207'
--	and 
--	rpcl.serial_number isnull
--	or c.unique_account_id = 'BXCK67955376'
--	and 
--	i.installation_date = c.customer_active_start_date 
--	and 
--	ccu.record_active_start_date >= i.installation_date
--	and 
--	cpd.customer_national_id_number like '%28450073%'
--	and
--	c.unique_account_id != 'BXCK22136131'
--	and
--	rpcl.serial_number = '351962796518310'
--	i.scheds_account_id = c.unique_account_id 
--	and
--	ccu.record_active is true
--	and 
--	i.sales_order_id = c.unique_account_id 
--	and ccu.record_active_start_date = cu.record_active_start_date
--	cpd.customer_national_id_number = '21843906'
GROUP by 
	c.unique_account_id,
    o.shop_name,
    cpd.customer_name,
    c.current_customer_status,
    cpd.customer_phone_1,
    cpd.customer_phone_2,
    cpd.customer_home_address,
    cpd.home_address_4,
    cpd.home_address_3,
    cpd.home_address_2,
    sa.username,
    sa.sales_agent_name,
    c.customer_active_start_date,
    t.username,
    t.technician_name,
    c.customer_active_end_date ,
    rpcl.serial_number ,
    rpcl.current_system 
--    t2.technician_name ,
--    t2.username ,
--    dcs.daily_rate 
--    c.account_id 
--    ccu.control_unit_id ,
--    cu.control_unit_id ,
--    i.installation_type --,
--    i.installation_date ,
--    i.installation_status ,
--    i.order_write_date ,
--    i.sales_order_id ,
--    ccu.record_active_start_date 
--	order by i.installation_date asc 
--    limit 1
    
-- select distinct 
--     		c.unique_account_id ,
--     		cu.serial_number ,
--     		to_char(cu.record_active_start_date , 'YYYY-MM-DD HH:MM:SS') as active_start_date,
--     		to_char(cu.record_active_end_date , 'YYYY-MM-DD HH:MM:SS') as active_end_date,
--     		cu.record_active 
--     from kenya.customer c 
--     left join
--     kenya.customer_control_unit_link ccul  
--     on 
--     c.account_id = ccul.account_id 
--     left join 
--     kenya.control_unit cu 
--     on
--     ccul.control_unit_id = cu.control_unit_id 
--     where 
--     unique_account_id = 'BXCK00000026'
-- --    and 
-- --    cu.record_active is true 
    
    
    
-- select * 
-- from kenya.technical_issues ti 
-- where ti.is_tampered is true 
-- and ti.
-- limit 10;