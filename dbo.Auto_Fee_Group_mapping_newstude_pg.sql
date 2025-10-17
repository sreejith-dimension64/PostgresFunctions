CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_newstude"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint,
    p_UserId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FYGHM_Id bigint;
    v_FMCC_Id bigint;
    v_AMCL_Id bigint;
    v_FMA_Id bigint;
    v_FTI_Name varchar(100);
    v_FMA_Amount numeric(16,2);
    v_FMH_Name varchar(100);
    v_FMG_Id bigint;
    v_FTP_Concession_Amt bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_FMSG_Id bigint;
    v_compulflag varchar(100);
    v_classid varchar(100);
    v_streamid varchar(100);
    v_AMST_Id bigint;
    v_UserId bigint;
    rec_feeinstallment RECORD;
BEGIN
    v_AMCL_Id := 0;
    v_FMCC_Id := 0;
    v_FMA_Id := 0;
    v_FTI_Name := '';
    v_FMA_Amount := 0;
    v_FMH_Name := '';
    v_FTP_Concession_Amt := 0;
    v_compulflag := '1';

    FOR v_AMST_Id IN 
        SELECT "amst_id" FROM "Adm_M_Student" WHERE "AMST_Id" IN (4846)
    LOOP
        v_FMG_Id := 11;

        SELECT "user_id" INTO v_UserId FROM "Fee_Master_Group" WHERE "FMG_Id" = v_FMG_Id;

        INSERT INTO "Fee_Master_Student_Group" ("MI_Id","AMST_Id","ASMAY_Id","FMG_Id","FMSG_ActiveFlag") 
        VALUES (p_MI_Id, v_AMST_Id, p_ASMAY_ID, v_FMG_Id, 'Y');

        SELECT MAX("FMSG_Id") INTO v_FMSG_Id FROM "Fee_Master_Student_Group";

        v_fmcc_id := 8;

        FOR rec_feeinstallment IN 
            SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
            FROM "Fee_Master_Amount" 
            WHERE "FMG_Id" = v_FMG_Id 
                AND "ASMAY_Id" = p_ASMAY_ID 
                AND "MI_Id" = p_MI_Id 
                AND "FMCC_Id" = v_FMCC_Id
        LOOP
            v_FMH_Id := rec_feeinstallment."FMH_Id";
            v_FTI_Id := rec_feeinstallment."FTI_Id";
            v_FMA_Id := rec_feeinstallment."FMA_Id";
            v_FMA_Amount := rec_feeinstallment."FMA_Amount";

            INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id","FMH_ID","FTI_ID") 
            VALUES (v_FMSG_Id, v_FMH_Id, v_FTI_Id);

            INSERT INTO "Fee_Student_Status"(
                "MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id",
                "FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges",
                "FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount",
                "FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount",
                "FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount",
                "FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount",
                "FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag",
                "FSS_ActiveFlag","User_Id","FSS_RefundableAmount"
            ) 
            VALUES(
                p_MI_Id, p_ASMAY_ID, v_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id,
                0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                v_FMA_Amount, 0, 0, 0, 1, v_UserId, 0
            );
        END LOOP;
    END LOOP;

    RETURN;
END;
$$;