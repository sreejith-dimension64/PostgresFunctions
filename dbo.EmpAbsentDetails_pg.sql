CREATE OR REPLACE FUNCTION "dbo"."EmpAbsentDetails"(@MI_Id bigint)
RETURNS TABLE (
    "HRME_Id" bigint,
    "name" text,
    "email" text
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT 
    a."HRME_Id", 
    (COALESCE(a."HRME_EmployeeFirstName",'') || ' ' || COALESCE(a."HRME_EmployeeMiddleName",'') || ' ' || COALESCE(a."HRME_EmployeeLastName",'')) AS "name", 
    b."HRMEM_EmailId" AS "email" 
FROM "HR_Master_Employee" a 
INNER JOIN "HR_Master_Employee_EmailId" b ON a."HRME_Id" = b."HRME_Id" 
WHERE a."MI_Id" = @MI_Id 
AND a."HRME_Id" NOT IN (
    SELECT DISTINCT "HRME_Id" 
    FROM "fo"."FO_Emp_Punch" 
    WHERE "MI_Id" = @MI_Id 
    AND CAST("FOEP_PunchDate" AS date) = CURRENT_DATE
)
AND a."HRME_ActiveFlag" = 1 
AND a."HRME_LeftFlag" = 0 
AND b."HRMEM_DeFaultFlag" = 'default';

END;
$$;