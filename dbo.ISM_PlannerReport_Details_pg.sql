CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerReport_Details"(
    p_MI_Id bigint,
    p_HRME_Id text,
    p_StartDate varchar(100),
    p_EndDate varchar(100)
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "employeename" text,
    "HRME_EmployeeCode" varchar,
    "HRMD_DepartmentName" varchar,
    "HRMDES_DesignationName" varchar,
    "ISMTPL_PlannerName" varchar,
    "ISMTPL_StartDate" timestamp,
    "ISMTPL_TotalHrs" numeric,
    "ISMTPL_EndDate" timestamp,
    "ISMTPL_Remarks" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
BEGIN
    
    v_sqldynamic := '
    SELECT DISTINCT b."HRME_Id",
           COALESCE(b."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(b."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(b."HRME_EmployeeLastName",'''') as employeename,
           b."HRME_EmployeeCode",
           d."HRMD_DepartmentName",
           ds."HRMDES_DesignationName",
           a."ISMTPL_PlannerName",
           a."ISMTPL_StartDate",
           a."ISMTPL_TotalHrs",
           a."ISMTPL_EndDate",
           a."ISMTPL_Remarks"
    FROM "ISM_Task_Planner" a 
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id" AND b."HRME_ActiveFlag" = true AND b."HRME_LeftFlag" = false
    INNER JOIN "Hr_Master_DEpartment" d ON b."HRMD_Id" = d."HRMD_Id"
    INNER JOIN "HR_Master_Designation" ds ON b."HRMDES_Id" = ds."HRMDES_Id"
    WHERE a."MI_Id" = ' || p_MI_Id::varchar || ' 
      AND a."HRME_Id" IN (' || p_HRME_Id || ') 
      AND (CAST(a."ISMTPL_StartDate" AS date) BETWEEN ''' || p_StartDate || ''' AND ''' || p_EndDate || ''' 
           OR CAST(a."ISMTPL_EndDate" AS date) BETWEEN ''' || p_StartDate || ''' AND ''' || p_EndDate || ''')';
    
    RETURN QUERY EXECUTE v_sqldynamic;
    
END;
$$;