CREATE OR REPLACE FUNCTION "dbo"."Class_Teacher_Attendance_Report"(
    "year" TEXT,
    "flag" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE(
    "ASALU_Id" INTEGER,
    "ASALUC_Id" INTEGER,
    "ASALUCS_Id" INTEGER,
    "IVRMSTAUL_UserName" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "PAMS_SubjectName" TEXT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "flag" = '2' THEN
        RETURN QUERY
        SELECT 
            a."ASALU_Id",
            COALESCE(c."ASALUC_Id", 0) AS "ASALUC_Id",
            COALESCE(c."ASALUCS_Id", 0) AS "ASALUCS_Id",
            (COALESCE(h."HRME_EmployeeFirstName", '') || ' ' || COALESCE(h."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(h."HRME_EmployeeLastName", '') || ' : ' || CAST(d."Emp_Code" AS VARCHAR)) AS "IVRMSTAUL_UserName",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            g."ISMS_SubjectName"::TEXT AS "PAMS_SubjectName",
            e."ASMCL_Order",
            f."ASMC_Order"
        FROM "Adm_School_Attendance_Login_User" a
        INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
        INNER JOIN "Adm_School_Attendance_Login_User_Class_Subjects" c ON c."ASALUC_Id" = b."ASALUC_Id"
        INNER JOIN "IVRM_Staff_User_Login" d ON d."Emp_Code" = a."HRME_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
        INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
        INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "HR_Master_Employee" h ON h."HRME_Id" = a."HRME_Id"
        WHERE a."MI_Id" = "mi_id"::INTEGER AND a."HRME_Id" != 0 AND a."ASMAY_Id" = "year"::INTEGER AND a."ASALU_EntryTypeFlag" = 1
        ORDER BY e."ASMCL_Order", f."ASMC_Order";
        
    ELSIF "flag" = '1' THEN
        RETURN QUERY
        SELECT 
            a."ASALU_Id",
            0 AS "ASALUC_Id",
            0 AS "ASALUCS_Id",
            (COALESCE(h."HRME_EmployeeFirstName", '') || ' ' || COALESCE(h."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(h."HRME_EmployeeLastName", '') || ' : ' || CAST(d."Emp_Code" AS VARCHAR)) AS "IVRMSTAUL_UserName",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            ''::TEXT AS "PAMS_SubjectName",
            e."ASMCL_Order",
            f."ASMC_Order"
        FROM "Adm_School_Attendance_Login_User" a
        INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
        INNER JOIN "IVRM_Staff_User_Login" d ON d."Emp_Code" = a."HRME_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
        INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
        INNER JOIN "HR_Master_Employee" h ON h."HRME_Id" = a."HRME_Id"
        WHERE a."MI_Id" = "mi_id"::INTEGER AND a."HRME_Id" != 0 AND a."ASMAY_Id" = "year"::INTEGER AND a."ASALU_EntryTypeFlag" = 2
        ORDER BY e."ASMCL_Order", f."ASMC_Order";
        
    ELSIF "flag" = '3' THEN
        RETURN QUERY
        SELECT 
            0 AS "ASALU_Id",
            0 AS "ASALUC_Id",
            0 AS "ASALUCS_Id",
            (COALESCE(h."HRME_EmployeeFirstName", '') || ' ' || COALESCE(h."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(h."HRME_EmployeeLastName", '') || ' : ' || CAST(h."HRME_EmployeeCode" AS VARCHAR)) AS "IVRMSTAUL_UserName",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            ''::TEXT AS "PAMS_SubjectName",
            e."ASMCL_Order",
            f."ASMC_Order"
        FROM "IVRM_Master_ClassTeacher" b
        INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
        INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
        INNER JOIN "HR_Master_Employee" h ON h."HRME_Id" = b."HRME_Id"
        WHERE b."MI_Id" = "mi_id"::INTEGER AND b."HRME_Id" != 0 AND b."ASMAY_Id" = "year"::INTEGER AND b."IMCT_ActiveFlag" = 1
        ORDER BY e."ASMCL_Order", f."ASMC_Order";
        
    END IF;
    
    RETURN;
END;
$$;