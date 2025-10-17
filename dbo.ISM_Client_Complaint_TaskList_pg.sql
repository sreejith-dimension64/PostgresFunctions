CREATE OR REPLACE FUNCTION "dbo"."ISM_Client_Complaint_TaskList"(
    "RoleFlg" VARCHAR(100),
    "TypeFlg" VARCHAR(100),
    "status" VARCHAR(200),
    "ISMMCLT_Id" VARCHAR(100),
    "IVRMM_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE(
    "ISMTCR_Id" INTEGER,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id" INTEGER,
    "createdby" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    IF "RoleFlg" = 'ClientUser' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate",
            "ISMTCR_TaskNo", "MCL"."ISMMCLT_Id", "MCL"."ISMMCLT_ClientName", "TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" "appuser" WHERE "appuser"."Id" = "TC"."ISMTCR_CreatedBy") AS "createdby"
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" "TCCL" ON "TC"."ISMTCR_Id" = "TCCL"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "MCL" ON "TCCL"."ISMMCLT_Id" = "MCL"."ISMMCLT_Id" AND "MCL"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Master_Client_Project" "MCLP" ON "MCLP"."ISMMCLT_Id" = "MCL"."ISMMCLT_Id" AND "MCL"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Master_Project" "IMP" ON ("IMP"."ISMMPR_Id" = "MCLP"."ISMMPR_Id") OR ("IMP"."ISMMPR_Id" = "TC"."ISMMPR_Id")
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TC"."ISMTCR_CreatedBy"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TC"."ISMTCR_CreatedBy"::INTEGER IN (' || "userid" || ') AND "MCL"."ISMMCLT_Id" IN (' || "ISMMCLT_Id" || ') ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "TypeFlg" = 'Search' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate",
            "ISMTCR_TaskNo", "MCL"."ISMMCLT_Id", "MCL"."ISMMCLT_ClientName", "TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" "appuser" WHERE "appuser"."Id" = "TC"."ISMTCR_CreatedBy") AS "createdby"
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" "TCCL" ON "TC"."ISMTCR_Id" = "TCCL"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "MCL" ON "TCCL"."ISMMCLT_Id" = "MCL"."ISMMCLT_Id" AND "MCL"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Master_Client_Project" "MCLP" ON "MCLP"."ISMMCLT_Id" = "MCL"."ISMMCLT_Id" AND "MCL"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Master_Project" "IMP" ON ("IMP"."ISMMPR_Id" = "MCLP"."ISMMPR_Id") OR ("IMP"."ISMMPR_Id" = "TC"."ISMMPR_Id")
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TC"."ISMTCR_CreatedBy"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TC"."ISMTCR_CreatedBy"::INTEGER IN (' || "userid" || ') AND "MCL"."ISMMCLT_Id" IN (' || "ISMMCLT_Id" || ') ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        END IF;
    END IF;
    
    RETURN;
END;
$$;