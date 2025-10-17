CREATE OR REPLACE FUNCTION "DropProcedures"()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Prname TEXT;
BEGIN
    FOR v_Prname IN 
        SELECT DISTINCT "proname" 
        FROM "pg_proc" p
        INNER JOIN "pg_namespace" n ON p."pronamespace" = n."oid"
        WHERE n."nspname" = 'public'
        AND "proname" NOT LIKE 'sp_%'
        AND "prokind" IN ('p', 'f')
    LOOP
        RAISE NOTICE 'drop procedure %', v_Prname;
        RAISE NOTICE 'go';
    END LOOP;
    
    RETURN;
END;
$$;