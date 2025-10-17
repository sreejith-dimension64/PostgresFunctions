CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_new_1"(
    "mi_id" BIGINT,
    "ASMAY_ID" BIGINT,
    "userid" BIGINT,
    "admno" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "fyghm_id" BIGINT;
    "fmcc_id" BIGINT;
    "amcl_id" BIGINT;
    "fma_id" BIGINT;
    "fti_name" VARCHAR(100);
    "fma_amount" NUMERIC;
    "fmh_name" VARCHAR(100);
    "fmg_id" BIGINT;
    "fmsgid" BIGINT;
    "ftp_concession_amt" BIGINT;
    "fmh_id" BIGINT;
    "fti_id" BIGINT;
    "FMSG_Id" BIGINT;
    "AmST_ID" BIGINT;
    "net" BIGINT;
    "paid" BIGINT;
    "bal" BIGINT;
    "v_row_count" INTEGER;
BEGIN
    "amcl_id" := 0;
    "fmcc_id" := 0;
    "fma_id" := 0;
    "fti_name" := '';
    "fma_amount" := 0;
    "fmh_name" := '';
    "ftp_concession_amt" := 0;
    "fmg_id" := 16;

    FOR "AmST_ID" IN 
        SELECT DISTINCT "AMST_Id" 
        FROM "Adm_School_Y_Student" 
        WHERE "ASMAY_Id" = 10019 
            AND "ASMCL_Id" = 14
            AND "AMST_Id" NOT IN (
                SELECT DISTINCT "AMST_Id" 
                FROM "Fee_Student_Status" 
                WHERE "MI_Id" = 10001 
                    AND "ASMAY_Id" = 10020 
                    AND "FMG_Id" = 16 
                    AND "FMH_Id" = 29
            )
    LOOP
        SELECT COUNT(*) INTO "v_row_count"
        FROM "Fee_Master_Student_Group" 
        WHERE "FMG_Id" = "fmg_id" 
            AND "MI_Id" = "mi_id" 
            AND "amst_id" = "AmST_ID" 
            AND "ASMAY_Id" = "ASMAY_ID";

        IF "v_row_count" = 0 THEN
            INSERT INTO "Fee_Master_Student_Group" (
                "MI_Id", 
                "AMST_Id", 
                "ASMAY_Id", 
                "FMG_Id", 
                "FMSG_ActiveFlag"
            ) 
            VALUES (
                "mi_id", 
                "AmST_ID", 
                "ASMAY_ID", 
                "fmg_id", 
                'Y'
            );

            SELECT MAX("FMSG_Id") INTO "FMSG_Id" 
            FROM "Fee_Master_Student_Group";

            "amcl_id" := 15;
            "fmcc_id" := 6;

            FOR "fmh_id", "fti_id", "fma_id", "fma_amount" IN
                SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                FROM "Fee_Master_Amount" 
                WHERE "FMG_Id" = "fmg_id" 
                    AND "ASMAY_Id" = "ASMAY_ID" 
                    AND "MI_Id" = "mi_id" 
                    AND "FMCC_Id" = "fmcc_id"
            LOOP
                INSERT INTO "Fee_Master_Student_Group_Installment" (
                    "FMSG_Id", 
                    "FMH_ID", 
                    "FTI_ID"
                ) 
                VALUES (
                    "FMSG_Id", 
                    "fmh_id", 
                    "fti_id"
                );

                INSERT INTO "Fee_Student_Status" (
                    "MI_Id", 
                    "ASMAY_Id", 
                    "AMST_Id", 
                    "FMG_Id", 
                    "FMH_Id", 
                    "FTI_Id", 
                    "FMA_Id", 
                    "FSS_OBArrearAmount", 
                    "FSS_OBExcessAmount", 
                    "FSS_CurrentYrCharges", 
                    "FSS_TotalToBePaid", 
                    "FSS_ToBePaid", 
                    "FSS_PaidAmount", 
                    "FSS_ExcessPaidAmount", 
                    "FSS_ExcessAdjustedAmount",
                    "FSS_RunningExcessAmount", 
                    "FSS_ConcessionAmount", 
                    "FSS_AdjustedAmount", 
                    "FSS_WaivedAmount", 
                    "FSS_RebateAmount", 
                    "FSS_FineAmount", 
                    "FSS_RefundAmount", 
                    "FSS_RefundAmountAdjusted", 
                    "FSS_NetAmount", 
                    "FSS_ChequeBounceFlag", 
                    "FSS_ArrearFlag", 
                    "FSS_RefundOverFlag", 
                    "FSS_ActiveFlag", 
                    "User_Id", 
                    "FSS_RefundableAmount"
                ) 
                VALUES (
                    "mi_id", 
                    "ASMAY_ID",
                    "AmST_ID", 
                    "fmg_id", 
                    "fmh_id", 
                    "fti_id", 
                    "fma_id", 
                    0, 
                    0, 
                    "fma_amount", 
                    "fma_amount", 
                    "fma_amount", 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    0, 
                    "fma_amount", 
                    0, 
                    0, 
                    0, 
                    1, 
                    "userid", 
                    0
                );
            END LOOP;
        END IF;
    END LOOP;

    RETURN;
END;
$$;