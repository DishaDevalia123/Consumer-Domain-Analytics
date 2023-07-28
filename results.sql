/*1*/
select distinct market from dim_customer where customer = "Atliq Exclusive" and region = 'APAC';

/*2*/
SELECT
    COUNT(DISTINCT CASE WHEN fiscal_year = '2020' THEN product_code END) AS unique_product_2020,
    COUNT(DISTINCT CASE WHEN fiscal_year = '2021' THEN product_code END) AS unique_product_2021,
    (COUNT(DISTINCT CASE WHEN fiscal_year = '2021' THEN product_code END) - COUNT(DISTINCT CASE WHEN fiscal_year = '2020' THEN product_code END)) * 100 / COUNT(DISTINCT CASE WHEN fiscal_year = '2020' THEN product_code END) AS percentage_chg
FROM
    fact_sales_monthly;
    
/*3*/
SELECT
    segment,
    COUNT(DISTINCT product_code) AS product_count
FROM
    dim_product
GROUP BY
    segment
ORDER BY
    product_count DESC;
    
/*4*/
SELECT
    d.segment,
    COUNT(DISTINCT CASE WHEN f.fiscal_year = '2020' THEN f.product_code END) AS product_count_2020,
    COUNT(DISTINCT CASE WHEN f.fiscal_year = '2021' THEN f.product_code END) AS product_count_2021,
    COUNT(DISTINCT CASE WHEN f.fiscal_year = '2021' THEN f.product_code END) - COUNT(DISTINCT CASE WHEN f.fiscal_year = '2020' THEN f.product_code END) AS difference
FROM
    dim_product AS d
JOIN
    fact_sales_monthly AS f ON d.product_code = f.product_code
GROUP BY
    d.segment
ORDER BY
    difference DESC;

/*5*/
SELECT
    d.product_code,
    d.product,
    f.manufacturing_cost
FROM
    dim_product d
JOIN
    fact_manufacturing_cost f ON d.product_code = f.product_code
WHERE
    f.manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
    OR f.manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost);

/*6*/
select 
	c.market,
	d.customer_code,
    c.customer,
	avg(d.pre_invoice_discount_pct) as average_discount_percentage
from
	dim_customer c
join
	fact_pre_invoice_deductions d on c.customer_code = d.customer_code
where 
    d.fiscal_year = '2021'
group by 
	c.market, c.customer_code, c.customer
order by
	average_discount_percentage desc
LIMIT 5;

/*7*/
SELECT
    dc.customer,
    MONTH(fm.date) AS Month,
    YEAR(fm.date) AS Year,
    ROUND(SUM(gp.gross_price * fm.sold_quantity), 2) AS Gross_sales_Amount
FROM
    fact_sales_monthly fm
    INNER JOIN dim_customer dc ON fm.customer_code = dc.customer_code
    INNER JOIN fact_gross_price gp ON fm.product_code = gp.product_code
GROUP BY
    dc.customer, MONTH(fm.date), YEAR(fm.date)
ORDER BY
    dc.customer, YEAR(fm.date), MONTH(fm.date);

/*8*/
SELECT
    CASE
        WHEN MONTH(date) BETWEEN 9 AND 11 THEN 'Q1'
        WHEN MONTH(date) BETWEEN 12 AND 2 THEN 'Q2'
        WHEN MONTH(date) BETWEEN 3 AND 5 THEN 'Q3'
        WHEN MONTH(date) BETWEEN 6 AND 8 THEN 'Q4'
    END AS quarter,
    SUM(sold_quantity) AS total_sold_quantity,
    product_code
FROM
    fact_sales_monthly
WHERE
    YEAR(date) = 2020
GROUP BY
    quarter
ORDER BY
    total_sold_quantity DESC;

SELECT
	product_code,
    MONTH(date) AS month,
    SUM(sold_quantity) AS total_quantity
FROM
    fact_sales_monthly
WHERE
    YEAR(date) = 2020 OR (YEAR(date) = 2019 AND MONTH(date) >= 9)
GROUP BY
    MONTH(date)
ORDER BY
    total_quantity desc;



/*9*/
SELECT
  dc.channel,
  ROUND(SUM(fgp.gross_price * fsm.sold_quantity) / 1000000, 2) AS gross_sales_mln,
  ROUND(SUM(fgp.gross_price * fsm.sold_quantity) / 
    (SELECT SUM(fgp.gross_price * fsm.sold_quantity) 
    FROM fact_sales_monthly fsm, dim_customer dc, fact_gross_price fgp 
    WHERE fsm.fiscal_year = 2021 
    AND fsm.customer_code = dc.customer_code 
    AND fsm.product_code = fgp.product_code) * 100, 2) AS percentage
FROM
  fact_sales_monthly fsm, dim_customer dc, fact_gross_price fgp
WHERE
  fsm.fiscal_year = 2021
  AND fsm.customer_code = dc.customer_code
  AND fsm.product_code = fgp.product_code
GROUP BY
  dc.channel
ORDER BY
  gross_sales_mln DESC
LIMIT 1;

/*10*/
SELECT
  division,
  product_code,
  product,
  total_sold_quantity,
  rank_order
FROM (
  SELECT
    dp.division,
    fsm.product_code,
    dp.product,
    SUM(fsm.sold_quantity) AS total_sold_quantity,
    RANK() OVER (PARTITION BY dp.division ORDER BY SUM(fsm.sold_quantity) DESC) AS rank_order
  FROM
    fact_sales_monthly fsm
  JOIN
    dim_product dp ON fsm.product_code = dp.product_code
  WHERE
    fsm.fiscal_year = 2021
  GROUP BY
    dp.division, fsm.product_code, dp.product
) subquery
WHERE
  rank_order <= 3
ORDER BY
  division ASC,
  rank_order ASC;








    




SELECT
    dc.customer,
    MONTH(fm.date) AS Month,
    YEAR(fm.date) AS Year,
    ROUND(SUM(gp.gross_price * fm.sold_quantity), 2) AS Gross_sales_Amount
FROM
    fact_sales_monthly fm,
    dim_customer dc,
    fact_gross_price gp
WHERE
    fm.customer_code = dc.customer_code
    AND fm.product_code = gp.product_code
GROUP BY
    dc.customer, MONTH(fm.date), YEAR(fm.date)
ORDER BY
    dc.customer, YEAR(fm.date), MONTH(fm.date);
SELECT
    dc.customer,
    MONTH(fm.date) AS Month,
    YEAR(fm.date) AS Year,
    ROUND(SUM(gp.gross_price * fm.sold_quantity), 2) AS Gross_sales_Amount
FROM
    fact_sales_monthly fm,
    dim_customer dc,
    fact_gross_price gp
WHERE
    fm.customer_code = dc.customer_code
    AND fm.product_code = gp.product_code
GROUP BY
    dc.customer, MONTH(fm.date), YEAR(fm.date)
ORDER BY
    dc.customer, YEAR(fm.date), MONTH(fm.date);
