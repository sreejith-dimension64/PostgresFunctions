CREATE OR REPLACE FUNCTION "dbo"."delete_duplicate_student_mapping"()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ASMCL_Id" INT;
    "v_ASMS_Id" INT;
    "v_ISMS_Id" INT;
    "v_ELP_Id" INT;
    "v_cnt" INT;
    "rec" RECORD;
BEGIN
    FOR "rec" IN
        SELECT "ASMCL_Id", "ASMS_Id", "ISMS_Id", "ELP_Id", COUNT(*) AS "cnt"
        FROM "Exm"."Exm_Login_Privilege_Subjects"
        WHERE "ELPS_Activeflg" = TRUE
        GROUP BY "ASMCL_Id", "ASMS_Id", "ISMS_Id", "ELP_Id"
        HAVING COUNT(*) > 1
    LOOP
        "v_ASMCL_Id" := "rec"."ASMCL_Id";
        "v_ASMS_Id" := "rec"."ASMS_Id";
        "v_ISMS_Id" := "rec"."ISMS_Id";
        "v_ELP_Id" := "rec"."ELP_Id";
        "v_cnt" := "rec"."cnt";
        
        BEGIN
            PERFORM * 
            FROM "Exm"."Exm_Login_Privilege_Subjects" 
            WHERE "ASMCL_Id" = "v_ASMCL_Id" 
                AND "ASMS_Id" = "v_ASMS_Id" 
                AND "ISMS_Id" = "v_ISMS_Id" 
                AND "ELP_Id" = "v_ELP_Id" 
                AND "ELPS_Activeflg" = TRUE;
            
            DELETE FROM "Exm"."Exm_Login_Privilege_Subjects" 
            WHERE "ctid" IN (
                SELECT "ctid" 
                FROM "Exm"."Exm_Login_Privilege_Subjects" 
                WHERE "ASMCL_Id" = "v_ASMCL_Id" 
                    AND "ASMS_Id" = "v_ASMS_Id" 
                    AND "ISMS_Id" = "v_ISMS_Id" 
                    AND "ELP_Id" = "v_ELP_Id" 
                    AND "ELPS_Activeflg" = TRUE
                LIMIT 1
            );
            
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;
    
    RETURN;
END;
$$;