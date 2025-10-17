CREATE OR REPLACE FUNCTION "dbo"."CHAIRMAN_EMP_POPUP"(
    p_MI_ID bigint,
    p_HRMDES_Id bigint,
    p_hrmd_id bigint
)
RETURNS TABLE(
    "hrmE_Id" bigint,
    "empname" text,
    "doj" timestamp,
    "mstatus" text,
    "gender" text,
    "mobileno" bigint,
    "email" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."hrmE_Id",
        (COALESCE(A."HRME_EmployeeFirstName", '') || '' || COALESCE(A."HRME_EmployeeMiddleName", '') || '' || COALESCE(A."HRME_EmployeeLastName", '')) AS "empname",
        A."HRME_DOJ" AS "doj",
        COALESCE(C."IVRMMMS_MaritalStatus", '') AS "mstatus",
        COALESCE(B."IVRMMG_GenderName", '') AS "gender",
        COALESCE(E."HRMEMNO_MobileNo", 0) AS "mobileno",
        COALESCE(D."HRMEM_EmailId", '') AS "email"
    FROM "HR_Master_Employee" AS A
    LEFT JOIN "IVRM_Master_Gender" AS B ON A."IVRMMG_Id" = B."IVRMMG_Id" AND A."MI_Id" = B."MI_Id"
    LEFT JOIN "IVRM_Master_Marital_Status" AS C ON A."IVRMMMS_Id" = C."IVRMMMS_Id" AND A."MI_Id" = C."MI_Id"
    LEFT JOIN "HR_Master_Employee_EmailId" AS D ON A."HRME_Id" = D."HRME_Id"
    LEFT JOIN "HR_Master_Employee_MobileNo" AS E ON A."HRME_Id" = E."HRME_Id"
    WHERE A."HRME_ActiveFlag" = 1 
        AND A."MI_Id" = p_MI_ID 
        AND A."HRMD_Id" = p_hrmd_id 
        AND A."HRMDES_Id" = p_HRMDES_Id;
END;
$$;