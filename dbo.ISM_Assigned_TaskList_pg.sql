CREATE OR REPLACE FUNCTION "dbo"."ISM_Assigned_TaskList" (
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCRASTO_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTCRASTO_AssignedDate" TIMESTAMP,
    "ISMTCRASTO_Remarks" TEXT,
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "assignedby" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "TCAT"."ISMTCRASTO_Id", 
        "TCAT"."ISMTCR_Id",
        "TC"."HRMD_Id",
        "HRD"."HRMD_DepartmentName",
        "TC"."HRMPR_Id",
        "HRP"."HRMP_Name",
        "TC"."ISMTCR_BugOREnhancementFlg",
        "TC"."ISMTCR_CreationDate",
        "TC"."ISMTCR_Title",
        "TC"."ISMTCR_Desc",
        "TC"."ISMTCR_Status",
        "TC"."ISMTCR_ReOpenFlg",
        "TC"."ISMTCR_ReOpenDate",
        "TC"."ISMTCR_TaskNo",
        "ac"."ISMMCLT_Id",
        "cl"."ISMMCLT_ClientName",
        "TCAT"."ISMTCRASTO_AssignedDate",
        "TCAT"."ISMTCRASTO_Remarks",
        "TCAT"."ISMTCRASTO_StartDate",
        "TCAT"."ISMTCRASTO_EndDate",
        "TCAT"."ISMTCRASTO_EffortInHrs",
        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
              ELSE "HRE"."HRME_EmployeeFirstName" END ||
         CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' 
              OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
              ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' 
              OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
              ELSE ' ' || "HRE"."HRME_EmployeeLastName" END))::VARCHAR AS "assignedby"
    FROM "ISM_TaskCreation_AssignedTo" "TCAT"
    INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "TCAT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = 1
    LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = 1
    LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
    INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" 
        AND "HRE"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy" 
        AND "HRE"."HRME_ActiveFlag" = 1 
        AND "HRE"."HRME_LeftFlag" = 0
    INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = 1
    WHERE "TCAT"."ISMTCRASTO_ActiveFlg" = 1 
        AND "TC"."MI_Id" = "MI_Id" 
        AND "TCAT"."HRME_Id" = "HRME_Id"
        AND "TCAT"."ISMTCR_Id" NOT IN (
            SELECT DISTINCT "ISMTCR_Id" 
            FROM "ISM_Task_Planner_Tasks" 
            WHERE "ISMTPLTA_ActiveFlg" = 1
        )
    ORDER BY "TCAT"."ISMTCRASTO_AssignedDate";
END;
$$;