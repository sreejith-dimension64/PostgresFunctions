CREATE OR REPLACE FUNCTION "dbo"."Evaluation_trainee_list_proc"(p_MI_Id INTEGER)
RETURNS TABLE(
    "HRME_EmployeeFirstName" VARCHAR,
    "HRME_Id" INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."HRME_EmployeeFirstName" AS "HRME_EmployeeFirstName", 
        i."Employee_Id" AS "HRME_Id" 
    FROM "HR_IndPr_Create_Mapping" i, 
         "HR_Master_Employee" e, 
         "HR_Evaluation" ev 
    WHERE i."Employee_Id" = e."HRME_Id" 
      AND i."Employee_Id" NOT IN (SELECT "HRME_Id" FROM "HR_Evaluation") 
      AND e."MI_Id" = p_MI_Id;
END;
$$;