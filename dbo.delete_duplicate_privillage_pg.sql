CREATE OR REPLACE FUNCTION "dbo"."delete_duplicate_privillage"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMCL_Id int;
    v_ASMS_Id int;
    v_ISMS_Id int;
    v_ELP_Id int;
    v_cnt int;
    exmsubjectdetails_rec RECORD;
BEGIN
    FOR exmsubjectdetails_rec IN
        SELECT "ASMCL_Id", "asms_id", "isms_id", "elp_id", COUNT(*) as cnt
        FROM "Exm"."Exm_Login_Privilege_Subjects"
        WHERE "ELPS_Activeflg" = 1
        GROUP BY "ASMCL_Id", "asms_id", "isms_id", "elp_id"
        HAVING COUNT(*) > 1
    LOOP
        BEGIN
            v_ASMCL_Id := exmsubjectdetails_rec."ASMCL_Id";
            v_ASMS_Id := exmsubjectdetails_rec."asms_id";
            v_ISMS_Id := exmsubjectdetails_rec."isms_id";
            v_ELP_Id := exmsubjectdetails_rec."elp_id";
            v_cnt := exmsubjectdetails_rec.cnt;
            
            PERFORM * FROM "Exm"."Exm_Login_Privilege_Subjects" 
            WHERE "ASMCL_Id" = v_ASMCL_Id 
                AND "asms_id" = v_ASMS_Id 
                AND "isms_id" = v_ISMS_Id 
                AND "elp_id" = v_ELP_Id 
                AND "elps_activeflg" = 1;
            
            DELETE FROM "Exm"."Exm_Login_Privilege_Subjects" 
            WHERE "ctid" = (
                SELECT "ctid" 
                FROM "Exm"."Exm_Login_Privilege_Subjects" 
                WHERE "ASMCL_Id" = v_ASMCL_Id 
                    AND "asms_id" = v_ASMS_Id 
                    AND "isms_id" = v_ISMS_Id 
                    AND "elp_id" = v_ELP_Id 
                    AND "elps_activeflg" = 1
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