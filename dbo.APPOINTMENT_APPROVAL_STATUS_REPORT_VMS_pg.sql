CREATE OR REPLACE FUNCTION "dbo"."APPOINTMENT_APPROVAL_STATUS_REPORT_VMS"(
    p_MI_Id TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_months TEXT,
    p_radiotype VARCHAR(50)
)
RETURNS TABLE(
    "empname" TEXT,
    "VMAP_VisitorName" VARCHAR,
    "VMAP_VisitorContactNo" VARCHAR,
    "VMAP_VisitorEmailid" VARCHAR,
    "VMAP_FromPlace" VARCHAR,
    "VMAP_FromAddress" VARCHAR,
    "VMAP_MeetingDateTime" TIMESTAMP,
    "VMAP_MeetingPurpose" TEXT,
    "VMAP_VisitTypeFlg" VARCHAR,
    "VMAP_HRME_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_content TEXT;
    v_content2 TEXT;
BEGIN
    -- Handle date range filter
    IF p_fromdate != '' AND p_todate != '' THEN
        v_content := 'AND CAST(a."VMAP_MeetingDateTime" AS DATE) BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''';
    ELSE
        v_content := '';
    END IF;

    -- Handle month filter
    IF p_months != '' THEN
        v_content2 := 'AND EXTRACT(MONTH FROM a."VMAP_MeetingDateTime") = ' || p_months;
    ELSE
        v_content2 := '';
    END IF;

    -- Build dynamic query based on radio type
    IF (p_radiotype = 'Approved' OR p_radiotype = 'Rejected') THEN
        v_sqldynamic := '
        SELECT 
            COALESCE(e."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(e."HRME_EmployeeLastName", '''') as empname,
            a."VMAP_VisitorName",
            a."VMAP_VisitorContactNo",
            a."VMAP_VisitorEmailid",
            a."VMAP_FromPlace",
            a."VMAP_FromAddress",
            a."VMAP_MeetingDateTime",
            a."VMAP_MeetingPurpose",
            a."VMAP_VisitTypeFlg",
            a."VMAP_HRME_Id"
        FROM "VM"."Visitor_Management_Appointment" a 
        INNER JOIN "VM"."Visitor_Management_Visitor_Appointment" b ON a."VMAP_Id" = b."VMAP_Id"
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."VMAP_HRME_Id"
        WHERE a."MI_Id" IN (' || p_MI_Id || ') AND a."VMAP_Status" = ''' || p_radiotype || ''' ' || v_content || ' ' || v_content2;

    ELSIF p_radiotype = 'Checked In' THEN
        v_sqldynamic := '
        SELECT 
            COALESCE(e."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(e."HRME_EmployeeLastName", '''') as empname,
            a."VMAP_VisitorName",
            a."VMAP_VisitorContactNo",
            a."VMAP_VisitorEmailid",
            a."VMAP_FromPlace",
            a."VMAP_FromAddress",
            a."VMAP_MeetingDateTime",
            a."VMAP_MeetingPurpose",
            a."VMAP_VisitTypeFlg",
            a."VMAP_HRME_Id"
        FROM "VM"."Visitor_Management_Appointment" a 
        INNER JOIN "VM"."Visitor_Management_Visitor_Appointment" b ON a."VMAP_Id" = b."VMAP_Id"
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."VMAP_HRME_Id"
        WHERE a."MI_Id" IN (' || p_MI_Id || ') AND a."VMAP_Status" = ''Approved'' AND a."VMAP_ChekInOutStatus" = ''Checked In'' ' || v_content || ' ' || v_content2;

    ELSIF p_radiotype = 'Checked Out' THEN
        v_sqldynamic := '
        SELECT 
            COALESCE(e."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(e."HRME_EmployeeLastName", '''') as empname,
            a."VMAP_VisitorName",
            a."VMAP_VisitorContactNo",
            a."VMAP_VisitorEmailid",
            a."VMAP_FromPlace",
            a."VMAP_FromAddress",
            a."VMAP_MeetingDateTime",
            a."VMAP_MeetingPurpose",
            a."VMAP_VisitTypeFlg",
            a."VMAP_HRME_Id"
        FROM "VM"."Visitor_Management_Appointment" a 
        INNER JOIN "VM"."Visitor_Management_Visitor_Appointment" b ON a."VMAP_Id" = b."VMAP_Id"
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."VMAP_HRME_Id"
        WHERE a."MI_Id" IN (' || p_MI_Id || ') AND a."VMAP_Status" = ''Approved'' AND a."VMAP_ChekInOutStatus" = ''Checked Out'' ' || v_content || ' ' || v_content2;
    END IF;

    -- Execute dynamic query and return results
    RETURN QUERY EXECUTE v_sqldynamic;
END;
$$;