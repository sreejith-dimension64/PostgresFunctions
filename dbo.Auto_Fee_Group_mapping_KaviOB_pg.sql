CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_KaviOB"(
    @mi_id bigint,
    @ASMAY_ID bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    @fyghm_id bigint;
    @fmcc_id bigint;
    @amcl_id bigint;
    @fma_id bigint;
    @fti_name varchar(100);
    @fma_amount numeric;
    @fmh_name varchar(100);
    @fmg_id bigint;
    @fmsgid bigint;
    @ftp_concession_amt bigint;
    @fmh_id bigint;
    @fti_id bigint;
    @FMSG_Id bigint;
    @FMC_DOACheckFlag int;
    @FTI_Id_N bigint;
    @amst_id bigint;
    v_row_count int;
BEGIN
    @amcl_id := 0;
    @fmcc_id := 0;
    @fma_id := 0;
    @fti_name := '';
    @fma_amount := 0;
    @fmh_name := '';
    @ftp_concession_amt := 0;

    FOR @amst_id IN
        SELECT DISTINCT "fee_student_status"."AMST_Id" 
        FROM "fee_student_status"
        INNER JOIN "Adm_M_Student" ON "fee_student_status"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        WHERE "fee_student_status"."mi_id" = 6 
            AND "fee_student_status"."ASMAY_Id" = 77 
            AND "FMG_Id" = 201 
            AND "FSS_ToBePaid" > 0 
            AND "AMST_SOL" = 'S'
            AND "fee_student_status"."AMST_Id" != 193
    LOOP
        SELECT COUNT(*) INTO v_row_count
        FROM "Fee_Master_Student_Group" 
        WHERE "FMG_Id" = 201 
            AND "MI_Id" = 6 
            AND "amst_id" = @amst_id 
            AND "ASMAY_Id" = 83;

        IF v_row_count = 0 THEN
            INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
            VALUES (6, @amst_id, 83, 201, 'Y');

            SELECT MAX("FMSG_Id") INTO @FMSG_Id FROM "Fee_Master_Student_Group";

            SELECT "ASMCL_Id" INTO @amcl_id 
            FROM "Adm_School_Y_Student" 
            WHERE "amst_id" = @amst_id 
                AND "ASMAY_Id" = 83;

            SELECT "FMCC_Id" INTO @fmcc_id 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id" = 83 
                AND "MI_Id" = 6 
                AND "FYCC_Id" IN (
                    SELECT "FYCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" = @amcl_id
                );

            FOR @fmh_id, @fti_id, @fma_id, @fma_amount IN
                SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                FROM "Fee_Master_Amount" 
                WHERE "FMG_Id" = 201 
                    AND "ASMAY_Id" = 83 
                    AND "MI_Id" = 6 
                    AND "FMCC_Id" = @fmcc_id
            LOOP
                INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
                VALUES (@FMSG_Id, @fmh_id, @fti_id);

                INSERT INTO "Fee_Student_Status" (
                    "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                    "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                    "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", 
                    "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", 
                    "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                    "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                    "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
                    "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
                ) 
                VALUES (
                    6, 83, @amst_id, 201, @fmh_id, @fti_id, @fma_id, 
                    0, 0, @fma_amount, @fma_amount, @fma_amount, 0, 0, 
                    0, 0, 0, 0, 0, 0, 0, 0, 0, @fma_amount, 
                    0, 0, 0, 1, 725, 0
                );
            END LOOP;
        END IF;
    END LOOP;

    RETURN;
END;
$$;