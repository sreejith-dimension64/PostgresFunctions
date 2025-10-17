CREATE OR REPLACE FUNCTION "dbo"."HR_Cumulative_Salary_Yearly_Report_Test"(
    "year" TEXT,
    "month" TEXT,
    "MI_ID" TEXT,
    "HRMDES_Id" TEXT,
    "HRMEId" BIGINT
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRES_Month" TEXT,
    "grossEarning" NUMERIC,
    "grossDeduction" NUMERIC,
    "netSalary" NUMERIC
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "SanctionLevelNo" BIGINT;
    "Rcount" BIGINT;
    "Rcount1" BIGINT;
    "MaxSanctionLevelNo" BIGINT;
    "MaxSanctionLevelNo_New" BIGINT;
    "ApprCount" BIGINT;
    "HRES_ID" TEXT;
    "Preuserid" TEXT;
    "HRME_ID" TEXT;
    "HRES_ID2" TEXT;
    "AppEmpRcount" BIGINT;
    "sqldynamic" TEXT;
    "sqldynamic1" TEXT;
    "PivotColumnNames" TEXT;
    "PivotSelectColumnNames" TEXT;
    "monthname" TEXT;
    "dynamic" TEXT;
    "dynamic1" TEXT;
    "dynamic2" TEXT;
    "IVRM_Month_Max_Days" BIGINT;
    "flag" BOOLEAN;
    "earningtotal" TEXT;
    "deductiontotal" TEXT;
BEGIN

    "monthname" := '''' || "month" || '''';

    SELECT STRING_AGG('"' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Order")
    INTO "PivotColumnNames"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name" 
        FROM "HR_Master_EarningsDeductions" D 
        WHERE "MI_ID" = "MI_ID" AND D."HRMED_ActiveFlag" = true
    ) AS PVColumns;

    SELECT STRING_AGG('SUM(COALESCE(' || '"' || "HRMED_Name" || '"' || ', 0)) AS ' || '"' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Order")
    INTO "PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name" 
        FROM "HR_Master_EarningsDeductions" D 
        WHERE "MI_ID" = "MI_ID" AND D."HRMED_ActiveFlag" = true
    ) AS PVSelctedColumns;

    SELECT STRING_AGG('sum(COALESCE(' || '"' || "HRMED_Name" || '"' || ', 0)) ', '+' ORDER BY "HRMED_Order")
    INTO "earningtotal"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name" 
        FROM "HR_Master_EarningsDeductions" D 
        WHERE "MI_ID" = "MI_ID" AND "HRMED_EarnDedFlag" = 'Earning' AND D."HRMED_ActiveFlag" = true
    ) AS earningtotal;

    SELECT STRING_AGG('sum(COALESCE(' || '"' || "HRMED_Name" || '"' || ', 0)) ', '+' ORDER BY "HRMED_Order")
    INTO "deductiontotal"
    FROM (
        SELECT DISTINCT "HRMED_Order", D."HRMED_Name" 
        FROM "HR_Master_EarningsDeductions" D 
        WHERE "MI_ID" = "MI_ID" AND "HRMED_EarnDedFlag" = 'Deduction' AND D."HRMED_ActiveFlag" = true
    ) AS deductiontotal;

    IF("HRMEId" > 0) THEN
        "dynamic" := 'and C."HRME_Id"=' || "HRMEId"::TEXT || '';
    ELSE
        "dynamic" := '';
    END IF;

    "sqldynamic" := '
    SELECT "HRME_Id", "HRES_Month", ' || "PivotSelectColumnNames" || ', (' || "earningtotal" || ') as "grossEarning", (' || "deductiontotal" || ') as "grossDeduction", ((' || "earningtotal" || ') - (' || "deductiontotal" || ')) as "netSalary"
    FROM (
        SELECT C."HRME_Id", A."HRES_Month", C."HRME_EmployeeCode", 
               CONCAT(COALESCE(C."HRME_EmployeeFirstname", ''''), '' '', COALESCE(C."HRME_EmployeeMiddleName", ''''), '' '', COALESCE(C."HRME_EmployeeLastName", '''')) AS "HRME_EmployeeFirstname",
               "HRMDES_DesignationName", "HRME_PFAccNo", D."HRMED_Name", Sum(B."HRESD_Amount") AS "HRESD_Amount"
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
        INNER JOIN "HR_Master_Employee" C ON C."HRME_Id" = A."HRME_Id"
        INNER JOIN "HR_Master_EarningsDeductions" D ON D."HRMED_Id" = B."HRMED_Id"
        INNER JOIN "HR_Employee_EarningsDeductions" E ON E."HRME_Id" = C."HRME_Id" AND E."HRMED_Id" = D."HRMED_Id"
        INNER JOIN "HR_Master_Designation" L ON C."HRMDES_Id" = L."HRMDES_Id"
        INNER JOIN "IVRM_Month" M ON A."HRES_Month" = M."IVRM_Month_Name"
        WHERE A."HRMDES_Id"::TEXT IN (' || "HRMDES_Id" || ') 
          AND A."HRES_Year" = ''' || "year" || ''' 
          AND M."IVRM_Month_Id"::TEXT IN (' || "month" || ')
          AND D."HRMED_ActiveFlag" = true 
          AND E."HREED_ActiveFlag" = true ' || "dynamic" || '
        GROUP BY C."HRME_Id", "HRES_Year", A."HRES_Month", "HRME_EmployeeCode", "HRME_EmployeeFirstname", 
                 "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", "HRMDES_DesignationName", "HRME_PFAccNo", D."HRMED_Name", "HRESD_Amount"
    ) AS New 
    PIVOT (SUM("HRESD_Amount") FOR "HRMED_Name" IN (' || "PivotColumnNames" || ')) AS Pvt 
    GROUP BY "HRME_Id", "HRME_EmployeeCode", "HRME_EmployeeFirstname", "HRMDES_DesignationName", "HRME_PFAccNo", "HRES_Month"
    ORDER BY "HRME_Id"';

    RAISE NOTICE '%', "sqldynamic";

    RETURN QUERY EXECUTE "sqldynamic";

END;
$$;