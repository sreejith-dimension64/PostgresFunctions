CREATE OR REPLACE FUNCTION "dbo"."ISM_Task_List" (
    "p_MI_Id" BIGINT,
    "p_HRME_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "ISMTCR_TaskNo" VARCHAR,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TEXT,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT
    "TC"."ISMTCR_Id",
    "TC"."ISMTCR_TaskNo",
    "TC"."HRMD_Id",
    "HMD"."HRMD_DepartmentName",
    "TC"."HRMPR_Id",
    "HMP"."HRMP_Name",
    (CASE 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement'
        ELSE 'Others' 
    END) AS "ISMTCR_BugOREnhancementFlg",
    TO_CHAR("TC"."ISMTCR_CreationDate", 'DD-MM-YYYY') AS "ISMTCR_CreationDate",
    "TC"."ISMTCR_Title",
    "TC"."ISMTCR_Desc",
    "TC"."ISMTCR_Status",
    "TC"."ISMTCR_ReOpenFlg",
    "TC"."ISMTCR_ReOpenDate",
    "TC"."ISMTCR_ActiveFlg"
FROM "ISM_TaskCreation" "TC"
INNER JOIN "HR_Master_Department" "HMD" ON "TC"."HRMD_Id" = "HMD"."HRMD_Id" AND "HMD"."HRMD_ActiveFlag" = true
INNER JOIN "HR_Master_Priority" "HMP" ON "TC"."HRMPR_Id" = "HMP"."HRMPR_Id" AND "HMP"."HRMP_ActiveFlag" = true
WHERE "TC"."MI_Id" = "p_MI_Id" AND "TC"."HRME_Id" = "p_HRME_Id"
ORDER BY "TC"."ISMTCR_Id" DESC;

END;
$$;