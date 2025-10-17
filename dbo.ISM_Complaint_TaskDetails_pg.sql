CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_TaskDetails" (
    "MI_Id" BIGINT,
    "ISMTCR_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTCRRES_Id" BIGINT,
    "ISMTCRAT_Attatchment" TEXT,
    "tasktype" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ISMTCR_Id",
        a."HRMD_Id",
        a."HRMPR_Id",
        e."HRMP_Name",
        a."ISMTCR_BugOREnhancementFlg",
        a."ISMTCR_CreationDate",
        a."ISMTCR_Title",
        a."ISMTCR_Desc",
        (CASE WHEN tat."ISMTCRASTO_StartDate" IS NULL THEN CURRENT_TIMESTAMP ELSE tat."ISMTCRASTO_StartDate" END) AS "ISMTCRASTO_StartDate",
        (CASE WHEN tat."ISMTCRASTO_EndDate" IS NULL THEN CURRENT_TIMESTAMP ELSE tat."ISMTCRASTO_EndDate" END) AS "ISMTCRASTO_EndDate",
        a."ISMTCR_Status",
        a."ISMTCR_ReOpenFlg",
        a."ISMTCR_ReOpenDate",
        a."ISMTCR_TaskNo",
        ac."ISMMCLT_Id",
        cl."ISMMCLT_ClientName",
        TCR."ISMTCRRES_Id",
        TATT."ISMTCRAT_Attatchment",
        (CASE WHEN a."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
              WHEN a."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement'
              ELSE 'Others' END) AS "tasktype"
    FROM "ISM_TaskCreation" a
    LEFT JOIN "ISM_TaskCreation_Client" ac ON a."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_AssignedTo" tat ON tat."ISMTCR_Id" = a."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
    LEFT JOIN "ISM_TaskCreation_Response" TCR ON TCR."ISMTCR_Id" = a."ISMTCR_Id" AND TCR."ISMTCRRES_ActiveFlg" = 1
    LEFT JOIN "ISM_TaskCreation_Attachment" TATT ON TATT."ISMTCR_Id" = a."ISMTCR_Id" AND TATT."ISMTCRAT_ActiveFlg" = 1
    INNER JOIN "HR_Master_Priority" e ON a."HRMPR_Id" = e."HRMPR_Id" AND e."HRMP_ActiveFlag" = 1
    WHERE a."ISMTCR_ActiveFlg" = 1 AND a."ISMTCR_Id" = "ISM_Complaint_TaskDetails"."ISMTCR_Id"
    ORDER BY TCR."ISMTCRRES_Id" DESC;
END;
$$;