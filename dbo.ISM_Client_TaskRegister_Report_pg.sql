CREATE OR REPLACE FUNCTION "dbo"."ISM_Client_TaskRegister_Report" (
    "TypeFlg" VARCHAR(100), 
    "startDate" TIMESTAMP, 
    "endDate" TIMESTAMP,
    "status" TEXT,
    "ISMMCLT_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE 
    "Slqdymaic" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
    "betweendates" TEXT;
    "startDate_var" TIMESTAMP;
    "endDate_var" TIMESTAMP;
BEGIN
    "startDate_var" := "startDate";
    "endDate_var" := "endDate";
    
    "StartDate_N" := TO_CHAR("startDate_var"::DATE, 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("endDate_var"::DATE, 'YYYY-MM-DD');
    
    IF "StartDate_N" != '' AND "EndDate_N" != '' THEN
        "betweendates" := '(TC."ISMTCR_CreationDate"::DATE) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''' ';
    ELSE
        "betweendates" := '';
    END IF;
    
    IF "TypeFlg" = 'Consolidated' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MCL"."ISMMCLT_Id", "MCL"."ISMMCLT_ClientName", COUNT("TC"."ISMTCR_Id") as "totalCount", "ISMTCR_Status"
        FROM "ISM_TaskCreation" "TC"
        LEFT JOIN "ISM_TaskCreation_Client" "TCCL" ON "TC"."ISMTCR_Id" = "TCCL"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "MCL" ON "TCCL"."ISMMCLT_Id" = "MCL"."ISMMCLT_Id" AND "MCL"."ISMMCLT_ActiveFlag" = 1
        LEFT JOIN "ISM_Master_Client_Project" "MCLP" ON "MCLP"."ISMMCLT_Id" = "MCL"."ISMMCLT_Id" AND "MCL"."ISMMCLT_ActiveFlag" = 1
        LEFT JOIN "ISM_Master_Project" "IMP" ON ("IMP"."ISMMPR_Id" = "MCLP"."ISMMPR_Id") OR ("IMP"."ISMMPR_Id" = "TC"."ISMMPR_Id")
        INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
        INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TC"."ISMTCR_CreatedBy"
        WHERE "TC"."ISMTCR_ActiveFlg" = 1
        AND ' || "betweendates" || ' AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
        AND "TC"."ISMTCR_CreatedBy" IN (' || "userid" || ') AND "MCL"."ISMMCLT_Id" IN (' || "ISMMCLT_Id" || ')
        GROUP BY "MCL"."ISMMCLT_Id", "MCL"."ISMMCLT_ClientName", "ISMTCR_Status"';
        
        EXECUTE "Slqdymaic";
        
    ELSIF "TypeFlg" = 'Detailed' THEN
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
        AND ' || "betweendates" || ' AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
        AND "TC"."ISMTCR_CreatedBy" IN (' || "userid" || ') AND "MCL"."ISMMCLT_Id" IN (' || "ISMMCLT_Id" || ')
        ORDER BY "ISMTCR_Id"';
        
        EXECUTE "Slqdymaic";
    END IF;
    
    RETURN;
END;
$$;