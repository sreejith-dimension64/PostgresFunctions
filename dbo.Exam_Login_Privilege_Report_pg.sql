CREATE OR REPLACE FUNCTION "dbo"."Exam_Login_Privilege_Report"(
    "mi_id" TEXT,
    "asmay_id" TEXT,
    "asmcl_id" TEXT,
    "asms_id" TEXT,
    "hrme_id" TEXT,
    "report_type" TEXT,
    "check_type" TEXT,
    "emca_id" TEXT
)
RETURNS TABLE(
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "HRME_EmployeeFirstName" TEXT,
    "ISMS_SubjectName" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "ISMS_OrderFlag" INTEGER,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "HRME_Id" BIGINT,
    "isms_id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "report_type" = 'all' THEN
        
        IF "hrme_id"::INTEGER > 0 THEN
            
            RETURN QUERY
            SELECT DISTINCT 
                cl."ASMCL_ClassName", 
                se."ASMC_SectionName",
                (COALESCE(g."HRME_EmployeeFirstName", '') || ' ' || COALESCE(g."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(g."HRME_EmployeeLastName", '') || ' :' || COALESCE(g."HRME_EmployeeCode", ''))::TEXT AS "HRME_EmployeeFirstName",
                d."ISMS_SubjectName", 
                cl."ASMCL_Order", 
                se."ASMC_Order", 
                d."ISMS_OrderFlag", 
                cl."ASMCL_Id", 
                se."ASMS_Id", 
                g."HRME_Id", 
                d."isms_id"
            FROM "exm"."Exm_Login_Privilege" a
            INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
            LEFT OUTER JOIN "exm"."Exm_Login_Privilege_SubSubjects" c ON c."ELPS_Id" = b."ELPS_Id"
            INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = b."ISMS_Id"
            LEFT OUTER JOIN "exm"."Exm_Master_SubSubject" e ON e."EMSS_Id" = c."EMSS_Id"
            INNER JOIN "ivrm_staff_user_login" f ON f."IVRMSTAUL_Id" = a."Login_Id"
            INNER JOIN "hr_master_employee" g ON g."HRME_Id" = f."Emp_Code"
            INNER JOIN "Adm_School_M_Class" cl ON cl."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_section" se ON se."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ye ON ye."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" class ON class."ASMCL_Id" = cl."ASMCL_Id" AND class."ASMS_Id" = se."ASMS_Id" AND class."ASMAY_Id" = ye."ASMAY_Id"
            WHERE a."MI_Id" = "mi_id"::BIGINT AND f."Emp_Code" = "hrme_id"::BIGINT AND class."EMCA_Id" = "emca_id"::BIGINT AND a."ASMAY_Id" = "asmay_id"::BIGINT AND class."ASMAY_Id" = "asmay_id"::BIGINT
            ORDER BY cl."ASMCL_Order", se."ASMC_Order", d."ISMS_OrderFlag";
            
        ELSE
            
            RETURN QUERY
            SELECT DISTINCT 
                cl."ASMCL_ClassName", 
                se."ASMC_SectionName",
                (COALESCE(g."HRME_EmployeeFirstName", '') || ' ' || COALESCE(g."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(g."HRME_EmployeeLastName", '') || ' :' || COALESCE(g."HRME_EmployeeCode", ''))::TEXT AS "HRME_EmployeeFirstName",
                d."ISMS_SubjectName", 
                cl."ASMCL_Order", 
                se."ASMC_Order", 
                d."ISMS_OrderFlag", 
                cl."ASMCL_Id", 
                se."ASMS_Id", 
                g."HRME_Id", 
                d."isms_id"
            FROM "exm"."Exm_Login_Privilege" a
            INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
            LEFT OUTER JOIN "exm"."Exm_Login_Privilege_SubSubjects" c ON c."ELPS_Id" = b."ELPS_Id"
            INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = b."ISMS_Id"
            LEFT OUTER JOIN "exm"."Exm_Master_SubSubject" e ON e."EMSS_Id" = c."EMSS_Id"
            INNER JOIN "ivrm_staff_user_login" f ON f."IVRMSTAUL_Id" = a."Login_Id"
            INNER JOIN "hr_master_employee" g ON g."HRME_Id" = f."Emp_Code"
            INNER JOIN "Adm_School_M_Class" cl ON cl."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_section" se ON se."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ye ON ye."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" class ON class."ASMCL_Id" = cl."ASMCL_Id" AND class."ASMS_Id" = se."ASMS_Id" AND class."ASMAY_Id" = ye."ASMAY_Id"
            WHERE a."MI_Id" = "mi_id"::BIGINT AND class."EMCA_Id" = "emca_id"::BIGINT AND a."ASMAY_Id" = "asmay_id"::BIGINT AND class."ASMAY_Id" = "asmay_id"::BIGINT
            ORDER BY cl."ASMCL_Order", se."ASMC_Order", d."ISMS_OrderFlag";
            
        END IF;
        
    ELSIF "report_type" != 'all' THEN
        
        IF "hrme_id"::INTEGER > 0 THEN
            
            RETURN QUERY
            SELECT DISTINCT 
                cl."ASMCL_ClassName", 
                se."ASMC_SectionName",
                (COALESCE(g."HRME_EmployeeFirstName", '') || ' ' || COALESCE(g."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(g."HRME_EmployeeLastName", '') || ' :' || COALESCE(g."HRME_EmployeeCode", ''))::TEXT AS "HRME_EmployeeFirstName",
                d."ISMS_SubjectName", 
                cl."ASMCL_Order", 
                se."ASMC_Order", 
                d."ISMS_OrderFlag", 
                cl."ASMCL_Id", 
                se."ASMS_Id", 
                g."HRME_Id", 
                d."isms_id"
            FROM "exm"."Exm_Login_Privilege" a
            INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
            LEFT OUTER JOIN "exm"."Exm_Login_Privilege_SubSubjects" c ON c."ELPS_Id" = b."ELPS_Id"
            INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = b."ISMS_Id"
            LEFT OUTER JOIN "exm"."Exm_Master_SubSubject" e ON e."EMSS_Id" = c."EMSS_Id"
            INNER JOIN "ivrm_staff_user_login" f ON f."IVRMSTAUL_Id" = a."Login_Id"
            INNER JOIN "hr_master_employee" g ON g."HRME_Id" = f."Emp_Code"
            INNER JOIN "Adm_School_M_Class" cl ON cl."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_section" se ON se."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ye ON ye."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" class ON class."ASMCL_Id" = cl."ASMCL_Id" AND class."ASMS_Id" = se."ASMS_Id" AND class."ASMAY_Id" = ye."ASMAY_Id"
            WHERE a."MI_Id" = "mi_id"::BIGINT AND f."Emp_Code" = "hrme_id"::BIGINT AND class."EMCA_Id" = "emca_id"::BIGINT AND a."ASMAY_Id" = "asmay_id"::BIGINT AND class."ASMAY_Id" = "asmay_id"::BIGINT AND class."ASMCL_Id" = "asmcl_id"::BIGINT
            AND class."ASMS_Id" = "asms_id"::BIGINT AND b."ASMCL_Id" = "asmcl_id"::BIGINT AND b."ASMS_Id" = "asms_id"::BIGINT
            ORDER BY cl."ASMCL_Order", se."ASMC_Order", d."ISMS_OrderFlag";
            
        ELSE
            
            RETURN QUERY
            SELECT DISTINCT 
                cl."ASMCL_ClassName", 
                se."ASMC_SectionName",
                (COALESCE(g."HRME_EmployeeFirstName", '') || ' ' || COALESCE(g."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(g."HRME_EmployeeLastName", '') || ' :' || COALESCE(g."HRME_EmployeeCode", ''))::TEXT AS "HRME_EmployeeFirstName",
                d."ISMS_SubjectName", 
                cl."ASMCL_Order", 
                se."ASMC_Order", 
                d."ISMS_OrderFlag", 
                cl."ASMCL_Id", 
                se."ASMS_Id", 
                g."HRME_Id", 
                d."isms_id"
            FROM "exm"."Exm_Login_Privilege" a
            INNER JOIN "exm"."Exm_Login_Privilege_Subjects" b ON a."ELP_Id" = b."ELP_Id"
            LEFT OUTER JOIN "exm"."Exm_Login_Privilege_SubSubjects" c ON c."ELPS_Id" = b."ELPS_Id"
            INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = b."ISMS_Id"
            LEFT OUTER JOIN "exm"."Exm_Master_SubSubject" e ON e."EMSS_Id" = c."EMSS_Id"
            INNER JOIN "ivrm_staff_user_login" f ON f."IVRMSTAUL_Id" = a."Login_Id"
            INNER JOIN "hr_master_employee" g ON g."HRME_Id" = f."Emp_Code"
            INNER JOIN "Adm_School_M_Class" cl ON cl."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_section" se ON se."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ye ON ye."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" class ON class."ASMCL_Id" = cl."ASMCL_Id" AND class."ASMS_Id" = se."ASMS_Id" AND class."ASMAY_Id" = ye."ASMAY_Id"
            WHERE a."MI_Id" = "mi_id"::BIGINT AND class."EMCA_Id" = "emca_id"::BIGINT AND a."ASMAY_Id" = "asmay_id"::BIGINT AND class."ASMAY_Id" = "asmay_id"::BIGINT AND class."ASMCL_Id" = "asmcl_id"::BIGINT
            AND class."ASMS_Id" = "asms_id"::BIGINT AND b."ASMCL_Id" = "asmcl_id"::BIGINT AND b."ASMS_Id" = "asms_id"::BIGINT
            ORDER BY cl."ASMCL_Order", se."ASMC_Order", d."ISMS_OrderFlag";
            
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;