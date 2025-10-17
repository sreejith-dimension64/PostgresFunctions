CREATE OR REPLACE FUNCTION "dbo"."Fees_10thAnd12thClassesGroupHeadsAmount_Updation"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMG_Id bigint;
    v_FMG_Id_GH bigint;
    v_AMST_Id bigint;
    v_FMH_Id bigint;
    v_CurrentYrCharges bigint;
    v_FSS_Id bigint;
    v_FMA_Id bigint;
    v_FSS_TotalToBePaid_N bigint;
    rec_groupids RECORD;
    rec_StudentWiseGroupHeadCharges RECORD;
BEGIN
    /*
    FOR rec_groupids IN 
        SELECT DISTINCT "FMG_Id" 
        FROM "Fee_Master_Group" 
        WHERE "FMG_Id" IN (21,22,23,24,25)
    LOOP
        v_FMG_Id := rec_groupids."FMG_Id";
        
        FOR rec_StudentWiseGroupHeadCharges IN
            SELECT DISTINCT "AMST_Id", "FMG_Id", "FMH_Id", SUM("FSS_TotalToBePaid") AS CurrentYrCharges
            FROM "Fee_Student_Status" 
            WHERE "MI_Id" = 10001 
                AND "asmay_id" = 10020 
                AND "FMG_Id" = v_FMG_Id 
                AND "FTI_Id" IN (10,11,20,21) 
                AND "FSS_PaidAmount" = 0 
                AND "FSS_ConcessionAmount" = 0
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "Adm_School_Y_Student" 
                    WHERE "AMAY_ActiveFlag" = 1 
                        AND "ASMAY_Id" = 10020 
                        AND "asmcl_id" IN (16,18)
                )
                AND "amst_id" != 1685
            GROUP BY "AMST_Id", "FMG_Id", "FMH_Id"
        LOOP
            v_AMST_Id := rec_StudentWiseGroupHeadCharges."AMST_Id";
            v_FMG_Id_GH := rec_StudentWiseGroupHeadCharges."FMG_Id";
            v_FMH_Id := rec_StudentWiseGroupHeadCharges."FMH_Id";
            v_CurrentYrCharges := rec_StudentWiseGroupHeadCharges.CurrentYrCharges;
            
            SELECT "FSS_Id", "FMA_Id"
            INTO v_FSS_Id, v_FMA_Id
            FROM "Fee_Student_Status" 
            WHERE "MI_Id" = 10001 
                AND "ASMAY_Id" = 10020 
                AND "FMG_Id" = v_FMG_Id_GH 
                AND "FMH_Id" = v_FMH_Id 
                AND "FTI_Id" IN (19) 
                AND "FSS_PaidAmount" = 0 
                AND "FSS_ConcessionAmount" = 0
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "Adm_School_Y_Student" 
                    WHERE "AMAY_ActiveFlag" = 1 
                        AND "ASMAY_Id" = 10020 
                        AND "asmcl_id" IN (16,18)
                )
                AND "AMST_Id" = v_AMST_Id;
            
            UPDATE "Fee_Student_Status" 
            SET "FSS_CurrentYrCharges" = "FSS_TotalToBePaid" + v_CurrentYrCharges,
                "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_CurrentYrCharges,
                "FSS_ToBePaid" = "FSS_TotalToBePaid" + v_CurrentYrCharges,
                "FSS_NetAmount" = "FSS_TotalToBePaid" + v_CurrentYrCharges 
            WHERE "FSS_Id" = v_FSS_Id;
            
            v_FSS_TotalToBePaid_N := 0;
            
            SELECT "FSS_TotalToBePaid" 
            INTO v_FSS_TotalToBePaid_N
            FROM "Fee_Student_Status" 
            WHERE "FSS_Id" = v_FSS_Id;
            
            UPDATE "Fee_Master_Amount" 
            SET "FMA_Amount" = v_FSS_TotalToBePaid_N  
            WHERE "MI_Id" = 10001 
                AND "ASMAY_Id" = 10020 
                AND "FMG_Id" = v_FMG_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "FMA_Id" = v_FMA_Id 
                AND "FTI_Id" = 19;
            
            UPDATE "Fee_Student_Status" 
            SET "FSS_CurrentYrCharges" = 0,
                "FSS_TotalToBePaid" = 0,
                "FSS_ToBePaid" = 0,
                "FSS_NetAmount" = 0
            WHERE "MI_Id" = 10001 
                AND "asmay_id" = 10020 
                AND "FMG_Id" = v_FMG_Id_GH 
                AND "FMH_Id" = v_FMH_Id 
                AND "FTI_Id" IN (10,11,20,21) 
                AND "FSS_PaidAmount" = 0 
                AND "FSS_ConcessionAmount" = 0
                AND "AMST_Id" IN (
                    SELECT DISTINCT "AMST_Id" 
                    FROM "Adm_School_Y_Student" 
                    WHERE "AMAY_ActiveFlag" = 1 
                        AND "ASMAY_Id" = 10020 
                        AND "asmcl_id" IN (16,18)
                )
                AND "AMST_Id" = v_AMST_Id;
                
        END LOOP;
        
    END LOOP;
    */
    
    RETURN;
END;
$$;