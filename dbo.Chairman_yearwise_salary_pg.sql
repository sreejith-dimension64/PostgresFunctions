CREATE OR REPLACE FUNCTION "dbo"."Chairman_yearwise_salary"(
    p_MI_ID integer,
    p_year varchar(50)
)
RETURNS TABLE(
    "month1" varchar,
    "IVRM_Month_Id" integer,
    "Deduction" numeric,
    "Earning" numeric,
    "netamount" numeric
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "New"."HRES_Month" as "month1",
        "New"."IVRM_Month_Id",
        "New"."Deduction",
        "New"."Earning",
        COALESCE("New"."Earning", 0) - COALESCE("New"."Deduction", 0) AS "netamount"
    FROM (
        SELECT 
            "PVT_Base"."HRES_Month",
            "PVT_Base"."IVRM_Month_Id",
            SUM(CASE WHEN "PVT_Base"."HRMED_EarnDedFlag" = 'Deduction' THEN "PVT_Base"."Amt" ELSE NULL END) AS "Deduction",
            SUM(CASE WHEN "PVT_Base"."HRMED_EarnDedFlag" = 'Earning' THEN "PVT_Base"."Amt" ELSE NULL END) AS "Earning"
        FROM (
            SELECT DISTINCT 
                "ED"."HRMED_EarnDedFlag",
                SUM("SD"."HRESD_Amount") AS "Amt",
                "ES"."HRES_Month",
                "d"."IVRM_Month_Id"
            FROM "HR_Master_Department" "MD"
            INNER JOIN "HR_Master_Employee" "E" ON "MD"."HRMD_Id" = "E"."HRMD_Id" 
                AND "E"."MI_Id" = p_MI_ID 
                AND "E"."HRME_ActiveFlag" = 1
            INNER JOIN "HR_Master_GroupType" "GT" ON "GT"."HRMGT_Id" = "E"."HRMGT_Id" 
                AND "GT"."MI_Id" = p_MI_ID
            INNER JOIN "HR_Employee_Salary" "ES" ON "ES"."MI_Id" = p_MI_ID 
                AND "ES"."HRME_Id" = "E"."HRME_Id" 
                AND "ES"."HRMD_Id" = "MD"."HRMD_Id"
            INNER JOIN "HR_Employee_Salary_Details" "SD" ON "SD"."HRES_Id" = "ES"."HRES_Id"
            INNER JOIN "HR_Master_EarningsDeductions" "ED" ON "ED"."HRMED_Id" = "SD"."HRMED_Id" 
                AND "ED"."MI_Id" = p_MI_ID
            INNER JOIN "IVRM_Month" "d" ON "ES"."HRES_Month" = "d"."IVRM_Month_Name"
            WHERE "MD"."MI_Id" = p_MI_ID 
                AND "MD"."HRMD_ActiveFlag" = 1
                AND "ES"."HRES_Year" = p_year 
                AND "ED"."HRMED_ActiveFlag" = 1
            GROUP BY "ED"."HRMED_EarnDedFlag", "ES"."HRES_Month", "d"."IVRM_Month_Id"
            ORDER BY "d"."IVRM_Month_Id"
            LIMIT 100
        ) AS "PVT_Base"
        GROUP BY "PVT_Base"."HRES_Month", "PVT_Base"."IVRM_Month_Id"
    ) AS "New";
END;
$$;