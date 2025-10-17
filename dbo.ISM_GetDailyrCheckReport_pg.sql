CREATE OR REPLACE FUNCTION "dbo"."ISM_GetDailyrCheckReport"(
    p_MI_Id bigint,
    p_HRME_IdS text,
    p_StartDate timestamp,
    p_EndDate timestamp,
    p_type varchar(50)
)
RETURNS TABLE (
    "employeename" text,
    "HRME_Id" bigint,
    "ISMMTCAT_TaskCategoryName" varchar,
    "ISMTCR_Title" varchar,
    "Count" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlexec text;
BEGIN
    IF p_type = 'Details' THEN
        v_sqlexec := '
        SELECT DISTINCT (COALESCE("HRME_EmployeeFirstName",'''') || COALESCE("HRME_EmployeeMiddleName",'''') || COALESCE("HRME_EmployeeLastName",'''')) AS employeename, 
               a."HRME_Id",
               c."ISMMTCAT_TaskCategoryName", 
               b."ISMTCR_Title"
        FROM "ISM_DailyReport" a 
        INNER JOIN "ISM_TaskCreation" b ON a."ISMTCR_Id" = b."ISMTCR_Id"
        LEFT JOIN "ISM_Master_TaskCategory" c ON c."ISMMTCAT_Id" = b."ISMMTCAT_Id"
        LEFT JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id"
        WHERE a."HRME_Id" IN (' || p_HRME_IdS || ') 
          AND a."MI_Id" = ' || p_MI_Id::varchar || '  
          AND a."ISMDRPT_Date" BETWEEN ''' || p_StartDate::date || ''' AND ''' || p_EndDate::date || '''';
        
        RETURN QUERY EXECUTE v_sqlexec;
        
    ELSIF p_type = 'Count' THEN
        v_sqlexec := '
        SELECT DISTINCT COUNT(*)::bigint AS "Count", 
               c."ISMMTCAT_TaskCategoryName",
               (COALESCE("HRME_EmployeeFirstName",'''') || COALESCE("HRME_EmployeeMiddleName",'''') || COALESCE("HRME_EmployeeLastName",'''')) AS employeename, 
               a."HRME_Id"
        FROM "ISM_DailyReport" a 
        INNER JOIN "ISM_TaskCreation" b ON a."ISMTCR_Id" = b."ISMTCR_Id"
        LEFT JOIN "ISM_Master_TaskCategory" c ON c."ISMMTCAT_Id" = b."ISMMTCAT_Id"
        LEFT JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id"
        WHERE a."HRME_Id" IN (' || p_HRME_IdS || ') 
          AND a."MI_Id" = ' || p_MI_Id::varchar || ' 
          AND a."ISMDRPT_Date" BETWEEN ''' || p_StartDate::date || ''' AND ''' || p_EndDate::date || ''' 
        GROUP BY c."ISMMTCAT_TaskCategoryName", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", a."HRME_Id"';
        
        RETURN QUERY EXECUTE v_sqlexec;
    END IF;
    
    RETURN;
END;
$$;