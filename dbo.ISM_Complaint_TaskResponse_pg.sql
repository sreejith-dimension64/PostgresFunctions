CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_TaskResponse" (
    "MI_Id" BIGINT,
    "ISMTCR_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" TEXT,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" TEXT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" TEXT,
    "ISMTCRRES_Id" BIGINT,
    "ISMTCRAT_Attatchment" TEXT,
    "ISMTCRRES_ResponseDate" TIMESTAMP,
    "tasktype" TEXT,
    "ISMTCRRES_Response" TEXT,
    "ISMTCRRES_ResponseAttachment" TEXT,
    "responseby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ISMTCR_Id",
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
        TATT."ISMTCRAT_Attatchment",
        TCR."ISMTCRRES_ResponseDate",
        (CASE 
            WHEN a."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
            WHEN a."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement'
            ELSE 'Others' 
        END) AS "tasktype",
        TCR."ISMTCRRES_Response",
        TCR."ISMTCRRES_ResponseAttachment",
        (
            (CASE 
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
            END)
        ) AS "responseby"
    FROM "dbo"."ISM_TaskCreation" a
    LEFT JOIN "dbo"."ISM_TaskCreation_Client" ac ON a."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "dbo"."ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
    LEFT JOIN "dbo"."ISM_TaskCreation_Response" TCR ON TCR."ISMTCR_Id" = a."ISMTCR_Id" AND TCR."ISMTCRRES_ActiveFlg" = 1
    LEFT JOIN "dbo"."ISM_TaskCreation_Attachment" TATT ON TATT."ISMTCR_Id" = a."ISMTCR_Id" AND TATT."ISMTCRAT_ActiveFlg" = 1
    LEFT JOIN "dbo"."HR_Master_Employee" c ON TCR."HRME_Id" = c."HRME_Id" AND c."HRME_ActiveFlag" = 1 AND c."HRME_LeftFlag" = 0
    INNER JOIN "dbo"."HR_Master_Priority" e ON a."HRMPR_Id" = e."HRMPR_Id" AND e."HRMP_ActiveFlag" = 1
    WHERE a."ISMTCR_ActiveFlg" = 1 
        AND a."ISMTCR_Id" = "ISM_Complaint_TaskResponse"."ISMTCR_Id"
    ORDER BY TCR."ISMTCRRES_Id" DESC;
    
    RETURN;
END;
$$;