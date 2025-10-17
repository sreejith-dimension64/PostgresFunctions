CREATE OR REPLACE FUNCTION "dbo"."ISM_PEDING_MEMO_LIST_NOTICE" (
    "@HRME_Id" VARCHAR(500)
)
RETURNS TABLE (
    "HRME_Id" INTEGER,
    "ISMEMN_No" VARCHAR,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "HRME_EmployeeFirstName" TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "ISMEMN_Date" VARCHAR,
    "ISMEMN_CompleByDate" VARCHAR,
    "comp_Date" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    "@Slqdymaic" := '
    SELECT DISTINCT 
        "MEMO"."HRME_Id",
        "MEMO"."ISMEMN_No",
        "ISMEMN_Startdate" AS "ISMTPL_StartDate",
        "ISMEMN_Enddate" AS "ISMTPL_EndDate",
        (SELECT ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                  CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                  CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
         FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "MEMO"."HRME_Id") AS "HRME_EmployeeFirstName",
        "HRMD_DepartmentName",
        TO_CHAR("ISMEMN_Date", ''DD-MM-YYYY'') AS "ISMEMN_Date",
        TO_CHAR("ISMEMN_CompleByDate", ''DD-MM-YYYY'') AS "ISMEMN_CompleByDate",
        "ISMEMN_CompleByDate" AS "comp_Date"
    FROM "ISM_EMPLOYEE_MEMO_NOTICE" "MEMO" 
    INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "MEMOTASK" ON "MEMO"."ISMEMN_ID" = "MEMOTASK"."ISMEMN_ID"
    INNER JOIN "ISM_Task_Planner" "ITP" ON "ITP"."HRME_Id" = "MEMO"."HRME_Id" AND "ITP"."ISMTPL_ApprovalFlg" = 1
    INNER JOIN "ISM_Task_Planner_Tasks" "PLT" ON "PLT"."ISMTPLTA_Id" = "MEMOTASK"."ISMTPLTA_Id" AND "ITP"."ISMTPL_Id" = "PLT"."ISMTPL_Id" AND "PLT"."ISMTPLTA_ApprovalFlg" = 1
    INNER JOIN "HR_Master_Employee" "HR" ON "HR"."HRME_Id" = "MEMO"."HRME_ID"
    INNER JOIN "HR_Master_Department" "HRD" ON "HRD"."HRMD_Id" = "HR"."HRMD_Id"
    WHERE ("ISMTPLTA_Status" != ''Completed'' AND "ISMTPLTA_Status" != ''Close'' AND "ISMTPLTA_Status" != ''Development Completed'')
    AND "MEMO"."ISMEMN_CompleByDate" <= CURRENT_TIMESTAMP 
    AND "MEMO"."ISMEMN_Type" = ''Memo''
    ORDER BY "ISMEMN_Date"';

    RETURN QUERY EXECUTE "@Slqdymaic";
END;
$$;