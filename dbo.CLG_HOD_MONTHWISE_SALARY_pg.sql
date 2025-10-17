CREATE OR REPLACE FUNCTION "dbo"."CLG_HOD_MONTHWISE_SALARY"(
    p_MI_ID INTEGER,
    p_year VARCHAR(50),
    p_HRME_Id TEXT
)
RETURNS TABLE(
    month1 VARCHAR,
    IVRM_Month_Id INTEGER,
    "Deduction" NUMERIC,
    "Earning" NUMERIC,
    netamount NUMERIC,
    HRMD_Id BIGINT,
    HRMD_DepartmentName VARCHAR,
    HRMDES_Id BIGINT,
    HRMDES_DesignationName VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stf_id BIGINT;
BEGIN
    
    SELECT "Emp_Code" INTO v_stf_id 
    FROM "IVRM_Staff_User_Login" 
    WHERE "id" = p_HRME_Id;
    
    RETURN QUERY
    SELECT 
        sub."HRES_Month" AS month1,
        sub."IVRM_Month_Id",
        sub."Deduction",
        sub."Earning",
        COALESCE(sub."Earning", 0) - COALESCE(sub."Deduction", 0) AS netamount,
        sub."HRMD_Id",
        sub."HRMD_DepartmentName",
        sub."HRMDES_Id",
        sub."HRMDES_DesignationName"
    FROM (
        SELECT 
            agg."HRES_Month",
            agg."IVRM_Month_Id",
            agg."HRMD_Id",
            agg."HRMD_DepartmentName",
            agg."HRMDES_Id",
            agg."HRMDES_DesignationName",
            SUM(CASE WHEN agg."HRMED_EarnDedFlag" = 'Deduction' THEN agg."Amt" ELSE 0 END) AS "Deduction",
            SUM(CASE WHEN agg."HRMED_EarnDedFlag" = 'Earning' THEN agg."Amt" ELSE 0 END) AS "Earning"
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
                AND "E"."HRME_Id" IN (
                    SELECT "HRME_Id" 
                    FROM "IVRM_HOD_Staff" 
                    WHERE "IHOD_Id" IN (
                        SELECT "IHOD_Id" 
                        FROM "IVRM_HOD" 
                        WHERE "HRME_Id" = v_stf_id
                    )
                )
            GROUP BY "ED"."HRMED_EarnDedFlag", "ES"."HRES_Month", "d"."IVRM_Month_Id", 
                     "MD"."HRMD_Id", "MD"."HRMD_DepartmentName", "F"."HRMDES_Id", "F"."HRMDES_DesignationName"
        ) AS agg
        GROUP BY agg."HRES_Month", agg."IVRM_Month_Id", agg."HRMD_Id", 
                 agg."HRMD_DepartmentName", agg."HRMDES_Id", agg."HRMDES_DesignationName"
    ) AS sub
    ORDER BY sub."IVRM_Month_Id"
    LIMIT 100;
    
END;
$$;