CREATE OR REPLACE FUNCTION "dbo"."Fee_ObandExcessTr"(
    "@mi_id" bigint,
    "@Lasmay_id" bigint,
    "@Nasmay_id" bigint,
    "@amst_id1" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "@ASMAY_From_Date" date;
    "@ASMAY_To_Date" date;
    "@FMH_Id" bigint;
    "@FMH_FeeName" varchar(150);
    "@AMST_Id" bigint;
    "@SFMH_Id" bigint;
    "@ToBePaid" bigint;
    "@ASMAY_Id_New" bigint;
    "@FMA_Amount" bigint;
    "@RAMST_Id" bigint;
    "@FSS_RunningExcessAmount" bigint;
    "@FTI_Id" bigint;
    "@SFTI_Id" bigint;
    "@PAMST_Id" bigint;
    "@PFMH_Id" bigint;
    "@PFTI_Id" bigint;
    "@SToBePaid" bigint;
    "@FSS_Id" bigint;
    "@FSS_IdNew" bigint;
    "@FMH_IdE" bigint;
    "@FFTI_Id" bigint;
    "@FMG_IdN" bigint;
    "@FMH_IdN" bigint;
    "@FMA_IdN" bigint;
    "CursorfeeNames" CURSOR FOR SELECT DISTINCT "FMH_Id", "FMH_FeeName" FROM "fee_master_head" WHERE "mi_id" = "@mi_id" AND "FMH_FeeName" NOT LIKE '%Excess%';
    "Cursorobamt" REFCURSOR;
    "RunningExStudents" REFCURSOR;
BEGIN

    FOR "@FMH_Id", "@FMH_FeeName" IN 
        SELECT DISTINCT "FMH_Id", "FMH_FeeName" 
        FROM "fee_master_head" 
        WHERE "mi_id" = "@mi_id" AND "FMH_FeeName" NOT LIKE '%Excess%'
    LOOP
        
        OPEN "Cursorobamt" FOR
            SELECT "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id", sum("FSS_ToBePaid") AS "ToBePaid"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = "@mi_id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = "@mi_id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = "@mi_id"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "@Lasmay_id"
            WHERE ("Adm_School_Y_Student"."ASMAY_Id" = "@Lasmay_id") 
                AND ("fee_student_status"."MI_Id" = "@mi_id") 
                AND ("fee_student_status"."ASMAY_Id" = "@Lasmay_id") 
                AND ("fee_student_status"."AMST_Id" = "@amst_id1")
                AND "Fee_Master_Head"."FMH_Id" = "@FMH_Id" 
                AND "Fee_Student_Status"."FMH_Id" = "@FMH_Id"
            GROUP BY "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id"
            HAVING sum("FSS_ToBePaid") > 0;
        
        LOOP
            FETCH "Cursorobamt" INTO "@AMST_Id", "@SFMH_Id", "@ToBePaid";
            EXIT WHEN NOT FOUND;
            
            SELECT "FSS_Id" INTO "@FSS_Id" 
            FROM "fee_student_status" 
            WHERE "MI_Id" = "@MI_Id" AND "AMST_Id" = "@AMST_Id" AND "FMH_Id" = "@FMH_Id" AND "ASMAY_Id" = "@Lasmay_id" 
            ORDER BY "FTI_Id" 
            LIMIT 1;
            
            UPDATE "Fee_Student_Status" 
            SET "FSS_OBTransferred" = "@ToBePaid" 
            WHERE "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@Lasmay_id" AND "AMST_Id" = "@AMST_Id" AND "FMH_Id" = "@FMH_Id" AND "FSS_Id" = "@FSS_Id";
            
            SELECT "FSS_Id", "FTI_Id" INTO "@FSS_IdNew", "@FTI_Id" 
            FROM "fee_student_status" 
            WHERE "MI_Id" = "@MI_Id" AND "AMST_Id" = "@AMST_Id" AND "FMH_Id" = "@FMH_Id" AND "ASMAY_Id" = "@Nasmay_id"
            LIMIT 1;
            
            IF (COALESCE("@FSS_IdNew", 0) <> 0) THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_OBArrearAmount" = "@ToBePaid",
                    "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + "@ToBePaid",
                    "FSS_ToBePaid" = "FSS_ToBePaid" + "@ToBePaid" 
                WHERE "FSS_Id" = "@FSS_IdNew" AND "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@Nasmay_id" AND "AMST_Id" = "@AMST_Id" AND "FMH_Id" = "@FMH_Id" AND "FTI_Id" = "@FTI_Id";
            ELSE
                SELECT "MG"."FMG_Id", "HM"."FMH_Id", "MG"."FMA_Id" INTO "@FMG_IdN", "@FMH_IdN", "@FMA_IdN" 
                FROM "Fee_Yearly_Group_Head_Mapping" "HM"
                INNER JOIN "Fee_Master_Amount" "MG" ON "HM"."ASMAY_Id" = "MG"."FMG_Id" AND "HM"."MI_Id" = "HM"."FMG_Id" 
                WHERE "HM"."MI_Id" = "@MI_Id" AND "HM"."ASMAY_Id" = "@Nasmay_id" AND "HM"."FYGHM_ActiveFlag" = 1;
                
                INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount", "FSS_OBTransferred", "FSS_ExcessTransferred")
                VALUES("@MI_Id", "@Nasmay_id", "@AMST_Id", "@FMG_IdN", "@FMH_IdN", "@FTI_Id", "@FMA_IdN", "@ToBePaid", "@ToBePaid", "@ToBePaid", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;
            
        END LOOP;
        
        CLOSE "Cursorobamt";
        
    END LOOP;
    
    SELECT "FMH_Id" INTO "@FMH_IdE" 
    FROM "fee_Master_Head" 
    WHERE "MI_Id" = "@MI_Id" AND "FMH_FeeName" LIKE '%Excess%';
    
    OPEN "RunningExStudents" FOR 
        SELECT "AMST_Id", "FSS_PaidAmount" + "FSS_RunningExcessAmount" 
        FROM "fee_student_status" 
        WHERE "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@Lasmay_id" AND "FMH_Id" = "@FMH_IdE" AND ("FSS_RunningExcessAmount" > 0 OR "FSS_PaidAmount" > 0);
    
    LOOP
        FETCH "RunningExStudents" INTO "@RAMST_Id", "@FSS_RunningExcessAmount";
        EXIT WHEN NOT FOUND;
        
        UPDATE "fee_student_status" 
        SET "FSS_ExcessTransferred" = "@FSS_RunningExcessAmount" 
        WHERE "FSS_Id" = "@FSS_Id" AND "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@Lasmay_id" AND "FMH_Id" = "@FMH_IdE" AND "AMST_Id" = "@RAMST_Id";
        
        SELECT "FSS_Id", "FTI_Id" INTO "@FSS_IdNew", "@FTI_Id" 
        FROM "fee_student_status" 
        WHERE "MI_Id" = "@MI_Id" AND "AMST_Id" = "@RAMST_Id" AND "FMH_Id" = "@FMH_IdE" AND "ASMAY_Id" = "@Nasmay_id"
        LIMIT 1;
        
        IF (COALESCE("@FSS_IdNew", 0) <> 0) THEN
            UPDATE "Fee_Student_Status" 
            SET "FSS_OBExcessAmount" = "@FSS_RunningExcessAmount",
                "FSS_ExcessPaidAmount" = "@FSS_RunningExcessAmount",
                "FSS_RunningExcessAmount" = "@FSS_RunningExcessAmount" 
            WHERE "FSS_Id" = "@FSS_IdNew" AND "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@Nasmay_id" AND "AMST_Id" = "@RAMST_Id" AND "FMH_Id" = "@FMH_IdE";
        ELSE
            SELECT "MG"."FMG_Id", "HM"."FMH_Id", "MG"."FMA_Id" INTO "@FMG_IdN", "@FMH_IdN", "@FMA_IdN" 
            FROM "Fee_Yearly_Group_Head_Mapping" "HM"
            INNER JOIN "Fee_Master_Amount" "MG" ON "HM"."ASMAY_Id" = "MG"."FMG_Id" AND "HM"."MI_Id" = "HM"."FMG_Id" 
            WHERE "HM"."MI_Id" = "@MI_Id" AND "HM"."ASMAY_Id" = "@Nasmay_id" AND "HM"."FYGHM_ActiveFlag" = 1;
            
            INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBExcessAmount", "FSS_ExcessPaidAmount", "FSS_RunningExcessAmount", "FSS_OBArrearAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessAdjustedAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount", "FSS_OBTransferred", "FSS_ExcessTransferred")
            VALUES("@MI_Id", "@Nasmay_id", "@AMST_Id", "@FMG_IdN", "@FMH_IdN", "@FTI_Id", "@FMA_IdN", "@FSS_RunningExcessAmount", "@FSS_RunningExcessAmount", "@FSS_RunningExcessAmount", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        END IF;
        
    END LOOP;
    
    CLOSE "RunningExStudents";

END;
$$;