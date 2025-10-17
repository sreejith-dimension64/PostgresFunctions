CREATE OR REPLACE FUNCTION "dbo"."class_teacher_list"(
    p_MI_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "emp_name" text,
    "HRMEMNO_MobileNo" text,
    "HRMEM_EmailId" text,
    "ClassTeacher" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        c."HRME_Id",
        COALESCE(c."HRME_EmployeeFirstName", '') || '' || COALESCE(c."HRME_EmployeeMiddleName", '') || '' || COALESCE(c."HRME_EmployeeLastName", '') as emp_name,
        d."HRMEMNO_MobileNo",
        e."HRMEM_EmailId",
        'ClassTeacher'::text as "ClassTeacher"
    FROM "IVRM_Master_ClassTeacher" a 
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id"
    INNER JOIN "HR_Master_Employee_MobileNo" d ON d."HRME_Id" = c."HRME_Id"
    INNER JOIN "HR_Master_Employee_EmailId" e ON e."HRME_Id" = c."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMCL_Id" = p_ASMCL_Id 
        AND a."ASMS_Id" = p_ASMS_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id;

END;
$$;