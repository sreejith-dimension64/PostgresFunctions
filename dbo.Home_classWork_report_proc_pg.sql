CREATE OR REPLACE FUNCTION "dbo"."Home_classWork_report_proc"(
    "@MI_Id" bigint,
    "@upload_flg" TEXT
)
RETURNS TABLE(
    "employeename" TEXT,
    "work_type" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "topic" TEXT,
    "Id" INTEGER,
    "HRME_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@upload_flg" = 'upload' THEN
        RETURN QUERY
        SELECT DISTINCT 
            COALESCE(d."HRME_EmployeeFirstName", '') || '' || COALESCE(d."HRME_EmployeeMiddleName", '') || '' || COALESCE(d."HRME_EmployeeLastName", '') AS "employeename",
            'Class Work'::TEXT AS "work_type",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            g."ISMS_SubjectName",
            b."ICW_Topic" AS "topic",
            NULL::INTEGER AS "Id",
            NULL::BIGINT AS "HRME_Id"
        FROM 
            "IVRM_Assignment" b,
            "IVRM_Staff_User_Login" c,
            "HR_Master_Employee" d,
            "Adm_School_M_Class" e,
            "Adm_School_M_Section" f,
            "IVRM_Master_Subjects" g
        WHERE 
            c."Id" = b."Login_Id" 
            AND c."Emp_Code" = d."HRME_Id" 
            AND b."ICW_FromDate" = CURRENT_DATE
            AND b."MI_Id" = "@MI_Id" 
            AND b."MI_Id" = b."MI_Id" 
            AND e."ASMCL_Id" = b."ASMCL_Id" 
            AND f."ASMS_Id" = b."ASMS_Id" 
            AND g."ISMS_Id" = b."ISMS_Id" 
            AND b."MI_Id" = g."MI_Id"
        
        UNION ALL
        
        SELECT DISTINCT 
            COALESCE(d."HRME_EmployeeFirstName", '') || '' || COALESCE(d."HRME_EmployeeMiddleName", '') || '' || COALESCE(d."HRME_EmployeeLastName", '') AS "employeename",
            'Home Work'::TEXT AS "work_type",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            g."ISMS_SubjectName",
            a."ihw_topic" AS "topic",
            NULL::INTEGER AS "Id",
            NULL::BIGINT AS "HRME_Id"
        FROM 
            "IVRM_HomeWork" a,
            "IVRM_Staff_User_Login" c,
            "HR_Master_Employee" d,
            "Adm_School_M_Class" e,
            "Adm_School_M_Section" f,
            "IVRM_Master_Subjects" g
        WHERE 
            a."IVRMUL_Id" = c."Id" 
            AND c."Emp_Code" = d."HRME_Id" 
            AND a."IHW_Date" = CURRENT_DATE
            AND a."MI_Id" = "@MI_Id" 
            AND a."MI_Id" = d."MI_Id" 
            AND e."ASMCL_Id" = a."ASMCL_Id" 
            AND f."ASMS_Id" = a."ASMS_Id" 
            AND g."ISMS_Id" = a."ISMS_Id" 
            AND a."MI_Id" = g."MI_Id";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            NULL::TEXT AS "employeename",
            NULL::TEXT AS "work_type",
            NULL::VARCHAR AS "ASMCL_ClassName",
            NULL::VARCHAR AS "ASMC_SectionName",
            NULL::VARCHAR AS "ISMS_SubjectName",
            '1b'::TEXT AS "topic",
            d."Id",
            b."HRME_Id"
        FROM 
            "IVRM_Staff_User_Login" a,
            "HR_Master_Employee" b,
            "ApplicationUserRole" c,
            "ApplicationRole" d
        WHERE 
            a."Emp_Code" = b."HRME_Id" 
            AND a."id" NOT IN (
                SELECT "IVRMUL_Id" 
                FROM "IVRM_HomeWork" 
                WHERE CAST("UpdatedDate" AS DATE) = CURRENT_DATE
                UNION ALL
                SELECT "Login_Id" 
                FROM "IVRM_Assignment" 
                WHERE CAST("UpdatedDate" AS DATE) = CURRENT_DATE
            )
            AND d."Name" = 'Staff' 
            AND a."MI_Id" = "@MI_Id" 
            AND a."MI_Id" = b."MI_Id";
            
        UPDATE "employeename"
        SET "employeename" = COALESCE(b."HRME_EmployeeFirstName", '') || '' || COALESCE(b."HRME_EmployeeMiddleName", '') || '' || COALESCE(b."HRME_EmployeeLastName", '')
        FROM "IVRM_Staff_User_Login" a, "HR_Master_Employee" b
        WHERE a."Emp_Code" = b."HRME_Id";
    END IF;
END;
$$;