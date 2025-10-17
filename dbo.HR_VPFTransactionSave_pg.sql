CREATE OR REPLACE FUNCTION "dbo"."HR_VPFTransactionSave"(
    "p_IMFY_Id" bigint,
    "p_Month_Id" bigint,
    "p_MI_Id" bigint,
    "p_HRME_Id" bigint,
    "p_userid" bigint,
    "p_Amount" decimal(18,2),
    "p_HeadType" varchar(50),
    "p_DepositWithdrow" varchar(50),
    "p_Remarks" varchar(50),
    "p_Headdate" date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_HREVPFST_ClosingBalance" decimal(18,2);
    "v_count" bigint;
    "v_HRMPFVPFINT_VPFInterestRate" decimal(18,2);
    "v_InterestAmt" decimal(18,2);
    "v_VPFContribution" decimal(18,2);
    "v_ClosingBalance" decimal(18,2);
    "v_IMFY_FromDate" DATE;
    "v_IMFY_ToDate" DATE;
    "v_YearId" bigint;
    "v_MonthName" VARCHAR(500);
    "v_MinDate" DATE;
    "v_MaxDate" DATE;
BEGIN

    SELECT "HRMPFVPFINT_VPFInterestRate" INTO "v_HRMPFVPFINT_VPFInterestRate"
    FROM "HR_Master_PFVPF_Interest"
    WHERE "MI_Id" = "p_MI_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "HRMPFVPFINT_ActiveFlg" = 1;

    SELECT "IVRM_Month_Name" INTO "v_MonthName"
    FROM "IVRM_Month"
    WHERE "IVRM_Month_Id" = "p_Month_Id" AND "Is_Active" = 1;

    SELECT "IMFY_FromDate", "IMFY_ToDate" INTO "v_IMFY_FromDate", "v_IMFY_ToDate"
    FROM "IVRM_Master_FinancialYear"
    WHERE "IMFY_Id" = "p_IMFY_Id";

    "v_MinDate" := "v_IMFY_FromDate";
    "v_MaxDate" := "v_IMFY_ToDate";

    CREATE TEMP TABLE "temp_date" ON COMMIT DROP AS
    SELECT generate_series("v_MinDate", "v_MaxDate", '1 day'::interval)::date AS "Date";

    SELECT EXTRACT(YEAR FROM "Date") INTO "v_YearId"
    FROM "temp_date"
    WHERE EXTRACT(MONTH FROM "Date") = "p_Month_Id"
    LIMIT 1;

    SELECT "HREVPFST_ClosingBalance" INTO "v_HREVPFST_ClosingBalance"
    FROM "HR_Employee_VPF_Status"
    WHERE "HRME_Id" = "p_HRME_Id"
    ORDER BY "HREVPFST_CreatedDate" DESC
    LIMIT 1;

    SELECT "B"."HRESD_Amount" INTO "v_VPFContribution"
    FROM "HR_Employee_Salary" "A"
    INNER JOIN "HR_Employee_Salary_Details" "B" ON "A"."HRES_ID" = "B"."HRES_ID"
    INNER JOIN "HR_Master_EarningsDeductions" "C" ON "B"."HRMED_ID" = "C"."HRMED_ID"
    WHERE "A"."MI_ID" = "p_MI_Id" AND "A"."HRME_ID" = "p_HRME_Id" 
    AND "A"."HRES_year" = "v_YearId" AND "A"."HRES_Month" = "v_MonthName" 
    AND "C"."HRMED_EDTypeFlag" = 'VPF'
    AND "C"."HRMED_ActiveFlag" = 1;

    IF ("v_VPFContribution" > 0) THEN
        "v_VPFContribution" := "v_VPFContribution";
    ELSE
        "v_VPFContribution" := 0;
    END IF;

    IF ("p_DepositWithdrow" = 'Deposit') THEN

        IF ("p_HeadType" = 'Opening Balance') THEN

            "v_InterestAmt" := ROUND(("p_Amount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            "v_ClosingBalance" := "p_Amount" + "v_VPFContribution";

            INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
            VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount","v_VPFContribution","v_InterestAmt",0,0,"v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,0,0,0);

        ELSIF ("p_HeadType" = 'PF Transefer') THEN

            IF (EXTRACT(DAY FROM "p_Headdate") <= 25) THEN
                "v_InterestAmt" := ROUND(("v_HREVPFST_ClosingBalance" + "p_Amount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            ELSIF (EXTRACT(DAY FROM "p_Headdate") > 25) THEN
                "v_InterestAmt" := ROUND(("v_HREVPFST_ClosingBalance") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            END IF;

            "v_ClosingBalance" := ("v_HREVPFST_ClosingBalance" + "v_VPFContribution") + "p_Amount";

            SELECT COUNT(*) INTO "v_count"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

            IF ("v_count" > 0) THEN
                UPDATE "HR_Employee_VPF_Status"
                SET "HREVPFST_TransferAmount" = "p_Amount", "HREVPFST_ClosingBalance" = "v_ClosingBalance"
                WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";
            ELSE
                INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","v_HREVPFST_ClosingBalance","v_VPFContribution","v_InterestAmt",0,0,"v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,"p_Amount",0,0);
            END IF;

        ELSIF ("p_HeadType" = 'FPF To PF') THEN

            "v_InterestAmt" := ROUND("v_HREVPFST_ClosingBalance" * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            "v_ClosingBalance" := "p_Amount" + "v_HREVPFST_ClosingBalance";

            INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
            VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","v_HREVPFST_ClosingBalance",0,"v_InterestAmt",0,0,"v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,0,0,0);

        ELSIF ("p_HeadType" = 'Interest Adjestment') THEN

            "v_InterestAmt" := ROUND("v_HREVPFST_ClosingBalance" * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            "v_ClosingBalance" := "p_Amount" + "v_HREVPFST_ClosingBalance";

            SELECT COUNT(*) INTO "v_count"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

            IF ("v_count" > 0) THEN
                UPDATE "HR_Employee_VPF_Status"
                SET "HREVPFST_DepositAdjustmentAmount" = "p_Amount", "HREVPFST_ClosingBalance" = "v_ClosingBalance"
                WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";
            ELSE
                INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","v_HREVPFST_ClosingBalance",0,"v_InterestAmt",0,0,"v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,0,"p_Amount",0);
            END IF;

        END IF;

    ELSIF ("p_DepositWithdrow" = 'Withdraw') THEN

        IF ("p_HeadType" = 'Settlement Of PF') THEN

            IF (EXTRACT(DAY FROM "p_Headdate") <= 25) THEN
                "v_InterestAmt" := ROUND(("v_HREVPFST_ClosingBalance" - "p_Amount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            ELSIF (EXTRACT(DAY FROM "p_Headdate") > 25) THEN
                "v_InterestAmt" := ROUND(("v_HREVPFST_ClosingBalance") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            END IF;

            "v_ClosingBalance" := ("v_HREVPFST_ClosingBalance" + "v_VPFContribution") - "p_Amount";

            SELECT COUNT(*) INTO "v_count"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

            IF ("v_count" > 0) THEN
                UPDATE "HR_Employee_VPF_Status"
                SET "HREVPFST_SettledAmount" = "p_Amount", "HREVPFST_ClosingBalance" = "v_ClosingBalance"
                WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

                INSERT INTO "HR_Employee_VPF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFW_Amount","HREVPFW_Date","HREVPFW_Flag","HREVPFW_Remarks","HREVPFW_ActiveFlg","HREVPFW_CreatedDate","HREVPFW_UpdatedDate","HREVPFW_CreatedBy","HREVPFW_UpdatedBy")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount","p_Headdate","p_HeadType","p_Remarks",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"p_userid","p_userid");
            ELSE
                INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","v_HREVPFST_ClosingBalance","v_VPFContribution","v_InterestAmt",0,"p_Amount","v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,0,0,0);

                INSERT INTO "HR_Employee_VPF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFW_Amount","HREVPFW_Date","HREVPFW_Flag","HREVPFW_Remarks","HREVPFW_ActiveFlg","HREVPFW_CreatedDate","HREVPFW_UpdatedDate","HREVPFW_CreatedBy","HREVPFW_UpdatedBy")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount","p_Headdate","p_HeadType","p_Remarks",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"p_userid","p_userid");
            END IF;

        ELSIF ("p_HeadType" = 'Interest Adjestment') THEN

            "v_InterestAmt" := ROUND("v_HREVPFST_ClosingBalance" * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            "v_ClosingBalance" := "v_HREVPFST_ClosingBalance" - "p_Amount";

            SELECT COUNT(*) INTO "v_count"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

            IF ("v_count" > 0) THEN
                UPDATE "HR_Employee_VPF_Status"
                SET "HREVPFST_WithsrawAdjustmentAmount" = "p_Amount", "HREVPFST_ClosingBalance" = "v_ClosingBalance"
                WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

                INSERT INTO "HR_Employee_VPF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFW_Amount","HREVPFW_Date","HREVPFW_Flag","HREVPFW_Remarks","HREVPFW_ActiveFlg","HREVPFW_CreatedDate","HREVPFW_UpdatedDate","HREVPFW_CreatedBy","HREVPFW_UpdatedBy")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount",CURRENT_TIMESTAMP,"p_HeadType","p_Remarks",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"p_userid","p_userid");
            ELSE
                INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","v_HREVPFST_ClosingBalance","v_VPFContribution","v_InterestAmt",0,0,"v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,0,0,"p_Amount");

                INSERT INTO "HR_Employee_VPF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFW_Amount","HREVPFW_Date","HREVPFW_Flag","HREVPFW_Remarks","HREVPFW_ActiveFlg","HREVPFW_CreatedDate","HREVPFW_UpdatedDate","HREVPFW_CreatedBy","HREVPFW_UpdatedBy")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount",CURRENT_TIMESTAMP,"p_HeadType","p_Remarks",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"p_userid","p_userid");
            END IF;

        ELSIF ("p_HeadType" = 'Non Refundable Loan') THEN

            IF (EXTRACT(DAY FROM "p_Headdate") <= 25) THEN
                "v_InterestAmt" := ROUND(("v_HREVPFST_ClosingBalance" - "p_Amount") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            ELSIF (EXTRACT(DAY FROM "p_Headdate") > 25) THEN
                "v_InterestAmt" := ROUND(("v_HREVPFST_ClosingBalance") * "v_HRMPFVPFINT_VPFInterestRate" / (12 * 100), 0);
            END IF;

            "v_ClosingBalance" := ("v_HREVPFST_ClosingBalance" + "v_VPFContribution") - "p_Amount";

            SELECT COUNT(*) INTO "v_count"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

            IF ("v_count" > 0) THEN
                UPDATE "HR_Employee_VPF_Status"
                SET "HREVPFST_SettledAmount" = "p_Amount", "HREVPFST_ClosingBalance" = "v_ClosingBalance"
                WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "p_HRME_Id" AND "IMFY_Id" = "p_IMFY_Id" AND "Month_Id" = "p_Month_Id";

                INSERT INTO "HR_Employee_VPF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFW_Amount","HREVPFW_Date","HREVPFW_Flag","HREVPFW_Remarks","HREVPFW_ActiveFlg","HREVPFW_CreatedDate","HREVPFW_UpdatedDate","HREVPFW_CreatedBy","HREVPFW_UpdatedBy")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount","p_Headdate","p_HeadType","p_Remarks",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"p_userid","p_userid");
            ELSE
                INSERT INTO "HR_Employee_VPF_Status" ("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFST_VOBAmount","HREVPFST_Contribution","HREVPFST_Intersest","HREVPFST_WithdrawnAmount","HREVPFST_SettledAmount","HREVPFST_ClosingBalance","HREVPFST_ActiveFlg","HREVPFST_CreatedBy","HREVPFST_UpdatedBy","HREVPFST_CreatedDate","HREVPFST_UpdatedDate","HREVPFST_TransferAmount","HREVPFST_DepositAdjustmentAmount","HREVPFST_WithsrawAdjustmentAmount")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","v_HREVPFST_ClosingBalance","v_VPFContribution","v_InterestAmt","p_Amount",0,"v_ClosingBalance",1,"p_userid","p_userid",CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,CONCAT("v_YearId",'-',"p_Month_Id",'-','12')::timestamp,0,0,0);

                INSERT INTO "HR_Employee_VPF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREVPFW_Amount","HREVPFW_Date","HREVPFW_Flag","HREVPFW_Remarks","HREVPFW_ActiveFlg","HREVPFW_CreatedDate","HREVPFW_UpdatedDate","HREVPFW_CreatedBy","HREVPFW_UpdatedBy")
                VALUES("p_MI_Id","p_HRME_Id","p_IMFY_Id","p_Month_Id","p_Amount","p_Headdate","p_HeadType","p_Remarks",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"p_userid","p_userid");
            END IF;

        END IF;

    END IF;

    RETURN;

END;
$$;