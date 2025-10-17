CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_EMPLOYEEDETAILS"(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMDES_Id" BIGINT,
    "HRME_EmployeeFirstName" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_Perstreet" VARCHAR,
    "HRME_PerArea" VARCHAR,
    "HRME_PerCity" VARCHAR,
    "HRME_PerAdd4" VARCHAR,
    "HRME_PerStateId" BIGINT,
    "HRME_PerCountryId" BIGINT,
    "HRME_PerPincode" VARCHAR,
    "HRME_DOB" TIMESTAMP,
    "HRME_DOJ" TIMESTAMP,
    "HRME_MobileNo" VARCHAR,
    "HRME_EmailId" VARCHAR,
    "HRME_BloodGroup" VARCHAR,
    "HRME_Photo" TEXT,
    "HRME_EmployeeOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        "HME"."HRME_Id",
        "HME"."HRMD_Id",
        "HME"."HRMDES_Id",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HME"."HRME_EmployeeFirstName" = '' THEN '' ELSE "HME"."HRME_EmployeeFirstName" END ||
         CASE WHEN "HME"."HRME_EmployeeMiddleName" IS NULL OR "HME"."HRME_EmployeeMiddleName" = '' OR "HME"."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HME"."HRME_EmployeeMiddleName" END ||
         CASE WHEN "HME"."HRME_EmployeeLastName" IS NULL OR "HME"."HRME_EmployeeLastName" = '' OR "HME"."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HME"."HRME_EmployeeLastName" END)::TEXT AS "HRME_EmployeeFirstName",
        "HME"."HRME_EmployeeCode",
        "HMD"."HRMD_DepartmentName",
        "HMDS"."HRMDES_DesignationName",
        "HME"."HRME_Perstreet",
        "HME"."HRME_PerArea",
        "HME"."HRME_PerCity",
        "HME"."HRME_PerAdd4",
        "HME"."HRME_PerStateId",
        "HME"."HRME_PerCountryId",
        "HME"."HRME_PerPincode",
        "HME"."HRME_DOB",
        "HME"."HRME_DOJ",
        "HME"."HRME_MobileNo",
        "HME"."HRME_EmailId",
        "HME"."HRME_BloodGroup",
        "HME"."HRME_Photo",
        "HME"."HRME_EmployeeOrder"
    FROM "HR_Master_Employee" "HME"
    INNER JOIN "HR_Master_Department" "HMD" ON "HME"."HRMD_Id" = "HMD"."HRMD_Id"
    INNER JOIN "HR_Master_Designation" "HMDS" ON "HMDS"."HRMDES_Id" = "HME"."HRMDES_Id"
    WHERE "HME"."HRME_ActiveFlag" = 1 
        AND "HMD"."HRMD_ActiveFlag" = 1 
        AND "HMDS"."HRMDES_ActiveFlag" = 1 
        AND "HME"."MI_Id" = "MI_Id" 
        AND "HME"."HRME_Id" = "HRME_Id"
    ORDER BY "HME"."HRME_EmployeeOrder";
END;
$$;