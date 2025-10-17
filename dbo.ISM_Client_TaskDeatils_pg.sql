CREATE OR REPLACE FUNCTION "dbo"."ISM_Client_TaskDeatils"(
    "MI_Id" BIGINT,
    "ISMTCR_Id" BIGINT
)
RETURNS TABLE(
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" TEXT,
    "ISMTCR_TaskNo" TEXT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" TEXT,
    "ISMTCRRES_Id" BIGINT,
    "ISMTCRAT_Attatchment" TEXT,
    "ISMTCRRES_ResponseDate" TIMESTAMP,
    "createdby" TEXT,
    "tasktype" TEXT,
    "ISMTCRRES_Response" TEXT,
    "ISMTCRRES_ResponseAttachment" TEXT
)
LANGUAGE plpgsql
AS $$
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
        a."ISMTCR_TaskNo",
        ac."ISMMCLT_Id",
        cl."ISMMCLT_ClientName",
        TCR."ISMTCRRES_Id",
        TATT."ISMTCRAT_Attatchment",
        TCR."ISMTCRRES_ResponseDate",
        (SELECT appuser."NormalizedUserName" 
         FROM "ApplicationUser" appuser 
         WHERE appuser."Id" = a."ISMTCR_CreatedBy") AS "createdby",
        (CASE 
            WHEN a."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
            WHEN a."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement'
            ELSE 'Others' 
         END) AS "tasktype",
        TCR."ISMTCRRES_Response",
        TCR."ISMTCRRES_ResponseAttachment"
    FROM "ISM_TaskCreation" a
    LEFT JOIN "ISM_TaskCreation_Client" ac ON a."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
    LEFT JOIN "ISM_TaskCreation_Response" TCR ON TCR."ISMTCR_Id" = a."ISMTCR_Id" AND TCR."ISMTCRRES_ActiveFlg" = 1
    LEFT JOIN "ISM_TaskCreation_Attachment" TATT ON TATT."ISMTCR_Id" = a."ISMTCR_Id" AND TATT."ISMTCRAT_ActiveFlg" = 1
    INNER JOIN "HR_Master_Priority" e ON a."HRMPR_Id" = e."HRMPR_Id" AND e."HRMP_ActiveFlag" = 1
    WHERE a."ISMTCR_ActiveFlg" = 1 AND a."ISMTCR_Id" = "ISM_Client_TaskDeatils"."ISMTCR_Id"
    ORDER BY TCR."ISMTCRRES_Id" DESC;
END;
$$;