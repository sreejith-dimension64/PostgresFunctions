CREATE OR REPLACE FUNCTION "dbo"."IVRM_duplicate_record_login"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_STD_APP_ID" bigint;
    "v_FAT_APP_ID" bigint;
    "v_MOT_APP_ID" bigint;
    "v_i" bigint;
    "v_rowcount" integer;
    "class_section_rec" RECORD;
BEGIN
    FOR "class_section_rec" IN 
        SELECT "STD_APP_ID", "FAT_APP_ID", "MOT_APP_ID" 
        FROM "Ivrm_User_StudentApp_login"
    LOOP
        "v_STD_APP_ID" := "class_section_rec"."STD_APP_ID";
        "v_FAT_APP_ID" := "class_section_rec"."FAT_APP_ID";
        "v_MOT_APP_ID" := "class_section_rec"."MOT_APP_ID";
        
        "v_i" := 0;
        
        IF "v_STD_APP_ID" > 0 THEN
            PERFORM * FROM "applicationuser" WHERE "id" = "v_STD_APP_ID";
            GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
            IF "v_rowcount" = 0 THEN
                "v_i" := "v_i" + 1;
            END IF;
        ELSE
            "v_i" := "v_i" + 1;
        END IF;
        
        IF "v_FAT_APP_ID" > 0 THEN
            PERFORM * FROM "applicationuser" WHERE "id" = "v_FAT_APP_ID";
            GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
            IF "v_rowcount" = 0 THEN
                "v_i" := "v_i" + 1;
            END IF;
        ELSE
            "v_i" := "v_i" + 1;
        END IF;
        
        IF "v_MOT_APP_ID" > 0 THEN
            PERFORM * FROM "applicationuser" WHERE "id" = "v_MOT_APP_ID";
            GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
            IF "v_rowcount" = 0 THEN
                "v_i" := "v_i" + 1;
            END IF;
        ELSE
            "v_i" := "v_i" + 1;
        END IF;
        
        IF "v_i" = 3 THEN
            DELETE FROM "Ivrm_User_StudentApp_login" 
            WHERE "STD_APP_ID" = "v_STD_APP_ID" 
                AND "FAT_APP_ID" = "v_FAT_APP_ID" 
                AND "MOT_APP_ID" = "v_MOT_APP_ID";
            
            DELETE FROM "applicationuser" 
            WHERE "id" IN ("v_STD_APP_ID", "v_FAT_APP_ID", "v_MOT_APP_ID");
        END IF;
    END LOOP;
END;
$$;