CREATE OR REPLACE FUNCTION "dbo"."FO_Planner_NotCreated_Details" (
    p_MI_Id bigint,
    p_startdate varchar(10)
)
RETURNS TABLE (
    employeename TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE(a."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(a."HRME_EmployeeLastName", ' ')) AS employeename,
        a."HRME_EmployeeCode",
        b."HRMD_DepartmentName",
        c."HRMDES_DesignationName"
    FROM "HR_Master_Employee" a
    JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id" 
        AND a."HRME_ActiveFlag" = 1 
        AND a."HRME_LeftFlag" = 0 
        AND a."MI_Id" = p_MI_Id
    JOIN "HR_Master_Designation" c ON a."HRMDES_Id" = c."HRMDES_Id" 
        AND a."HRME_Id" NOT IN (
            SELECT "HRME_Id" 
            FROM "ISM_Task_Planner" 
            WHERE CAST("ISMTPL_StartDate" AS date) = TO_DATE(p_startdate, 'YYYY-MM-DD')
        )
    ORDER BY a."HRME_EmployeeCode";
END;
$$;