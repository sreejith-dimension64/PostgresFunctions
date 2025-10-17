CREATE OR REPLACE FUNCTION "Adm_Get_ConsCertificate_stud_rpt"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASC_ReportType TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT
)
RETURNS TABLE(
    "AMST_AdmNo" VARCHAR,
    "AMST_FirstName" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "AMST_DOB" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
BEGIN
    IF (p_ASMS_Id = '0') THEN
        v_SQLQUERY := 'SELECT c."AMST_AdmNo", 
            CONCAT(c."AMST_FirstName", '' '', c."AMST_MiddleName", ''  '', c."AMST_LastName") AS "AMST_FirstName",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            c."AMST_MobileNo",
            TO_CHAR(c."AMST_DOB", ''DD-MM-YYYY'') AS "AMST_DOB"
        FROM "Adm_Study_Certificate_Report" a
        INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = a."ASMAY_Id" AND d."MI_Id" = a."MI_Id"
        INNER JOIN "Adm_School_M_Class" e ON b."ASMCL_Id" = e."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = b."ASMS_Id"
        WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND c."MI_Id" = ' || p_MI_Id || ' 
            AND b."ASMCL_Id" IN (' || p_ASMCL_Id || ')
            AND a."ASC_ReportType" = COALESCE(''' || p_ASC_ReportType || ''', a."ASC_ReportType") 
            AND a."ASC_ReportType" IS NOT NULL
        GROUP BY c."AMST_FirstName", c."AMST_MiddleName", c."AMST_LastName", 
            e."ASMCL_ClassName", f."ASMC_SectionName", c."AMST_AdmNo", c."AMST_DOB", c."AMST_MobileNo"';
        
        RETURN QUERY EXECUTE v_SQLQUERY;
    ELSE
        v_SQLQUERY := 'SELECT c."AMST_AdmNo", 
            CONCAT(c."AMST_FirstName", '' '', c."AMST_MiddleName", ''  '', c."AMST_LastName") AS "AMST_FirstName",
            e."ASMCL_ClassName",
            f."ASMC_SectionName",
            c."AMST_MobileNo",
            TO_CHAR(c."AMST_DOB", ''DD-MM-YYYY'') AS "AMST_DOB"
        FROM "Adm_Study_Certificate_Report" a
        INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = a."ASMAY_Id" AND d."MI_Id" = a."MI_Id"
        INNER JOIN "Adm_School_M_Class" e ON b."ASMCL_Id" = e."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = b."ASMS_Id"
        WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND c."MI_Id" = ' || p_MI_Id || ' 
            AND b."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
            AND b."ASMS_Id" IN (' || p_ASMS_Id || ')
            AND a."ASC_ReportType" = COALESCE(''' || p_ASC_ReportType || ''', a."ASC_ReportType") 
            AND a."ASC_ReportType" IS NOT NULL
        GROUP BY c."AMST_FirstName", c."AMST_MiddleName", c."AMST_LastName", 
            e."ASMCL_ClassName", f."ASMC_SectionName", c."AMST_AdmNo", c."AMST_DOB", c."AMST_MobileNo"';
        
        RETURN QUERY EXECUTE v_SQLQUERY;
    END IF;
END;
$$;