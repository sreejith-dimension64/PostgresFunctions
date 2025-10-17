CREATE OR REPLACE FUNCTION "dbo"."ISM_UserDeatils" (
    "MI_Id" BIGINT,
    "HRMD_Id" VARCHAR(100)
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "employeeName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := '
    SELECT DISTINCT "HRE"."HRME_Id",
                    "HRE"."HRMD_Id",
                    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '''' THEN '''' 
                           ELSE "HRE"."HRME_EmployeeFirstName" END || 
                      CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '''' 
                                OR "HRE"."HRME_EmployeeMiddleName" = ''0'' THEN '''' 
                           ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END || 
                      CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '''' 
                                OR "HRE"."HRME_EmployeeLastName" = ''0'' THEN '''' 
                           ELSE '' '' || "HRE"."HRME_EmployeeLastName" END)) AS "employeeName"
    FROM "HR_Master_Employee" "HRE"
    INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
    LEFT JOIN "ISM_Master_Module" "MM" ON "MM"."HRMD_Id" = "HRD"."HRMD_Id" AND "MM"."ISMMMD_ActiveFlag" = 1
    LEFT JOIN "ISM_Master_Module_Developers" "MMD" ON "MM"."ISMMMD_Id" = "MMD"."ISMMMD_Id"
    WHERE "HRE"."HRME_ActiveFlag" = 1 
      AND "HRE"."HRME_LeftFlag" = 0 
      AND "HRE"."HRME_ActiveFlag" = 1 
      AND "HRE"."MI_Id" = ' || $1 || ' 
      AND "HRD"."HRMD_Id" IN (' || $2 || ')
    ORDER BY "employeeName"';

    RETURN QUERY EXECUTE "Slqdymaic" USING "MI_Id", "HRMD_Id";
END;
$$;