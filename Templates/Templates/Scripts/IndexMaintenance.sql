
/*** Show index fragmentation ***/

DECLARE @db_id SMALLINT, @object_id INT;

SET @db_id = DB_ID(N'WideWorldImporters');

SET @object_id = OBJECT_ID(N'WideWorldImporters.Sales.Orders');

SELECT 
	ixs.index_id                   AS idx_id,
    ix.[name]                      AS ObjectName,
    index_type_desc,
    page_count,
    avg_page_space_used_in_percent AS AvgPageSpacePct,
    fragment_count                 AS frag_ct,
    avg_fragmentation_in_percent   AS AvgFragPct
FROM sys.dm_db_index_physical_stats (@db_id, @object_id, NULL, NULL, 'Detailed') ixs
    INNER JOIN sys.indexes ix ON ixs.index_id = ix.index_id
		AND ixs.object_id = ix.object_id
ORDER BY avg_fragmentation_in_percent DESC;


/*** Show index usage ***/

SELECT
    OBJECT_NAME(ixu.object_id, DB_ID('WideWorldImporters')) AS [object_name] ,
    ix.[name]                                               AS index_name ,
    ixu.user_seeks + ixu.user_scans + ixu.user_lookups      AS user_reads,
    ixu.user_updates                                        AS user_writes
FROM sys.dm_db_index_usage_stats ixu
    INNER JOIN WideWorldImporters.sys.indexes ix ON ixu.[object_id] = ix.[object_id] AND 
													ixu.index_id = ix.index_id
WHERE ixu.database_id = DB_ID('WideWorldImporters')
ORDER BY user_reads DESC;


/*** Show overlapping indexes ***/

WITH IndexColumns AS (
    SELECT '[' + s.Name + '].[' + T.Name + ']' AS TableName,
           ix.name                             AS IndexName,
           c.name                              AS ColumnName,
           ix.index_id,
           ixc.index_column_id,
           COUNT(*) OVER (PARTITION BY t.OBJECT_ID, ix.index_id) AS ColumnCount
    FROM sys.schemas AS S
    JOIN sys.tables  AS t  ON t.schema_id = S.schema_id
    JOIN sys.indexes AS ix ON ix.OBJECT_ID = t.OBJECT_ID
    JOIN sys.index_columns AS ixc ON ixc.OBJECT_ID = ix.OBJECT_ID AND
                                     ixc.index_id = ix.index_id
    JOIN sys.columns AS c ON c.OBJECT_ID = ixc.OBJECT_ID AND
                             c.column_id = ixc.column_id
    WHERE ixc.is_included_column = 0
      AND LEFT(ix.name, 2) NOT IN ('PK', 'UQ', 'FK'))
SELECT DISTINCT ix1.TableName, ix1.IndexName AS Index1, ix2.IndexName AS Index2
FROM IndexColumns AS ix1
	JOIN IndexColumns AS ix2 ON ix1.TableName = ix2.TableName AND
	                            ix1.IndexName <> ix2.IndexName AND
	                            ix1.index_column_id = ix2.index_column_id AND
	                            ix1.ColumnName = ix2.ColumnName AND
	                            ix1.index_column_id < 3 AND
	                            ix1.index_id < ix2.index_id AND
	                            ix1.ColumnCount <= ix2.ColumnCount
ORDER BY ix1.TableName, ix2.IndexName;


/*** Show unused indexes ***/

SELECT
    OBJECT_NAME(ix.object_id) AS ObjectName,
    ix.name
FROM sys.indexes AS ix
    INNER JOIN sys.objects AS o ON ix.object_id = o.object_id
WHERE ix.index_id NOT IN (
    SELECT ixu.index_id 
    FROM sys.dm_db_index_usage_stats AS ixu
    WHERE ixu.object_id = ix.object_id AND
          ixu.index_id = ix.index_id AND
          database_id = DB_ID()
) AND o.[type] = 'U'
ORDER BY OBJECT_NAME(ix.object_id) ASC;


/*** Show updated but never used indexes ***/

SELECT
    o.name                                             AS ObjectName,
    ix.name                                            AS IndexName,
    ixu.user_seeks + ixu.user_scans + ixu.user_lookups AS user_reads,
    ixu.user_updates                                   AS user_writes,
    SUM(p.rows)                                        AS total_rows
FROM sys.dm_db_index_usage_stats ixu
    INNER JOIN sys.indexes ix ON ixu.object_id = ix.object_id AND
                                 ixu.index_id = ix.index_id
    INNER JOIN sys.partitions p ON ixu.object_id = p.object_id AND
                                   ixu.index_id = p.index_id
    INNER JOIN sys.objects o ON ixu.object_id = o.object_id
WHERE ixu.database_id = DB_ID() AND
      OBJECTPROPERTY(ixu.object_id, 'IsUserTable') = 1 AND
      ixu.index_id > 0
GROUP BY
    o.name,
    ix.name,
    ixu.user_seeks + ixu.user_scans + ixu.user_lookups,
    ixu.user_updates
HAVING ixu.user_seeks + ixu.user_scans + ixu.user_lookups = 0
ORDER BY ixu.user_updates DESC, o.name, ix.name;