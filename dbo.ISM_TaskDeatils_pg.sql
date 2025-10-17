CREATE OR REPLACE FUNCTION "dbo"."ISM_TaskDeatils"(
    "@MI_Id" BIGINT,
    "@ISMTCR_Id" BIGINT
)
RETURNS TABLE(
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "createdby" VARCHAR,
    "AssignedEmployee" VARCHAR,
    "ISMTCRASTO_AssignedBy" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ISMTCR_Id",
        a."HRMD_Id",
        b."HRMD_DepartmentName",
        a."HRMPR_Id",
        e."HRMP_Name",
        a."ISMTCR_CreationDate",
        a."ISMTCR_Title",
        taskassigned."ISMTCRASTO_StartDate",
        taskassigned."ISMTCRASTO_EndDate",
        taskassigned."ISMTCRASTO_EffortInHrs",
        a."ISMTCR_Status",
        a."ISMTCR_ReOpenFlg",
        a."ISMTCR_ReOpenDate",
        a."ISMTCR_TaskNo",
        ac."ISMMCLT_Id",
        cl."ISMMCLT_ClientName",
        a."ISMTCR_Desc",
        (CASE 
            WHEN a."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
            WHEN a."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
            ELSE 'Others' 
        END)::VARCHAR AS "ISMTCR_BugOREnhancementFlg",
        ((CASE 
            WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' 
            ELSE c."HRME_EmployeeFirstName" 
        END || 
        CASE 
            WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' OR c."HRME_EmployeeMiddleName" = '0' THEN '' 
            ELSE ' ' || c."HRME_EmployeeMiddleName" 
        END || 
        CASE 
            WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' OR c."HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || c."HRME_EmployeeLastName" 
        END))::VARCHAR AS "createdby",
        (SELECT ("HRME_EmployeeFirstName" || '' || "HRME_EmployeeMiddleName" || '' || "HRME_EmployeeLastName")::VARCHAR 
         FROM "HR_Master_Employee" 
         WHERE "HRME_Id" = taskassigned."ISMTCRASTO_AssignedBy") AS "AssignedEmployee",
        taskassigned."ISMTCRASTO_AssignedBy"
    FROM "ISM_TaskCreation" a
    INNER JOIN "ISM_TaskCreation_AssignedTo" taskassigned ON taskassigned."ISMTCR_Id" = a."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" ac ON a."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
    INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id" AND b."HRMD_ActiveFlag" = 1
    LEFT JOIN "HR_Master_Employee" c ON b."HRMD_Id" = c."HRMD_Id" AND c."HRME_ActiveFlag" = 1 AND c."HRME_LeftFlag" = 0 AND a."HRME_Id" = c."HRME_Id"
    INNER JOIN "HR_Master_Priority" e ON a."HRMPR_Id" = e."HRMPR_Id" AND e."HRMP_ActiveFlag" = 1
    WHERE a."ISMTCR_ActiveFlg" = 1
    AND a."ISMTCR_Id" = "@ISMTCR_Id";
    
    RETURN;
END;
$$;