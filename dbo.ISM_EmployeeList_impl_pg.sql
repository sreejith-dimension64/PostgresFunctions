CREATE OR REPLACE FUNCTION "dbo"."ISM_EmployeeList_impl"(
    p_MI_Id BIGINT
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "employeeName" TEXT,
    "HRMD_DepartmentName" TEXT,
    "HRME_Photo" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "HRE"."HRME_Id",
        "HRE"."HRMD_Id",
        (
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' ELSE 
            "HRE"."HRME_EmployeeFirstName" END ||
            CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' 
            OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
            CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' 
            OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END)
        ) AS "employeeName",
        "HRD"."HRMD_DepartmentName",
        "HRE"."HRME_Photo"
    FROM "HR_Master_Employee" "HRE"
    INNER JOIN "HR_Master_Department" "HRD" 
        ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" 
        AND "HRD"."HRMD_ActiveFlag" = 1
    WHERE "HRE"."HRME_ActiveFlag" = 1 
        AND "HRE"."HRME_LeftFlag" = 0 
        AND "HRE"."HRME_ActiveFlag" = 1
    ORDER BY "employeeName";
END;
$$;