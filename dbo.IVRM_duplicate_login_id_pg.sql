CREATE OR REPLACE FUNCTION "dbo"."IVRM_duplicate_login_id"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_STD_APP_ID" bigint;
    "v_FAT_APP_ID" bigint;
    "v_MOT_APP_ID" bigint;
    "v_id" bigint;
    "v_i" bigint;
    "v_rowcount" integer;
BEGIN
    FOR "v_id" IN 
        SELECT "id" FROM "applicationuser" 
        WHERE "email" NOT IN ('dontDelete@gmail.com') 
        AND "id" BETWEEN 9000 AND 9500
    LOOP
        "v_i" := 0;
        
        PERFORM * FROM "Ivrm_User_StudentApp_login" WHERE "STD_APP_ID" = "v_id";
        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
        IF "v_rowcount" = 0 THEN
            "v_i" := "v_i" + 1;
        END IF;
        
        PERFORM * FROM "Ivrm_User_StudentApp_login" WHERE "FAT_APP_ID" = "v_id";
        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
        IF "v_rowcount" = 0 THEN
            "v_i" := "v_i" + 1;
        END IF;
        
        PERFORM * FROM "Ivrm_User_StudentApp_login" WHERE "MOT_APP_ID" = "v_id";
        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
        IF "v_rowcount" = 0 THEN
            "v_i" := "v_i" + 1;
        END IF;
        
        IF "v_i" = 3 THEN
            INSERT INTO "duplicate_id_login" VALUES ("v_id");
        END IF;
    END LOOP;
    
    RETURN;
END;
$$;