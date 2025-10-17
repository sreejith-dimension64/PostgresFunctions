CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_List_Rolewise" (
    "@MI_Id" BIGINT, 
    "@HRMD_Id" BIGINT, 
    "@roletype" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannedBy" BIGINT,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "ISMTPL_ApprovedBy" BIGINT,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "planDate" TIMESTAMP,
    "plannedby" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
    'SELECT DISTINCT "TP"."ISMTPL_Id", "TP"."HRME_Id", "TP"."ISMTPL_PlannedBy", "TP"."ISMTPL_PlannerName", "TP"."ISMTPL_Remarks", "TP"."ISMTPL_StartDate", "TP"."ISMTPL_EndDate", "TP"."ISMTPL_TotalHrs",
    "TP"."ISMTPL_ApprovalFlg", "TP"."ISMTPL_ApprovedBy", "TP"."ISMTPL_ActiveFlg", "TP"."CreatedDate" AS "planDate",
    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "plannedby"
    
    FROM "ISM_Task_Planner" "TP"
    INNER JOIN "ISM_Task_Planner_Tasks" "TPT" ON "TP"."ISMTPL_Id" = "TPT"."ISMTPL_Id" AND "TPT"."ISMTPLTA_ActiveFlg" = true
    INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "TPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = true
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "TC"."HRMD_Id" AND "HRE"."HRME_Id" = "TP"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false
    INNER JOIN "IVRM_Staff_User_Login" "f" ON "TC"."ISMTCR_CreatedBy" = "f"."Id" AND "f"."Emp_Code" = "TP"."HRME_Id"
    INNER JOIN "HR_Master_Department" "HRD" ON "HRD"."HRMD_Id" = "HRE"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
    WHERE "TP"."ISMTPL_ActiveFlg" = true AND "TP"."MI_Id" = ' || "@MI_Id" || ' AND "TC"."HRMD_Id" = ' || "@HRMD_Id" || '
    ORDER BY "TP"."ISMTPL_Id" DESC';
END;
$$;