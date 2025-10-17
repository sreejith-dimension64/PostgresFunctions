CREATE OR REPLACE FUNCTION "dbo"."ISM_DEVIATED_TASK_EMPLOYEE"(
    p_MI_Id BIGINT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "EMPNAME" TEXT,
    "HRMEM_EmailId" TEXT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" TEXT,
    "HRMDES_DesignationName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        C."MI_Id",
        C."HRME_Id",
        (COALESCE(C."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(C."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(C."HRME_EmployeeLastName", ' ')) AS "EMPNAME",
        COALESCE(D."HRMEM_EmailId", '') AS "HRMEM_EmailId",
        C."HRMD_Id",
        X."HRMD_DepartmentName",
        Y."HRMDES_DesignationName"
    FROM "ISM_TaskCreation" AS A 
    INNER JOIN "ISM_TaskCreation_AssignedTo" AS B ON B."ISMTCR_Id" = A."ISMTCR_Id"
    INNER JOIN "HR_Master_Employee" AS C ON C."HRME_Id" = B."HRME_Id"
    INNER JOIN "HR_Master_Employee_EmailId" AS D ON D."HRME_Id" = C."HRME_Id" AND D."HRMEM_DeFaultFlag" = 'default'
    INNER JOIN "HR_Master_Department" AS X ON X."HRMD_Id" = C."HRMD_Id"
    INNER JOIN "HR_Master_Designation" AS Y ON Y."HRMDES_Id" = C."HRMDES_Id"
    WHERE A."ISMTCR_Status" <> 'Completed' 
        AND B."ISMTCRASTO_EndDate"::DATE < CURRENT_DATE 
        AND C."HRME_ActiveFlag" = 1 
        AND C."HRME_LeftFlag" = 0
    
    UNION ALL
    
    SELECT DISTINCT 
        C."MI_Id",
        C."HRME_Id",
        (COALESCE(C."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(C."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(C."HRME_EmployeeLastName", ' ')) AS "EMPNAME",
        COALESCE(D."HRMEM_EmailId", '') AS "HRMEM_EmailId",
        C."HRMD_Id",
        X."HRMD_DepartmentName",
        Y."HRMDES_DesignationName"
    FROM "ISM_Task_Planner" AS A 
    INNER JOIN "ISM_Task_Planner_Tasks" AS B ON B."ISMTPL_Id" = A."ISMTPL_Id"
    INNER JOIN "HR_Master_Employee" AS C ON C."HRME_Id" = A."HRME_Id"
    INNER JOIN "HR_Master_Employee_EmailId" AS D ON D."HRME_Id" = C."HRME_Id" AND D."HRMEM_DeFaultFlag" = 'default'
    INNER JOIN "HR_Master_Department" AS X ON X."HRMD_Id" = C."HRMD_Id"
    INNER JOIN "HR_Master_Designation" AS Y ON Y."HRMDES_Id" = C."HRMDES_Id"
    WHERE B."ISMTPLTA_Status" <> 'Completed' 
        AND B."ISMTPLTA_EndDate"::DATE < CURRENT_DATE 
        AND A."HRME_Id" NOT IN (
            SELECT DISTINCT COALESCE(C."HRME_Id", 0) AS "HRME_Id" 
            FROM "ISM_TaskCreation" AS A 
            INNER JOIN "ISM_TaskCreation_AssignedTo" AS B ON B."ISMTCR_Id" = A."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" AS C ON C."HRME_Id" = B."HRME_Id"
            INNER JOIN "HR_Master_Employee_EmailId" AS D ON D."HRME_Id" = C."HRME_Id" AND D."HRMEM_DeFaultFlag" = 'default'
            WHERE A."ISMTCR_Status" <> 'Completed' 
                AND B."ISMTCRASTO_EndDate"::DATE < CURRENT_DATE
        ) 
        AND C."HRME_ActiveFlag" = 1 
        AND C."HRME_LeftFlag" = 0;
    
    RETURN;
END;
$$;