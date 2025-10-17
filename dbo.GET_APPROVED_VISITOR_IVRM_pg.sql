CREATE OR REPLACE FUNCTION "dbo"."GET_APPROVED_VISITOR_IVRM"(
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
    "VMAP_RequestFromTime" VARCHAR,
    "VMAP_RequestToTime" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_ROLE = 'COORDINATOR' OR p_ROLE = 'ADMIN' OR p_ROLE = 'HR' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            "A"."MI_Id" as "mI_Id",
            "B"."MI_Name",
            "A"."VMAP_Id",
            "A"."VMAP_VisitorName",
            "A"."VMAP_VisitTypeFlg",
            "A"."VMAP_ToMeet",
            "A"."VMAP_EntryDateTime",
            "A"."VMAP_FromPlace",
            "A"."VMAP_Status",
            "A"."VMAP_MeetingPurpose",
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = "A"."VMAP_Id") AS "FCNT",
            "A"."VMAP_MeetingLocation",
            "C"."HRME_Id" AS "hrmE_Id",
            COALESCE("C"."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE("C"."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE("C"."HRME_EmployeeLastName", ' ') AS "hrmE_EmployeeFirstName",
            "A"."VMAP_MeetingTiming",
            "A"."VMAP_MeetingDateTime",
            "A"."VMAP_VisitorContactNo",
            "A"."VMAP_VisitorEmailid",
            TO_CHAR("A"."VMAP_MeetingTiming"::TIME, 'HH12:MI AM') AS "VMAP_MeetingTiming1",
            TO_CHAR("A"."VMAP_MeetingToTime"::TIME, 'HH12:MI AM') AS "VMAP_MeetingToTime1",
            "A"."VMAP_MeetingToTime",
            "A"."VMAP_Remarks",
            TO_CHAR("A"."VMAP_RequestFromTime"::TIME, 'HH12:MI AM') AS "VMAP_RequestFromTime",
            TO_CHAR("A"."VMAP_RequestToTime"::TIME, 'HH12:MI AM') AS "VMAP_RequestToTime"
        FROM "VM"."Visitor_Management_Appointment" AS "A"
        INNER JOIN "Master_Institution" AS "B" ON "B"."MI_Id" = "A"."MI_Id"
        INNER JOIN "HR_Master_Employee" AS "C" ON "C"."HRME_Id" = "A"."VMAP_HRME_Id"
        WHERE "B"."MI_ActiveFlag" = 1 
            AND "A"."VMAP_Status" = 'Approved' 
            AND "A"."VMAP_ActiveFlag" = 1 
            AND "A"."MI_Id" = p_MI_Id 
        ORDER BY "A"."VMAP_MeetingDateTime" DESC;
    
    ELSIF p_ROLE = '' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            "A"."MI_Id" as "mI_Id",
            "B"."MI_Name",
            "A"."VMAP_Id",
            "A"."VMAP_VisitorName",
            "A"."VMAP_VisitTypeFlg",
            "A"."VMAP_ToMeet",
            "A"."VMAP_EntryDateTime",
            "A"."VMAP_FromPlace",
            "A"."VMAP_Status",
            "A"."VMAP_MeetingPurpose",
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = "A"."VMAP_Id") AS "FCNT",
            "A"."VMAP_MeetingLocation",
            "C"."HRME_Id" AS "hrmE_Id",
            COALESCE("C"."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE("C"."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE("C"."HRME_EmployeeLastName", ' ') AS "hrmE_EmployeeFirstName",
            "A"."VMAP_MeetingTiming",
            "A"."VMAP_MeetingDateTime",
            "A"."VMAP_VisitorContactNo",
            "A"."VMAP_VisitorEmailid",
            TO_CHAR("A"."VMAP_MeetingTiming"::TIME, 'HH12:MI AM') AS "VMAP_MeetingTiming1",
            TO_CHAR("A"."VMAP_MeetingToTime"::TIME, 'HH12:MI AM') AS "VMAP_MeetingToTime1",
            "A"."VMAP_MeetingToTime",
            "A"."VMAP_Remarks",
            TO_CHAR("A"."VMAP_RequestFromTime"::TIME, 'HH12:MI AM') AS "VMAP_RequestFromTime",
            TO_CHAR("A"."VMAP_RequestToTime"::TIME, 'HH12:MI AM') AS "VMAP_RequestToTime"
        FROM "VM"."Visitor_Management_Appointment" AS "A"
        INNER JOIN "Master_Institution" AS "B" ON "B"."MI_Id" = "A"."MI_Id"
        INNER JOIN "IVRM_User_Login_Institutionwise" AS "D" ON "D"."MI_Id" = "A"."MI_Id" AND "D"."Id" = p_USER_ID AND "D"."Activeflag" = 1
        INNER JOIN "HR_Master_Employee" AS "C" ON "C"."HRME_Id" = "A"."VMAP_HRME_Id"
        WHERE "B"."MI_ActiveFlag" = 1 
            AND "A"."VMAP_Status" = 'Approved' 
            AND "A"."VMAP_ActiveFlag" = 1 
            AND "A"."MI_Id" = p_MI_Id 
        ORDER BY "A"."VMAP_MeetingDateTime" DESC;
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            "A"."MI_Id" as "mI_Id",
            "B"."MI_Name",
            "A"."VMAP_Id",
            "A"."VMAP_VisitorName",
            "A"."VMAP_VisitTypeFlg",
            "A"."VMAP_ToMeet",
            "A"."VMAP_EntryDateTime",
            "A"."VMAP_FromPlace",
            "A"."VMAP_Status",
            "A"."VMAP_MeetingPurpose",
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = "A"."VMAP_Id") AS "FCNT",
            "A"."VMAP_MeetingLocation",
            "C"."HRME_Id" AS "hrmE_Id",
            COALESCE("C"."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE("C"."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE("C"."HRME_EmployeeLastName", ' ') AS "hrmE_EmployeeFirstName",
            "A"."VMAP_MeetingTiming",
            "A"."VMAP_MeetingDateTime",
            "A"."VMAP_VisitorContactNo",
            "A"."VMAP_VisitorEmailid",
            TO_CHAR("A"."VMAP_MeetingTiming"::TIME, 'HH12:MI AM') AS "VMAP_MeetingTiming1",
            TO_CHAR("A"."VMAP_MeetingToTime"::TIME, 'HH12:MI AM') AS "VMAP_MeetingToTime1",
            "A"."VMAP_MeetingToTime",
            "A"."VMAP_Remarks",
            TO_CHAR("A"."VMAP_RequestFromTime"::TIME, 'HH12:MI AM') AS "VMAP_RequestFromTime",
            TO_CHAR("A"."VMAP_RequestToTime"::TIME, 'HH12:MI AM') AS "VMAP_RequestToTime"
        FROM "VM"."Visitor_Management_Appointment" AS "A"
        INNER JOIN "Master_Institution" AS "B" ON "B"."MI_Id" = "A"."MI_Id"
        INNER JOIN "IVRM_User_Login_Institutionwise" AS "D" ON "D"."MI_Id" = "A"."MI_Id" AND "D"."Id" = p_USER_ID AND "D"."Activeflag" = 1
        INNER JOIN "HR_Master_Employee" AS "C" ON "C"."HRME_Id" = "A"."VMAP_HRME_Id"
        WHERE "B"."MI_ActiveFlag" = 1 
            AND "A"."VMAP_Status" = 'Approved' 
            AND "A"."VMAP_ActiveFlag" = 1 
            AND "A"."MI_Id" = p_MI_Id 
        ORDER BY "A"."VMAP_MeetingDateTime" DESC;
    
    END IF;

    RETURN;

END;
$$;