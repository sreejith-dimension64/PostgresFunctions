CREATE OR REPLACE FUNCTION "dbo"."HR_PF_YearlyReport"(
    "p_MI_ID" TEXT,
    "p_HRME_ID" TEXT,
    "p_IMFY_ID" TEXT,
    "p_Flag" TEXT
)
RETURNS TABLE(
    "HREPFST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "IVRM_Month_Name" TEXT,
    "HREPFST_OwnContribution" NUMERIC(18,2),
    "HREPFST_IntstituteContribution" NUMERIC(18,2),
    "HREPFST_OwnInterest" NUMERIC(18,2),
    "HREPFST_InstituteInterest" NUMERIC(18,2),
    "ordercolumn" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_DYNAMIC" TEXT;
    "v_HRME_ID1" BIGINT;
    "rec_cursor" RECORD;
BEGIN

    DROP TABLE IF EXISTS "PFYearlyReport_Temp6";

    IF "p_Flag" = 'EmployeePFreport' THEN
        
        "v_DYNAMIC" := 'CREATE TEMP TABLE "PFYearlyReport_Temp6" AS SELECT DISTINCT "HRME_ID" FROM "HR_Employee_PF_Status" WHERE "MI_Id"=' || "p_MI_ID" || ' AND "IMFY_Id"=' || "p_IMFY_ID" || ' AND "HRME_Id" IN (' || "p_HRME_ID" || ')';
        EXECUTE "v_DYNAMIC";

        CREATE TEMP TABLE IF NOT EXISTS "#PFREPORT_TEMP1"(
            "HREPFST_Id" BIGINT,
            "HRME_Id" BIGINT,
            "IVRM_Month_Name" TEXT,
            "HREPFST_OwnContribution" NUMERIC(18,2),
            "HREPFST_InstituteContribution" NUMERIC(18,2),
            "HREPFST_OwnInterest" NUMERIC(18,2),
            "HREPFST_InstituteInterest" NUMERIC(18,2),
            "ordercolumn" INTEGER
        );

        FOR "rec_cursor" IN SELECT "HRME_ID" FROM "PFYearlyReport_Temp6"
        LOOP
            "v_HRME_ID1" := "rec_cursor"."HRME_ID";

            DROP TABLE IF EXISTS "#PFYearlyReport_Temp";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp1";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp2";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp3";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp4";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp5";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp7";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp8";
            DROP TABLE IF EXISTS "#PFYearlyReport_Temp9";

            CREATE TEMP TABLE "#PFYearlyReport_Temp" AS
            SELECT A."HREPFST_Id", A."HRME_Id",
            (CASE WHEN B."IVRM_Month_Id" BETWEEN 4 AND 12 THEN CONCAT(B."IVRM_Month_Name", '-', LEFT(D."IMFY_FromDate"::TEXT, CAST("p_MI_ID" AS INTEGER)))
                  WHEN B."IVRM_Month_Id" BETWEEN 1 AND 3 THEN CONCAT(B."IVRM_Month_Name", '-', LEFT(D."IMFY_ToDate"::TEXT, CAST("p_MI_ID" AS INTEGER))) END) AS "IVRM_Month_Name",
            A."HREPFST_OwnContribution", A."HREPFST_IntstituteContribution", A."HREPFST_OwnInterest", A."HREPFST_InstituteInterest", 2 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" A
            INNER JOIN "IVRM_Month" B ON A."Month_Id" = B."IVRM_Month_Id"
            INNER JOIN "HR_Master_Employee" C ON C."HRME_Id" = A."HRME_Id"
            INNER JOIN "IVRM_Master_FinancialYear" D ON D."IMFY_Id" = A."IMFY_Id"
            WHERE A."MI_Id" = CAST("p_MI_ID" AS BIGINT) AND A."IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND A."HRME_Id" = "v_HRME_ID1" AND A."HREPFST_ActiveFlg" = TRUE;

            CREATE TEMP TABLE "#PFYearlyReport_Temp1" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Opening Balance' AS "IVRM_Month_Name", "HREPFST_OBOwnAmount" AS "HREPFST_OwnContribution",
            "HREPFST_OBInstituteAmount" AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 1 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE ORDER BY "HREPFST_Id" LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp2" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Non Refundable Loan' AS "IVRM_Month_Name", "HREPFST_OwnWithdrwanAmount" AS "HREPFST_OwnContribution",
            "HREPFST_InstituteWithdrawnAmount" AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 3 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE AND ("HREPFST_OwnWithdrwanAmount" > 0 OR "HREPFST_InstituteWithdrawnAmount" > 0) ORDER BY "HREPFST_Id" LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp3" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Settled Amount' AS "IVRM_Month_Name", "HREPFST_OwnSettlementAmount" AS "HREPFST_OwnContribution",
            "HREPFST_InstituteLSettlementAmount" AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 4 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE AND "HREPFST_OwnSettlementAmount" > 0 AND "HREPFST_InstituteLSettlementAmount" > 0 ORDER BY "HREPFST_Id" LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp5" AS
            SELECT "HREPFST_Id", "HRME_Id", 'PF Transfer' AS "IVRM_Month_Name", "HREPFST_OwnTransferAmount" AS "HREPFST_OwnContribution",
            "HREPFST_InstituteTransferAmount" AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 5 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE AND "HREPFST_OwnTransferAmount" > 0 AND "HREPFST_InstituteTransferAmount" > 0 ORDER BY "HREPFST_Id" LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp8" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Interest Adjestment(Deposit)' AS "IVRM_Month_Name", COALESCE("HREPFST_OwnDepositAdjustmentAmount", 0) AS "HREPFST_OwnContribution",
            COALESCE("HREPFST_InstituteDepositAdjustmentAmount", 0) AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 6 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE AND "HREPFST_OwnDepositAdjustmentAmount" > 0 AND "HREPFST_InstituteDepositAdjustmentAmount" > 0 ORDER BY "HREPFST_Id" LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp9" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Interest Adjestment(Withdraw)' AS "IVRM_Month_Name", COALESCE("HREPFST_OwnWithdrawAdjustmentAmount", 0) AS "HREPFST_OwnContribution",
            COALESCE("HREPFST_InstituteWithdrawAdjustmentAmount", 0) AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 7 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE AND "HREPFST_OwnWithdrawAdjustmentAmount" > 0 AND "HREPFST_InstituteWithdrawAdjustmentAmount" > 0 ORDER BY "HREPFST_Id" LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp7" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Total Amount' AS "IVRM_Month_Name", "HREPFST_OwnClosingBalance" AS "HREPFST_OwnContribution", "HREPFST_InstituteClosingBalance" AS "HREPFST_IntstituteContribution",
            (SELECT SUM("HREPFST_OwnInterest") FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1" AND "HREPFST_ActiveFlg" = TRUE) AS "HREPFST_OwnInterest",
            (SELECT SUM("HREPFST_InstituteInterest") FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1" AND "HREPFST_ActiveFlg" = TRUE) AS "HREPFST_InstituteInterest", 8 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1" AND "HREPFST_ActiveFlg" = TRUE
            ORDER BY "HREPFST_Id" DESC LIMIT 1;

            CREATE TEMP TABLE "#PFYearlyReport_Temp4" AS
            SELECT "HREPFST_Id", "HRME_Id", 'Closing Balance' AS "IVRM_Month_Name",
            (SELECT SUM("HREPFST_OwnInterest") FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1" AND "HREPFST_ActiveFlg" = TRUE) + "HREPFST_OwnClosingBalance" AS "HREPFST_OwnContribution",
            (SELECT SUM("HREPFST_InstituteInterest") FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1" AND "HREPFST_ActiveFlg" = TRUE) + "HREPFST_InstituteClosingBalance" AS "HREPFST_IntstituteContribution", 0 AS "HREPFST_OwnInterest", 0 AS "HREPFST_InstituteInterest", 9 AS "ordercolumn"
            FROM "HR_Employee_PF_Status" WHERE "MI_Id" = CAST("p_MI_ID" AS BIGINT) AND "IMFY_Id" = CAST("p_IMFY_ID" AS BIGINT) AND "HRME_Id" = "v_HRME_ID1"
            AND "HREPFST_ActiveFlg" = TRUE ORDER BY "HREPFST_Id" DESC LIMIT 1;

            INSERT INTO "#PFREPORT_TEMP1"
            SELECT * FROM "#PFYearlyReport_Temp1"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp2"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp3"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp5"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp8"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp9"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp7"
            UNION ALL
            SELECT * FROM "#PFYearlyReport_Temp4";

        END LOOP;

        RETURN QUERY SELECT * FROM "#PFREPORT_TEMP1" ORDER BY "HRME_Id", "HREPFST_Id", "ordercolumn";

    ELSIF "p_Flag" = 'PFTotalReport' THEN

        "v_DYNAMIC" := '
        SELECT B."HRME_EmployeeCode", CONCAT(B."HRME_EmployeeFirstName", '' '', B."HRME_EmployeeMiddleName", '' '', B."HRME_EmployeeLastName") AS "HRME_EmployeeFirstName",
        A."HRME_Id", SUM(A."HREPFST_OBOwnAmount") AS "HREPFST_OBOwnAmount", SUM(A."HREPFST_OBInstituteAmount") AS "HREPFST_OBInstituteAmount",
        SUM(A."HREPFST_OwnContribution") AS "HREVPFST_Contribution", SUM(A."HREPFST_IntstituteContribution") AS "HREPFST_IntstituteContribution",
        SUM(A."HREPFST_OwnInterest") AS "HREVPFST_Intersest", SUM(A."HREPFST_InstituteInterest") AS "HREPFST_InstituteInterest",
        SUM(A."HREPFST_OwnClosingBalance") AS "HREPFST_OwnClosingBalance", SUM(A."HREPFST_InstituteClosingBalance") AS "HREPFST_InstituteClosingBalance",
        SUM(A."HREPFST_OwnSettlementAmount") AS "HREPFST_OwnSettlementAmount", SUM(A."HREPFST_InstituteLSettlementAmount") AS "HREPFST_InstituteLSettlementAmount"
        FROM "HR_Employee_PF_Status" A
        INNER JOIN "HR_Master_Employee" B ON B."HRME_Id" = A."HRME_Id"
        WHERE A."MI_Id" = ' || "p_MI_ID" || ' AND "IMFY_Id" = ' || "p_IMFY_ID" || ' AND A."HRME_Id" IN (' || "p_HRME_ID" || ')
        AND "HREPFST_ActiveFlg" = TRUE
        GROUP BY B."HRME_EmployeeCode", CONCAT(B."HRME_EmployeeFirstName", '' '', B."HRME_EmployeeMiddleName", '' '', B."HRME_EmployeeLastName"), A."HRME_Id"';

        RETURN QUERY EXECUTE "v_DYNAMIC";

    ELSIF "p_Flag" = 'PFGrandTotalReport' THEN

        "v_DYNAMIC" := '
        SELECT SUM(A."HREPFST_OBOwnAmount") AS "HREPFST_OBOwnAmount", SUM(A."HREPFST_OBInstituteAmount") AS "HREPFST_OBInstituteAmount",
        SUM(A."HREPFST_OwnContribution") AS "HREVPFST_Contribution", SUM(A."HREPFST_IntstituteContribution") AS "HREPFST_IntstituteContribution",
        SUM(A."HREPFST_OwnInterest") AS "HREVPFST_Intersest", SUM(A."HREPFST_InstituteInterest") AS "HREPFST_InstituteInterest",
        SUM(A."HREPFST_OwnClosingBalance") AS "HREPFST_OwnClosingBalance", SUM(A."HREPFST_InstituteClosingBalance") AS "HREPFST_InstituteClosingBalance",
        SUM(A."HREPFST_OwnSettlementAmount") AS "HREPFST_OwnSettlementAmount", SUM(A."HREPFST_InstituteLSettlementAmount") AS "HREPFST_InstituteLSettlementAmount"
        FROM "HR_Employee_PF_Status" A
        INNER JOIN "HR_Master_Employee" B ON B."HRME_Id" = A."HRME_Id"
        WHERE A."MI_Id" = ' || "p_MI_ID" || ' AND "IMFY_Id" = ' || "p_IMFY_ID" || '
        AND "HREPFST_ActiveFlg" = TRUE
        GROUP BY B."HRME_EmployeeCode", CONCAT(B."HRME_EmployeeFirstName", '' '', B."HRME_EmployeeMiddleName", '' '', B."HRME_EmployeeLastName"), A."HRME_Id"';

        RETURN QUERY EXECUTE "v_DYNAMIC";

    END IF;

    RETURN;

END;
$$;