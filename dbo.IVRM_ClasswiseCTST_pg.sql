CREATE OR REPLACE FUNCTION "dbo"."IVRM_ClasswiseCTST"(p_MI_Id BIGINT)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "EmpName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        d."HRME_Id",
        (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", '')) AS "EmpName"
    FROM "Exm"."Exm_Login_Privilege" a
    INNER JOIN "Exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id" AND a."MI_Id" = p_MI_Id
    INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id" AND c."MI_Id" = p_MI_Id
    INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code" AND d."MI_Id" = p_MI_Id
    INNER JOIN "HR_Master_Designation" De ON De."HRMDES_Id" = d."HRMDES_Id" AND De."MI_Id" = p_MI_Id
    INNER JOIN "Adm_School_M_Class" f ON b."ASMCL_Id" = f."ASMCL_Id" AND f."MI_Id" = p_MI_Id
    WHERE a."ELP_ActiveFlg" = 1 
        AND b."ELPS_ActiveFlg" = 1 
        AND a."MI_Id" = p_MI_Id 
        AND De."HRMDES_DesignationName" ILIKE '%TEACHER%' 
        AND a."ELP_Flg" IN ('ct', 'st')
        AND d."HRME_ActiveFlag" = 1 
        AND c."IVRMSTAUL_ActiveFlag" = 1 
        AND f."ASMCL_ActiveFlag" = 1
    ORDER BY d."HRME_Id";
END;
$$;