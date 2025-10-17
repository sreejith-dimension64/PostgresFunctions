CREATE OR REPLACE FUNCTION "dbo"."FeeGroupChangeAutoUpdate"(
    p_ASMAY_Id BIGINT,
    p_MI_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_AMST_ID BIGINT,
    p_userid BIGINT,
    p_FMG_Idold BIGINT,
    p_FMGIDNEW BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_fmcc_id BIGINT;
    v_fmg_id BIGINT;
    v_fmh_id BIGINT;
    v_fti_id BIGINT;
    v_fma_id BIGINT;
    v_fma_amount BIGINT;
    v_grpcount BIGINT;
    v_FMSG_Id BIGINT;
    v_fmcc_idnew BIGINT;
    v_PAIDAMT BIGINT;
    v_FSS_Id BIGINT;
    v_FSS_PaidAmt BIGINT;
    v_FSS_TOBEPAID BIGINT;
    v_CNT BIGINT;
    v_FSSPAIDAMOUNT BIGINT;
    v_FSSIDADJ BIGINT;
    v_ADMC_CEAutoFeeGroupMapFlg BOOLEAN;
    v_rowcount INTEGER;
    rec_feeinstallment RECORD;
    rec_feeadjustment RECORD;
    rec_paidamt RECORD;
BEGIN

    v_ADMC_CEAutoFeeGroupMapFlg := TRUE;

    IF (v_ADMC_CEAutoFeeGroupMapFlg = TRUE) THEN
    BEGIN

        PERFORM * FROM "Fee_Student_Status" 
        WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id 
            AND "AMST_Id" = p_AMST_ID 
            AND "FSS_PaidAmount" = 0 
            AND "FMG_Id" = p_FMG_Idold;

        SELECT COUNT(*) INTO v_CNT 
        FROM "Adm_School_Y_Student" 
        WHERE "AMST_Id" = p_AMST_ID;

        GET DIAGNOSTICS v_rowcount = ROW_COUNT;

        IF v_rowcount > 0 THEN
        BEGIN

            DELETE FROM "Fee_Student_Status" 
            WHERE "ASMAY_Id" = p_ASMAY_Id 
                AND "MI_Id" = p_MI_Id 
                AND "AMST_Id" = p_AMST_ID 
                AND "FSS_PaidAmount" = 0 
                AND "FMG_Id" = p_FMG_Idold;

            DELETE FROM "Fee_Master_Student_Group_Installment" 
            WHERE "FMSG_Id" IN (
                SELECT "FMSG_Id" FROM "Fee_Master_Student_Group" 
                WHERE "AMST_Id" = p_AMST_ID 
                    AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "FMG_Id" = p_FMG_Idold
            );

            DELETE FROM "Fee_Master_Student_Group" 
            WHERE "AMST_Id" = p_AMST_ID 
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "FMG_Id" = p_FMG_Idold;

        END;
        END IF;

        SELECT "FMCC_Id" INTO v_fmcc_id 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" = p_ASMCL_Id
            )
        LIMIT 1;

        FOR rec_feeinstallment IN
            SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
            FROM "Fee_Master_Amount" 
            WHERE "ASMAY_Id" = p_ASMAY_Id 
                AND "MI_Id" = p_MI_Id 
                AND "FMCC_Id" = v_fmcc_id 
                AND "FMG_Id" = p_FMGIDNEW
        LOOP

            v_fmg_id := rec_feeinstallment."FMG_Id";
            v_fmh_id := rec_feeinstallment."FMH_Id";
            v_fti_id := rec_feeinstallment."FTI_Id";
            v_fma_id := rec_feeinstallment."FMA_Id";
            v_fma_amount := rec_feeinstallment."FMA_Amount";

            SELECT COUNT(*) INTO v_grpcount 
            FROM "Fee_Master_Student_Group" 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = p_AMST_ID 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "FMG_Id" = v_fmg_id;

            IF (v_grpcount > 0) THEN
            BEGIN
                SELECT "FMSG_Id" INTO v_FMSG_Id 
                FROM "Fee_Master_Student_Group" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "AMST_Id" = p_AMST_ID 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "FMG_Id" = v_fmg_id
                LIMIT 1;

                SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
                FROM "Fee_Master_Student_Group";
            END;
            ELSE
            BEGIN
                INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                VALUES (p_MI_Id, p_AMST_ID, p_ASMAY_Id, v_fmg_id, 'Y');

                SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
                FROM "Fee_Master_Student_Group";
            END;
            END IF;

            INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
            VALUES (v_FMSG_Id, v_fmh_id, v_fti_id);

            INSERT INTO "Fee_Student_Status"(
                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", 
                "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", 
                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
                "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
            ) 
            VALUES(
                p_MI_Id, p_ASMAY_Id, p_AMST_ID, v_fmg_id, v_fmh_id, v_fti_id, v_fma_id, 
                0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                0, 0, v_fma_amount, 0, 0, 0, 1, p_userid, 0
            );

        END LOOP;

        SELECT "FMCC_Id" INTO v_fmcc_idnew 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" = p_ASMCL_Id
            )
        LIMIT 1;

        SELECT SUM("FSS_PaidAmount") INTO v_PAIDAMT 
        FROM "Fee_Student_Status" 
        WHERE "AMST_Id" = p_AMST_ID 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id 
            AND "FMG_Id" = p_FMG_Idold;

        IF (COALESCE(v_PAIDAMT, 0) > 0) THEN
        BEGIN

            FOR rec_feeadjustment IN
                SELECT "FSS_Id", "FSS_PaidAmount" 
                FROM "Fee_Student_Status" 
                WHERE "AMST_Id" = p_AMST_ID 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "MI_Id" = p_MI_Id 
                    AND "FMG_Id" = p_FMG_Idold
            LOOP

                v_FSSIDADJ := rec_feeadjustment."FSS_Id";
                v_FSSPAIDAMOUNT := rec_feeadjustment."FSS_PaidAmount";

                UPDATE "Fee_Student_Status" 
                SET "FSS_ExcessAdjustedAmount" = v_FSSPAIDAMOUNT,
                    "FSS_ExcessPaidAmount" = v_FSSPAIDAMOUNT,
                    "FSS_PaidAmount" = v_FSSPAIDAMOUNT,
                    "FSS_CurrentYrCharges" = 0,
                    "FSS_TotalToBePaid" = 0 
                WHERE "FSS_Id" = v_FSSIDADJ;

            END LOOP;

        END;
        END IF;

        IF (COALESCE(v_PAIDAMT, 0) > 0) THEN
        BEGIN

            FOR rec_paidamt IN
                SELECT A."FSS_Id", A."FSS_ToBePaid", A."FSS_PaidAmount" 
                FROM "Fee_Student_Status" A
                INNER JOIN "Fee_Master_Group" B ON B."FMG_Id" = A."FMG_Id"
                INNER JOIN "Fee_Master_Head" C ON C."FMH_Id" = A."FMH_Id"
                INNER JOIN "Fee_T_Installment" D ON D."FTI_Id" = A."FTI_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" E ON E."FMH_Id" = A."FMH_Id" AND E."FTI_Id" = A."FTI_Id"
                INNER JOIN "Fee_Master_Terms" F ON F."FMT_Id" = E."FMT_Id"
                WHERE A."AMST_Id" = p_AMST_ID 
                    AND A."ASMAY_Id" = p_ASMAY_Id 
                    AND A."FMG_Id" = p_FMGIDNEW
                    AND A."FMA_Id" IN (
                        SELECT "FMA_Id" FROM "Fee_Master_Amount" 
                        WHERE "ASMAY_Id" = p_ASMAY_Id 
                            AND "MI_Id" = p_MI_Id 
                            AND "FMCC_Id" = v_fmcc_id 
                            AND "FMG_Id" = p_FMGIDNEW
                    )
                ORDER BY C."FMH_Order"
            LOOP

                v_FSS_Id := rec_paidamt."FSS_Id";
                v_FSS_TOBEPAID := rec_paidamt."FSS_ToBePaid";
                v_FSS_PaidAmt := rec_paidamt."FSS_PaidAmount";

                IF (v_PAIDAMT > v_FSS_TOBEPAID) THEN
                BEGIN

                    UPDATE "Fee_Student_Status" 
                    SET "FSS_ToBePaid" = 0, 
                        "FSS_PaidAmount" = v_FSS_TOBEPAID,
                        "FSS_AdjustedAmount" = v_FSS_TOBEPAID 
                    WHERE "FSS_Id" = v_FSS_Id;

                    v_PAIDAMT := v_PAIDAMT - v_FSS_TOBEPAID;

                END;
                ELSIF (v_PAIDAMT <= v_FSS_TOBEPAID) THEN
                BEGIN

                    UPDATE "Fee_Student_Status" 
                    SET "FSS_ToBePaid" = v_FSS_TOBEPAID - v_PAIDAMT,
                        "FSS_AdjustedAmount" = v_PAIDAMT 
                    WHERE "FSS_Id" = v_FSS_Id;

                    v_PAIDAMT := 0;

                END;
                END IF;

            END LOOP;

        END;
        END IF;

    END;
    END IF;

END;
$$;