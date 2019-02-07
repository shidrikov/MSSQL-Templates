
/* Most expensive queries */

DECLARE @db_name_pattern NVARCHAR(100) = 'MyDB_%' -- pattern of database name to be included in result
DECLARE @top BIGINT = 100 -- limits the result to top N records

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT TOP (@top)
	creation_time,
	last_execution_time,
	execution_count,
	total_worker_time / 1000                                                              AS CPU,
	convert(REAL, (total_worker_time)) / (execution_count * 1000)                         AS [AvgCPUTime],
	qs.total_elapsed_time / 1000                                                          AS TotDuration,
	convert(REAL, (qs.total_elapsed_time)) / (execution_count * 1000)                     AS [AvgDur],
	total_logical_reads                                                                   AS [Reads],
	total_logical_writes                                                                  AS [Writes],
	total_logical_reads + total_logical_writes                                            AS [AggIO],
	convert(REAL, (total_logical_reads + total_logical_writes) / (execution_count + 0.0)) AS [AvgIO],
	CASE
		WHEN sql_handle IS NULL THEN ' '
		ELSE substring(
				st.text,
				(qs.statement_start_offset + 2) / 2,
				(CASE
					 WHEN qs.statement_end_offset = -1 THEN len(convert(NVARCHAR(MAX), st.text)) * 2
					 ELSE qs.statement_end_offset
					 END - qs.statement_start_offset) / 2)
		END                                                                                AS query_text,
	db_name(st.dbid)                                                                       AS [database_name],
	object_schema_name(st.objectid, st.dbid) + '.' + object_name(st.objectid, st.dbid)     AS [object_name]
FROM sys.dm_exec_query_stats qs
			 CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
WHERE 
      total_logical_reads > 0 AND 
      db_name(st.dbid) LIKE @db_name_pattern
ORDER BY AvgDur DESC