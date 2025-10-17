CREATE OR REPLACE FUNCTION INCREMENTDETAILS(p_MI_ID BIGINT)
RETURNS TABLE (
    HRMED_Name VARCHAR,
    HREIC_Id BIGINT,
    EmployeeName TEXT,
    HRMD_DepartmentName VARCHAR,
    Amount NUMERIC,
    flag TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        C."HRMED_Name",
        A."HREIC_Id",
        D."HRME_EmployeeFirstName" || '' || D."HRME_EmployeeMiddleName" || '' || D."HRME_EmployeeLastName" AS EmployeeName,
        E."HRMD_DepartmentName",
        CASE WHEN B."HREICED_Amount" = 0 THEN B."HREICED_Percentage" ELSE B."HREICED_Amount" END AS Amount,
        CASE WHEN B."HREICED_Amount" = 0 THEN 'Percentage' ELSE 'Amount' END AS flag
    FROM "HR_Employee_Increment" A
    INNER JOIN "HR_Employee_Increment_EDHeads" B ON B."HREIC_Id" = A."HREIC_Id"
    INNER JOIN "HR_Master_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id"
    INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id"
    INNER JOIN "HR_Master_Department" E ON E."HRMD_Id" = D."HRMD_Id"
    WHERE B."HREICED_ActiveFlag" = 1 
        AND D."HRME_ActiveFlag" = 1 
        AND D."HRME_LeftFlag" = 0 
        AND A."MI_Id" = p_MI_ID;
END;
$$;