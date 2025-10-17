CREATE OR REPLACE FUNCTION "dbo"."GET_VISITORS_FOR_APPROVAL_NEW_IVRM"(
    p_USER_ID bigint,
    p_ROLE TEXT,
    p_MI_Id bigint
)
RETURNS TABLE(
    "mI_Id" bigint,
    "MI_Name" VARCHAR,
    "VMAP_Id" bigint,
    "VMAP_VisitorName" VARCHAR,
    "VMAP_VisitTypeFlg" VARCHAR,
    "VMAP_ToMeet" VARCHAR,
    "VMAP_EntryDateTime" TIMESTAMP,
    "VMAP_FromPlace" VARCHAR,
    "VMAP_Status" VARCHAR,
    "VMAP_MeetingPurpose" TEXT,
    "FCNT" bigint,
    "VMAP_MeetingLocation" VARCHAR,
    "hrmE_Id" bigint,
    "hrmE_EmployeeFirstName" TEXT,
    "VMAP_MeetingTiming" TIME,
    "VMAP_MeetingDateTime" TIMESTAMP,
    "VMAP_VisitorContactNo" VARCHAR,
    "VMAP_VisitorEmailid" VARCHAR,
    "VMAP_MeetingTiming1" VARCHAR,
    "VMAP_MeetingToTime1" VARCHAR,
    "VMAP_MeetingToTime" TIME,
    "VMAP_Remarks" TEXT,
    "createdby" TEXT,
    "VMAP_RequestFromTime" VARCHAR,
    "VMAP_RequestToTime" VARCHAR,
    "LoginDate" DATE,
    "LoginTime" TIME,
    "LoginTime1" VARCHAR,
    "VMAP_FromAddress" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_ROLE = 'COORDINATOR' OR p_ROLE = 'ADMIN' OR p_ROLE = 'HR' THEN
    
        RETURN QUERY
        SELECT DISTINCT  
            A."MI_Id" as "mI_Id",
            B."MI_Name",
            A."VMAP_Id",
            A."VMAP_VisitorName",
            A."VMAP_VisitTypeFlg",
            A."VMAP_ToMeet",
            A."VMAP_EntryDateTime",
            A."VMAP_FromPlace",
            A."VMAP_Status",
            A."VMAP_MeetingPurpose",
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = A."VMAP_Id")::"FCNT",
            A."VMAP_MeetingLocation",
            C."HRME_Id" as "hrmE_Id",
            (COALESCE(C."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(C."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(C."HRME_EmployeeLastName", ' ')) AS "hrmE_EmployeeFirstName",
            A."VMAP_MeetingTiming",
            A."VMAP_MeetingDateTime",
            A."VMAP_VisitorContactNo",
            A."VMAP_VisitorEmailid",
            TO_CHAR(A."VMAP_MeetingTiming", 'HH12:MI AM')::"VMAP_MeetingTiming1",
            TO_CHAR(A."VMAP_MeetingToTime", 'HH12:MI AM')::"VMAP_MeetingToTime1",
            A."VMAP_MeetingToTime",
            A."VMAP_Remarks",
            (SELECT DISTINCT 
                CASE WHEN assi."HRME_Id" IS NULL THEN AU."UserName"
                ELSE (CASE WHEN assi."HRME_EmployeeFirstName" IS NULL OR assi."HRME_EmployeeFirstName" = '' THEN '' ELSE assi."HRME_EmployeeFirstName" END ||
                      CASE WHEN assi."HRME_EmployeeMiddleName" IS NULL OR assi."HRME_EmployeeMiddleName" = '' OR assi."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || assi."HRME_EmployeeMiddleName" END ||
                      CASE WHEN assi."HRME_EmployeeLastName" IS NULL OR assi."HRME_EmployeeLastName" = '' OR assi."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || assi."HRME_EmployeeLastName" END) END
            FROM "ApplicationUser" AU 
            LEFT JOIN "IVRM_Staff_User_Login" UL ON UL."id" = AU."id" 
            LEFT JOIN "HR_Master_Employee" assi ON UL."Emp_Code" = assi."HRME_Id"
            LEFT JOIN "VM"."Visitor_Management_Appointment" AP ON AP."VMAP_HRME_Id" = assi."HRME_Id" AND AP."VMAP_Id" = A."VMAP_Id"
            WHERE (assi."HRME_Id" = C."HRME_Id" OR AU."id" = A."VMAP_CreatedBy")
            LIMIT 1) as "createdby",
            TO_CHAR(A."VMAP_RequestFromTime", 'HH12:MI AM')::"VMAP_RequestFromTime",
            TO_CHAR(A."VMAP_RequestToTime", 'HH12:MI AM')::"VMAP_RequestToTime",
            A."createdDate"::date as "LoginDate",
            A."CreatedDate"::time(0) AS "LoginTime",
            TO_CHAR(A."CreatedDate"::time(0), 'HH12:MI AM')::"LoginTime1",
            A."VMAP_FromAddress"
        FROM "VM"."Visitor_Management_Appointment" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "HR_Master_Employee" AS C ON C."HRME_Id" = A."VMAP_HRME_Id"
        WHERE B."MI_ActiveFlag" = 1 
            AND A."VMAP_Status" = 'Waiting' 
            AND A."VMAP_ActiveFlag" = 1 
            AND A."MI_Id" = p_MI_Id;

    ELSIF p_ROLE = '' THEN
    
        RETURN QUERY
        SELECT DISTINCT  
            A."MI_Id" as "mI_Id",
            B."MI_Name",
            A."VMAP_Id",
            A."VMAP_VisitorName",
            A."VMAP_VisitTypeFlg",
            A."VMAP_ToMeet",
            A."VMAP_EntryDateTime",
            A."VMAP_FromPlace",
            A."VMAP_Status",
            A."VMAP_MeetingPurpose",
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = A."VMAP_Id")::"FCNT",
            A."VMAP_MeetingLocation",
            D."HRME_Id" as "hrmE_Id",
            (COALESCE(D."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(D."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(D."HRME_EmployeeLastName", ' ')) AS "hrmE_EmployeeFirstName",
            A."VMAP_MeetingTiming",
            A."VMAP_MeetingDateTime",
            A."VMAP_VisitorContactNo",
            A."VMAP_VisitorEmailid",
            TO_CHAR(A."VMAP_MeetingTiming", 'HH12:MI AM')::"VMAP_MeetingTiming1",
            TO_CHAR(A."VMAP_MeetingToTime", 'HH12:MI AM')::"VMAP_MeetingToTime1",
            A."VMAP_MeetingToTime",
            A."VMAP_Remarks",
            (SELECT DISTINCT 
                CASE WHEN assi."HRME_Id" IS NULL THEN AU."UserName"
                ELSE (CASE WHEN assi."HRME_EmployeeFirstName" IS NULL OR assi."HRME_EmployeeFirstName" = '' THEN '' ELSE assi."HRME_EmployeeFirstName" END ||
                      CASE WHEN assi."HRME_EmployeeMiddleName" IS NULL OR assi."HRME_EmployeeMiddleName" = '' OR assi."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || assi."HRME_EmployeeMiddleName" END ||
                      CASE WHEN assi."HRME_EmployeeLastName" IS NULL OR assi."HRME_EmployeeLastName" = '' OR assi."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || assi."HRME_EmployeeLastName" END) END
            FROM "ApplicationUser" AU 
            LEFT JOIN "IVRM_Staff_User_Login" UL ON UL."id" = AU."id" 
            LEFT JOIN "HR_Master_Employee" assi ON UL."Emp_Code" = assi."HRME_Id"
            LEFT JOIN "VM"."Visitor_Management_Appointment" AP ON AP."VMAP_HRME_Id" = assi."HRME_Id" AND AP."VMAP_Id" = A."VMAP_Id"
            WHERE (assi."HRME_Id" = D."HRME_Id" OR AU."id" = A."VMAP_CreatedBy")
            LIMIT 1) as "createdby",
            TO_CHAR(A."VMAP_RequestFromTime", 'HH12:MI AM')::"VMAP_RequestFromTime",
            TO_CHAR(A."VMAP_RequestToTime", 'HH12:MI AM')::"VMAP_RequestToTime",
            A."createdDate"::date as "LoginDate",
            A."CreatedDate"::time(0) AS "LoginTime",
            TO_CHAR(A."CreatedDate"::time(0), 'HH12:MI AM')::"LoginTime1",
            A."VMAP_FromAddress"
        FROM "VM"."Visitor_Management_Appointment" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "IVRM_User_Login_Institutionwise" AS C ON C."MI_Id" = A."MI_Id" AND C."Id" = p_USER_ID AND C."Activeflag" = 1
        INNER JOIN "HR_Master_Employee" AS D ON D."HRME_Id" = A."VMAP_HRME_Id"
        WHERE B."MI_ActiveFlag" = 1 
            AND A."VMAP_Status" = 'Waiting' 
            AND A."VMAP_ActiveFlag" = 1 
            AND A."MI_Id" = p_MI_Id;

    ELSE
    
        RETURN QUERY
        SELECT DISTINCT  
            A."MI_Id" as "mI_Id",
            B."MI_Name",
            A."VMAP_Id",
            A."VMAP_VisitorName",
            A."VMAP_VisitTypeFlg",
            A."VMAP_ToMeet",
            A."VMAP_EntryDateTime",
            A."VMAP_FromPlace",
            A."VMAP_Status",
            A."VMAP_MeetingPurpose",
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = A."VMAP_Id")::"FCNT",
            A."VMAP_MeetingLocation",
            D."HRME_Id" as "hrmE_Id",
            (COALESCE(D."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(D."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(D."HRME_EmployeeLastName", ' ')) AS "hrmE_EmployeeFirstName",
            A."VMAP_MeetingTiming",
            A."VMAP_MeetingDateTime",
            A."VMAP_VisitorContactNo",
            A."VMAP_VisitorEmailid",
            TO_CHAR(A."VMAP_MeetingTiming", 'HH12:MI AM')::"VMAP_MeetingTiming1",
            TO_CHAR(A."VMAP_MeetingToTime", 'HH12:MI AM')::"VMAP_MeetingToTime1",
            A."VMAP_MeetingToTime",
            A."VMAP_Remarks",
            (SELECT DISTINCT 
                CASE WHEN assi."HRME_Id" IS NULL THEN AU."UserName"
                ELSE (CASE WHEN assi."HRME_EmployeeFirstName" IS NULL OR assi."HRME_EmployeeFirstName" = '' THEN '' ELSE assi."HRME_EmployeeFirstName" END ||
                      CASE WHEN assi."HRME_EmployeeMiddleName" IS NULL OR assi."HRME_EmployeeMiddleName" = '' OR assi."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || assi."HRME_EmployeeMiddleName" END ||
                      CASE WHEN assi."HRME_EmployeeLastName" IS NULL OR assi."HRME_EmployeeLastName" = '' OR assi."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || assi."HRME_EmployeeLastName" END) END
            FROM "ApplicationUser" AU 
            LEFT JOIN "IVRM_Staff_User_Login" UL ON UL."id" = AU."id" 
            LEFT JOIN "HR_Master_Employee" assi ON UL."Emp_Code" = assi."HRME_Id"
            LEFT JOIN "VM"."Visitor_Management_Appointment" AP ON AP."VMAP_HRME_Id" = assi."HRME_Id" AND AP."VMAP_Id" = A."VMAP_Id"
            WHERE (assi."HRME_Id" = D."HRME_Id" OR AU."id" = A."VMAP_CreatedBy")
            LIMIT 1) as "createdby",
            TO_CHAR(A."VMAP_RequestFromTime", 'HH12:MI AM')::"VMAP_RequestFromTime",
            TO_CHAR(A."VMAP_RequestToTime", 'HH12:MI AM')::"VMAP_RequestToTime",
            A."createdDate"::date as "LoginDate",
            A."CreatedDate"::time(0) AS "LoginTime",
            TO_CHAR(A."CreatedDate"::time(0), 'HH12:MI AM')::"LoginTime1",
            A."VMAP_FromAddress"
        FROM "VM"."Visitor_Management_Appointment" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "IVRM_User_Login_Institutionwise" AS C ON C."MI_Id" = A."MI_Id" AND C."Id" = p_USER_ID AND C."Activeflag" = 1
        INNER JOIN "HR_Master_Employee" AS D ON D."HRME_Id" = A."VMAP_HRME_Id"
        WHERE B."MI_ActiveFlag" = 1 
            AND A."VMAP_Status" = 'Waiting' 
            AND A."VMAP_ActiveFlag" = 1 
            AND A."MI_Id" = p_MI_Id;

    END IF;

    RETURN;

END;
$$;