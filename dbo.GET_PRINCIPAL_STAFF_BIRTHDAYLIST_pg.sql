CREATE OR REPLACE FUNCTION "dbo"."GET_PRINCIPAL_STAFF_BIRTHDAYLIST"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "hrmE_Id" bigint,
    "employeeName" text,
    "HRMDES_DesignationName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."HRME_Id" AS "hrmE_Id",
        CONCAT(A."HRME_EmployeeFirstName", ' ', A."HRME_EmployeeMiddleName", ' ', A."HRME_EmployeeLastName") AS "employeeName",
        B."HRMDES_DesignationName"
    FROM "HR_MASTER_EMPLOYEE" AS A
    INNER JOIN "HR_Master_Designation" AS B ON A."HRMDES_Id" = B."HRMDES_Id"
    WHERE A."MI_ID" = p_MI_Id 
        AND A."HRME_ActiveFlag" = 1 
        AND A."HRME_LeftFlag" = 0 
        AND EXTRACT(DAY FROM A."hrme_dob") = EXTRACT(DAY FROM CURRENT_TIMESTAMP) 
        AND EXTRACT(MONTH FROM A."hrme_dob") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP);
END;
$$;