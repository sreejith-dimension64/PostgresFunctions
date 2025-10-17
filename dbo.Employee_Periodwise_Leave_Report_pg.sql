CREATE OR REPLACE FUNCTION "Employee_Periodwise_Leave_Report"(
    "@status" VARCHAR(100),
    "@fromdate" VARCHAR(50),
    "@todate" VARCHAR(50),
    "@HRME_id" VARCHAR(10)
)
RETURNS TABLE(
    "HRME_Id" VARCHAR,
    "OnleaveEmployeeName" TEXT,
    "HRMDES_DesignationName" VARCHAR,
    "HRELT_Status" VARCHAR,
    "HRELT_Reportingdate" TIMESTAMP,
    "HRELT_LeaveReason" TEXT,
    "HRELTD_TotDays" NUMERIC,
    "HRML_LeaveName" VARCHAR,
    "HRELAPDD_Period" VARCHAR,
    "HRME_Id_Approver" VARCHAR,
    "ApproverEmployeeName" TEXT,
    "HRELAPDD_ApprovalFlg" VARCHAR,
    "HRELAPDD_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql1 TEXT;
    v_sql2 TEXT;
    v_sql3 TEXT;
    v_dates TEXT;
BEGIN

    v_dates := 'and a."HRELT_FromDate"::date >= ''' || "@fromdate" || '''::date and a."HRELT_ToDate"::date <= ''' || "@todate" || '''::date';
    
    RAISE NOTICE '%', v_dates;

    IF ("@status" = 'Approved') THEN
        
        v_sql2 := '
        SELECT d."HRME_Id",
               COALESCE(d."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(d."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(d."HRME_EmployeeLastName",'''') as "OnleaveEmployeeName",
               e."HRMDES_DesignationName",
               a."HRELT_Status",
               a."HRELT_Reportingdate",
               a."HRELT_LeaveReason",
               b."HRELTD_TotDays",
               c."HRML_LeaveName",
               f."HRELAPDD_Period",
               g."HRME_Id" as "HRME_Id_Approver",
               COALESCE(g."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(g."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(g."HRME_EmployeeLastName",'''') as "ApproverEmployeeName",
               f."HRELAPDD_ApprovalFlg",
               f."HRELAPDD_Remarks"
        FROM "HR_Emp_Leave_Trans" a 
        INNER JOIN "HR_Emp_Leave_Trans_Details" b ON a."HRELT_Id" = b."HRELT_Id"
        INNER JOIN "HR_Master_Leave" c ON c."HRML_Id" = b."HRML_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id" AND d."HRME_ActiveFlag" = 1 AND d."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Designation" e ON e."HRMDES_Id" = d."HRMDES_Id"
        INNER JOIN "HR_Emp_Leave_Application" l ON l."HRME_Id" = d."HRME_Id"
        INNER JOIN "HR_Emp_Leave_Appl_Details" k ON k."HRELAP_Id" = l."HRELAP_Id"
        INNER JOIN "HR_Emp_Leave_Application_Deputation" f ON f."HRELAPD_Id" = k."HRELAPD_Id"
        INNER JOIN "HR_Master_Employee" g ON g."HRME_Id" = f."HRME_Id" AND g."HRME_ActiveFlag" = 1 AND g."HRME_LeftFlag" = 0
        WHERE a."HRELT_ActiveFlag" = 1 ' || v_dates || ' AND d."HRME_Id" IN (' || "@HRME_id" || ') AND a."HRELT_Status" IN (''' || "@status" || ''')';
        
        RAISE NOTICE '%', v_sql2;
        
        RETURN QUERY EXECUTE v_sql2;
        
    END IF;
    
    RETURN;
    
END;
$$;