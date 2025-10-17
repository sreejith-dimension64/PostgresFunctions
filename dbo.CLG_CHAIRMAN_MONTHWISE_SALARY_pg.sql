CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_MONTHWISE_SALARY"(
    p_MI_ID integer,
    p_year varchar(50)
)
RETURNS TABLE(
    "month1" varchar,
    "IVRM_Month_Id" integer,
    "Deduction" numeric,
    "Earning" numeric,
    "netamount" numeric,
    "HRMD_Id" integer,
    "HRMD_DepartmentName" varchar,
    "HRMDES_Id" integer,
    "HRMDES_DesignationName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "PVT"."month1",
        "PVT"."IVRM_Month_Id",
        "PVT"."Deduction",
        "PVT"."Earning",
        COALESCE("PVT"."Earning", 0) - COALESCE("PVT"."Deduction", 0) AS "netamount",
        "PVT"."HRMD_Id",
        "PVT"."HRMD_DepartmentName",
        "PVT"."HRMDES_Id",
        "PVT"."HRMDES_DesignationName"
    FROM (
        SELECT 
            "New"."HRES_Month" AS "month1",
            "New"."IVRM_Month_Id",
            "New"."HRMD_Id",
            "New"."HRMD_DepartmentName",
            "New"."HRMDES_Id",
            "New"."HRMDES_DesignationName",
            SUM(CASE WHEN "New"."HRMED_EarnDedFlag" = 'Deduction' THEN "New"."Amt" ELSE NULL END) AS "Deduction",
            SUM(CASE WHEN "New"."HRMED_EarnDedFlag" = 'Earning' THEN "New"."Amt" ELSE NULL END) AS "Earning"
        FROM (
            SELECT DISTINCT
                "ED"."HRMED_EarnDedFlag",
                SUM("SD"."HRESD_Amount") AS "Amt",
                "ES"."HRES_Month",
                "d"."IVRM_Month_Id",
                "MD"."HRMD_Id",
                "MD"."HRMD_DepartmentName",
                "F"."HRMDES_Id",
                "F"."HRMDES_DesignationName"
            FROM "HR_Master_Department" "MD"
            INNER JOIN "HR_Master_Employee" "E" ON "MD"."HRMD_Id" = "E"."HRMD_Id" 
                AND "E"."MI_Id" = p_MI_ID 
                AND "E"."HRME_ActiveFlag" = 1 
                AND "E"."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_GroupType" "GT" ON "GT"."HRMGT_Id" = "E"."HRMGT_Id" 
                AND "GT"."MI_Id" = p_MI_ID
            INNER JOIN "HR_Employee_Salary" "ES" ON "ES"."MI_Id" = p_MI_ID 
                AND "ES"."HRME_Id" = "E"."HRME_Id" 
                AND "ES"."HRMD_Id" = "MD"."HRMD_Id"
            INNER JOIN "HR_Employee_Salary_Details" "SD" ON "SD"."HRES_Id" = "ES"."HRES_Id"
            INNER JOIN "HR_Master_EarningsDeductions" "ED" ON "ED"."HRMED_Id" = "SD"."HRMED_Id" 
                AND "ED"."MI_Id" = p_MI_ID
            INNER JOIN "IVRM_Month" AS "d" ON "ES"."HRES_Month" = "d"."IVRM_Month_Name"
            INNER JOIN "HR_Master_Designation" AS "F" ON "F"."HRMDES_Id" = "E"."HRMDES_Id" 
                AND "F"."HRMDES_ActiveFlag" = 1 
                AND "F"."MI_Id" = p_MI_ID
            WHERE "MD"."MI_Id" = p_MI_ID 
                AND "MD"."HRMD_ActiveFlag" = 1
                AND "ES"."HRES_Year" = p_year 
                AND "ED"."HRMED_ActiveFlag" = 1
            GROUP BY "ED"."HRMED_EarnDedFlag", "ES"."HRES_Month", "d"."IVRM_Month_Id", 
                     "MD"."HRMD_Id", "MD"."HRMD_DepartmentName", "F"."HRMDES_Id", "F"."HRMDES_DesignationName"
            ORDER BY "d"."IVRM_Month_Id"
            LIMIT 100
        ) AS "New"
        GROUP BY "New"."HRES_Month", "New"."IVRM_Month_Id", "New"."HRMD_Id", 
                 "New"."HRMD_DepartmentName", "New"."HRMDES_Id", "New"."HRMDES_DesignationName"
    ) AS "PVT"
    ORDER BY "PVT"."IVRM_Month_Id";
END;
$$;