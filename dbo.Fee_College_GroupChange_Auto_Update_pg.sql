CREATE OR REPLACE FUNCTION "Fee_College_GroupChange_Auto_Update"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCST_ID bigint,
    p_AMB_Id bigint,
    p_AMCO_Id bigint,
    p_userid bigint,
    p_FMG_IdOLD bigint,
    p_FMGIDNEW bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fmcc_id bigint;
    v_fmg_id bigint;
    v_fmh_id bigint;
    v_fti_id bigint;
    v_FCMA_Id bigint;
    v_fma_amount bigint;
    v_grpcount bigint;
    v_FCMSGH_Id bigint;
    v_fmcc_idnew bigint;
    v_PAIDAMT bigint;
    v_FSS_Id bigint;
    v_FSS_PaidAmt bigint;
    v_FSS_TOBEPAID bigint;
    v_CNT bigint;
    v_FSSPAIDAMOUNT bigint;
    v_FSSIDADJ bigint;
    v_FCMSGH_Id_NEW bigint;
    v_FCMAS_Amount decimal(18,2);
    v_ADMC_CEAutoFeeGroupMapFlg boolean;
    v_RowCount bigint;
    v_CurrentRow bigint;
    v_PaidRow bigint;
    v_FCSS_Id bigint;
    v_FCSS_PaidAmount decimal(18,2);
    v_FCSS_ToBePaid decimal(18,2);
BEGIN

    v_ADMC_CEAutoFeeGroupMapFlg := true;

    IF (v_ADMC_CEAutoFeeGroupMapFlg = true) THEN
    BEGIN

        SELECT COUNT(1) INTO v_CNT 
        FROM "CLG"."Adm_College_Yearly_Student" 
        WHERE "AMCST_Id" = p_AMCST_ID AND "AMB_Id" = p_AMB_Id AND "AMCO_Id" = p_AMCO_Id;

        IF (v_CNT > 0) THEN
        BEGIN

            DELETE FROM "CLG"."Fee_College_Student_Status" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "AMCST_Id" = p_AMCST_Id 
            AND "FCSS_PaidAmount" = 0 AND "FMG_Id" = p_FMG_IdOLD;

            DELETE FROM "clg"."Fee_C_Master_Student_GroupHead_Installments" 
            WHERE "FCMSGH_Id" IN (
                SELECT "FCMSGH_Id" FROM "clg"."Fee_College_Master_Student_GroupHead"
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "AMCST_Id" = p_AMCST_Id 
                AND "FMG_Id" = p_FMG_IdOLD
            );

            DELETE FROM "clg"."Fee_College_Master_Student_GroupHead" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "AMCST_Id" = p_AMCST_Id 
            AND "FMG_Id" = p_FMG_IdOLD;

        END;
        END IF;

        DROP TABLE IF EXISTS "FeeMasterAmountTemp";

        CREATE TEMP TABLE "FeeMasterAmountTemp" (
            "RowID" SERIAL,
            "FMG_Id" bigint,
            "FMH_Id" bigint,
            "FTI_Id" bigint,
            "FCMA_Id" bigint,
            "FCMAS_Amount" decimal(18,2)
        );

        INSERT INTO "FeeMasterAmountTemp" ("FMG_Id", "FMH_Id", "FTI_Id", "FCMA_Id", "FCMAS_Amount")
        SELECT A."FMG_Id", A."FMH_Id", A."FTI_Id", A."FCMA_Id", B."FCMAS_Amount"
        FROM "clg"."Fee_College_Master_Amount" A 
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" B ON A."FCMA_Id" = B."FCMA_Id"
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id AND "FMG_Id" = p_FMGIDNEW;

        SELECT COUNT(1) INTO v_RowCount FROM "FeeMasterAmountTemp";
        v_CurrentRow := 1;

        WHILE v_CurrentRow <= v_RowCount LOOP

            SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FCMA_Id", "FCMAS_Amount"
            INTO v_fmg_id, v_fmh_id, v_fti_id, v_FCMA_Id, v_FCMAS_Amount
            FROM "FeeMasterAmountTemp"
            WHERE "RowID" = v_CurrentRow;

            SELECT COUNT(1) INTO v_grpcount
            FROM "clg"."Fee_College_Master_Student_GroupHead"
            WHERE "MI_Id" = p_MI_Id AND "AMCST_Id" = p_AMCST_ID AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FMG_Id" = v_fmg_id;

            IF (v_grpcount > 0) THEN
            BEGIN

                SELECT MAX("FCMSGH_Id") INTO v_FCMSGH_Id
                FROM "clg"."Fee_College_Master_Student_GroupHead"
                WHERE "MI_Id" = p_MI_Id AND "AMCST_Id" = p_AMCST_ID AND "ASMAY_Id" = p_ASMAY_Id 
                AND "FMG_Id" = v_fmg_id;

            END;
            ELSE
            BEGIN

                INSERT INTO "clg"."Fee_College_Master_Student_GroupHead" 
                    ("MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag")
                VALUES (p_MI_Id, p_AMCST_ID, p_ASMAY_Id, v_fmg_id, 1)
                RETURNING "FCMSGH_Id" INTO v_FCMSGH_Id_NEW;

            END;
            END IF;

            INSERT INTO "clg"."Fee_C_Master_Student_GroupHead_Installments" 
                ("FCMSGH_Id", "FMH_ID", "FTI_ID")
            VALUES (v_FCMSGH_Id_NEW, v_fmh_id, v_fti_id);

            INSERT INTO "CLG"."Fee_College_Student_Status" (
                "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                "FCSS_TotalCharges", "FCSS_ConcessionAmount", "FCSS_WaivedAmount", "FCSS_ToBePaid", 
                "FCSS_PaidAmount", "FCSS_RefundableAmount", "FCSS_ExcessPaidAmount", 
                "FCSS_ExcessAmountAdjusted", "FCSS_RunningExcessAmount", "FCSS_AdjustedAmount", 
                "FCSS_RebateAmount", "FCSS_FineAmount", "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted",
                "FCSS_NetAmount", "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", 
                "FCSS_ActiveFlag", "User_Id", "FCSS_CreatedDate", "FCSS_UpdatedDate"
            )
            VALUES(
                p_MI_Id, p_ASMAY_Id, p_AMCST_ID, v_fmg_id, v_fmh_id, v_fti_id, v_FCMA_Id, 
                0, 0, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, v_FCMAS_Amount, v_FCMAS_Amount, 
                0, 0, 0, 0, 0, 0, 0, 0, 0, v_FCMAS_Amount, 0, 0, false, 1, p_userid, 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );

            v_CurrentRow := v_CurrentRow + 1;

        END LOOP;

        DROP TABLE IF EXISTS "FeeMasterAmountTemp";

        SELECT COALESCE(sum("FCSS_PaidAmount"), 0) INTO v_PAIDAMT
        FROM "CLG"."Fee_College_Student_Status" 
        WHERE "AMCST_Id" = p_AMCST_ID AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
        AND "FMG_Id" = p_FMG_IdOLD;

        IF (v_PAIDAMT > 0) THEN
        BEGIN

            DROP TABLE IF EXISTS "PaidAmount";

            CREATE TEMP TABLE "PaidAmount" (
                "RowID" SERIAL,
                "FCSS_Id" bigint,
                "FCSS_PaidAmount" decimal(18,2)
            );

            INSERT INTO "PaidAmount"("FCSS_Id", "FCSS_PaidAmount")
            SELECT "FCSS_Id", "FCSS_PaidAmount"
            FROM "CLG"."Fee_College_Student_Status"
            WHERE "AMCST_Id" = p_AMCST_ID AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "FMG_Id" = p_FMG_IdOLD;

            SELECT COUNT(1) INTO v_PAIDAMT FROM "PaidAmount";

            v_PaidRow := 1;

            WHILE v_PaidRow <= v_PAIDAMT LOOP

                SELECT "FCSS_Id", "FCSS_PaidAmount" INTO v_FCSS_Id, v_FCSS_PaidAmount
                FROM "PaidAmount"
                WHERE "RowID" = v_PaidRow;

                UPDATE "CLG"."Fee_College_Student_Status" 
                SET "FCSS_ToBePaid" = 0, "FCSS_PaidAmount" = v_FCSS_PaidAmount, 
                    "FCSS_AdjustedAmount" = v_FCSS_PaidAmount
                WHERE "FCSS_Id" = v_FCSS_Id;

                v_PaidRow := v_PaidRow + 1;

            END LOOP;

            DROP TABLE IF EXISTS "PaidAmount";

        END;
        END IF;

        IF (v_PAIDAMT > 0) THEN
        BEGIN

            DROP TABLE IF EXISTS "FeeStudentStatusPaymentsTemp";

            CREATE TEMP TABLE "FeeStudentStatusPaymentsTemp" (
                "RowID" SERIAL,
                "FCSS_Id" bigint,
                "FCSS_ToBePaid" bigint,
                "FCSS_PaidAmount" decimal(18,2)
            );

            INSERT INTO "FeeStudentStatusPaymentsTemp" ("FCSS_Id", "FCSS_ToBePaid", "FCSS_PaidAmount")
            SELECT A."FCSS_Id", A."FCSS_ToBePaid", A."FCSS_PaidAmount"
            FROM "CLG"."Fee_College_Student_Status" A 
            INNER JOIN "Fee_Master_Group" B ON A."FMG_Id" = B."FMG_Id"
            INNER JOIN "Fee_Master_Head" C ON C."FMH_Id" = A."FMH_Id"
            INNER JOIN "Fee_T_Installment" D ON D."FTI_Id" = A."FTI_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" E ON E."FMH_Id" = A."FMH_Id" AND E."FTI_Id" = A."FTI_Id"
            INNER JOIN "Fee_Master_Terms" F ON F."FMT_Id" = E."FMT_Id"
            WHERE A."AMCST_Id" = p_AMCST_ID AND A."ASMAY_id" = p_ASMAY_Id AND A."FMG_Id" = p_FMGIDNEW 
            AND "FCMAS_Id" IN (
                SELECT "FCMAS_Id" FROM "clg"."Fee_College_Master_Amount" K 
                INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" L ON K."FCMA_Id" = L."FCMA_Id"
                WHERE K."MI_Id" = p_MI_Id AND K."ASMAY_Id" = p_ASMAY_Id AND "FMG_Id" = p_FMGIDNEW
            )
            ORDER BY "FMH_Order";

            SELECT COUNT(1) INTO v_RowCount FROM "FeeStudentStatusPaymentsTemp";
            v_CurrentRow := 1;

            WHILE v_CurrentRow <= v_RowCount LOOP

                SELECT "FCSS_Id", "FCSS_ToBePaid", "FCSS_PaidAmount" 
                INTO v_FCSS_Id, v_FCSS_ToBePaid, v_FCSS_PaidAmount
                FROM "FeeStudentStatusPaymentsTemp"
                WHERE "RowID" = v_CurrentRow;

                IF (v_PAIDAMT > v_FSS_TOBEPAID) THEN
                BEGIN

                    UPDATE "CLG"."Fee_College_Student_Status" 
                    SET "FCSS_ToBePaid" = 0, "FCSS_PaidAmount" = v_FCSS_ToBePaid, 
                        "FCSS_AdjustedAmount" = v_FCSS_ToBePaid
                    WHERE "FCSS_Id" = v_FCSS_Id;

                    v_PAIDAMT := v_PAIDAMT - v_FCSS_ToBePaid;

                END;
                ELSIF (v_PAIDAMT <= v_FCSS_ToBePaid) THEN
                BEGIN

                    UPDATE "CLG"."Fee_College_Student_Status" 
                    SET "FCSS_ToBePaid" = 0, "FCSS_PaidAmount" = v_FCSS_ToBePaid - v_PAIDAMT, 
                        "FCSS_AdjustedAmount" = v_PAIDAMT
                    WHERE "FCSS_Id" = v_FCSS_Id;

                    v_PAIDAMT := 0;

                END;
                END IF;

                v_CurrentRow := v_CurrentRow + 1;

            END LOOP;

            DROP TABLE IF EXISTS "FeeStudentStatusPaymentsTemp";

        END;
        END IF;

    END;
    END IF;

END;
$$;