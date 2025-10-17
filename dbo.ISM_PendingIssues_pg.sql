CREATE OR REPLACE FUNCTION "dbo"."ISM_PendingIssues"(
    "@MI_Id" bigint,
    "@UserId" bigint,
    "@HRME_Id" bigint,
    "@HRMPR_Id" bigint
)
RETURNS TABLE (
    "ISMTCR_Id" bigint,
    "ISMTCR_Title" text,
    "ISMTCR_Desc" text,
    "ISMTCR_TaskNo" text,
    "ISMTCRASTO_StartDate" timestamp,
    "ISMTCRASTO_EndDate" timestamp,
    "totaldeviation" bigint,
    "CreatedBy" text,
    "AssignedBy" text,
    "HRMPR_Id" bigint,
    "HRMP_Name" text,
    "totalcount" bigint,
    "MI_Name" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@count" bigint;
    "v_HRME_Id" bigint;
BEGIN
    "v_HRME_Id" := "@HRME_Id";
    
    IF "v_HRME_Id" = 0 THEN
        SELECT COUNT(*) INTO "@count" 
        FROM "IVRM_Staff_User_Login" 
        WHERE "Id" = "@UserId";
        
        IF "@count" > 0 THEN
            SELECT "Emp_Code" INTO "v_HRME_Id" 
            FROM "IVRM_Staff_User_Login" 
            WHERE "Id" = "@UserId" 
            LIMIT 1;
        END IF;
    END IF;

    IF "@HRMPR_Id" > 0 THEN
        RETURN QUERY
        SELECT 
            a."ISMTCR_Id", 
            a."ISMTCR_Title", 
            a."ISMTCR_Desc", 
            a."ISMTCR_TaskNo", 
            b."ISMTCRASTO_StartDate", 
            b."ISMTCRASTO_EndDate", 
            (CASE 
                WHEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - b."ISMTCRASTO_EndDate")) > 0 
                THEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - b."ISMTCRASTO_EndDate"))::bigint 
                ELSE 0 
            END) AS "totaldeviation", 
            (COALESCE(e."HRME_EmployeeFirstName", '') || COALESCE(e."HRME_EmployeeMiddleName", '') || COALESCE(e."HRME_EmployeeLastName", '')) AS "CreatedBy", 
            (COALESCE(d."HRME_EmployeeFirstName", '') || COALESCE(d."HRME_EmployeeMiddleName", '') || COALESCE(d."HRME_EmployeeLastName", '')) AS "AssignedBy",
            NULL::bigint AS "HRMPR_Id",
            NULL::text AS "HRMP_Name",
            NULL::bigint AS "totalcount",
            NULL::text AS "MI_Name"
        FROM "ISM_TaskCreation" a 
        INNER JOIN "ISM_TaskCreation_AssignedTo" b ON a."ISMTCR_Id" = b."ISMTCR_Id"
        LEFT JOIN "HR_Master_Priority" c ON c."HRMPR_Id" = a."HRMPR_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = b."ISMTCRASTO_AssignedBy"
        INNER JOIN "HR_Master_Employee" e ON e."HRME_Id" = a."HRME_Id"
        WHERE b."HRME_Id" = "v_HRME_Id" 
            AND a."ISMTCR_Status" IN ('Inprogress', 'Open', 'In Progress', 'Not Completed', 'Pending', 'Reopen', 'Management Blocker') 
            AND c."HRMPR_Id" = "@HRMPR_Id";
    ELSE
        RETURN QUERY
        SELECT 
            NULL::bigint AS "ISMTCR_Id",
            NULL::text AS "ISMTCR_Title",
            NULL::text AS "ISMTCR_Desc",
            NULL::text AS "ISMTCR_TaskNo",
            NULL::timestamp AS "ISMTCRASTO_StartDate",
            NULL::timestamp AS "ISMTCRASTO_EndDate",
            NULL::bigint AS "totaldeviation",
            NULL::text AS "CreatedBy",
            NULL::text AS "AssignedBy",
            c."HRMPR_Id",
            c."HRMP_Name", 
            COUNT(a."ISMTCR_Title") AS "totalcount", 
            d."MI_Name"
        FROM "ISM_TaskCreation" a 
        INNER JOIN "ISM_TaskCreation_AssignedTo" b ON a."ISMTCR_Id" = b."ISMTCR_Id"
        LEFT JOIN "HR_Master_Priority" c ON c."HRMPR_Id" = a."HRMPR_Id"
        LEFT JOIN "Master_Institution" d ON d."MI_Id" = c."MI_Id"
        WHERE b."HRME_Id" = "v_HRME_Id" 
            AND a."ISMTCR_Status" IN ('Inprogress', 'Open', 'In Progress', 'Not Completed', 'Pending', 'Reopen', 'Management Blocker')
        GROUP BY c."HRMPR_Id", c."HRMP_Name", d."MI_Name"
        ORDER BY c."HRMP_Name";
    END IF;

    RETURN;
END;
$$;