CREATE OR REPLACE FUNCTION "dbo"."EmployeeSalarySlipGeneration_1"(
    "p_HRME_ID" TEXT,
    "p_MI_ID" TEXT,
    "p_HRMLY_LeaveYear" TEXT,
    "p_IVRM_Month_Name" TEXT
)
RETURNS TABLE(
    "name" TEXT,
    "MI_Id" TEXT,
    "HRME_Id" TEXT,
    "HRES_Year" TEXT,
    "HRES_Month" TEXT,
    "Deduction" NUMERIC,
    "Earning" NUMERIC,
    "NetAmt" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqlquery1" TEXT;
BEGIN

    DROP TABLE IF EXISTS "HR_EmplyeeEarD";

    "v_sqlquery1" := '
    CREATE TEMP TABLE "HR_EmplyeeEarD" AS
    SELECT  "HME"."HRME_EmployeeFirstName",
     
    (COALESCE("HME"."HRME_EmployeeFirstName",'' '')||'' ''||COALESCE("HME"."HRME_EmployeeMiddleName",'' '')||'' ''||COALESCE("HME"."HRME_EmployeeLastName",'' '')) as "name",

    "HRES"."MI_Id"::TEXT,"HRES"."HRME_Id"::TEXT,"HRES"."HRES_Year"::TEXT,"HRES"."HRES_Month", 
    "HRMED"."HRMED_EarnDedFlag",
    ROUND(SUM("HRESD"."HRESD_Amount"),0) As "Amount"
    FROM "HR_Employee_Salary" "HRES"
    LEFT JOIN "HR_Employee_Salary_Details" "HRESD" ON "HRESD"."HRES_Id" = "HRES"."HRES_Id"
    LEFT JOIN "HR_Master_EarningsDeductions" "HRMED" ON "HRMED"."HRMED_Id" = "HRESD"."HRMED_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_ID"="HRES"."HRME_ID"
    WHERE "HRES"."MI_Id"::TEXT = ''' || "p_MI_ID" || ''' AND "HRES"."HRME_Id"::TEXT IN (' || 
    (SELECT string_agg('''' || unnest || '''', ',') FROM unnest(string_to_array("p_HRME_ID", ','))) || ') 
    AND "HRES"."HRES_Year"::TEXT = ''' || "p_HRMLY_LeaveYear" || ''' AND "HRES"."HRES_Month" =''' || "p_IVRM_Month_Name" || '''
    AND "HRMED"."HRMED_ActiveFlag" = 1
    GROUP BY  "HME"."HRME_EmployeeFirstName","HME"."HRME_EmployeeMiddleName","HME"."HRME_EmployeeLastName","HRES"."MI_Id", "HRES"."HRME_Id","HRES"."HRES_Year","HRES"."HRES_Month","HRMED"."HRMED_EarnDedFlag"';
    
    EXECUTE "v_sqlquery1";

    RETURN QUERY
    SELECT 
        "PVT"."name",
        "PVT"."MI_Id",
        "PVT"."HRME_Id",
        "PVT"."HRES_Year",
        "PVT"."HRES_Month",
        "PVT"."Deduction",
        "PVT"."Earning",
        (COALESCE("PVT"."Earning",0) - COALESCE("PVT"."Deduction",0)) AS "NetAmt"
    FROM (
        SELECT 
            "New"."name",
            "New"."MI_Id",
            "New"."HRME_Id",
            "New"."HRES_Year",
            "New"."HRES_Month",
            SUM(CASE WHEN "New"."HRMED_EarnDedFlag" = 'Deduction' THEN "New"."Amount" ELSE 0 END) AS "Deduction",
            SUM(CASE WHEN "New"."HRMED_EarnDedFlag" = 'Earning' THEN "New"."Amount" ELSE 0 END) AS "Earning"
        FROM "HR_EmplyeeEarD" "New"
        GROUP BY "New"."name", "New"."MI_Id", "New"."HRME_Id", "New"."HRES_Year", "New"."HRES_Month"
    ) "PVT";

    DROP TABLE IF EXISTS "HR_EmplyeeEarD";

    RETURN;

END;
$$;