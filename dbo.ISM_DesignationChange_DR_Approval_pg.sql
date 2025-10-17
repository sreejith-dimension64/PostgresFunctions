CREATE OR REPLACE FUNCTION "dbo"."ISM_DesignationChange_DR_Approval"(
    "departments" VARCHAR,
    "role" VARCHAR,
    "user_Id" VARCHAR
)
RETURNS TABLE(
    "userEmpName" TEXT,
    "HRME_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "MI_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN

    IF ("role" = 'Admin' OR "role" = 'HR' OR "role" = 'HR') THEN
    
        "Slqdymaic" := 'SELECT  
((CASE WHEN HRE."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
"HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as userEmpName, HRE."HRME_Id" as "HRME_Id","HRMDES_DesignationName" as  
"HRMD_DepartmentName",HRE."MI_Id" FROM  "HR_Master_Employee" HRE inner join "HR_Master_Designation" on "HR_Master_Designation"."HRMDES_Id"=HRE."HRMDES_Id" where HRE."HRME_ActiveFlag"=1 
AND HRE."HRME_LeftFlag"=0 AND HRE."HRME_ActiveFlag"=1 and "HR_Master_Designation"."HRMDES_Id" in (' || "departments" || ') ORDER BY userEmpName';
    
    ELSE
    
        "Slqdymaic" := 'SELECT  
((CASE WHEN HRE."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
"HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as userEmpName, HRE."HRME_Id" as "HRME_Id","HRMDES_DesignationName" as  
"HRMD_DepartmentName",HRE."MI_Id" 
FROM  "HR_Master_Employee" HRE 
inner join "HR_Master_Designation" on "HR_Master_Designation"."HRMDES_Id"=HRE."HRMDES_Id" 
where HRE."HRME_ActiveFlag"=1 
AND HRE."HRME_LeftFlag"=0 AND HRE."HRME_ActiveFlag"=1 and "HR_Master_Designation"."HRMDES_Id" in (' || "departments" || ') AND HRE."HRME_Id" NOT IN (SELECT distinct "Emp_Code" FROM "IVRM_Staff_User_Login" WHERE "ID"=' || "user_Id" || ') ORDER BY userEmpName';
    
    END IF;

    RETURN QUERY EXECUTE "Slqdymaic";

END;
$$;