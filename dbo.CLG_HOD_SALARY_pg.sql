CREATE OR REPLACE FUNCTION "dbo"."CLG_HOD_SALARY"(
    "p_MI_ID" integer,
    "p_year" varchar(50),
    "p_HRME_Id" text
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
DECLARE
    "v_stf_id" bigint;
BEGIN
    SELECT "Emp_Code" INTO "v_stf_id" 
    FROM "IVRM_Staff_User_Login" 
    WHERE "id" = "p_HRME_Id";

    RETURN QUERY
    SELECT 
        "HRES_Month" as "month1",
        "IVRM_Month_Id",
        "Deduction",
        "Earning",
        COALESCE("Earning", 0) - COALESCE("Deduction", 0) AS "netamount",
        "HRMD_Id",
        "HRMD_DepartmentName",
        "HRMDES_Id",
        "HRMDES_DesignationName"
    FROM (
        SELECT 
            "HRMED_EarnDedFlag",
            SUM("HRESD_Amount") AS "Amt",
            "ES"."HRES_Month",
            "d"."IVRM_Month_Id",
            "MD"."HRMD_Id",
            "MD"."HRMD_DepartmentName",
            "F"."HRMDES_Id",
            "F"."HRMDES_DesignationName"
        FROM "HR_Master_Department" "MD"
        INNER JOIN "HR_Master_Employee" "E" ON "MD"."HRMD_Id" = "E"."HRMD_Id" 
            AND "E"."MI_Id" = "p_MI_ID" 
            AND "E"."HRME_ActiveFlag" = 1 
            AND "E"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_GroupType" "GT" ON "GT"."HRMGT_Id" = "E"."HRMGT_Id" 
            AND "GT"."MI_Id" = "p_MI_ID"
        INNER JOIN "HR_Employee_Salary" "ES" ON "ES"."MI_Id" = "p_MI_ID" 
            AND "ES"."HRME_Id" = "E"."HRME_Id" 
            AND "ES"."HRMD_Id" = "MD"."HRMD_Id"
        INNER JOIN "HR_Employee_Salary_Details" "SD" ON "SD"."HRES_Id" = "ES"."HRES_Id"
        INNER JOIN "HR_Master_EarningsDeductions" "ED" ON "ED"."HRMED_Id" = "SD"."HRMED_Id" 
            AND "ED"."MI_Id" = "p_MI_ID"
        INNER JOIN "IVRM_Month" AS "d" ON "ES"."HRES_Month" = "d"."IVRM_Month_Name"
        INNER JOIN "HR_Master_Designation" AS "F" ON "F"."HRMDES_Id" = "E"."HRMDES_Id" 
            AND "F"."HRMDES_ActiveFlag" = 1 
            AND "F"."MI_Id" = "p_MI_ID"
        WHERE "MD"."MI_Id" = "p_MI_ID" 
            AND "MD"."HRMD_ActiveFlag" = 1
            AND "ES"."HRES_Year" = "p_year" 
            AND "ED"."HRMED_ActiveFlag" = 1
            AND "E"."HRME_Id" = "v_stf_id"
        GROUP BY "ED"."HRMED_EarnDedFlag", "ES"."HRES_Month", "d"."IVRM_Month_Id", 
                 "MD"."HRMD_Id", "MD"."HRMD_DepartmentName", "F"."HRMDES_Id", "F"."HRMDES_DesignationName"
        ORDER BY "d"."IVRM_Month_Id"
        LIMIT 100
    ) AS "New"
    CROSS JOIN LATERAL (
        SELECT 
            "New"."HRES_Month",
            "New"."IVRM_Month_Id",
            "New"."HRMD_Id",
            "New"."HRMD_DepartmentName",
            "New"."HRMDES_Id",
            "New"."HRMDES_DesignationName",
            SUM(CASE WHEN "New"."HRMED_EarnDedFlag" = 'Deduction' THEN "New"."Amt" ELSE NULL END) AS "Deduction",
            SUM(CASE WHEN "New"."HRMED_EarnDedFlag" = 'Earning' THEN "New"."Amt" ELSE NULL END) AS "Earning"
    ) AS "PVT"
    ORDER BY "IVRM_Month_Id";
    
    RETURN;
END;
$$;