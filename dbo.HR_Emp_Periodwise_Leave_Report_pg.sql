CREATE OR REPLACE FUNCTION "HR_Emp_Periodwise_Leave_Report"(
    "p_status" VARCHAR(100),
    "p_fromdate" VARCHAR(50),
    "p_todate" VARCHAR(50),
    "p_HRME_id" VARCHAR(50)
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "OnleaveEmployeeName" TEXT,
    "HRMDES_DesignationName" TEXT,
    "HRELT_Status" VARCHAR,
    "HRELT_Reportingdate" TIMESTAMP,
    "HRELT_LeaveReason" TEXT,
    "HRELTD_TotDays" NUMERIC,
    "HRML_LeaveName" VARCHAR,
    "HRELAPDD_Period" VARCHAR,
    "HRME_Id_Approver" INTEGER,
    "ApproverEmployeeName" TEXT,
    "HRELAPDD_ApprovalFlg" BOOLEAN,
    "HRELAPDD_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
    "v_dates" TEXT;
BEGIN
    
    "v_dates" := ' and a."HRELT_FromDate"::date >= ''' || "p_fromdate" || '''::date and a."HRELT_ToDate"::date <= ''' || "p_todate" || '''::date';
    
    IF (UPPER("p_status") = 'ALL') THEN
        
        "v_sql" := '
        SELECT d."HRME_Id",
               COALESCE(d."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(d."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(d."HRME_EmployeeLastName",'''') as OnleaveEmployeeName,
               e."HRMDES_DesignationName",
               a."HRELT_Status",
               a."HRELT_Reportingdate",
               a."HRELT_LeaveReason",
               b."HRELTD_TotDays",
               c."HRML_LeaveName",
               f."HRELAPDD_Period",
               g."HRME_Id",
               COALESCE(g."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(g."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(g."HRME_EmployeeLastName",'''') as ApproverEmployeeName,
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
        WHERE a."HRELT_ActiveFlag" = 1 ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_sql";
        
    ELSE
        
        "v_sql" := '
        SELECT d."HRME_Id",
               COALESCE(d."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(d."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(d."HRME_EmployeeLastName",'''') as OnleaveEmployeeName,
               e."HRMDES_DesignationName",
               a."HRELT_Status",
               a."HRELT_Reportingdate",
               a."HRELT_LeaveReason",
               b."HRELTD_TotDays",
               c."HRML_LeaveName",
               f."HRELAPDD_Period",
               g."HRME_Id",
               COALESCE(g."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(g."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(g."HRME_EmployeeLastName",'''') as ApproverEmployeeName,
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
        WHERE a."HRELT_ActiveFlag" = 1 ' || "v_dates" || ' AND d."HRME_Id" IN (' || "p_HRME_id" || ') AND A."HRELT_Status" IN (''' || "p_status" || ''')';
        
        RETURN QUERY EXECUTE "v_sql";
        
    END IF;
    
    RETURN;
    
END;
$$;