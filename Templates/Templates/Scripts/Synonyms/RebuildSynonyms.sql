
/*
	Drops synonyms referenced to database with @prefix_old  
	and creates them as referenced to database with @prefix_new 
*/

DECLARE @prefix_old NVARCHAR(MAX) = 'DEV'; -- old target database prefix
DECLARE @prefix_new NVARCHAR(MAX) = 'PROD'; -- new target database prefix

DECLARE cur CURSOR STATIC FOR
WITH 
[drop] AS (
	SELECT
		row_number() OVER (ORDER BY syn.name)                     AS rownum,
		'DROP SYNONYM [' + sch.name + '].' + '[' + syn.name + ']' AS script_drop
	FROM sys.synonyms syn
		JOIN sys.schemas sch ON sch.schema_id = syn.schema_id
),
[create] AS (
	SELECT
		row_number() OVER ( ORDER BY syn.name)              AS rownum,
		'CREATE SYNONYM [' + sch.name + '].' + '[' + syn.name + '] FOR ' +
		REPLACE(base_object_name, @prefix_old, @prefix_new) AS script_create
	FROM sys.synonyms syn
		JOIN sys.schemas sch ON sch.schema_id = syn.schema_id
),
drop_create AS (
	SELECT
		script_drop,
		script_create
	FROM [drop] d
		JOIN [create] c ON d.rownum = c.rownum
)
SELECT
	script_drop,
	script_create
FROM drop_create;

DECLARE
	@script_drop NVARCHAR(MAX),
	@script_create NVARCHAR(MAX);

OPEN cur;
FETCH NEXT FROM cur INTO @script_drop, @script_create;

WHILE @@fetch_status = 0
BEGIN
	--exec sp_executesql @script_drop
	--exec sp_executesql @script_create
	PRINT @script_drop 
	PRINT @script_create
	FETCH NEXT FROM cur INTO @script_drop, @script_create
END;

CLOSE cur;
DEALLOCATE cur;