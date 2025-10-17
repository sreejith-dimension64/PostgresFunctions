CREATE OR REPLACE FUNCTION "dbo"."Employee_details"(
    "MI_Id" TEXT,
    "HRME_ID" TEXT
)
RETURNS TABLE(
    "employeename" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRME_DOJ" TEXT,
    "HRME_MobileNo" TEXT,
    "HRME_AadharCardNo" TEXT,
    "HRME_PANCardNo" TEXT,
    "HRME_EmailId" TEXT,
    "HRMEMNO_MobileNo" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "MI_Name" VARCHAR,
    "HRME_LeftFlag" VARCHAR,
    "HRME_DOL" TIMESTAMP,
    "HRME_LeavingReason" TEXT,
    "HRME_Photo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "dynamic" TEXT;
BEGIN
    
    "dynamic" := 'SELECT COALESCE("HRME_EmployeeFirstName",'''') || '' '' || COALESCE("HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("HRME_EmployeeLastName",'''') AS employeename,
                         "HRME_EmployeeCode",
                         COALESCE("HRME_DOJ"::TEXT,'''') AS "HRME_DOJ",
                         COALESCE("HRME_MobileNo",'''') AS "HRME_MobileNo",
                         COALESCE("HRME_AadharCardNo",'''') AS "HRME_AadharCardNo",
                         COALESCE("HRME_PANCardNo",'''') AS "HRME_PANCardNo",
                         COALESCE("HRMEM_EmailId",'''') AS "HRME_EmailId",
                         "HRMEMNO_MobileNo",
                         "HRMD_DepartmentName",
                         "HRMDES_DesignationName",
                         "MI_Name",
                         "HRME_LeftFlag",
                         "HRME_DOL",
                         "HRME_LeavingReason",
                         "HRME_Photo"
                  FROM "HR_MAster_Employee" a
                  LEFT JOIN "hr_master_employee_emailid" b ON a."HRME_ID" = b."HRME_ID" AND "HRMEM_DeFaultFlag" = ''Default''
                  INNER JOIN "HR_Master_Department" c ON a."HRMD_Id" = c."HRMD_Id"
                  INNER JOIN "HR_Master_Designation" d ON a."HRMDES_Id" = d."HRMDES_Id"
                  INNER JOIN "Master_Institution" e ON a."MI_Id" = e."MI_Id"
                  LEFT JOIN "HR_Master_Employee_MobileNo" f ON a."HRME_ID" = f."HRME_ID" AND "HRMEMNO_DeFaultFlag" = ''default''
                  WHERE a."HRME_ID" IN (''' || "HRME_ID" || ''')';
    
    RAISE NOTICE '%', "dynamic";
    
    RETURN QUERY EXECUTE "dynamic";
    
END;
$$;