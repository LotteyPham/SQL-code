WITH cte1 AS (
	-- điều chỉnh số lượng nhập
     SELECT i.*
          , SUM(CASE WHEN TransactionType = 'IN' THEN 1 ELSE 0 END) OVER (PARTITION BY SKU, WarehouseCode ORDER BY TransactionDate) AS grp
       FROM inventory AS i
      WHERE TransactionType IN ('IN', 'ADJ')
     )
	, cte2 AS (
     SELECT SKU, WarehouseCode, 'IN' AS TransactionType
          , MIN(TransactionDate) AS TransactionDate
          , SUM(Qty) AS Qty
       FROM cte1
      GROUP BY WarehouseCode, SKU, grp
      UNION -- gộp giao dịch OUT tạo bảng đúng số liệu
     SELECT SKU, WarehouseCode, TransactionType, TransactionDate, Qty
       FROM inventory
      WHERE TransactionType = 'OUT'
     )
   , cumulative AS ( -- tính toán số lượng IN, OUT tích lũy
     SELECT *
          , SUM(CASE WHEN TransactionType = 'OUT' THEN Qty ELSE 0 END) OVER (PARTITION BY SKU, WarehouseCode) AS qty_out_final
          , SUM(CASE WHEN TransactionType = 'IN'  THEN Qty ELSE 0 END) OVER (PARTITION BY SKU, WarehouseCode ORDER BY TransactionDate) AS qty_in_so_far
       FROM cte2
     )
	, report AS( -- tính toán FIFO
	 SELECT SKU, WarehouseCode, TransactionType, TransactionDate
			, qty_out_final, qty_in_so_far, Qty
			, CASE WHEN qty_out_final >= qty_in_so_far  THEN 0
				   WHEN (qty_in_so_far - qty_out_final) > Qty THEN Qty
				   ELSE qty_in_so_far - qty_out_final END AS qty_final
			, DATEDIFF(day, TransactionDate, '2021-05-30') + 1  AS aging
		FROM cumulative
		WHERE TransactionType = 'IN' --and SKU='100' and WarehouseCode='WH1'
		--ORDER BY TransactionDate desc, SKU, WarehouseCode
		)
SELECT WarehouseCode,SKU, 
	SUM (qty_final) as Stock,
	SUM (CASE WHEN aging BETWEEN 0 AND 15 THEN qty_final ELSE 0 END) AS Age_0_15,
	SUM (CASE WHEN aging BETWEEN 16 AND 20 THEN qty_final ELSE 0 END) AS Age_16_20,
	SUM (CASE WHEN aging BETWEEN 21 AND 30 THEN qty_final ELSE 0 END) AS Age_21_30,
	SUM (CASE WHEN aging >30 THEN qty_final ELSE 0 END) AS Age_Over30
FROM report
GROUP BY WarehouseCode, SKU
ORDER BY WarehouseCode, SKU
