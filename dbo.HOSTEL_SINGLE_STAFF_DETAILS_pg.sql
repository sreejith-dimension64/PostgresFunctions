CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_SINGLE_STAFF_DETAILS"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HRME_Id BIGINT
)
RETURNS TABLE(
    "empName" TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_EmployeeCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        COALESCE("HME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HME"."HRME_EmployeeLastName", '') AS "empName",
        "HMD"."HRMD_DepartmentName",
        "HMDES"."HRMDES_DesignationName",
        "HME"."HRME_EmployeeCode"
    FROM "HR_Master_Employee" "HME" 
    INNER JOIN "HR_Master_Department" "HMD" ON "HME"."HRMD_Id" = "HMD"."HRMD_Id"
    INNER JOIN "HR_Master_Designation" "HMDES" ON "HME"."HRMDES_Id" = "HMDES"."HRMDES_Id"
    WHERE "HME"."MI_Id" = p_MI_Id 
        AND "HME"."HRME_Id" = p_HRME_Id 
        AND "HME"."HRME_LeftFlag" = 0 
        AND "HME"."HRME_ActiveFlag" = 1;

END;
$$;