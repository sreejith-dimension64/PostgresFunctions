CREATE OR REPLACE FUNCTION "dbo"."APPOINTMENT_APPROVAL_STATUS_REPORT_IVRM"(
    "MI_Id" TEXT,
    "fromdate" TEXT,
    "todate" TEXT,
    "months" TEXT,
    "radiotype" VARCHAR(50)
)
RETURNS TABLE(
    empname TEXT,
    "VMAP_VisitorName" TEXT,
    "VMAP_VisitorContactNo" TEXT,
    "VMAP_VisitorEmailid" TEXT,
    "VMAP_FromPlace" TEXT,
    "VMAP_FromAddress" TEXT,
    "VMAP_MeetingDateTime" TIMESTAMP,
    "VMAP_MeetingPurpose" TEXT,
    "VMAP_VisitTypeFlg" TEXT,
    "VMAP_MeetingTiming" TEXT,
    "VMAP_HRME_Id" BIGINT,
    "VMAP_MeetingToTime" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic TEXT;
    "ASMAY_Id" TEXT;
    content TEXT;
    content2 TEXT;
BEGIN

    IF "fromdate" != '' AND "todate" != '' THEN
        content := 'and "VMAP_MeetingDateTime"::date between ''' || "fromdate" || '''::date and ''' || "todate" || '''::date';
    ELSE
        content := '';
    END IF;

    IF "months" != '' THEN
        content2 := 'And EXTRACT(MONTH FROM "VMAP_MeetingDateTime") = ''' || "months" || '''';
    ELSE
        content2 := '';
    END IF;

    IF ("radiotype" = 'Approved' OR "radiotype" = 'Rejected' OR "radiotype" = 'Canceled') THEN
        sqldynamic := '
        SELECT 
        COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') as empname,
        "VMAP_VisitorName","VMAP_VisitorContactNo","VMAP_VisitorEmailid","VMAP_FromPlace","VMAP_FromAddress","VMAP_MeetingDateTime","VMAP_MeetingPurpose","VMAP_VisitTypeFlg",
        TO_CHAR("VMAP_MeetingTiming"::TIME, ''HH12:MI AM'') as "VMAP_MeetingTiming",
        "VMAP_HRME_Id",
        TO_CHAR("VMAP_MeetingToTime"::TIME, ''HH12:MI AM'') as "VMAP_MeetingToTime"
        FROM "VM"."Visitor_Management_Appointment" a 
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."VMAP_HRME_Id"
        WHERE a."MI_Id"::TEXT IN (' || "MI_Id" || ') AND "VMAP_Status" = ''' || "radiotype" || ''' ' || content || ' ' || content2 || ' 
        ORDER BY "VMAP_MeetingDateTime", "VMAP_MeetingTiming"';

    ELSIF "radiotype" = 'Checked In' THEN
        sqldynamic := '
        SELECT 
        COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') as empname,
        "VMAP_VisitorName","VMAP_VisitorContactNo","VMAP_VisitorEmailid","VMAP_FromPlace","VMAP_FromAddress","VMAP_MeetingDateTime","VMAP_MeetingPurpose","VMAP_VisitTypeFlg",
        TO_CHAR("VMAP_MeetingTiming"::TIME, ''HH12:MI AM'') as "VMAP_MeetingTiming",
        "VMAP_HRME_Id",
        TO_CHAR("VMAP_MeetingToTime"::TIME, ''HH12:MI AM'') as "VMAP_MeetingToTime"
        FROM "VM"."Visitor_Management_Appointment" a 
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."VMAP_HRME_Id"
        WHERE a."MI_Id"::TEXT IN (' || "MI_Id" || ') AND "VMAP_Status" = ''Approved'' AND a."VMAP_ChekInOutStatus" = ''Checked In'' ' || content || ' ' || content2 || ' ';

    ELSIF "radiotype" = 'Checked Out' THEN
        sqldynamic := '
        SELECT 
        COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') as empname,
        "VMAP_VisitorName","VMAP_VisitorContactNo","VMAP_VisitorEmailid","VMAP_FromPlace","VMAP_FromAddress","VMAP_MeetingDateTime","VMAP_MeetingPurpose","VMAP_VisitTypeFlg",
        TO_CHAR("VMAP_MeetingTiming"::TIME, ''HH12:MI AM'') as "VMAP_MeetingTiming",
        "VMAP_HRME_Id",
        TO_CHAR("VMAP_MeetingToTime"::TIME, ''HH12:MI AM'') as "VMAP_MeetingToTime"
        FROM "VM"."Visitor_Management_Appointment" a 
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."VMAP_HRME_Id"
        WHERE a."MI_Id"::TEXT IN (' || "MI_Id" || ') AND "VMAP_Status" = ''Approved'' AND a."VMAP_ChekInOutStatus" = ''Checked Out'' ' || content || ' ' || content2 || ' ';
    END IF;

    RETURN QUERY EXECUTE sqldynamic;

END;
$$;