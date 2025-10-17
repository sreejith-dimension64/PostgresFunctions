CREATE OR REPLACE FUNCTION "HR_Employee_Leave_Delete"(p_HRELAP_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id bigint;
    v_HRELT_Id bigint;
    v_HRELAP_FromDate timestamp;
    v_HRELAP_ToDate timestamp;
BEGIN
    
    SELECT "HRME_Id", "HRELAP_FromDate"::date, "HRELAP_ToDate"::date
    INTO v_HRME_Id, v_HRELAP_FromDate, v_HRELAP_ToDate
    FROM "HR_Emp_Leave_Application" 
    WHERE "HRELAP_ApplicationStatus" = 'Applied' 
    AND "HRELAP_Id" = p_HRELAP_Id;

    DELETE FROM "HR_Emp_Leave_Appl_Details" 
    WHERE "HRELAPD_LeaveStatus" = 'Applied' 
    AND "HRELAP_Id" = p_HRELAP_Id;

    DELETE FROM "HR_Emp_Leave_Application" 
    WHERE "HRELAP_ApplicationStatus" = 'Applied' 
    AND "HRME_Id" = v_HRME_Id 
    AND "HRELAP_Id" = p_HRELAP_Id;

    SELECT "HRELT_Id" 
    INTO v_HRELT_Id
    FROM "HR_Emp_Leave_Trans" 
    WHERE "hrme_id" = v_HRME_Id 
    AND "HRELT_Status" = 'Applied' 
    AND "HRELT_FromDate"::date = v_HRELAP_FromDate::date 
    AND "HRELT_ToDate"::date = v_HRELAP_ToDate::date;

    DELETE FROM "HR_Emp_Leave_Trans_Details" 
    WHERE "hrme_id" = v_HRME_Id 
    AND "HRELT_Id" = v_HRELT_Id;

    DELETE FROM "HR_Emp_Leave_Trans" 
    WHERE "hrme_id" = v_HRME_Id 
    AND "HRELT_Status" = 'Applied' 
    AND "HRELT_Id" = v_HRELT_Id;

    RETURN;
END;
$$;