CREATE OR REPLACE FUNCTION "dbo"."AddColumnsAllTables"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_TABLE_NAME varchar(500);
    v_firastclmname varchar(500);
    v_secondclmName varchar(500);
    v_thirdclmName varchar(500);
    v_querybuild varchar(500);
    v_datattype varchar(500);
    v_foreignkeyadd varchar(500);
BEGIN
    v_datattype := ' as timestamp';
    v_firastclmname := 'CreatedDate';
    v_secondclmName := 'UpdatedDate';
    v_thirdclmName := 'userid';
    v_foreignkeyadd := ' as bigint ';

    FOR v_TABLE_NAME IN 
        SELECT "TABLE_NAME" 
        FROM "INFORMATION_SCHEMA"."TABLES" 
        WHERE "TABLE_NAME" NOT LIKE 'Fee%'
    LOOP
        v_querybuild := 'ALTER TABLE "' || v_TABLE_NAME || '" ADD COLUMN "' || v_firastclmname || '" timestamp, ADD COLUMN "' || v_secondclmName || '" timestamp';
        EXECUTE v_querybuild;

        v_querybuild := 'UPDATE "' || v_TABLE_NAME || '" SET "CreatedDate" = CURRENT_TIMESTAMP, "UpdatedDate" = CURRENT_TIMESTAMP';
        EXECUTE v_querybuild;
    END LOOP;

    RETURN;
END;
$$;