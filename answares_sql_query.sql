-- Answer 1

-- Stored Procedure: daily_cleanup
DELIMITER //
CREATE PROCEDURE daily_cleanup()
BEGIN
    DELETE ci 
    FROM cart_items ci
    INNER JOIN carts c ON ci.cart_id = c.id
    WHERE c.created_at <= NOW() - INTERVAL 2 DAY;

    DELETE FROM carts 
    WHERE created_at <= NOW() - INTERVAL 2 DAY;
END //
DELIMITER ;

-- Scheduler to execute daily_cleanup
CREATE EVENT daily_cleanup_event
ON SCHEDULE EVERY 1 DAY
STARTS '2024-11-30 02:00:00'
DO CALL daily_cleanup();


-- Answer 2
-- mysqldump command
mysqldump --user=root --password=1234 --databases gift_shop \
--no-create-info --routines --triggers --ignore-table=gift_shop.activity_log > /backups/gift_shop_backup.sql

crontab -e

-- schedule the backup 30 minutes after daily_cleanup
30 2 * * * mysqldump --user=root --password=your_password --databases gift_shop --no-create-info --routines --triggers --ignore-table=gift_shop.activity_log > /backups/gift_shop_backup.sql


-- Answer 3
-- Add the configuration to my.cnf or my.ini

[mysqld]
-- Optimize for memory and processing power
innodb_buffer_pool_size = 48G
innodb_buffer_pool_instances = 8
innodb_log_file_size = 4G
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 2
innodb_io_capacity = 2000
innodb_thread_concurrency = 0

-- Connection and cache settings
thread_cache_size = 100
max_connections = 1000

-- Temporary table settings
tmp_table_size = 128M
max_heap_table_size = 128M

-- Restart the MySQL server

-- Answer 4
--Create View
CREATE VIEW order_data AS
SELECT 
    o.id AS order_id,
    o.created_at AS order_date,
    oi.product_id,
    oi.quantity,
    o.shipment_address,
    c.name AS customer_name,
    c.email AS customer_email,
    c.phone AS customer_phone
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN customers c ON o.customer_id = c.id;


-- Create the User and Grant Permissions
CREATE USER 'delivery_service'@'%' IDENTIFIED BY 'secure_password';
GRANT SELECT ON gift_shop.order_data TO 'delivery_service'@'%';


