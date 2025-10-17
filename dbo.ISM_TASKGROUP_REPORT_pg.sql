CREATE OR REPLACE FUNCTION "dbo"."ISM_TASKGROUP_REPORT"(
    "MI_Id" bigint,
    "ISMMTGRP_Id" varchar,
    "HRMD_Id" varchar
)
RETURNS TABLE(
    "ISMMTGRP_TaskGroupName" varchar,
    "ISMTCR_Title" varchar,
    "ISMTPLAPTA_Status" varchar,
    "ISMTPLAPTA_Remarks" text,
    "ISMTPLAPTA_StartDate" timestamp,
    "ISMTPLAPTA_EndDate" timestamp,
    "HRMD_DepartmentName" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic text;
BEGIN
    sqldynamic := 'SELECT
        a."ISMMTGRP_TaskGroupName",
        b."ISMTCR_Title",
        c."ISMTPLAPTA_Status",
        c."ISMTPLAPTA_Remarks",
        c."ISMTPLAPTA_StartDate",
        c."ISMTPLAPTA_EndDate",
        d."HRMD_DepartmentName"
    FROM "ISM_Master_TaskGroup" a
    INNER JOIN "ISM_TaskCreation" b ON a."MI_Id" = b."MI_Id" AND a."ISMMTGRP_Id" = b."ISMMTGRP_Id"
    INNER JOIN "ISM_Task_Planner_Approved_Tasks" c ON b."ISMTCR_Id" = c."ISMTCR_Id"
    INNER JOIN "HR_Master_Department" d ON d."MI_Id" = b."MI_Id"
    WHERE a."MI_Id" = ' || "MI_Id"::varchar || ' AND a."ISMMTGRP_Id" IN (' || "ISMMTGRP_Id" || ') AND d."HRMD_Id" IN (' || "HRMD_Id" || ')';
    
    RETURN QUERY EXECUTE sqldynamic;
END;
$$;