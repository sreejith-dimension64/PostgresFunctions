CREATE OR REPLACE FUNCTION "dbo"."ISM_Client_Task_List" (
    "MI_Id" BIGINT,
    "User_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "ISMTCR_TaskNo" VARCHAR,
    "HRMD_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        TC."ISMTCR_Id",
        TC."ISMTCR_TaskNo",
        TC."HRMD_Id",
        TC."HRMPR_Id",
        HMP."HRMP_Name",
        (CASE 
            WHEN TC."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
            WHEN TC."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
            ELSE 'Others' 
        END)::TEXT AS "ISMTCR_BugOREnhancementFlg",
        TC."ISMTCR_CreationDate",
        TC."ISMTCR_Title",
        TC."ISMTCR_Desc",
        TC."ISMTCR_Status",
        TC."ISMTCR_ReOpenFlg",
        TC."ISMTCR_ReOpenDate",
        TC."ISMTCR_ActiveFlg"
    FROM "ISM_TaskCreation" TC
    INNER JOIN "HR_Master_Priority" HMP ON TC."HRMPR_Id" = HMP."HRMPR_Id" AND HMP."HRMP_ActiveFlag" = 1
    INNER JOIN "ApplicationUser" AU ON TC."ISMTCR_CreatedBy" = AU."Id"
    WHERE TC."MI_Id" = "MI_Id" AND TC."ISMTCR_CreatedBy" = "User_Id"
    ORDER BY TC."ISMTCR_CreationDate" DESC;
END;
$$;