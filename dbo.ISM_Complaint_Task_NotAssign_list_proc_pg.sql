CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_Task_NotAssign_list_proc"(
    "RoleFlg" VARCHAR,
    "TypeFlg" VARCHAR(100),
    "status" VARCHAR(200),
    "HRME_Id" VARCHAR(100),
    "IVRMM_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE(
    "ISMTCR_Id" INTEGER,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Status" VARCHAR,
    "createdBy" VARCHAR,
    "ISMMCLT_ClientName" VARCHAR,
    "IVRMM_ModuleName" VARCHAR,
    "IVRMMMDDE_ModuleIncharge" INTEGER,
    "ISMTCR_CreatedBy" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "IVRMM_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic1" TEXT;
BEGIN
    IF "RoleFlg" != 'ClientUser' THEN
        RETURN QUERY
        SELECT 
            a."ISMTCR_Id", 
            a."ISMTCR_TaskNo",
            a."ISMTCR_Title",
            a."ISMTCR_CreationDate",
            a."ISMTCR_Status",
            hr."HRME_EmployeeFirstName" AS "createdBy", 
            d."ISMMCLT_ClientName",
            f."IVRMM_ModuleName", 
            c."IVRMMMDDE_ModuleIncharge",
            NULL::VARCHAR AS "ISMTCR_CreatedBy",
            NULL::INTEGER AS "ISMMCLT_Id",
            NULL::INTEGER AS "IVRMM_Id"
        FROM "ISM_TaskCreation" a
        INNER JOIN "ISM_Master_Module" b ON b."IVRMM_Id" = a."IVRMM_Id" 
        LEFT JOIN "ISM_Master_Module_Developers" c ON c."IVRMMMDDE_ModuleIncharge" = b."ISMMMD_ModuleHeadId"
        INNER JOIN "ISM_Master_Client" d ON d."ISMMCLT_Id" = a."ISMMCLT_Id"
        INNER JOIN "HR_Master_Employee" hr ON hr."HRME_Id" = c."IVRMMMDDE_ModuleIncharge"
        INNER JOIN "IVRM_Staff_User_Login" e ON e."Emp_Code" = hr."HRME_Id"
        INNER JOIN "IVRM_Module" f ON a."IVRMM_Id" = f."IVRMM_Id"
        WHERE c."IVRMMMDDE_ModuleIncharge" = 1393 
          AND a."ISMTCR_Status" = 'Open' 
          AND a."ISMTCR_Id" NOT IN (
              SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo"
          );
    ELSE
        "Slqdymaic1" := 'SELECT NULL::INTEGER, a."ISMTCR_TaskNo", a."ISMTCR_Title", a."ISMTCR_CreationDate", a."ISMTCR_Status", NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, a."ISMTCR_CreatedBy", d."ISMMCLT_Id", a."IVRMM_Id" ' ||
                        'FROM "ISM_TaskCreation" a, "ISM_Master_Module" b, "ISM_Master_Module_Developers" c, "ISM_TaskCreation_Client" d ' ||
                        'WHERE c."IVRMMMDDE_ModuleIncharge" IN (' || "HRME_Id" || ') ' ||
                        'AND c."IVRMMMDDE_ModuleIncharge" = b."ISMMMD_ModuleHeadId" ' ||
                        'AND b."IVRMM_Id" = a."IVRMM_Id" ' ||
                        'AND a."ISMTCR_Status" = ''Open'' ' ||
                        'AND a."ISMTCR_Id" = d."ISMTCR_Id"';
        
        RETURN QUERY EXECUTE "Slqdymaic1";
    END IF;
END;
$$;