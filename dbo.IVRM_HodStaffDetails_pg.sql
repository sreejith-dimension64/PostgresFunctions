CREATE OR REPLACE FUNCTION "dbo"."IVRM_HodStaffDetails"(@MI_Id bigint)
RETURNS TABLE(
    "ihoD_Id" bigint,
    "ihoD_ActiveFlag" boolean,
    "ihodS_ActiveFlag" boolean,
    "HOD" bigint,
    "HodName" text,
    "ihodS_Id" bigint,
    "Staff" bigint,
    "StaffName" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "H"."IHOD_Id" as "ihoD_Id",
        "H"."IHOD_ActiveFlag" as "ihoD_ActiveFlag",
        "S"."IHODS_ActiveFlag" as "ihodS_ActiveFlag",
        "H"."HRME_Id" AS "HOD",
        (SELECT CONCAT("HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName") 
         FROM "HR_Master_Employee" 
         WHERE "HRME_Id" = "H"."HRME_Id" AND "MI_Id" = @MI_Id) AS "HodName",
        "S"."IHODS_Id" as "ihodS_Id",
        "S"."HRME_Id" AS "Staff",
        (SELECT CONCAT("HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName") 
         FROM "HR_Master_Employee" 
         WHERE "HRME_Id" = "S"."HRME_Id" AND "MI_Id" = @MI_Id) AS "StaffName"
    FROM "IVRM_HOD_Staff" "S"
    INNER JOIN "IVRM_HOD" "H" ON "H"."IHOD_Id" = "S"."IHOD_Id" 
    WHERE "H"."MI_Id" = @MI_Id;
END;
$$;