CREATE OR REPLACE FUNCTION "dbo"."CRM_Fees_CautionDeposit_Insert"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Id bigint;
    v_ASMCL_Id bigint;
    v_FMA_Id bigint;
    v_FMG_Id bigint;
    v_FTI_Id bigint;
    v_FMA_Amount bigint;
    studentids_cursor CURSOR FOR
        SELECT DISTINCT "AMS"."AMST_Id"
        FROM "Adm_M_Student" "AMS"
        INNER JOIN "Fee_CautionDeposit_Temp" "CT" ON "CT"."AMST_Adm_No" = "AMS"."AMST_AdmNo"
        INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "AMS"."AMST_Id";
BEGIN

    OPEN studentids_cursor;
    
    LOOP
        FETCH NEXT FROM studentids_cursor INTO v_AMST_Id;
        EXIT WHEN NOT FOUND;
        
        SELECT "ASMCL_Id" INTO v_ASMCL_Id
        FROM "Adm_School_Y_Student"
        WHERE "AMST_Id" = v_AMST_Id AND "asmay_id" = 10001;
        
        SELECT DISTINCT "FMA"."FMA_Id", "FMA"."FMG_Id", "FMA"."FTI_Id", "FMA"."FMA_Amount"
        INTO v_FMA_Id, v_FMG_Id, v_FTI_Id, v_FMA_Amount
        FROM "Fee_Master_Amount" "FMA"
        INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "FYCC"."FMCC_Id" = "FMA"."FMCC_Id"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "YCCC" ON "YCCC"."FYCC_Id" = "FYCC"."FYCC_Id"
        WHERE "FMA"."MI_Id" = 10001 
            AND "FMA"."ASMAY_Id" = 10001 
            AND "FYCC"."ASMAY_Id" = 10001  
            AND "FMA"."FMH_Id" = 3 
            AND "ASMCL_Id" = v_ASMCL_Id;
        
        INSERT INTO "Fee_Student_Status"(
            "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
            "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges",
            "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount",
            "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
            "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount",
            "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount",
            "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag",
            "User_Id", "FSS_RefundableAmount", "FSS_ExcessTransferred", "FSS_OBTransferred"
        )
        VALUES(
            10001, 10001, v_AMST_Id, v_FMG_Id, 3, v_FTI_Id, v_FMA_Id,
            0, 0, 10000, 10000, 0, 10000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000,
            0, 0, 0, 1, 87, 0, 0, 0
        );
        
    END LOOP;
    
    CLOSE studentids_cursor;

    RETURN;
END;
$$;