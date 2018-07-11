
WITH
 target_user_list AS
 (
    SELECT
     open_id
    FROM
     common_i3.activity_push
    WHERE
     dt BETWEEN '{{集計開始日}}' AND '{{集計終了日}}'
     AND option = 'optin'
 )
 , data_purchase AS
 (
    SELECT
     member_id
     , basket_service_type
     , MIN(purchase_date) AS min_time
    FROM
     common_purchase.v_view_purchase_detail
    WHERE
     dt >= '1998-08-11'
     AND status = 'success'
     AND member_id LIKE 'D100%'
    GROUP BY
     member_id
     , basket_service_type
 )
 , data_point AS
 (
    SELECT
     account_id AS member_id
     , client_type AS basket_service_type
     , MIN(transaction_date) AS min_time
    FROM
     common_emoney.v_history_view
    WHERE
     dt >= '1998-08-11'
     AND transaction_type = 'use'
     AND account_id LIKE 'D100%'
    GROUP BY
     account_id
     , client_type
 )
 , union_purchase_point AS
 (
    SELECT
     member_id
     , basket_service_type
     , min_time
    FROM
     data_purchase
    
    UNION ALL

    SELECT
     member_id
     , basket_service_type
     , min_time
    FROM
     data_point
 )
 , data_first_date AS
 (
    SELECT
     member_id
     , MIN(min_time) AS first_buy_time
    FROM
     union_purchase_point
    GROUP BY
     member_id
 )
 , join_first_buy AS
 (
    SELECT
     t1.member_id
     , t2.basket_service_type
    FROM
     data_first_date AS t1
      JOIN
       union_purchase_point AS t2
      ON
       t1.member_id = t2.member_id
       AND t1.first_buy_time = t2.min_time
 )


SELECT
 basket_service_type
 , COUNT(DISTINCT member_id) AS dis_uu
FROM
 join_first_buy
GROUP BY
 basket_service_type
ORDER BY
 COUNT(DISTINCT member_id) DESC


LIMIT 1000
