CREATE OR REPLACE FUNCTION "HR_MASTER_EMP_DETAILS"(p_HRME_ID TEXT)
RETURNS TABLE(
    "HRME_EmployeeFirstName" VARCHAR,
    "HRME_DOJ" TIMESTAMP,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_Photo" TEXT,
    "HRMEM_EmailId" VARCHAR,
    "HRMEMNO_MobileNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMPLOYEE TEXT;
BEGIN
    v_EMPLOYEE := '
    SELECT a."HRME_EmployeeFirstName",a."HRME_DOJ",b."HRMDES_DesignationName",a."HRME_Photo",c."HRMEM_EmailId",d."HRMEMNO_MobileNo"
    FROM "HR_Master_Employee" a
    INNER JOIN "HR_Master_Designation" b ON a."HRMDES_Id" = b."HRMDES_Id"
    INNER JOIN "HR_Master_Employee_EmailId" c ON a."HRME_Id" = c."HRME_Id"
    INNER JOIN "HR_Master_Employee_MobileNo" d ON a."HRME_Id" = d."HRME_Id"
    WHERE a."HRME_Id" IN (''' || p_HRME_ID || ''')';
    
    RETURN QUERY EXECUTE v_EMPLOYEE;
END;
$$;