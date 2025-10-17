CREATE OR REPLACE FUNCTION "dbo"."ISM_Peding_Memo_List" (
    "p_HRME_Id" VARCHAR(500)
)
RETURNS TABLE (
    "HRME_Id" INTEGER,
    "ISMEMN_No" VARCHAR,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "HRME_EmployeeFirstName" TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "ISMEMN_Date" VARCHAR,
    "ISMEMN_CompleByDate" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
BEGIN
    v_Slqdymaic := '
    SELECT DISTINCT 
        MEMO."HRME_Id",
        MEMO."ISMEMN_No",
        MEMO."ISMEMN_Startdate" AS "ISMTPL_StartDate",
        MEMO."ISMEMN_Enddate" AS "ISMTPL_EndDate",
        (SELECT (
            (CASE WHEN assi."HRME_EmployeeFirstName" IS NULL OR assi."HRME_EmployeeFirstName" = '''' THEN '''' ELSE assi."HRME_EmployeeFirstName" END ||
             CASE WHEN assi."HRME_EmployeeMiddleName" IS NULL OR assi."HRME_EmployeeMiddleName" = '''' OR assi."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || assi."HRME_EmployeeMiddleName" END ||
             CASE WHEN assi."HRME_EmployeeLastName" IS NULL OR assi."HRME_EmployeeLastName" = '''' OR assi."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || assi."HRME_EmployeeLastName" END)
        ) 
        FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = MEMO."HRME_Id") AS "HRME_EmployeeFirstName",
        "HRMD_DepartmentName",
        TO_CHAR("ISMEMN_Date", ''DD-MM-YYYY'') AS "ISMEMN_Date",
        TO_CHAR("ISMEMN_CompleByDate", ''DD-MM-YYYY'') AS "ISMEMN_CompleByDate"
    FROM "ISM_EMPLOYEE_MEMO_NOTICE" MEMO 
    INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" MEMOTASK ON MEMO."ISMEMN_ID" = MEMOTASK."ISMEMN_ID" 
    INNER JOIN "ISM_Task_Planner" ITP ON ITP."HRME_Id" = MEMO."HRME_Id" AND ITP."ISMTPL_ApprovalFlg" = 1
    INNER JOIN "ISM_Task_Planner_Tasks" PLT ON PLT."ISMTPLTA_Id" = MEMOTASK."ISMTPLTA_Id" AND ITP."ISMTPL_Id" = PLT."ISMTPL_Id" AND PLT."ISMTPLTA_ApprovalFlg" = 1 
    INNER JOIN "HR_Master_Employee" HR ON HR."HRME_Id" = MEMO."HRME_ID" 
    INNER JOIN "HR_Master_Department" HRD ON HRD."HRMD_Id" = HR."HRMD_Id" 
    WHERE ("ISMTPLTA_Status" != ''Completed'' AND "ISMTPLTA_Status" != ''Close'' AND "ISMTPLTA_Status" != ''Development Completed'') 
    AND MEMO."HRME_Id" IN (' || "p_HRME_Id" || ') 
    AND MEMO."ISMEMN_CompleByDate" <= CURRENT_TIMESTAMP 
    AND MEMO."ISMEMN_Type" = ''Memo'' 
    ORDER BY "ISMEMN_Date"';
    
    RETURN QUERY EXECUTE v_Slqdymaic;
END;
$$;