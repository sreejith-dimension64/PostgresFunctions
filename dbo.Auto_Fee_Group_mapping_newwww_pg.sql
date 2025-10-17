CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_newwww"(
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
    v_rowcount integer;
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

    BEGIN
        FOR v_FMG_Id IN 
            SELECT "FMG_Id" FROM "Fee_Master_Group" WHERE "FMG_Id" IN (3,5,6)
        LOOP
            SELECT COUNT(*) INTO v_rowcount 
            FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = v_FMG_Id 
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id;

            IF v_rowcount = 0 THEN
                INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                VALUES (p_MI_Id, p_AMST_Id, p_ASMAY_Id, v_FMG_Id, 'Y');

                SELECT MAX("FMSG_Id") INTO v_FMSG_Id FROM "Fee_Master_Student_Group";

                SELECT "ASMCL_Id" INTO v_AMCL_Id 
                FROM "Adm_M_Student" 
                WHERE "amst_id" = p_AMST_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id;

                SELECT "FMCC_Id" INTO v_FMCC_Id 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "ASMAY_Id" = p_ASMAY_Id 
                    AND "MI_Id" = p_MI_Id 
                    AND "FYCC_Id" IN (
                        SELECT "FYCC_Id" 
                        FROM "Fee_Yearly_Class_Category_Classes" 
                        WHERE "ASMCL_Id" = v_AMCL_Id
                    );

                FOR rec_feeinstallment IN 
                    SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                    FROM "Fee_Master_Amount" 
                    WHERE "FMG_Id" = v_FMG_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "MI_Id" = p_MI_Id 
                        AND "FMCC_Id" = v_FMCC_Id
                LOOP
                    v_FMH_Id := rec_feeinstallment."FMH_Id";
                    v_FTI_Id := rec_feeinstallment."FTI_Id";
                    v_FMA_Id := rec_feeinstallment."FMA_Id";
                    v_FMA_Amount := rec_feeinstallment."FMA_Amount";

                    INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
                    VALUES (v_FMSG_Id, v_FMH_Id, v_FTI_Id);

                    INSERT INTO "Fee_Student_Status"(
                        "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                        "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                        "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", 
                        "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", 
                        "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                        "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                        "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
                        "FSS_ActiveFlag", "User_Id"
                    ) 
                    VALUES(
                        p_MI_Id, p_ASMAY_Id, p_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 
                        0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                        0, 0, v_FMA_Amount, 0, 0, 0, 1, p_UserId
                    );
                END LOOP;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;