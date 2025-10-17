CREATE OR REPLACE FUNCTION "dbo"."Allflgdefaultzero"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_TABLE_SCHEMA varchar(50);
    v_TABLE_NAME text;
    v_COLUMN_NAME varchar(200);
    v_dynamic text;
    flgsdefaultzerocur CURSOR FOR
        SELECT "table_schema", "table_name", "column_name" 
        FROM "information_schema"."columns" 
        WHERE "data_type" LIKE 'boolean%' 
        AND "table_name" LIKE 'IVRM_%' 
        AND "column_name" LIKE '%fl%';
BEGIN
    FOR v_TABLE_SCHEMA, v_TABLE_NAME, v_COLUMN_NAME IN
        SELECT "table_schema", "table_name", "column_name" 
        FROM "information_schema"."columns" 
        WHERE "data_type" LIKE 'boolean%' 
        AND "table_name" LIKE 'IVRM_%' 
        AND "column_name" LIKE '%fl%'
    LOOP
        v_dynamic := 'ALTER TABLE "' || v_TABLE_SCHEMA || '"."' || v_TABLE_NAME || '" ALTER COLUMN "' || v_COLUMN_NAME || '" SET DEFAULT false';
        
        EXECUTE v_dynamic;
    END LOOP;
    
    RETURN;
END;
$$;