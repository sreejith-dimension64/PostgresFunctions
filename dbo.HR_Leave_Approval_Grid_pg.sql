CREATE OR REPLACE FUNCTION "HR_Leave_Approval_Grid"(@id bigint)
RETURNS TABLE (
    "hrmE_Id" bigint,
    "EmployeeName" text,
    "hrelT_Id" bigint,
    "hrmL_LeaveName" text,
    "hrelT_FromDate" timestamp,
    "hrelT_ToDate" timestamp,
    "hrelT_TotDays" numeric,
    "hrmE_EmployeeCode" text,
    "hrelaP_ApplicationDate" timestamp,
    "hrelT_Status" text,
    "hrelaP_Id" bigint,
    "hrelaP_LeaveReason" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."hrmE_Id",
        COALESCE(e."HRME_EmployeeFirstName", '') || ' ' || COALESCE(e."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(e."HRME_EmployeeLastName", '') as "EmployeeName",
        g."hrelT_Id",
        f."hrmL_LeaveName",
        g."hrelT_FromDate",
        g."hrelT_ToDate",
        g."hrelT_TotDays",
        e."hrmE_EmployeeCode",
        c."hrelaP_ApplicationDate",
        g."hrelT_Status",
        c."hrelaP_Id",
        c."hrelaP_LeaveReason"
    FROM "ivrm_Staff_User_Login" a 
    INNER JOIN "HR_Leave_Auth_OrderNo" b ON a."id" = b."IVRMUL_Id"
    INNER JOIN "HR_Emp_Leave_Application" c ON c."HRME_Id" = b."HRME_Id" AND c."HRELAP_ActiveFlag" = 1
    INNER JOIN "HR_Emp_Leave_Appl_Authorisation" d ON c."HRELAP_Id" = d."HRELAP_Id" AND b."HRLAON_SanctionLevelNo" = d."HRELAPA_SanctioningLevel"
    INNER JOIN "HR_Master_Employee" e ON c."HRME_Id" = e."HRME_Id" AND e."HRME_ActiveFlag" = 1 AND e."HRME_LeftFlag" = 0
    INNER JOIN "HR_Master_Leave" f ON e."MI_Id" = f."MI_Id"
    INNER JOIN "HR_Emp_Leave_Trans" g ON g."MI_Id" = f."MI_Id" AND g."HRELT_FromDate" = c."HRELAP_FromDate" AND g."HRELT_ToDate" = c."HRELAP_ToDate" AND g."HRELT_ActiveFlag" = 1 AND g."HRME_Id" = c."HRME_Id" AND g."HRELT_LeaveId" = f."HRML_Id"
    WHERE a."Id" = @id
    ORDER BY g."HRELT_FromDate" DESC, g."HRELT_ToDate" DESC;
END;
$$;