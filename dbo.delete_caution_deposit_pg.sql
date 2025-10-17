CREATE OR REPLACE FUNCTION "dbo"."delete_caution_deposit"(
    "@mi_id" BIGINT,
    "@asmay_id" BIGINT,
    "@fmg_id" BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@amst_id" BIGINT;
    "@fmh_id" BIGINT;
    "@FMSG_Id" BIGINT;
    "v_row_count" INTEGER;
    "rec_amstid" RECORD;
    "rec_find_group" RECORD;
BEGIN

    SELECT "FMH_Id" INTO "@fmh_id" 
    FROM "Fee_Yearly_Group_Head_Mapping" 
    WHERE "MI_Id" = "@mi_id" 
        AND "ASMAY_Id" = "@asmay_id" 
        AND "FMG_Id" = "@fmg_id";

    FOR "rec_amstid" IN
        SELECT "Adm_M_Student"."AMST_Id" 
        FROM "Adm_M_Student"  
        INNER JOIN "fee_student_status" ON "Adm_M_Student"."amst_id" = "fee_student_status"."amst_id" 
        WHERE "AMST_AdmNo" NOT LIKE '%2017%' 
            AND "Adm_M_Student"."MI_Id" = "@mi_id"
            AND "Adm_M_Student"."asmay_id" = "@asmay_id" 
            AND "fee_student_status"."fmg_id" = "@fmg_id" 
            AND "fee_student_status"."fmh_id" = "@fmh_id" 
            AND "fee_student_status"."fss_tobepaid" > 0
    LOOP
        "@amst_id" := "rec_amstid"."AMST_Id";
        
        FOR "rec_find_group" IN
            SELECT "FMSG_Id" 
            FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = "@fmg_id" 
                AND "MI_Id" = "@mi_id" 
                AND "ASMAY_Id" = "@asmay_id"  
                AND "AMST_Id" = "@amst_id"
        LOOP
            "@FMSG_Id" := "rec_find_group"."FMSG_Id";
            
            SELECT COUNT(*) INTO "v_row_count"
            FROM "Fee_Master_Student_Group_Installment" 
            WHERE "FMSG_Id" = "@FMSG_Id" 
                AND "FMH_ID" = "@fmh_id";
            
            IF "v_row_count" != 0 THEN
                DELETE FROM "Fee_Master_Student_Group_Installment" 
                WHERE "FMSG_Id" = "@FMSG_Id" 
                    AND "FMH_ID" = "@fmh_id";
            END IF;
            
            DELETE FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = "@fmg_id" 
                AND "MI_Id" = "@mi_id" 
                AND "ASMAY_Id" = "@asmay_id"  
                AND "AMST_Id" = "@amst_id";
            
            SELECT COUNT(*) INTO "v_row_count"
            FROM "Fee_Student_Status" 
            WHERE "MI_Id" = "@mi_id" 
                AND "FMG_Id" = "@fmg_id" 
                AND "ASMAY_Id" = "@asmay_id" 
                AND "FMH_Id" = "@fmh_id" 
                AND "amst_id" = "@amst_id"  
                AND "fss_tobepaid" > 0;
            
            IF "v_row_count" != 0 THEN
                DELETE FROM "Fee_Student_Status" 
                WHERE "MI_Id" = "@mi_id" 
                    AND "FMG_Id" = "@fmg_id" 
                    AND "ASMAY_Id" = "@asmay_id" 
                    AND "FMH_Id" = "@fmh_id" 
                    AND "amst_id" = "@amst_id"  
                    AND "fss_tobepaid" > 0;
            END IF;
            
        END LOOP;
        
    END LOOP;

    RETURN;
END;
$$;