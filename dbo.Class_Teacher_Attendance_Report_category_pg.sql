CREATE OR REPLACE FUNCTION "dbo"."Class_Teacher_Attendance_Report_category"(
    "year" TEXT,
    "flag" TEXT,
    "mi_id" TEXT,
    "AMC_Id" TEXT
)
RETURNS TABLE(
    "ASALU_Id" INTEGER,
    "ASALUC_Id" INTEGER,
    "ASALUCS_Id" INTEGER,
    "IVRMSTAUL_UserName" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "PAMS_SubjectName" TEXT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "ISMS_OrderFlag" INTEGER,
    "ASMCL_Id" INTEGER,
    "ASMS_Id" INTEGER,
    "HRME_Id" INTEGER,
    "isms_id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "category" TEXT;
BEGIN
    
    IF "AMC_Id"::INTEGER > 0 THEN
        "category" := ' and "ASMCC"."AMC_Id" = ' || "AMC_Id" || ' and "ASMCC"."ASMAY_Id" = ' || "year" || ' and "ASMCC"."MI_Id" = ' || "mi_id" || '';
    ELSE
        "category" := '';
    END IF;
    
    IF "flag" = '2' THEN
        RETURN QUERY
        SELECT 
            NULL::INTEGER AS "ASALU_Id",
            NULL::INTEGER AS "ASALUC_Id",
            NULL::INTEGER AS "ASALUCS_Id",
            (COALESCE("g"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("g"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("g"."HRME_EmployeeLastName", '') || ' :' || COALESCE("g"."HRME_EmployeeCode", '')) AS "IVRMSTAUL_UserName",
            "cl"."ASMCL_ClassName",
            "se"."ASMC_SectionName",
            "d"."ISMS_SubjectName" AS "PAMS_SubjectName",
            "cl"."ASMCL_Order",
            "se"."ASMC_Order",
            "d"."ISMS_OrderFlag",
            "cl"."ASMCL_Id",
            "se"."ASMS_Id",
            "g"."HRME_Id",
            "d"."isms_id"
        FROM "exm"."Exm_Login_Privilege" "a"
        INNER JOIN "exm"."Exm_Login_Privilege_Subjects" "b" ON "a"."ELP_Id" = "b"."ELP_Id"
        LEFT OUTER JOIN "exm"."Exm_Login_Privilege_SubSubjects" "c" ON "c"."ELPS_Id" = "b"."ELPS_Id"
        INNER JOIN "IVRM_Master_Subjects" "d" ON "d"."ISMS_Id" = "b"."ISMS_Id"
        LEFT OUTER JOIN "exm"."Exm_Master_SubSubject" "e" ON "e"."EMSS_Id" = "c"."EMSS_Id"
        INNER JOIN "ivrm_staff_user_login" "f" ON "f"."IVRMSTAUL_Id" = "a"."Login_Id"
        INNER JOIN "hr_master_employee" "g" ON "g"."HRME_Id" = "f"."Emp_Code"
        INNER JOIN "Adm_School_M_Class" "cl" ON "cl"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_section" "se" ON "se"."ASMS_Id" = "b"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "ye" ON "ye"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "Exm"."Exm_Category_Class" "class" ON "class"."ASMCL_Id" = "cl"."ASMCL_Id" 
            AND "class"."ASMS_Id" = "se"."ASMS_Id" 
            AND "class"."ASMAY_Id" = "ye"."ASMAY_Id"
        WHERE "a"."MI_Id" = "mi_id"::INTEGER 
            AND "a"."ASMAY_Id" = "year"::INTEGER 
            AND "class"."ASMAY_Id" = "year"::INTEGER 
            AND "g"."HRME_Id" != 1237
        ORDER BY "cl"."ASMCL_Order", "se"."ASMC_Order", "d"."ISMS_OrderFlag";
        
    ELSIF "flag" = '1' THEN
        
        "query" := 'SELECT "a"."ASALU_Id", 0::INTEGER AS "ASALUC_Id", 0::INTEGER AS "ASALUCS_Id", 
            (COALESCE("h"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("h"."HRME_EmployeeMiddleName", '''') || '' '' || 
            COALESCE("h"."HRME_EmployeeLastName", '''') || '' : '' || CAST("h"."HRME_EmployeeCode" AS TEXT)) AS "IVRMSTAUL_UserName", 
            "e"."ASMCL_ClassName", "f"."ASMC_SectionName", '''' AS "PAMS_SubjectName", "e"."ASMCL_Order", "f"."ASMC_Order",
            NULL::INTEGER AS "ISMS_OrderFlag", NULL::INTEGER AS "ASMCL_Id", NULL::INTEGER AS "ASMS_Id", NULL::INTEGER AS "HRME_Id", NULL::INTEGER AS "isms_id"
            FROM "Adm_School_Attendance_Login_User" "a"
            INNER JOIN "Adm_School_Attendance_Login_User_Class" "b" ON "a"."ASALU_Id" = "b"."ASALU_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCL_Id" = "b"."ASMCL_Id" AND "ASMCC"."ASMAY_Id" = ' || "year" || '
            INNER JOIN "IVRM_Staff_User_Login" "d" ON "d"."Emp_Code" = "a"."HRME_Id"
            INNER JOIN "Adm_School_M_Class" "e" ON "e"."asmcl_id" = "ASMCC"."asmcl_id"
            INNER JOIN "adm_school_M_section" "f" ON "f"."asms_id" = "b"."ASMS_Id"
            INNER JOIN "HR_Master_Employee" "h" ON "h"."HRME_Id" = "a"."HRME_Id"
            WHERE "a"."MI_Id" = ' || "mi_id" || ' AND "a"."HRME_Id" != 0 AND "a"."ASMAY_Id" = ' || "year" || '
            AND "a"."ASALU_EntryTypeFlag" = 2 ' || "category" || ' AND "h"."HRME_Id" != 1237
            ORDER BY "e"."ASMCL_Order", "f"."ASMC_Order"';
        
        RETURN QUERY EXECUTE "query";
        
    ELSIF "flag" = '3' THEN
        
        "query" := 'SELECT NULL::INTEGER AS "ASALU_Id", 0::INTEGER AS "ASALUC_Id", 0::INTEGER AS "ASALUCS_Id",
            (COALESCE("h"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("h"."HRME_EmployeeMiddleName", '''') || '' '' || 
            COALESCE("h"."HRME_EmployeeLastName", '''') || '' : '' || CAST("h"."HRME_EmployeeCode" AS TEXT)) AS "IVRMSTAUL_UserName", 
            "e"."ASMCL_ClassName", "f"."ASMC_SectionName", '''' AS "PAMS_SubjectName", "e"."ASMCL_Order", "f"."ASMC_Order",
            NULL::INTEGER AS "ISMS_OrderFlag", NULL::INTEGER AS "ASMCL_Id", NULL::INTEGER AS "ASMS_Id", NULL::INTEGER AS "HRME_Id", NULL::INTEGER AS "isms_id"
            FROM "HR_Master_Employee" "h"
            INNER JOIN "IVRM_Master_ClassTeacher" "b" ON "b"."HRME_Id" = "h"."HRME_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCL_Id" = "b"."ASMCL_Id" AND "ASMCC"."ASMAY_Id" = ' || "year" || '
            INNER JOIN "Adm_School_M_Class" "e" ON "e"."asmcl_id" = "b"."asmcl_id"
            INNER JOIN "adm_school_M_section" "f" ON "f"."asms_id" = "b"."ASMS_Id"
            WHERE "h"."MI_Id" = ' || "mi_id" || ' AND "h"."HRME_Id" != 0 AND "b"."ASMAY_Id" = ' || "year" || '
            AND "b"."IMCT_ActiveFlag" = 1 ' || "category" || ' AND "b"."HRME_Id" != 1237
            ORDER BY "e"."ASMCL_Order", "f"."ASMC_Order"';
        
        RETURN QUERY EXECUTE "query";
        
    END IF;
    
END;
$$;