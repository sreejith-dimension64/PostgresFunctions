CREATE OR REPLACE FUNCTION "dbo"."ISM_User_EmployeeList_admin_Dept_Wise"(
    "p_MI_Id" bigint,
    "p_role" text,
    "p_user_Id" bigint,
    "p_Dept_Id" bigint
)
RETURNS TABLE(
    "userEmpName" text,
    "HRME_Id" bigint,
    "HRMD_DepartmentName" text,
    "MI_Id" bigint,
    "HRMD_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" text;
BEGIN
    IF "p_role" = 'Admin' OR "p_role" = 'HR' THEN
        RETURN QUERY EXECUTE 
        'SELECT    
        ((CASE WHEN HRE."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else   
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''   
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = ''''   
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END ))::text as userEmpName, 
        HRE."HRME_Id" as "HRME_Id",
        "HRMDES_DesignationName"::text as "HRMD_DepartmentName",
        HRE."MI_Id",
        NULL::bigint as "HRMD_Id"
        FROM  "HR_Master_Employee" HRE 
        inner join "HR_Master_Designation" on "HR_Master_Designation"."HRMDES_Id"=HRE."HRMDES_Id" 
        where HRE."HRME_ActiveFlag"=1 
        AND HRE."HRME_LeftFlag"=0 AND HRE."HRME_ActiveFlag"=1 AND  "HR_Master_Designation"."HRMDC_ID"=' || "p_Dept_Id";
    ELSE
        IF("p_user_Id" != 0) THEN
            RETURN QUERY
            SELECT DISTINCT 
            ((CASE WHEN HRE."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='' then '' else   
            "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''   
            or "HRME_EmployeeMiddleName" = '0' then '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = ''   
            or "HRME_EmployeeLastName" = '0' then '' ELSE ' ' || "HRME_EmployeeLastName" END ))::text as userEmpName,
            UEM."HRME_Id",
            HMD."HRMDES_DesignationName"::text as "HRMD_DepartmentName",
            HRE."MI_Id",
            HRE."HRMD_Id"
            FROM "ISM_User_Employees_Mapping" UEM  
            INNER JOIN "HR_Master_Employee" HRE ON UEM."HRME_Id"=HRE."HRME_Id" AND HRE."HRME_ActiveFlag"=1 AND HRE."HRME_LeftFlag"=0 AND HRE."HRME_ActiveFlag"=1   
            INNER JOIN "HR_Master_Designation" HMD ON HRE."HRMDES_Id"=HMD."HRMDES_Id" AND HMD."HRMDES_ActiveFlag"=1  
            WHERE UEM."User_Id"="p_user_Id" AND UEM."ISMUSEMM_ActiveFlag"=1 AND HMD."HRMDC_ID"="p_Dept_Id"
            ORDER BY userEmpName;
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
            ((CASE WHEN HRE."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='' then '' else   
            "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''   
            or "HRME_EmployeeMiddleName" = '0' then '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = ''   
            or "HRME_EmployeeLastName" = '0' then '' ELSE ' ' || "HRME_EmployeeLastName" END ))::text as userEmpName,
            HRE."HRME_Id" as "HRME_Id",
            NULL::text as "HRMD_DepartmentName",
            HRE."MI_Id",
            NULL::bigint as "HRMD_Id"
            FROM  "HR_Master_Employee" HRE 
            INNER JOIN "HR_Master_Designation" HMD ON HRE."HRMDES_Id"=HMD."HRMDES_Id" AND HMD."HRMDES_ActiveFlag"=1  
            where HRE."HRME_ActiveFlag"=1 AND HRE."HRME_LeftFlag"=0 AND HRE."HRME_ActiveFlag"=1 and HRE."MI_Id"="p_MI_Id" AND HMD."HRMDC_ID"="p_Dept_Id"
            ORDER BY userEmpName;
        END IF;
    END IF;
END;
$$;