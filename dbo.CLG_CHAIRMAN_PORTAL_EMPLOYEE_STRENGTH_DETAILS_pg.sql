CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_PORTAL_EMPLOYEE_STRENGTH_DETAILS"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "HRME_Id" bigint,
    empname text,
    "HRMD_Id" bigint,
    "HRMD_DepartmentName" text,
    "HRMDES_Id" bigint,
    "HRMDES_DesignationName" text,
    emp_cnt bigint,
    "HRMDES_Order" integer,
    "IVRMMG_GenderName" text,
    "HRME_DOJ" timestamp,
    "IVRMMMS_MaritalStatus" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        A."HRME_Id",
        (COALESCE(A."HRME_EmployeeFirstName",' ') || ' ' || COALESCE(A."HRME_EmployeeMiddleName",' ') || ' ' || COALESCE(A."HRME_EmployeeLastName",' ')) AS empname,
        D."HRMD_Id",
        D."HRMD_DepartmentName",
        B."HRMDES_Id",
        B."HRMDES_DesignationName",
        COUNT(A."HRME_Id") AS emp_cnt,
        B."HRMDES_Order",
        G."IVRMMG_GenderName",
        A."HRME_DOJ",
        M."IVRMMMS_MaritalStatus"
    FROM "HR_Master_Employee" AS A
    INNER JOIN "HR_Master_Department" AS D ON D."HRMD_Id" = A."HRMD_Id" AND D."HRMD_ActiveFlag" = 1
    INNER JOIN "HR_Master_Designation" AS B ON A."HRMDES_Id" = B."HRMDES_Id" AND A."MI_Id" = B."MI_Id"
    LEFT JOIN "IVRM_Master_Gender" AS G ON G."IVRMMG_Id" = A."IVRMMG_Id" AND G."IVRMMG_ActiveFlag" = 1
    LEFT JOIN "IVRM_Master_Marital_Status" AS M ON M."IVRMMMS_Id" = A."IVRMMMS_Id" AND M."IVRMMMS_ActiveFlag" = 1
    WHERE A."MI_Id" = p_MI_Id 
        AND A."HRME_ActiveFlag" = 1 
        AND A."HRME_LeftFlag" = 0 
        AND B."HRMDES_ActiveFlag" = 1
    GROUP BY 
        B."HRMDES_Id",
        B."HRMDES_DesignationName",
        B."HRMDES_Order",
        D."HRMD_Id",
        D."HRMD_DepartmentName",
        A."HRME_Id",
        A."HRME_EmployeeFirstName",
        A."HRME_EmployeeMiddleName",
        A."HRME_EmployeeLastName",
        G."IVRMMG_GenderName",
        A."HRME_DOJ",
        M."IVRMMMS_MaritalStatus"
    ORDER BY B."HRMDES_DesignationName", B."HRMDES_Order";
END;
$$;