
/* 
	Create a column of natural sequential numbers
*/

CREATE FUNCTION [dbo].[GenerateSequentialNumbers](@max int)
RETURNS TABLE 
AS
RETURN  
  WITH 
    l0 AS (SELECT 1 AS c UNION ALL SELECT 1), -- 2 entries
    l1 AS (SELECT 1 AS c from l0 AS a CROSS JOIN l0 AS b), -- 2^2 entries
    l2 AS (SELECT 1 AS c from l1 AS a CROSS JOIN l1 AS b), -- 2^4 entries
    l3 AS (SELECT 1 AS c from l2 AS a CROSS JOIN l2 AS b), -- 2^8 entries
    l4 AS (SELECT 1 AS c from l3 AS a CROSS JOIN l3 AS b), -- 2^16 entries
    l5 AS (SELECT 1 AS c from l4 AS a CROSS JOIN l4 AS b), -- 2^32 entries
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS number FROM l5)
    SELECT TOP (@max) number FROM Nums ORDER BY number;