CREATE OR REPLACE FUNCTION "HR_MASTER_LEAVE_APPLICATION_DETAILS"(
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10),
    p_HRME_ID TEXT
)
RETURNS TABLE(
    empname TEXT,
    "HRELAP_FromDate" TIMESTAMP,
    "HRELAP_ToDate" TIMESTAMP,
    "HRELAP_ApplicationStatus" VARCHAR,
    "HRELAPD_InTime" TIME,
    "HRELAPD_OutTime" TIME,
    "HRML_LeaveName" VARCHAR,
    "HRML_LeaveCode" VARCHAR,
    "HRELAPA_SanctioningLevel" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_LEAVE TEXT;
    v_query TEXT;
BEGIN
    v_LEAVE := '
    SELECT CONCAT(COALESCE("E"."HRME_EmployeeFirstName",''''),'' '',COALESCE("E"."HRME_EmployeeMiddleName",''''),'' '',COALESCE("E"."HRME_EmployeeLastName",'''')) as empname, 
    "A"."HRELAP_FromDate",
    "A"."HRELAP_ToDate",
    "A"."HRELAP_ApplicationStatus",
    "B"."HRELAPD_InTime",
    "B"."HRELAPD_OutTime",
    "C"."HRML_LeaveName",
    "C"."HRML_LeaveCode",
    "D"."HRELAPA_SanctioningLevel"    
    FROM "HR_Emp_Leave_Application" "A"
    INNER JOIN "HR_Emp_Leave_Appl_Details" "B"    
    ON "A"."HRELAP_Id" = "B"."HRELAP_Id"    
    INNER JOIN "HR_Master_Leave" "C" ON "C"."HRML_Id" = "B"."HRML_Id"    
    INNER JOIN "HR_Emp_Leave_Appl_Authorisation" "D" ON "D"."HRELAP_Id" = "A"."HRELAP_Id"    
    INNER JOIN "HR_Master_Employee" "E" ON "E"."HRME_Id" = "A"."HRME_Id"    
    WHERE "A"."HRME_Id" IN (' || p_HRME_ID || ') 
    AND CAST("A"."HRELAP_FromDate" AS DATE) = ''' || p_fromdate || ''' 
    AND CAST("A"."HRELAP_ToDate" AS DATE) = ''' || p_todate || '''';
    
    RAISE NOTICE '%', v_LEAVE;
    
    RETURN QUERY EXECUTE v_LEAVE;
END;
$$;