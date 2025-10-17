CREATE OR REPLACE FUNCTION "dbo"."Class_Teacher_Attendance_Report_category_test"(
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
    "ASMC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "category" TEXT;
BEGIN

    IF ("AMC_Id"::INTEGER > 0) THEN
        "category" := 'and ASMCC."AMC_Id" = ' || "AMC_Id" || ' and ASMCC."ASMAY_Id" = ' || "year" || ' and ASMCC."MI_Id" = ' || "mi_id" || '';
    ELSE
        "category" := '';
    END IF;

    IF "flag" = '2' THEN
        "query" := 'select a."ELP_id" AS "ASALU_Id", 0 AS "ASALUC_Id", COALESCE(b."ELPS_ID", 0) AS "ASALUCS_Id",
                    (COALESCE(d."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(d."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(d."HRME_EmployeeLastName", '''') || '' : '' || 
                    CAST(c."Emp_Code" AS VARCHAR)) AS "IVRMSTAUL_UserName", f."ASMCL_ClassName", g."ASMC_SectionName", e."ISMS_SubjectName" AS "PAMS_SubjectName",
                    f."ASMCL_Order", g."ASMC_Order" FROM "exm"."Exm_Login_Privilege" a
                    INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
                    INNER JOIN "IVRM_Staff_User_Login" c ON c."IVRMSTAUL_Id" = a."Login_Id" AND c."MI_Id" = a."MI_Id"
                    INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."Emp_Code" AND d."MI_Id" = a."MI_Id"
                    INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = b."ISMS_Id" AND e."MI_Id" = a."MI_Id"
                    INNER JOIN "Adm_School_M_Class" f ON b."ASMCL_Id" = f."ASMCL_Id" AND f."MI_Id" = a."MI_Id"
                    LEFT JOIN "adm_school_M_section" g ON g."asms_id" = b."ASMS_Id" AND g."MI_Id" = a."MI_Id"
                    INNER JOIN "dbo"."Adm_School_M_Class_Category" ASMCC ON ASMCC."ASMCL_Id" = b."ASMCL_Id" AND ASMCC."ASMAY_Id" = ' || "year" || '
                    WHERE a."ELP_ActiveFlg" = 1 AND b."ELPS_ActiveFlg" = 1 AND a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "year" || ' AND a."ELP_Flg" = ''st'' ' || "category" || '
                    GROUP BY a."ELP_id", b."ELPS_ID", d."HRME_EmployeeFirstName", d."HRME_EmployeeMiddleName", d."HRME_EmployeeLastName", c."Emp_Code", f."ASMCL_ClassName",
                    g."ASMC_SectionName", e."ISMS_SubjectName", f."ASMCL_Order", g."ASMC_Order"';

        RETURN QUERY EXECUTE "query";

    ELSIF "flag" = '1' THEN
        "query" := 'SELECT a."ASALU_Id", (COALESCE(h."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(h."HRME_EmployeeMiddleName", '''') || '' '' ||
                    COALESCE(h."HRME_EmployeeLastName", '''') || '' : '' || CAST(h."HRME_EmployeeCode" AS VARCHAR)) AS "IVRMSTAUL_UserName", e."ASMCL_ClassName", f."ASMC_SectionName", 0 AS "ASALUC_Id", 0 AS "ASALUCS_Id", ''''::TEXT AS "PAMS_SubjectName", e."ASMCL_Order", f."ASMC_Order" FROM
                    "Adm_School_Attendance_Login_User" a
                    INNER JOIN "Adm_School_Attendance_Login_User_Class" b ON a."ASALU_Id" = b."ASALU_Id"
                    INNER JOIN "dbo"."Adm_School_M_Class_Category" ASMCC ON ASMCC."ASMCL_Id" = b."ASMCL_Id" AND ASMCC."ASMAY_Id" = ' || "year" || '
                    INNER JOIN "IVRM_Staff_User_Login" d ON d."Emp_Code" = a."HRME_Id"
                    INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = ASMCC."asmcl_id"
                    INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
                    INNER JOIN "HR_Master_Employee" h ON h."HRME_Id" = a."HRME_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND a."HRME_Id" != 0 AND a."ASMAY_Id" = ' || "year" || ' AND a."ASALU_EntryTypeFlag" = 2 ' || "category" || '
                    ORDER BY e."ASMCL_Order", f."ASMC_Order"';

        RETURN QUERY EXECUTE "query";

    ELSIF "flag" = '3' THEN
        "query" := 'SELECT (COALESCE(h."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(h."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(h."HRME_EmployeeLastName", '''') || '' : '' || CAST(h."HRME_EmployeeCode" AS VARCHAR)) AS "IVRMSTAUL_UserName", e."ASMCL_ClassName", f."ASMC_SectionName", 0 AS "ASALUC_Id", 0 AS "ASALUCS_Id", ''''::TEXT AS "PAMS_SubjectName", e."ASMCL_Order", f."ASMC_Order" FROM
                    "HR_Master_Employee" h
                    INNER JOIN "IVRM_Master_ClassTeacher" b ON b."HRME_Id" = h."HRME_Id"
                    INNER JOIN "dbo"."Adm_School_M_Class_Category" ASMCC ON ASMCC."ASMCL_Id" = b."ASMCL_Id" AND ASMCC."ASMAY_Id" = ' || "year" || '
                    INNER JOIN "Adm_School_M_Class" e ON e."asmcl_id" = b."asmcl_id"
                    INNER JOIN "adm_school_M_section" f ON f."asms_id" = b."ASMS_Id"
                    WHERE h."MI_Id" = ' || "mi_id" || ' AND h."HRME_Id" != 0 AND b."ASMAY_Id" = ' || "year" || ' AND b."IMCT_ActiveFlag" = 1 ' || "category" || '
                    ORDER BY e."ASMCL_Order", f."ASMC_Order"';

        RETURN QUERY EXECUTE "query";

    END IF;

    RETURN;

END;
$$;