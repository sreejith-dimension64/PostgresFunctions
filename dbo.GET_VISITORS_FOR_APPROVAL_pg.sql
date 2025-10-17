CREATE OR REPLACE FUNCTION "dbo"."GET_VISITORS_FOR_APPROVAL"(
    "USER_ID" bigint,
    "ROLE" TEXT
)
RETURNS TABLE(
    "mI_Id" bigint,
    "MI_Name" TEXT,
    "VMAP_Id" bigint,
    "VMAP_VisitorName" TEXT,
    "VMAP_VisitTypeFlg" TEXT,
    "VMAP_ToMeet" TEXT,
    "VMAP_EntryDateTime" TIMESTAMP,
    "VMAP_FromPlace" TEXT,
    "VMAP_Status" TEXT,
    "VMAP_MeetingPurpose" TEXT,
    "FCNT" bigint,
    "VMAP_MeetingLocation" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "ROLE" = 'COORDINATOR' OR "ROLE" = 'ADMIN' OR "ROLE" = 'HR' THEN
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
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = A."VMAP_Id")::"bigint" AS "FCNT",
            A."VMAP_MeetingLocation"
        FROM "VM"."Visitor_Management_Appointment" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        WHERE B."MI_ActiveFlag" = 1 
            AND A."VMAP_Status" = 'Waiting' 
            AND A."VMAP_ActiveFlag" = 1;
    
    ELSIF "ROLE" = '' THEN
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
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = A."VMAP_Id")::"bigint" AS "FCNT",
            A."VMAP_MeetingLocation"
        FROM "VM"."Visitor_Management_Appointment" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "IVRM_User_Login_Institutionwise" AS C ON C."MI_Id" = A."MI_Id" 
            AND C."Id" = "USER_ID" 
            AND C."Activeflag" = 1
        WHERE B."MI_ActiveFlag" = 1 
            AND A."VMAP_Status" = 'Waiting' 
            AND A."VMAP_ActiveFlag" = 1;
    
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
            (SELECT COUNT(*) FROM "VM"."Visitor_Management_Appointment_files" WHERE "VMAP_Id" = A."VMAP_Id")::"bigint" AS "FCNT",
            A."VMAP_MeetingLocation"
        FROM "VM"."Visitor_Management_Appointment" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "IVRM_User_Login_Institutionwise" AS C ON C."MI_Id" = A."MI_Id" 
            AND C."Id" = "USER_ID" 
            AND C."Activeflag" = 1
        WHERE B."MI_ActiveFlag" = 1 
            AND A."VMAP_Status" = 'Waiting' 
            AND A."VMAP_ActiveFlag" = 1;
    
    END IF;
END;
$$;