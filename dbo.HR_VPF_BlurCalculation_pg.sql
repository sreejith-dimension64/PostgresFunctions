CREATE OR REPLACE FUNCTION "dbo"."HR_VPF_BlurCalculation"(
    "p_HREVPFST_Id" bigint,
    "p_HREVPFST_VOBAmount" decimal(18,2),
    "p_HREVPFST_TransferAmount" decimal(18,2),
    "p_HREVPFST_WithdrawnAmount" decimal(18,2),
    "p_HREVPFST_SettledAmount" decimal(18,2),
    "p_HREVPFST_DepositAdjustmentAmount" decimal(18,2),
    "p_HREVPFST_WithsrawAdjustmentAmount" decimal(18,2),
    "p_Headdate" date
)
RETURNS TABLE(
    "HREVPFST_Id" bigint,
    "IMFY_Id" bigint,
    "HRME_Id" bigint,
    "IVRM_Month_Name" text,
    "HREVPFST_VOBAmount" decimal(18,2),
    "HREVPFST_Contribution" decimal(18,2),
    "HREVPFST_WithdrawnAmount" decimal(18,2),
    "HREVPFST_SettledAmount" decimal(18,2),
    "HREVPFST_TransferAmount" decimal(18,2),
    "HREVPFST_DepositAdjustmentAmount" decimal(18,2),
    "HREVPFST_WithsrawAdjustmentAmount" decimal(18,2),
    "HREVPFST_Intersest" decimal(18,2),
    "HREVPFST_ClosingBalance" decimal(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ClosingBalance" decimal(18,2);
    "v_InterestAmt" decimal(18,2);
    "v_Contribution" decimal(18,2);
    "v_WithdrawnAmount" decimal(18,2);
    "v_SettledAmount" decimal(18,2);
    "v_TransferAmount" decimal(18,2);
    "v_DepositAdjustmentAmount" decimal(18,2);
    "v_WithsrawAdjustmentAmount" decimal(18,2);
    "v_Openingbalance" decimal(18,2);
    "v_MI_Id" bigint;
    "v_IMFY_Id" bigint;
    "v_HRME_Id" bigint;
    "v_TranctionID" bigint;
    "v_IVRM_Month_Name" text;
    "v_HRMPFVPFINT_VPFInterestRate" decimal(18,2);
    "v_NextOpeningbalance" decimal(18,2);
    "v_MonthId" bigint;
    "v_YearId" bigint;
    "rec" RECORD;
BEGIN

    SELECT "IMFY_Id", "HRME_Id" INTO "v_IMFY_Id", "v_HRME_Id"
    FROM "HR_Employee_VPF_Status"
    WHERE "HREVPFST_Id" = "p_HREVPFST_Id";

    "v_NextOpeningbalance" := 0;
    "v_ClosingBalance" := 0;
    "v_Contribution" := 0;
    "v_InterestAmt" := 0;
    "v_HRMPFVPFINT_VPFInterestRate" := 0;

    FOR "rec" IN
        SELECT 
            "HREVPFST_Id",
            "IMFY_Id",
            "IVRM_Month_Name",
            "HREVPFST_VOBAmount",
            "HREVPFST_Contribution",
            "HREVPFST_WithdrawnAmount",
            "HREVPFST_SettledAmount",
            "HREVPFST_TransferAmount",
            "HREVPFST_DepositAdjustmentAmount",
            "HREVPFST_WithsrawAdjustmentAmount"
        FROM "HR_Employee_VPF_Status_Edit"
        WHERE "HRME_Id" = "v_HRME_Id" 
            AND "IMFY_Id" = "v_IMFY_Id" 
            AND "HREVPFST_Id" >= "p_HREVPFST_Id"
        ORDER BY "HREVPFST_Id"
    LOOP
        "v_TranctionID" := "rec"."HREVPFST_Id";
        "v_IMFY_Id" := "rec"."IMFY_Id";
        "v_IVRM_Month_Name" := "rec"."IVRM_Month_Name";
        "v_Openingbalance" := "rec"."HREVPFST_VOBAmount";
        "v_Contribution" := "rec"."HREVPFST_Contribution";
        "v_WithdrawnAmount" := "rec"."HREVPFST_WithdrawnAmount";
        "v_SettledAmount" := "rec"."HREVPFST_SettledAmount";
        "v_TransferAmount" := "rec"."HREVPFST_TransferAmount";
        "v_DepositAdjustmentAmount" := "rec"."HREVPFST_DepositAdjustmentAmount";
        "v_WithsrawAdjustmentAmount" := "rec"."HREVPFST_WithsrawAdjustmentAmount";

        SELECT "HRMPFVPFINT_VPFInterestRate" INTO "v_HRMPFVPFINT_VPFInterestRate"
        FROM "HR_Master_PFVPF_Interest"
        WHERE "IMFY_Id" = "v_IMFY_Id" 
            AND "HRMPFVPFINT_ActiveFlg" = 1;

        "v_HRMPFVPFINT_VPFInterestRate" := COALESCE("v_HRMPFVPFINT_VPFInterestRate", 0);

        SELECT "IVRM_Month_Id" INTO "v_MonthId"
        FROM "IVRM_Month"
        WHERE "IVRM_Month_Name" = "v_IVRM_Month_Name";

        IF ("v_MonthId" >= 4) THEN
            SELECT EXTRACT(YEAR FROM "IMFY_FromDate") INTO "v_YearId"
            FROM "IVRM_Master_FinancialYear"
            WHERE "IMFY_Id" = "v_IMFY_Id";
        ELSE
            SELECT EXTRACT(YEAR FROM "IMFY_ToDate") INTO "v_YearId"
            FROM "IVRM_Master_FinancialYear"
            WHERE "IMFY_Id" = "v_IMFY_Id";
        END IF;

        SELECT B."HRESD_Amount" INTO "v_Contribution"
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_ID" = B."HRES_ID"
        INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_ID" = C."HRMED_ID"
        WHERE A."MI_ID" = "v_MI_Id" 
            AND A."HRME_ID" = "v_HRME_Id" 
            AND A."HRES_year" = "v_YearId" 
            AND A."HRES_Month" = "v_IVRM_Month_Name" 
            AND C."HRMED_EDTypeFlag" = 'VPF'
            AND C."HRMED_ActiveFlag" = 1;

        IF ("v_Contribution" > 0) THEN
            "v_Contribution" := "v_Contribution";
        ELSE
            "v_Contribution" := 0;
        END IF;

        IF ("v_TranctionID" = "p_HREVPFST_Id") THEN

            "v_InterestAmt" := ROUND(("p_HREVPFST_VOBAmount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);

            "v_ClosingBalance" := ("p_HREVPFST_VOBAmount" + "v_Contribution" + "p_HREVPFST_TransferAmount" + "p_HREVPFST_DepositAdjustmentAmount") - 
                                  ("p_HREVPFST_WithdrawnAmount" + "p_HREVPFST_SettledAmount" + "p_HREVPFST_WithsrawAdjustmentAmount");

            IF ("p_HREVPFST_SettledAmount" > 0 OR "p_HREVPFST_WithdrawnAmount" > 0) THEN
                IF (EXTRACT(DAY FROM "p_Headdate") >= 25) THEN
                    IF ("p_HREVPFST_SettledAmount" > 0) THEN
                        "v_InterestAmt" := ROUND(("p_HREVPFST_VOBAmount" - "p_HREVPFST_SettledAmount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
                    ELSIF ("p_HREVPFST_WithdrawnAmount" > 0) THEN
                        "v_InterestAmt" := ROUND(("p_HREVPFST_VOBAmount" - "p_HREVPFST_WithdrawnAmount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
                    END IF;
                END IF;
            ELSE
                IF (EXTRACT(DAY FROM "p_Headdate") < 25) THEN
                    "v_InterestAmt" := ROUND(("p_HREVPFST_VOBAmount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
                END IF;
            END IF;

            UPDATE "HR_Employee_VPF_Status_Edit" SET
                "HREVPFST_VOBAmount" = "p_HREVPFST_VOBAmount",
                "HREVPFST_Contribution" = "v_Contribution",
                "HREVPFST_Intersest" = "v_InterestAmt",
                "HREVPFST_WithdrawnAmount" = "p_HREVPFST_WithdrawnAmount",
                "HREVPFST_SettledAmount" = "p_HREVPFST_SettledAmount",
                "HREVPFST_TransferAmount" = "p_HREVPFST_TransferAmount",
                "HREVPFST_DepositAdjustmentAmount" = "v_DepositAdjustmentAmount",
                "HREVPFST_WithsrawAdjustmentAmount" = "p_HREVPFST_WithsrawAdjustmentAmount",
                "HREVPFST_ClosingBalance" = "v_ClosingBalance"
            WHERE "HREVPFST_Id" = "p_HREVPFST_Id";

            "v_NextOpeningbalance" := "v_ClosingBalance";

        ELSE

            "v_InterestAmt" := ROUND(("v_NextOpeningbalance") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);

            "v_ClosingBalance" := ("v_NextOpeningbalance" + "v_Contribution" + "v_TransferAmount" + "v_DepositAdjustmentAmount") - 
                                  ("v_WithdrawnAmount" + "v_SettledAmount" + "v_WithsrawAdjustmentAmount");

            UPDATE "HR_Employee_VPF_Status_Edit" SET
                "HREVPFST_VOBAmount" = "v_NextOpeningbalance",
                "HREVPFST_Contribution" = "v_Contribution",
                "HREVPFST_Intersest" = "v_InterestAmt",
                "HREVPFST_ClosingBalance" = "v_ClosingBalance"
            WHERE "HREVPFST_Id" = "v_TranctionID";

            "v_NextOpeningbalance" := "v_ClosingBalance";

        END IF;

    END LOOP;

    RETURN QUERY
    SELECT 
        e."HREVPFST_Id",
        e."IMFY_Id",
        e."HRME_Id",
        e."IVRM_Month_Name",
        e."HREVPFST_VOBAmount",
        e."HREVPFST_Contribution",
        e."HREVPFST_WithdrawnAmount",
        e."HREVPFST_SettledAmount",
        e."HREVPFST_TransferAmount",
        e."HREVPFST_DepositAdjustmentAmount",
        e."HREVPFST_WithsrawAdjustmentAmount",
        e."HREVPFST_Intersest",
        e."HREVPFST_ClosingBalance"
    FROM "HR_Employee_VPF_Status_Edit" e;

END;
$$;