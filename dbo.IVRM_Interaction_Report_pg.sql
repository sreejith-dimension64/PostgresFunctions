CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_Report"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_IINTS_Flag varchar(100)
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "EmpName" text,
    "ISMS_SubjectName" varchar,
    "ASMS_Id" bigint,
    "ASMC_SectionName" varchar,
    "ASMCL_ClassName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_IINTS_Flag = 'SubjectTeacher' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::text AS "EmpName",
            e."ISMS_SubjectName",
            NULL::bigint AS "ASMS_Id",
            NULL::varchar AS "ASMC_SectionName",
            NULL::varchar AS "ASMCL_ClassName"
        FROM "exm"."Exm_Login_Privilege" a
        INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
        INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code"
        INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = b."ISMS_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND b."ASMCL_Id" = p_ASMCL_Id 
            AND b."ASMS_Id" = p_ASMS_Id 
            AND a."ELP_ActiveFlg" = 1 
            AND b."ELPS_ActiveFlg" = 1 
            AND a."ELP_Flg" = 'st';
            
    ELSIF p_IINTS_Flag = 'ClassTeacher' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::text AS "EmpName",
            NULL::varchar AS "ISMS_SubjectName",
            b."ASMS_Id",
            g."ASMC_SectionName",
            NULL::varchar AS "ASMCL_ClassName"
        FROM "exm"."Exm_Login_Privilege" a
        INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
        INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code"
        INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = b."ISMS_Id"
        INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = b."ASMS_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND b."ASMCL_Id" = p_ASMCL_Id 
            AND b."ASMS_Id" = p_ASMS_Id 
            AND a."ELP_ActiveFlg" = 1 
            AND b."ELPS_ActiveFlg" = 1 
            AND a."ELP_Flg" = 'ct';
            
    ELSIF p_IINTS_Flag = 'HOD' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::text AS "EmpName",
            NULL::varchar AS "ISMS_SubjectName",
            NULL::bigint AS "ASMS_Id",
            NULL::varchar AS "ASMC_SectionName",
            e."ASMCL_ClassName"
        FROM "IVRM_HOD" a
        INNER JOIN "IVRM_HOD_Class" b ON a."IHOD_Id" = b."IHOD_Id"
        INNER JOIN "IVRM_HOD_Staff" c ON c."IHOD_Id" = a."IHOD_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."HRME_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = b."ASMCL_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND b."ASMCL_Id" = p_ASMCL_Id 
            AND a."IHOD_ActiveFlag" = 1 
            AND b."IHODC_ActiveFlag" = 1 
            AND c."IHODS_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
            
    ELSIF p_IINTS_Flag = 'Principal' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."IVRMUL_Id" AS "HRME_Id",
            (COALESCE(d."HRME_EmployeeFirstName", '') || ' ' || COALESCE(d."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(d."HRME_EmployeeLastName", ''))::text AS "EmpName",
            NULL::varchar AS "ISMS_SubjectName",
            NULL::bigint AS "ASMS_Id",
            NULL::varchar AS "ASMC_SectionName",
            NULL::varchar AS "ASMCL_ClassName"
        FROM "IVRM_Principal" a
        INNER JOIN "IVRM_Principal_Class" b ON a."IPR_Id" = b."IPR_Id"
        INNER JOIN "IVRM_Principal_Staff" c ON c."IPR_Id" = a."IPR_Id"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = a."IVRMUL_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = b."ASMCL_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND b."ASMCL_Id" = p_ASMCL_Id 
            AND a."IPR_ActiveFlag" = 1 
            AND b."IRPC_ActiveFlag" = 1 
            AND c."IRPS_ActiveFlag" = 1 
            AND d."HRME_ActiveFlag" = 1;
    END IF;
    
    RETURN;
END;
$$;