CREATE OR REPLACE FUNCTION "dbo"."HR_Cumulative_Salary_Yearly_Report"(
    "p_year" TEXT,
    "p_month" TEXT,
    "p_MI_ID" TEXT,
    "p_HRMDES_Id" TEXT
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "HRME_EmployeeCode" VARCHAR,
    "HRME_EmployeeFirstname" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_PFAccNo" VARCHAR
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
    "v_monthname" TEXT;
    "v_dynamic" TEXT;
    "v_dynamic1" TEXT;
    "v_dynamic2" TEXT;
    "v_IVRM_Month_Max_Days" BIGINT;
    "v_flag" BOOLEAN;
BEGIN

    "v_monthname" := '''' || "p_month" || '''';

    DROP TABLE IF EXISTS "Empallsalaryheads_Temp1";
    DROP TABLE IF EXISTS "totalearnings";
    DROP TABLE IF EXISTS "totaldeductions";
    DROP TABLE IF EXISTS "totalArrear";

    "v_dynamic" := '
    CREATE TEMP TABLE "totalearnings" AS
    SELECT DISTINCT Sum(B."HRESD_Amount") AS "TotalEarnings", A."HRME_Id"
    FROM "HR_Employee_Salary" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
    INNER JOIN "HR_Master_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id"
    INNER JOIN "IVRM_Month" M ON A."HRES_Month" = M."IVRM_Month_Name"
    WHERE C."HRMED_EarnDedFlag" = ''Earning'' 
        AND A."HRES_Year" = ' || "p_year" || ' 
        AND M."IVRM_Month_Id" IN (' || "p_month" || ') 
        AND A."MI_ID" = ' || "p_MI_ID" || '
    GROUP BY A."HRME_Id"';
    
    EXECUTE "v_dynamic";

    "v_dynamic1" := '
    CREATE TEMP TABLE "totaldeductions" AS
    SELECT DISTINCT Sum(B."HRESD_Amount") AS "Totaldeduction", A."HRME_Id"
    FROM "HR_Employee_Salary" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
    INNER JOIN "HR_Master_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id"
    INNER JOIN "IVRM_Month" M ON A."HRES_Month" = M."IVRM_Month_Name"
    WHERE C."HRMED_EarnDedFlag" = ''Deduction'' 
        AND A."HRES_Year" = ' || "p_year" || ' 
        AND M."IVRM_Month_Id" IN (' || "p_month" || ') 
        AND A."MI_ID" = ' || "p_MI_ID" || '
    GROUP BY A."HRME_Id"';
    
    EXECUTE "v_dynamic1";

    "v_dynamic2" := '
    CREATE TEMP TABLE "totalArrear" AS
    SELECT DISTINCT Sum(B."HRESD_Amount") AS "totalArrear", A."HRME_Id"
    FROM "HR_Employee_Salary" A
    INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
    INNER JOIN "HR_Master_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id"
    INNER JOIN "IVRM_Month" M ON A."HRES_Month" = M."IVRM_Month_Name"
    WHERE C."HRMED_EarnDedFlag" = ''Arrear'' 
        AND A."HRES_Year" = ' || "p_year" || ' 
        AND M."IVRM_Month_Id" IN (' || "p_month" || ') 
        AND A."MI_ID" = ' || "p_MI_ID" || '
    GROUP BY A."HRME_Id"';
    
    EXECUTE "v_dynamic2";

    SELECT STRING_AGG('"' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Order")
    INTO "v_PivotColumnNames"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name" 
        FROM "HR_Master_EarningsDeductions" D 
        WHERE "MI_ID" = "p_MI_ID"::BIGINT 
            AND D."HRMED_ActiveFlag" = true
    ) AS "PVColumns";

    SELECT STRING_AGG('SUM(COALESCE("' || "HRMED_Name" || '", 0)) AS "' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Order")
    INTO "v_PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name" 
        FROM "HR_Master_EarningsDeductions" D 
        WHERE "MI_ID" = "p_MI_ID"::BIGINT 
            AND D."HRMED_ActiveFlag" = true
    ) AS "PVSelctedColumns";

    "v_sqldynamic" := '
    CREATE TEMP TABLE "Empallsalaryheads_Temp1" AS
    SELECT "HRME_Id", "HRME_EmployeeCode", "HRME_EmployeeFirstname", 
           "HRMDES_DesignationName", "HRME_PFAccNo", ' || "v_PivotSelectColumnNames" || '
    FROM (
        SELECT C."HRME_Id", C."HRME_EmployeeCode",
               CONCAT(COALESCE(C."HRME_EmployeeFirstname", ''''), '' '', 
                      COALESCE(C."HRME_EmployeeMiddleName", ''''), '' '', 
                      COALESCE(C."HRME_EmployeeLastName", '''')) AS "HRME_EmployeeFirstname",
               "HRMDES_DesignationName", "HRME_PFAccNo", D."HRMED_Name",
               SUM(B."HRESD_Amount") AS "HRESD_Amount"
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
        INNER JOIN "HR_Master_Employee" C ON C."HRME_Id" = A."HRME_Id"
        INNER JOIN "HR_Master_EarningsDeductions" D ON D."HRMED_Id" = B."HRMED_Id"
        INNER JOIN "HR_Employee_EarningsDeductions" E ON E."HRME_Id" = C."HRME_Id" 
            AND E."HRMED_Id" = D."HRMED_Id"
        INNER JOIN "HR_Master_Designation" L ON C."HRMDES_Id" = L."HRMDES_Id"
        INNER JOIN "IVRM_Month" M ON A."HRES_Month" = M."IVRM_Month_Name"
        WHERE A."HRMDES_Id" IN (' || "p_HRMDES_Id" || ') 
            AND A."HRES_Year" = ''' || "p_year" || ''' 
            AND M."IVRM_Month_Id" IN (' || "p_month" || ')
            AND D."HRMED_ActiveFlag" = true 
            AND E."HREED_ActiveFlag" = true
        GROUP BY C."HRME_Id", "HRES_Year", "HRME_EmployeeCode", "HRME_EmployeeFirstname",
                 "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", "HRMDES_DesignationName",
                 "HRME_PFAccNo", D."HRMED_Name", "HRESD_Amount"
    ) AS "SourceTable"
    CROSS JOIN LATERAL (
        SELECT ' || REPLACE("v_PivotColumnNames", ',', ' UNION ALL SELECT ') || '
    ) AS "Columns"("HRMED_Name")
    GROUP BY "HRME_Id", "HRME_EmployeeCode", "HRME_EmployeeFirstname", 
             "HRMDES_DesignationName", "HRME_PFAccNo"
    ORDER BY "HRME_Id"';

    EXECUTE "v_sqldynamic";

    RETURN QUERY SELECT * FROM "Empallsalaryheads_Temp1";

END;
$$;