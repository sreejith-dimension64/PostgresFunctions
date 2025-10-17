CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_TaskList" (
    "MI_Id" BIGINT,
    "HRMD_Id" VARCHAR(100)
)
RETURNS TABLE (
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
    "createdby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := '
    SELECT DISTINCT a."ISMTCR_Id",a."HRMD_Id",b."HRMD_DepartmentName",a."HRMPR_Id",e."HRMP_Name",a."ISMTCR_BugOREnhancementFlg",a."ISMTCR_CreationDate",a."ISMTCR_Title",a."ISMTCR_Desc",
    a."ISMTCR_Status",a."ISMTCR_ReOpenFlg",a."ISMTCR_ReOpenDate",a."ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",
    ((CASE WHEN c."HRME_EmployeeFirstName" is null or c."HRME_EmployeeFirstName"='''' then '''' else 
    c."HRME_EmployeeFirstName" end || CASE WHEN c."HRME_EmployeeMiddleName" is null or c."HRME_EmployeeMiddleName" = '''' 
    or c."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || c."HRME_EmployeeMiddleName" END || CASE WHEN c."HRME_EmployeeLastName" is null or c."HRME_EmployeeLastName" = '''' 
    or c."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || c."HRME_EmployeeLastName" END )) as createdby
    FROM "ISM_TaskCreation" a
    LEFT JOIN "ISM_TaskCreation_Client" ac on a."ISMTCR_Id"=ac."ISMTCR_Id" 
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=1
    INNER JOIN "HR_Master_Department" b ON a."HRMD_Id"=b."HRMD_Id" AND b."HRMD_ActiveFlag"=1
    INNER JOIN "HR_Master_Employee" c ON b."HRMD_Id"=c."HRMD_Id" AND a."HRME_Id"=c."HRME_Id" AND c."HRME_ActiveFlag"=1 AND c."HRME_LeftFlag"=0
    INNER JOIN "HR_Master_Priority" e ON a."HRMPR_Id"=e."HRMPR_Id" AND e."HRMP_ActiveFlag"=1
    INNER JOIN "IVRM_Staff_User_Login" f ON a."ISMTCR_CreatedBy"=f."Id" AND f."Emp_Code"=a."HRME_Id"
    where a."ISMTCR_ActiveFlg"=1 AND a."MI_Id"=' || "MI_Id"::VARCHAR || ' AND a."HRMD_Id" IN (' || "HRMD_Id" || ')';
    
    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;