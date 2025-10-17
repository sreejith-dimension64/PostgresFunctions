CREATE OR REPLACE FUNCTION "dbo"."Fees_BBHSOBTranferAmount_Insert"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Id bigint;
    v_FMG_Id bigint;
    v_FMH_Id bigint;
    v_FSS_TobePaid bigint;
    v_FMH_FeeName text;
    v_FMH_Id_N bigint;
    v_FMG_Id_N bigint;
    v_FTI_Id bigint;
    v_ASMCL_Id bigint;
    v_FMCC_Id bigint;
    v_FMA_Id bigint;
    v_FTI_Id_N bigint;
    v_FSSRcount int;
    v_FSTRcount bigint;
    rec RECORD;
BEGIN
    v_MI_Id := 6;
    v_ASMAY_Id := 77;
    v_FMG_Id_N := 201;
    v_FTI_Id := 22;

    FOR rec IN 
        SELECT DISTINCT "AMST_Id", "FMG_Id", "FMH_Id", SUM("FSS_TobePaid") AS "FSS_TobePaid"
        FROM "BBHS_UKGClass_FeesOBTransfer_Temp"
        GROUP BY "AMST_Id", "FMG_Id", "FMH_Id"
        ORDER BY "AMST_Id"
    LOOP
        v_AMST_Id := rec."AMST_Id";
        v_FMG_Id := rec."FMG_Id";
        v_FMH_Id := rec."FMH_Id";
        v_FSS_TobePaid := rec."FSS_TobePaid";

        SELECT "FMH_FeeName" INTO v_FMH_FeeName 
        FROM "Fee_Master_Head" 
        WHERE "MI_Id" = v_MI_Id AND "FMH_Id" = v_FMH_Id;

        v_FMH_FeeName := substring(v_FMH_FeeName, 1, position(' ' IN v_FMH_FeeName));

        SELECT "FMH_Id" INTO v_FMH_Id_N 
        FROM "Fee_Master_Head" 
        WHERE "MI_Id" = v_MI_Id 
            AND "FMH_FeeName" LIKE '%' || '(OB)' || '%' 
            AND "FMH_FeeName" LIKE '%' || v_FMH_FeeName || '%' 
        ORDER BY "FMH_Id" DESC 
        LIMIT 1;

        SELECT "ASMCL_Id" INTO v_ASMCL_Id 
        FROM "Adm_School_Y_Student" 
        WHERE "AMST_Id" = v_AMST_Id AND "ASMAY_Id" = v_ASMAY_Id;

        SELECT "FMCC_Id" INTO v_FMCC_Id 
        FROM "Fee_Yearly_Class_Category" "FYCC"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "FYCCC" ON "FYCC"."FYCC_Id" = "FYCCC"."FYCC_Id"
        WHERE "ASMCL_Id" = v_ASMCL_Id AND "FYCC"."ASMAY_Id" = v_ASMAY_Id;

        SELECT "FMA_Id", "FTI_Id" INTO v_FMA_Id, v_FTI_Id_N 
        FROM "Fee_Master_Amount" 
        WHERE "FMG_Id" = v_FMG_Id_N 
            AND "ASMAY_Id" = v_ASMAY_Id 
            AND "FTI_Id" = v_FTI_Id 
            AND "FMH_Id" = v_FMH_Id_N 
            AND "FMCC_Id" = v_FMCC_Id;

        v_FSTRcount := 0;
        SELECT COUNT(*) INTO v_FSTRcount 
        FROM "Fee_Student_Status" 
        WHERE "ASMAY_Id" = v_ASMAY_Id 
            AND "MI_Id" = v_MI_Id 
            AND "AMST_Id" = v_AMST_Id;

        v_FSSRcount := 0;
        SELECT COUNT(*) INTO v_FSSRcount 
        FROM "Fee_Student_Status" 
        WHERE "ASMAY_Id" = v_ASMAY_Id 
            AND "MI_Id" = v_MI_Id 
            AND "AMST_Id" = v_AMST_Id 
            AND "FMH_Id" = v_FMH_Id_N 
            AND "FTI_Id" = v_FTI_Id 
            AND "FMG_Id" = v_FMG_Id_N 
            AND "FMA_Id" = v_FMA_Id;

        IF (v_FSSRcount = 0) AND (v_FSTRcount <> 0) THEN
            INSERT INTO "Fee_Student_Status"(
                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges",
                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount",
                "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount",
                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount",
                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag",
                "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount", "FSS_ExcessTransferred",
                "FSS_OBTransferred", "FSS_OBAsPerFY", "FSS_CBAsPerFY"
            )
            VALUES(
                v_MI_Id, v_ASMAY_Id, v_AMST_Id, v_FMG_Id_N, v_FMH_Id_N, v_FTI_Id_N, v_FMA_Id,
                v_FSS_TobePaid, 0, v_FSS_TobePaid, v_FSS_TobePaid, v_FSS_TobePaid, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, v_FSS_TobePaid,
                0, 0, 0, 1, 725, 0, 0, 0, 0, 0
            );
        END IF;
    END LOOP;

    RETURN;
END;
$$;