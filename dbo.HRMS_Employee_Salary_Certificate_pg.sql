CREATE OR REPLACE FUNCTION "dbo"."HRMS_Employee_Salary_Certificate"(
    p_HRME_Id bigint,
    p_MI_Id bigint
)
RETURNS TABLE(
    hrme_id bigint,
    "EmployeeName" text,
    "HRME_DOJ" timestamp,
    "HRMD_DepartmentName" varchar,
    "HREED_Amount" numeric,
    "MI_Name" varchar,
    "HRMED_EarnDedFlag" varchar,
    "HRMED_Name" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."hrme_id",
        (COALESCE(c."HRME_EmployeeFirstName", '') || ' ' ||
         COALESCE(c."HRME_EmployeeMiddleName", '') || ' ' ||
         COALESCE(c."HRME_EmployeeLastName", '')) AS "EmployeeName",
        c."HRME_DOJ",
        d."HRMD_DepartmentName",
        a."HREED_Amount",
        f."MI_Name",
        b."HRMED_EarnDedFlag",
        b."HRMED_Name"
    FROM "HR_Employee_EarningsDeductions" a
    INNER JOIN "HR_Master_EarningsDeductions" b ON a."HRMED_Id" = b."HRMED_Id"
    INNER JOIN "HR_Master_Employee" c ON a."hrme_id" = c."hrme_id"
    INNER JOIN "HR_Master_Department" d ON c."HRMD_Id" = d."HRMD_Id"
    INNER JOIN "HR_Master_Designation" e ON e."HRMDES_Id" = c."HRMDES_Id"
    INNER JOIN "Master_Institution" f ON c."MI_Id" = f."MI_Id"
    WHERE d."HRMD_ActiveFlag" = 1 
      AND b."HRMED_ActiveFlag" = 1 
      AND c."MI_Id" = p_MI_Id 
      AND c."HRME_Id" = p_HRME_Id;
END;
$$;