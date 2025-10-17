CREATE OR REPLACE FUNCTION "dbo"."HR_Cumulative_Salary_Report"(
    "p_year" TEXT,
    "p_month" TEXT,
    "p_MI_ID" TEXT,
    "p_HRMDES_Id" TEXT
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRES_Id" BIGINT,
    "HRME_EmployeeCode" TEXT,
    "HRME_EmployeeFirstname" TEXT,
    "HRMDES_DesignationName" TEXT,
    "HRME_PFAccNo" TEXT,
    "HRES_WorkingDays" INTEGER,
    "TotalEarnings" NUMERIC,
    "Totaldeduction" NUMERIC,
    "totalArrear" NUMERIC,
    "TotalPayable" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SanctionLevelNo" BIGINT;
    "v_Rcount" BIGINT;
    "v_Rcount1" BIGINT;
    "v_MaxSanctionLevelNo" BIGINT;
    "v_MaxSanctionLevelNo_New" BIGINT;
    "v_ApprCount" BIGINT;
    "v_HRES_ID" TEXT;
    "v_Preuserid" TEXT;
    "v_HRME_ID" TEXT;
    "v_HRES_ID2" TEXT;
    "v_AppEmpRcount" BIGINT;
    "v_sqldynamic" TEXT;
    "v_sqldynamic1" TEXT;
    "v_PivotColumnNames" TEXT;
    "v_PivotSelectColumnNames" TEXT;
    "v_monthname" TEXT := '''' || "p_month" || '''';
    "v_dynamic" TEXT;
    "v_IVRM_Month_Max_Days" BIGINT;
    "v_flag" BOOLEAN;
    "v_SUMAMOUNT" NUMERIC(18,2);
    "v_PENSIONAMOUNT" NUMERIC(18,2);
    "v_HRME_ID_CUR1" BIGINT;
    "v_HRES_ID_CUR1" BIGINT;
    "v_BASICPAY" NUMERIC(18,2);
    "v_DA" NUMERIC(18,2);
    "v_PERSONALPAY" NUMERIC(18,2);
    "v_CLAMT" NUMERIC(18,2);
    "v_AGE" NUMERIC;
    "v_HRES_WorkingDays" INTEGER;
    "v_HRME_FPFNotApplicableFlg" BOOLEAN;
    "v_RETIREDATE" DATE;
    "v_MONTHID" BIGINT;
    "v_REFDATE" DATE;
    "v_WorkingDay" BIGINT;
    "v_PFAMOUNT" NUMERIC(18,2);
    "v_SCHOOLPF" NUMERIC(18,2);
    "v_PFSAL" NUMERIC(18,2);
    "v_EDLISAL" NUMERIC(18,2);
    "v_PENSIONSAL" NUMERIC(18,2);
    "rec" RECORD;
BEGIN

    DROP TABLE IF EXISTS "Empsalaryid_Temp";
    DROP TABLE IF EXISTS "Empallsalaryheads_Temp1";

    "v_dynamic" := '
    CREATE TEMP TABLE "Empsalaryid_Temp" AS
    SELECT DISTINCT A."HRES_ID", A."HRME_Id" 
    FROM "HR_Employee_Salary" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
    WHERE A."HRES_Year" = ' || "p_year" || ' 
    AND A."HRES_Month" = ''' || "p_month" || ''' 
    AND A."MI_ID" = ' || "p_MI_ID";
    
    EXECUTE "v_dynamic";

    CREATE TEMP TABLE "totalearnings" AS
    SELECT SUM(B."HRESD_Amount") AS "TotalEarnings", B."HRES_Id"
    FROM "HR_Master_EarningsDeductions" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRMED_Id" = B."HRMED_Id"
    WHERE A."HRMED_EarnDedFlag" = 'Earning' 
    AND B."hres_id" IN (SELECT "HRES_ID" FROM "Empsalaryid_Temp")
    GROUP BY B."HRES_Id";

    CREATE TEMP TABLE "totaldeductions" AS
    SELECT SUM(B."HRESD_Amount") AS "Totaldeduction", B."HRES_Id"
    FROM "HR_Master_EarningsDeductions" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRMED_Id" = B."HRMED_Id"
    WHERE A."HRMED_EarnDedFlag" = 'Deduction' 
    AND B."hres_id" IN (SELECT "HRES_ID" FROM "Empsalaryid_Temp")
    GROUP BY B."HRES_Id";

    CREATE TEMP TABLE "totalArrear" AS
    SELECT SUM(B."HRESD_Amount") AS "totalArrear", B."HRES_Id"
    FROM "HR_Master_EarningsDeductions" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRMED_Id" = B."HRMED_Id"
    WHERE A."HRMED_EarnDedFlag" = 'Arrear' 
    AND B."hres_id" IN (SELECT "HRES_ID" FROM "Empsalaryid_Temp")
    GROUP BY B."HRES_Id";

    SELECT STRING_AGG('"' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Order")
    INTO "v_PivotColumnNames"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name"
        FROM "HR_Master_EarningsDeductions" D
        WHERE "MI_ID" = CAST("p_MI_ID" AS BIGINT) 
        AND D."HRMED_ActiveFlag" = TRUE
    ) AS "PVColumns";

    SELECT STRING_AGG('SUM(COALESCE("' || "HRMED_Name" || '", 0)) AS "' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Order")
    INTO "v_PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name"
        FROM "HR_Master_EarningsDeductions" D
        WHERE "MI_ID" = CAST("p_MI_ID" AS BIGINT) 
        AND D."HRMED_ActiveFlag" = TRUE
    ) AS "PVSelctedColumns";

    "v_sqldynamic" := '
    CREATE TEMP TABLE "Empallsalaryheads_Temp1" AS
    SELECT "HRME_Id", "HRES_Id", "HRME_EmployeeCode", "HRME_EmployeeFirstname", 
           "HRMDES_DesignationName", "HRME_PFAccNo", "HRES_WorkingDays",
           ' || "v_PivotSelectColumnNames" || ',
           COALESCE("TotalEarnings", 0) AS "TotalEarnings",
           COALESCE("Totaldeduction", 0) AS "Totaldeduction",
           COALESCE("totalArrear", 0) AS "totalArrear",
           (COALESCE("TotalEarnings", 0) - COALESCE("Totaldeduction", 0)) AS "TotalPayable"
    FROM CROSSTAB(
        ''SELECT C."HRME_Id", A."HRES_Id", C."HRME_EmployeeCode",
                CONCAT(COALESCE(C."HRME_EmployeeFirstname", ''''''''), '''' '''', 
                       COALESCE(C."HRME_EmployeeMiddleName", ''''''''), '''' '''', 
                       COALESCE(C."HRME_EmployeeLastName", '''''''')),
                L."HRMDES_DesignationName", C."HRME_PFAccNo", D."HRMED_Name", 
                B."HRESD_Amount", A."HRES_WorkingDays",
                F."TotalEarnings", G."Totaldeduction", H."totalArrear"
         FROM "HR_Employee_Salary" A
         INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
         INNER JOIN "HR_Master_Employee" C ON C."HRME_Id" = A."HRME_Id"
         INNER JOIN "HR_Master_EarningsDeductions" D ON D."HRMED_Id" = B."HRMED_Id"
         INNER JOIN "HR_Employee_EarningsDeductions" E ON E."HRME_Id" = C."HRME_Id" AND E."HRMED_Id" = D."HRMED_Id"
         LEFT JOIN "totalearnings" F ON F."HRES_Id" = A."HRES_Id"
         LEFT JOIN "totaldeductions" G ON G."HRES_Id" = A."HRES_Id"
         LEFT JOIN "totalArrear" H ON H."HRES_Id" = A."HRES_Id"
         INNER JOIN "HR_Master_Designation" L ON C."HRMDES_Id" = L."HRMDES_Id"
         WHERE A."HRMDES_Id" IN (' || "p_HRMDES_Id" || ') 
         AND A."HRES_Id" IN (SELECT "HRES_ID" FROM "Empsalaryid_Temp")
         AND A."HRES_Month" = ''''' || "p_month" || '''''
         AND A."HRES_Year" = ''''' || "p_year" || '''''
         AND D."HRMED_ActiveFlag" = TRUE 
         AND E."HREED_ActiveFlag" = TRUE
         ORDER BY 1, 7''
    ) AS ct("HRME_Id" BIGINT, "HRES_Id" BIGINT, "HRME_EmployeeCode" TEXT, 
            "HRME_EmployeeFirstname" TEXT, "HRMDES_DesignationName" TEXT, 
            "HRME_PFAccNo" TEXT, "HRES_WorkingDays" INTEGER,
            ' || "v_PivotColumnNames" || ',
            "TotalEarnings" NUMERIC, "Totaldeduction" NUMERIC, "totalArrear" NUMERIC)
    GROUP BY "HRME_Id", "HRES_Id", "HRME_EmployeeCode", "HRME_EmployeeFirstname",
             "HRMDES_DesignationName", "HRME_PFAccNo", "HRES_WorkingDays",
             "TotalEarnings", "Totaldeduction", "totalArrear"
    ORDER BY "HRME_Id"';

    EXECUTE "v_sqldynamic";

    FOR "rec" IN 
        EXECUTE 'SELECT DISTINCT "HRME_ID", "HRES_ID", 
                        COALESCE("Basic Pay", 0), COALESCE("DA", 0), 
                        COALESCE("PERSONAL PAY", 0), COALESCE("CL AMT", 0), 
                        "HRES_WorkingDays", COALESCE("P F", 0)
                 FROM "Empallsalaryheads_Temp1"'
    LOOP
        "v_HRME_ID_CUR1" := "rec"."HRME_ID";
        "v_HRES_ID_CUR1" := "rec"."HRES_ID";
        "v_BASICPAY" := "rec"."Basic Pay";
        "v_DA" := "rec"."DA";
        "v_PERSONALPAY" := "rec"."PERSONAL PAY";
        "v_CLAMT" := "rec"."CL AMT";
        "v_HRES_WorkingDays" := "rec"."HRES_WorkingDays";
        "v_PFAMOUNT" := "rec"."P F";

        "v_PENSIONAMOUNT" := 0;
        "v_SUMAMOUNT" := 0;
        "v_SUMAMOUNT" := "v_BASICPAY" + "v_DA" + "v_PERSONALPAY" + "v_CLAMT";

        SELECT ("HRME_DOB" + INTERVAL '58 years' - INTERVAL '1 day')
        INTO "v_RETIREDATE"
        FROM "HR_Master_Employee"
        WHERE "HRME_ID" = "v_HRME_ID_CUR1" AND "HRME_ActiveFlag" = TRUE;

        SELECT "IVRM_Month_Id" INTO "v_MONTHID"
        FROM "IVRM_Month" WHERE "IVRM_Month_Name" = "p_month";

        SELECT "IVRM_Month_Max_Days" INTO "v_IVRM_Month_Max_Days"
        FROM "IVRM_Month" WHERE "IVRM_Month_Name" = "p_month";

        IF (DATE_TRUNC('month', (CAST("p_year" || '-' || "v_MONTHID" || '-01' AS DATE))) + INTERVAL '1 month' - INTERVAL '1 day' = "v_RETIREDATE") THEN
            "v_REFDATE" := "v_RETIREDATE";
            "v_WorkingDay" := EXTRACT(DAY FROM "v_RETIREDATE");
            "v_flag" := TRUE;

            IF ("v_WorkingDay" > 30) THEN
                "v_WorkingDay" := 30;
            END IF;

        ELSIF ("v_RETIREDATE" < (DATE_TRUNC('month', (CAST("p_year" || '-' || "v_MONTHID" || '-01' AS DATE))) + INTERVAL '1 month' - INTERVAL '1 day')) THEN
            "v_WorkingDay" := EXTRACT(DAY FROM "v_RETIREDATE");

            IF ("v_WorkingDay" <= 30) THEN
                "v_WorkingDay" := EXTRACT(DAY FROM "v_RETIREDATE");
                SELECT ("HRME_DOB" + INTERVAL '58 years')
                INTO "v_RETIREDATE"
                FROM "HR_Master_Employee"
                WHERE "HRME_ID" = "v_HRME_ID_CUR1" AND "HRME_ActiveFlag" = TRUE;

                "v_REFDATE" := "v_RETIREDATE";
            ELSIF ("v_WorkingDay" > 30) THEN
                "v_WorkingDay" := 30;
                SELECT (DATE_TRUNC('month', (CAST("p_year" || '-' || "v_MONTHID" || '-01' AS DATE))) + INTERVAL '1 month' - INTERVAL '1 day')
                INTO "v_REFDATE";
            ELSE
                "v_WorkingDay" := 30;
                SELECT (DATE_TRUNC('month', (CAST("p_year" || '-' || "v_MONTHID" || '-01' AS DATE))) + INTERVAL '1 month' - INTERVAL '1 day')
                INTO "v_REFDATE";
            END IF;
        END IF;

        SELECT EXTRACT(YEAR FROM AGE("v_REFDATE", "HRME_DOB")) +
               CASE 
                   WHEN "v_REFDATE" >= MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER, 
                                                   EXTRACT(MONTH FROM "HRME_DOB")::INTEGER, 
                                                   EXTRACT(DAY FROM "HRME_DOB")::INTEGER) THEN
                       (1.0 * ("v_REFDATE" - MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER, 
                                                         EXTRACT(MONTH FROM "HRME_DOB")::INTEGER, 
                                                         EXTRACT(DAY FROM "HRME_DOB")::INTEGER)) /
                        (MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER + 1, 1, 1) - 
                         MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER, 1, 1)))
                   ELSE
                       -1 * (-1.0 * ("v_REFDATE" - MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER, 
                                                               EXTRACT(MONTH FROM "HRME_DOB")::INTEGER, 
                                                               EXTRACT(DAY FROM "HRME_DOB")::INTEGER)) /
                             (MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER + 1, 1, 1) - 
                              MAKE_DATE(EXTRACT(YEAR FROM "v_REFDATE")::INTEGER, 1, 1)))
               END,
               "HRME_FPFNotApplicableFlg"
        INTO "v_AGE", "v_HRME_FPFNotApplicableFlg"
        FROM "HR_Master_Employee"
        WHERE "HRME_Id" = "v_HRME_ID_CUR1";

        IF ("v_AGE" >= 58) THEN
            IF ("v_WorkingDay" > 0 AND "v_WorkingDay" < 30) THEN
                "v_PENSIONAMOUNT" := ROUND((1250 * "v_WorkingDay") / 30.0, 2);
            ELSE
                "v_PENSIONAMOUNT" := 0;
            END IF;
        ELSIF ("v_SUMAMOUNT" < 15000 AND "v_HRME_FPFNotApplicableFlg" = TRUE) THEN
            "v_PENSIONAMOUNT" := ROUND((8.33 / 100.0) * "v_SUMAMOUNT", 2);
        ELSIF ("v_HRME_FPFNotApplicableFlg" = TRUE) THEN
            "v_PENSIONAMOUNT" := 1250;
        ELSE
            "v_PENSIONAMOUNT" := 0;
        END IF;

        IF ("v_HRME_FPFNotApplicableFlg" = FALSE) THEN
            "v_SCHOOLPF" := "v_PFAMOUNT";
        ELSE
            "v_SCHOOLPF" := "v_PFAMOUNT" - "v_PENSIONAMOUNT";
        END IF;

        IF ("v_PFAMOUNT" > 1800 OR "v_PFAMOUNT" < 1800) THEN
            "v_PFSAL" := "v_SUMAMOUNT";
        ELSIF ("v_PFAMOUNT" = 1800) THEN
            "v_PFSAL" := 15000;
        ELSIF ("v_PFAMOUNT" = 0 OR "v_PFAMOUNT" IS NULL) THEN
            "v_PFSAL" := 0;
        END IF;

        IF ("v_SUMAMOUNT" > 15000) THEN
            "v_EDLISAL" := 15000;
        ELSE
            "v_EDLISAL" := "v_SUMAMOUNT";
        END IF;

        IF ("v_SUMAMOUNT" >= 15000) THEN
            "v_PENSIONSAL" := "v_SUMAMOUNT";
        END IF;
        
        IF ("v_PENSIONAMOUNT" = 0) THEN
            "v_PENSIONSAL" := 0;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'Empallsalaryheads_Temp1' 
                   AND column_name = 'PENSION') THEN
            EXECUTE 'UPDATE "Empallsalaryheads_Temp1" 
                     SET "PENSION" = $1, "PF GROSS" = $2, "SCHOOL PF" = $3, 
                         "PF SAL" = $4, "EDLI SAL" = $5, "PENSION SAL" = $6
                     WHERE "HRME_ID" = $7 AND "HRES_ID" = $8'
            USING "v_PENSIONAMOUNT", "v_SUMAMOUNT", "v_SCHOOLPF", "v_PFSAL", 
                  "v_EDLISAL", "v_PENSIONSAL", "v_HRME_ID_CUR1", "v_HRES_ID_CUR1";
        END IF;
    END LOOP;

    RETURN QUERY EXECUTE 'SELECT "HRME_Id", "HRES_Id", "HRME_EmployeeCode", 
                                  "HRME_EmployeeFirstname", "HRMDES_DesignationName", 
                                  "HRME_PFAccNo", "HRES_WorkingDays", 
                                  "TotalEarnings", "Totaldeduction", "totalArrear", 
                                  "TotalPayable"
                           FROM "Empallsalaryheads_Temp1"';

END;
$$;