CREATE OR REPLACE FUNCTION "dbo"."HR_VPF_YearlyReport"(
    "p_MI_ID" TEXT,
    "p_HRME_ID" TEXT,
    "p_IMFY_ID" TEXT,
    "p_Flag" TEXT
)
RETURNS TABLE(
    "HREVPFST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "IVRM_Month_Name" TEXT,
    "HREVPFST_Contribution" DECIMAL(18,2),
    "HREVPFST_Intersest" DECIMAL(18,2),
    "HRME_EmployeeCode" TEXT,
    "HRME_EmployeeFirstName" TEXT,
    "HREVPFST_VOBAmount" DECIMAL(18,2),
    "HREVPFST_ClosingBalance" DECIMAL(18,2),
    "HREVPFST_SettledAmount" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_DYNAMIC" TEXT;
    "v_DYNAMIC1" TEXT;
    "v_HRME_ID1" BIGINT;
    "rec_HRME_ID" RECORD;
BEGIN

    DROP TABLE IF EXISTS "VPFYearlyReport_Temp6";

    IF("p_Flag" = 'EmployeeVPFreport') THEN
        
        "v_DYNAMIC1" := 'CREATE TEMP TABLE "VPFYearlyReport_Temp6" AS SELECT DISTINCT "HRME_ID" FROM "HR_Employee_VPF_Status" WHERE "MI_Id"=' || "p_MI_ID" || ' AND "IMFY_Id"=' || "p_IMFY_ID" || ' AND "HRME_Id" IN (' || "p_HRME_ID" || ')';
        EXECUTE "v_DYNAMIC1";

        DROP TABLE IF EXISTS "PFREPORT_TEMP";
        CREATE TEMP TABLE "PFREPORT_TEMP"(
            "HREVPFST_Id" BIGINT,
            "HRME_Id" BIGINT,
            "IVRM_Month_Name" TEXT,
            "HREVPFST_Contribution" DECIMAL(18,2),
            "HREVPFST_Intersest" DECIMAL(18,2)
        );

        FOR "rec_HRME_ID" IN SELECT "HRME_ID" FROM "VPFYearlyReport_Temp6"
        LOOP
            "v_HRME_ID1" := "rec_HRME_ID"."HRME_ID";

            DROP TABLE IF EXISTS "VPFYearlyReport_Temp";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp1";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp2";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp3";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp4";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp5";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp7";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp8";
            DROP TABLE IF EXISTS "VPFYearlyReport_Temp9";

            CREATE TEMP TABLE "VPFYearlyReport_Temp" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Opening Balance' as "IVRM_Month_Name", "HREVPFST_VOBAmount" as "HREVPFST_Contribution", 0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE
            ORDER BY "HREVPFST_Id"
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp1" AS
            SELECT A."HREVPFST_Id", A."HRME_Id",
            (CASE WHEN B."IVRM_Month_Id" BETWEEN 4 AND 12 THEN CONCAT(B."IVRM_Month_Name", '-', LEFT(D."IMFY_FromDate"::TEXT, 4))
                  WHEN B."IVRM_Month_Id" BETWEEN 1 AND 3 THEN CONCAT(B."IVRM_Month_Name", '-', LEFT(D."IMFY_ToDate"::TEXT, 4)) END) AS "IVRM_Month_Name",
            A."HREVPFST_Contribution", A."HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status" A
            INNER JOIN "IVRM_Month" B ON A."Month_Id" = B."IVRM_Month_Id"
            INNER JOIN "HR_Master_Employee" C ON C."HRME_Id" = A."HRME_Id"
            INNER JOIN "IVRM_Master_FinancialYear" D ON D."IMFY_Id" = A."IMFY_Id"
            WHERE A."MI_Id" = "p_MI_ID"::BIGINT AND A."IMFY_Id" = "p_IMFY_ID"::BIGINT AND A."HRME_Id" = "v_HRME_ID1" AND A."HREVPFST_ActiveFlg" = TRUE;

            CREATE TEMP TABLE "VPFYearlyReport_Temp2" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Withdrawn Amount' as "IVRM_Month_Name", "HREVPFST_WithdrawnAmount" as "HREVPFST_Contribution", 0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE AND "HREVPFST_WithdrawnAmount" > 0
            ORDER BY "HREVPFST_Id"
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp3" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Settled Amount' as "IVRM_Month_Name", "HREVPFST_SettledAmount" as "HREVPFST_Contribution", 0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE AND "HREVPFST_SettledAmount" > 0
            ORDER BY "HREVPFST_Id"
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp4" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'VPF Transfer' as "IVRM_Month_Name", "HREVPFST_TransferAmount" as "HREVPFST_Contribution", 0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE AND "HREVPFST_TransferAmount" > 0
            ORDER BY "HREVPFST_Id"
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp8" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Interest Adjestment(Deposit) ' as "IVRM_Month_Name", "HREVPFST_DepositAdjustmentAmount" as "HREVPFST_Contribution", 0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE AND "HREVPFST_DepositAdjustmentAmount" > 0
            ORDER BY "HREVPFST_Id"
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp9" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Interest Adjestment(Withdraw) ' as "IVRM_Month_Name", "HREVPFST_WithsrawAdjustmentAmount" as "HREVPFST_Contribution", 0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE AND "HREVPFST_WithsrawAdjustmentAmount" > 0
            ORDER BY "HREVPFST_Id"
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp7" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Total Amount' as "IVRM_Month_Name", "HREVPFST_ClosingBalance" as "HREVPFST_Contribution",
            (SELECT SUM("HREVPFST_Intersest") FROM "HR_Employee_VPF_Status" WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1" AND "HREVPFST_ActiveFlg" = TRUE) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE
            ORDER BY "HREVPFST_Id" DESC
            LIMIT 1;

            CREATE TEMP TABLE "VPFYearlyReport_Temp5" AS
            SELECT "HREVPFST_Id", "HRME_Id", 'Closing Balance' as "IVRM_Month_Name",
            ("HREVPFST_ClosingBalance" + (SELECT "HREVPFST_Intersest" FROM "VPFYearlyReport_Temp7" LIMIT 1)) as "HREVPFST_Contribution",
            0::DECIMAL(18,2) as "HREVPFST_Intersest"
            FROM "HR_Employee_VPF_Status"
            WHERE "MI_Id" = "p_MI_ID"::BIGINT AND "IMFY_Id" = "p_IMFY_ID"::BIGINT AND "HRME_Id" = "v_HRME_ID1"
            AND "HREVPFST_ActiveFlg" = TRUE
            ORDER BY "HREVPFST_Id" DESC
            LIMIT 1;

            INSERT INTO "PFREPORT_TEMP"
            SELECT * FROM (
                SELECT * FROM "VPFYearlyReport_Temp"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp1"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp2"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp3"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp8"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp9"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp7"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp4"
                UNION ALL
                SELECT * FROM "VPFYearlyReport_Temp5"
            ) A ORDER BY "HREVPFST_Id";

        END LOOP;

        RETURN QUERY SELECT "HREVPFST_Id", "HRME_Id", "IVRM_Month_Name", "HREVPFST_Contribution", "HREVPFST_Intersest", NULL::TEXT, NULL::TEXT, NULL::DECIMAL(18,2), NULL::DECIMAL(18,2), NULL::DECIMAL(18,2) FROM "PFREPORT_TEMP" ORDER BY "HRME_ID", "HREVPFST_Id";

    ELSIF("p_Flag" = 'VPFTotalReport') THEN

        "v_DYNAMIC" := '
        SELECT NULL::BIGINT AS "HREVPFST_Id", A."HRME_Id", NULL::TEXT AS "IVRM_Month_Name", NULL::DECIMAL(18,2) AS "HREVPFST_Contribution", NULL::DECIMAL(18,2) AS "HREVPFST_Intersest",
        B."HRME_EmployeeCode", CONCAT(B."HRME_EmployeeFirstName", '' '', B."HRME_EmployeeMiddleName", '' '', B."HRME_EmployeeLastName") AS "HRME_EmployeeFirstName",
        SUM(A."HREVPFST_VOBAmount") AS "HREVPFST_VOBAmount", SUM(A."HREVPFST_Contribution") AS "HREVPFST_Contribution_Sum",
        SUM(A."HREVPFST_Intersest") AS "HREVPFST_Intersest_Sum", SUM(A."HREVPFST_ClosingBalance") AS "HREVPFST_ClosingBalance",
        SUM(A."HREVPFST_SettledAmount") AS "HREVPFST_SettledAmount"
        FROM "HR_Employee_VPF_Status" A
        INNER JOIN "HR_Master_Employee" B ON B."HRME_Id" = A."HRME_Id"
        WHERE A."MI_Id" = ' || "p_MI_ID" || ' AND A."IMFY_Id" = ' || "p_IMFY_ID" || ' AND A."HRME_Id" IN (' || "p_HRME_ID" || ')
        AND A."HREVPFST_ActiveFlg" = TRUE
        GROUP BY B."HRME_EmployeeCode", CONCAT(B."HRME_EmployeeFirstName", '' '', B."HRME_EmployeeMiddleName", '' '', B."HRME_EmployeeLastName"), A."HRME_Id"';

        RETURN QUERY EXECUTE "v_DYNAMIC";

    ELSIF("p_Flag" = 'VPFGrandTotalReport') THEN

        "v_DYNAMIC" := '
        SELECT NULL::BIGINT AS "HREVPFST_Id", NULL::BIGINT AS "HRME_Id", NULL::TEXT AS "IVRM_Month_Name", NULL::DECIMAL(18,2) AS "HREVPFST_Contribution", NULL::DECIMAL(18,2) AS "HREVPFST_Intersest",
        NULL::TEXT AS "HRME_EmployeeCode", NULL::TEXT AS "HRME_EmployeeFirstName",
        SUM(A."HREVPFST_VOBAmount") AS "HREVPFST_VOBAmount", SUM(A."HREVPFST_Contribution") AS "HREVPFST_Contribution_Sum",
        SUM(A."HREVPFST_Intersest") AS "HREVPFST_Intersest_Sum", SUM(A."HREVPFST_ClosingBalance") AS "HREVPFST_ClosingBalance",
        SUM(A."HREVPFST_SettledAmount") AS "HREVPFST_SettledAmount"
        FROM "HR_Employee_VPF_Status" A
        INNER JOIN "HR_Master_Employee" B ON B."HRME_Id" = A."HRME_Id"
        WHERE A."MI_Id" = ' || "p_MI_ID" || ' AND A."IMFY_Id" = ' || "p_IMFY_ID" || '
        AND A."HREVPFST_ActiveFlg" = TRUE';

        RETURN QUERY EXECUTE "v_DYNAMIC";

    END IF;

END;
$$;