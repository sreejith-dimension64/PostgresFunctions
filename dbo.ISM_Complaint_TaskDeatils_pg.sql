CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_TaskDeatils"(
    "MI_Id" BIGINT,
    "ISMTCR_Id" BIGINT
)
RETURNS TABLE(
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
    "ISMTCRRES_Id" BIGINT,
    "ISMTCRRES_ResponseDate" TIMESTAMP,
    "ISMTCRRES_Response" TEXT,
    "ISMTCRRES_ResponseAttachment" TEXT,
    "responseby" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ISMTCR_Id",
        a."HRMD_Id",
        b."HRMD_DepartmentName",
        a."HRMPR_Id",
        e."HRMP_Name",
        a."ISMTCR_BugOREnhancementFlg",
        a."ISMTCR_CreationDate",
        a."ISMTCR_Title",
        a."ISMTCR_Desc",
        a."ISMTCR_Status",
        a."ISMTCR_ReOpenFlg",
        a."ISMTCR_ReOpenDate",
        a."ISMTCR_TaskNo",
        ac."ISMMCLT_Id",
        cl."ISMMCLT_ClientName",
        TCR."ISMTCRRES_Id",
        TCR."ISMTCRRES_ResponseDate",
        TCR."ISMTCRRES_Response",
        TCR."ISMTCRRES_ResponseAttachment",
        ((CASE WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' ELSE 
        c."HRME_EmployeeFirstName" END || CASE WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' 
        OR c."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeMiddleName" END || CASE WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' 
        OR c."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeLastName" END))::TEXT AS "responseby"
    FROM "ISM_TaskCreation" a
    LEFT JOIN "ISM_TaskCreation_Client" ac ON a."ISMTCR_Id" = ac."ISMTCR_Id" 
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
    LEFT JOIN "ISM_TaskCreation_Response" TCR ON TCR."ISMTCR_Id" = a."ISMTCR_Id" AND TCR."ISMTCRRES_ActiveFlg" = 1
    INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id" AND b."HRMD_ActiveFlag" = 1
    LEFT JOIN "HR_Master_Employee" c ON b."HRMD_Id" = c."HRMD_Id" AND TCR."HRME_Id" = c."HRME_Id" AND c."HRME_ActiveFlag" = 1 AND c."HRME_LeftFlag" = 0
    INNER JOIN "HR_Master_Priority" e ON a."HRMPR_Id" = e."HRMPR_Id" AND e."HRMP_ActiveFlag" = 1
    WHERE a."ISMTCR_ActiveFlg" = 1 
    AND a."MI_Id" = "MI_Id" 
    AND a."ISMTCR_Id" = "ISMTCR_Id"
    ORDER BY TCR."ISMTCRRES_Id" DESC;
    
    RETURN;
END;
$$;