CREATE OR REPLACE FUNCTION "dbo"."Fee_RebateTermWise_calculation"(
    "p_MI_Id" VARCHAR(500),
    "p_ASMAY_ID" VARCHAR(500),
    "p_AMST_ID" VARCHAR(500),
    "p_FMT_ID" TEXT,
    "p_paiddate" DATE,
    "p_paidamount" BIGINT,
    "p_USERID" VARCHAR(25),
    OUT "p_totalrebateamount" BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    "v_FMC_RebateAplicableFlg" BOOLEAN;
    "v_FMC_RebateAgainstFullPaymentFlg" BOOLEAN;
    "v_FMC_RebateAgainstPartialPaymentFlg" BOOLEAN;
    "v_FMA_ID" BIGINT;
    "v_FYREBSET_RebateTypeFlg" VARCHAR(50);
    "v_FYREBSET_RebateDate" DATE;
    "v_FYREBSET_RebateAmtOrPercentValue" DECIMAL(18,2);
    "v_totalyrcharges" BIGINT;
    "v_FYGH_RebateApplicableFlg" BOOLEAN;
    "v_FYGH_RebateTypeFlg" VARCHAR(50);
    "v_CurrentYrCharges" BIGINT;
    "v_FMG_IDFullpayment" BIGINT;
    "v_FMH_IDFullpayment" BIGINT;
    "v_FMT_IDFullpayment" BIGINT;
    "v_FTI_IDFullpayment" BIGINT;
    "v_rebateamount" BIGINT;
    "v_FMG_IDFullpaymentamt" BIGINT;
    "v_FMH_IDFullpaymentamt" BIGINT;
    "v_FMT_IDFullpaymentamt" BIGINT;
    "v_FTI_IDFullpaymentamt" BIGINT;
    "v_FMTRS_RebateAmountPercentValue" BIGINT;
    "v_FMG_IDPartialpercent" BIGINT;
    "v_FMTRS_RebateAmountPercentFlg" VARCHAR(500);
    "v_FMH_IDPartialpercent" BIGINT;
    "v_FMT_IDPartialpercent" BIGINT;
    "v_FTI_IDPartialpercent" BIGINT;
    "v_FMTRS_RebateApplicableDate" DATE;
    "v_FMG_IDPartialamt" BIGINT;
    "v_FMH_IDPartialamt" BIGINT;
    "v_FMI_IDPartialamt" BIGINT;
    "v_FTI_IDPartialamt" BIGINT;
    "v_FMT_IDPartialfmtid" BIGINT;
    "v_count" BIGINT;
    "rec_fullpayment" RECORD;
    "rec_partialpercent" RECORD;
    "rec_partialfmtid" RECORD;
BEGIN

    DROP TABLE IF EXISTS "groupheadinstallment_temp";
    DROP TABLE IF EXISTS "currentyrchargestotal";
    DROP TABLE IF EXISTS "groupcount";

    SELECT "FMC_RebateAplicableFlg", "FMC_RebateAgainstFullPaymentFlg", "FMC_RebateAgainstPartialPaymentFlg"
    INTO "v_FMC_RebateAplicableFlg", "v_FMC_RebateAgainstFullPaymentFlg", "v_FMC_RebateAgainstPartialPaymentFlg"
    FROM "Fee_Master_Configuration" 
    WHERE "MI_ID" = "p_MI_Id"::BIGINT AND "USERID" = "p_USERID"::BIGINT AND "ASMAY_ID" != 0;

    SELECT "FYREBSET_RebateTypeFlg", "FYREBSET_RebateDate", "FYREBSET_RebateAmtOrPercentValue"
    INTO "v_FYREBSET_RebateTypeFlg", "v_FYREBSET_RebateDate", "v_FYREBSET_RebateAmtOrPercentValue"
    FROM "Fee_Yearly_RebateSetting" 
    WHERE "MI_ID" = "p_MI_Id"::BIGINT AND "ASMAY_Id" = "p_ASMAY_ID"::BIGINT;

    "v_rebateamount" := 0;
    "p_totalrebateamount" := 0;

    CREATE TEMP TABLE "Termids_temp" AS
    SELECT DISTINCT "Fee_Master_Terms_FeeHeads"."FMT_ID"
    FROM "Fee_Student_Status" 
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
        AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
    INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."fmg_id" = "Fee_Student_Status"."FMG_Id"
        AND "Fee_Group_Login_Previledge"."fmh_id" = "Fee_Student_Status"."fmh_id"
    WHERE "Amst_Id" IN (SELECT DISTINCT "Amst_Id" FROM "Adm_School_Y_Student" 
                        WHERE "amst_id" = "p_AMST_ID"::BIGINT AND "asmay_id" = "p_ASMAY_ID"::BIGINT)
    AND "FSS_ActiveFlag" = 1 
    AND "Fee_Student_Status"."MI_Id" = "p_MI_Id"::BIGINT 
    AND "Fee_Student_Status"."ASMAY_Id" = "p_ASMAY_ID"::BIGINT
    AND "Fee_Group_Login_Previledge"."user_id" = "p_USERID"::BIGINT;

    EXECUTE format('
        CREATE TEMP TABLE "groupheadinstallment_temp" AS
        SELECT "Fee_Master_Terms_FeeHeads"."FMT_ID", "Fee_Student_Status"."fmg_id", 
               "Fee_Student_Status"."Fmh_id", "Fee_Student_Status"."fti_id"
        FROM "Fee_Student_Status" 
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
        INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."fmg_id" = "Fee_Student_Status"."FMG_Id"
            AND "Fee_Group_Login_Previledge"."fmh_id" = "Fee_Student_Status"."fmh_id"
        WHERE "Amst_Id" IN (SELECT DISTINCT "Amst_Id" FROM "Adm_School_Y_Student" 
                           WHERE "amst_id" = %s AND "asmay_id" = %s)
        AND "FSS_ActiveFlag" = 1 
        AND "Fee_Student_Status"."MI_Id" = %s 
        AND "Fee_Student_Status"."ASMAY_Id" = %s
        AND "Fee_Group_Login_Previledge"."user_id" = %s 
        AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (%s)',
        "p_AMST_ID"::BIGINT, "p_ASMAY_ID"::BIGINT, "p_MI_Id"::BIGINT, 
        "p_ASMAY_ID"::BIGINT, "p_USERID"::BIGINT, "p_FMT_ID");

    EXECUTE format('
        CREATE TEMP TABLE "currentyrchargestotal" AS
        SELECT SUM("Fee_Student_Status"."FSS_CurrentYrCharges") AS "Currentyrchargestotal"
        FROM "Fee_Student_Status" 
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
        INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."fmg_id" = "Fee_Student_Status"."FMG_Id"
            AND "Fee_Group_Login_Previledge"."fmh_id" = "Fee_Student_Status"."fmh_id"
        WHERE "Amst_Id" IN (SELECT DISTINCT "Amst_Id" FROM "Adm_School_Y_Student" 
                           WHERE "amst_id" = %s AND "asmay_id" = %s)
        AND "FSS_ActiveFlag" = 1 
        AND "Fee_Student_Status"."MI_Id" = %s 
        AND "Fee_Student_Status"."ASMAY_Id" = %s
        AND "Fee_Group_Login_Previledge"."user_id" = %s 
        AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (SELECT DISTINCT "FMT_ID" FROM "Termids_temp")',
        "p_AMST_ID"::BIGINT, "p_ASMAY_ID"::BIGINT, "p_MI_Id"::BIGINT, 
        "p_ASMAY_ID"::BIGINT, "p_USERID"::BIGINT);

    EXECUTE format('
        CREATE TEMP TABLE "groupcount" AS
        SELECT COUNT(DISTINCT "Fee_Student_Status"."fmg_id") AS "FmgidCount"
        FROM "Fee_Student_Status" 
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
        INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."fmg_id" = "Fee_Student_Status"."FMG_Id"
            AND "Fee_Group_Login_Previledge"."fmh_id" = "Fee_Student_Status"."fmh_id"
        WHERE "Amst_Id" IN (SELECT DISTINCT "Amst_Id" FROM "Adm_School_Y_Student" 
                           WHERE "amst_id" = %s AND "asmay_id" = %s)
        AND "FSS_ActiveFlag" = 1 
        AND "Fee_Student_Status"."MI_Id" = %s 
        AND "Fee_Student_Status"."ASMAY_Id" = %s
        AND "Fee_Group_Login_Previledge"."user_id" = %s 
        AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (%s)',
        "p_AMST_ID"::BIGINT, "p_ASMAY_ID"::BIGINT, "p_MI_Id"::BIGINT, 
        "p_ASMAY_ID"::BIGINT, "p_USERID"::BIGINT, "p_FMT_ID");

    SELECT "Currentyrchargestotal" INTO "v_totalyrcharges" FROM "currentyrchargestotal";
    SELECT "FmgidCount" INTO "v_count" FROM "groupcount";

    IF ("p_paidamount" >= "v_totalyrcharges") THEN

        IF ("v_FMC_RebateAplicableFlg" = TRUE AND "v_FMC_RebateAgainstFullPaymentFlg" = TRUE 
            AND "v_FMC_RebateAgainstPartialPaymentFlg" = FALSE) THEN

            FOR "rec_fullpayment" IN 
                SELECT * FROM "groupheadinstallment_temp"
            LOOP
                "v_FMT_IDFullpayment" := "rec_fullpayment"."FMT_ID";
                "v_FMG_IDFullpayment" := "rec_fullpayment"."fmg_id";
                "v_FMH_IDFullpayment" := "rec_fullpayment"."Fmh_id";
                "v_FTI_IDFullpayment" := "rec_fullpayment"."fti_id";

                SELECT "FYG_RebateApplicableFlg", "FYG_RebateTypeFlg"
                INTO "v_FYGH_RebateApplicableFlg", "v_FYGH_RebateTypeFlg"
                FROM "Fee_Yearly_Group"
                WHERE "MI_ID" = "p_MI_Id"::BIGINT 
                    AND "ASMAY_Id" = "p_ASMAY_ID"::BIGINT 
                    AND "FMG_ID" = "v_FMG_IDFullpayment";

                IF ("v_FYGH_RebateApplicableFlg" = TRUE AND "v_FYGH_RebateTypeFlg" = 'Percentage') THEN

                    IF ("v_FYREBSET_RebateTypeFlg" = 'Percentage') THEN

                        SELECT "FSS_CurrentYrCharges" INTO "v_CurrentYrCharges"
                        FROM "Fee_Student_Status" 
                        WHERE "MI_ID" = "p_MI_Id"::BIGINT 
                            AND "ASMAY_Id" = "p_ASMAY_ID"::BIGINT 
                            AND "FMG_ID" = "v_FMG_IDFullpayment"
                            AND "FMH_Id" = "v_FMH_IDFullpayment" 
                            AND "FTI_Id" = "v_FTI_IDFullpayment" 
                            AND "AMST_ID" = "p_AMST_ID"::BIGINT;

                        IF ("p_paiddate" <= "v_FYREBSET_RebateDate") THEN
                            "v_rebateamount" := (("v_CurrentYrCharges" * "v_FYREBSET_RebateAmtOrPercentValue") / 100);
                            "p_totalrebateamount" := "p_totalrebateamount" + "v_rebateamount";
                        ELSE
                            "p_totalrebateamount" := 0;
                        END IF;

                    END IF;

                ELSIF ("v_FYGH_RebateApplicableFlg" = TRUE AND "v_FYGH_RebateTypeFlg" = 'Amount') THEN

                    IF ("v_FYREBSET_RebateTypeFlg" = 'Amount') THEN

                        IF ("p_paiddate" <= "v_FYREBSET_RebateDate") THEN
                            "v_rebateamount" := ("v_FYREBSET_RebateAmtOrPercentValue" / "v_count");
                            "p_totalrebateamount" := "v_rebateamount";
                        ELSE
                            "p_totalrebateamount" := 0;
                        END IF;

                    END IF;

                END IF;

            END LOOP;

        END IF;

    ELSIF ("p_paidamount" < "v_totalyrcharges") THEN

        IF ("v_FMC_RebateAplicableFlg" = TRUE AND "v_FMC_RebateAgainstFullPaymentFlg" = FALSE 
            AND "v_FMC_RebateAgainstPartialPaymentFlg" = TRUE) THEN

            FOR "rec_partialpercent" IN 
                SELECT * FROM "groupheadinstallment_temp"
            LOOP
                "v_FMT_IDPartialpercent" := "rec_partialpercent"."FMT_ID";
                "v_FMG_IDPartialpercent" := "rec_partialpercent"."fmg_id";
                "v_FMH_IDPartialpercent" := "rec_partialpercent"."Fmh_id";
                "v_FTI_IDPartialpercent" := "rec_partialpercent"."fti_id";

                SELECT "FYG_RebateApplicableFlg"
                INTO "v_FYGH_RebateApplicableFlg"
                FROM "Fee_Yearly_Group"
                WHERE "MI_ID" = "p_MI_Id"::BIGINT 
                    AND "ASMAY_Id" = "p_ASMAY_ID"::BIGINT 
                    AND "FMG_ID" = "v_FMG_IDPartialpercent";

                IF ("v_FYGH_RebateApplicableFlg" = TRUE) THEN

                    "v_FMTRS_RebateApplicableDate" := '1970-01-01';
                    "v_FMTRS_RebateAmountPercentFlg" := '';
                    "v_FMTRS_RebateAmountPercentValue" := 0;

                    SELECT "FMTRS_RebateApplicableDate", "FMTRS_RebateAmountPercentFlg", "FMTRS_RebateAmountPercentValue"
                    INTO "v_FMTRS_RebateApplicableDate", "v_FMTRS_RebateAmountPercentFlg", "v_FMTRS_RebateAmountPercentValue"
                    FROM "Fee_Master_Terms_RebateSetting" 
                    WHERE "FMT_Id" = "v_FMT_IDPartialpercent" AND "ASMAY_ID" = "p_ASMAY_ID"::BIGINT;

                    IF ("v_FMTRS_RebateAmountPercentFlg" = 'Percentage') THEN

                        SELECT "FSS_CurrentYrCharges" INTO "v_CurrentYrCharges"
                        FROM "Fee_Student_Status" 
                        WHERE "MI_ID" = "p_MI_Id"::BIGINT 
                            AND "ASMAY_Id" = "p_ASMAY_ID"::BIGINT 
                            AND "FMG_ID" = "v_FMG_IDPartialpercent"
                            AND "FMH_Id" = "v_FMH_IDPartialpercent" 
                            AND "FTI_Id" = "v_FTI_IDPartialpercent" 
                            AND "AMST_ID" = "p_AMST_ID"::BIGINT;

                        IF ("p_paiddate" <= "v_FMTRS_RebateApplicableDate") THEN
                            "v_rebateamount" := (("v_CurrentYrCharges" * "v_FMTRS_RebateAmountPercentValue") / 100);
                            "p_totalrebateamount" := "p_totalrebateamount" + "v_rebateamount";
                        ELSIF ("v_FMTRS_RebateApplicableDate" != '1970-01-01') THEN
                            "p_totalrebateamount" := 0;
                        END IF;

                    END IF;

                END IF;

            END LOOP;

            IF ("v_FMTRS_RebateAmountPercentFlg" = 'Amount') THEN

                FOR "rec_partialfmtid" IN 
                    SELECT DISTINCT "FMT_ID" 
                    FROM "Fee_Master_Terms" 
                    WHERE "MI_Id" = "p_MI_Id"::BIGINT 
                        AND "FMT_Id" IN (SELECT DISTINCT "FMT_ID" FROM "groupheadinstallment_temp")
                LOOP
                    "v_FMT_IDPartialfmtid" := "rec_partialfmtid"."FMT_ID";

                    "v_FMTRS_RebateApplicableDate" := '1970-01-01';
                    "v_FMTRS_RebateAmountPercentFlg" := '';
                    "v_FMTRS_RebateAmountPercentValue" := 0;

                    SELECT "FMTRS_RebateApplicableDate", "FMTRS_RebateAmountPercentFlg", "FMTRS_RebateAmountPercentValue"
                    INTO "v_FMTRS_RebateApplicableDate", "v_FMTRS_RebateAmountPercentFlg", "v_FMTRS_RebateAmountPercentValue"
                    FROM "Fee_Master_Terms_RebateSetting" 
                    WHERE "FMT_Id" = "v_FMT_IDPartialfmtid" AND "ASMAY_ID" = "p_ASMAY_ID"::BIGINT;

                    IF ("p_paiddate" <= "v_FMTRS_RebateApplicableDate") THEN
                        "v_rebateamount" := "v_FMTRS_RebateAmountPercentValue";
                        "p_totalrebateamount" := "p_totalrebateamount" + "v_rebateamount";
                    ELSIF ("v_FMTRS_RebateApplicableDate" != '1970-01-01') THEN
                        "p_totalrebateamount" := 0;
                    END IF;

                END LOOP;

            END IF;

        END IF;

    ELSE
        "p_totalrebateamount" := 0;
    END IF;

    RETURN;

END;
$$;