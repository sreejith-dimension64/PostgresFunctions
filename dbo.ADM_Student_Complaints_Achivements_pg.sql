CREATE OR REPLACE FUNCTION "dbo"."ADM_Student_Complaints_Achivements" (
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "ReportFlag" BIGINT,
    "ReportType" VARCHAR(20)
)
RETURNS TABLE (
    "AMST_FirstName" TEXT,
    "ASMS_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASTEC_Date" TIMESTAMP,
    "ASTEC_Extracurricular" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ASTECD_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ASTECD_FileName" TEXT,
    "ASTECD_FilePath" TEXT,
    "ASCOMP_Id" BIGINT,
    "ASCOMP_Subject" TEXT,
    "ASCOMP_FilePath" TEXT,
    "ASCOMP_Date" TIMESTAMP,
    "ASCOMP_Complaints" TEXT,
    "ASCOMP_FileName" TEXT,
    "ASCOMP_CorrectiveAction" TEXT,
    "AMST_AdmNo" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "ReportFlag" = 2 AND "ReportType" = 'Ind' THEN
        RETURN QUERY
        SELECT 
            (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "AMST_FirstName",
            e."ASMS_Id",
            e."ASMAY_Id",
            e."ASMCL_Id",
            a."ASTEC_Date",
            a."ASTEC_Extracurricular",
            d."ASMCL_ClassName",
            f."ASMC_SectionName",
            b."ASTECD_Id",
            a."AMST_Id",
            b."ASTECD_FileName",
            b."ASTECD_FilePath",
            NULL::BIGINT AS "ASCOMP_Id",
            NULL::TEXT AS "ASCOMP_Subject",
            NULL::TEXT AS "ASCOMP_FilePath",
            NULL::TIMESTAMP AS "ASCOMP_Date",
            NULL::TEXT AS "ASCOMP_Complaints",
            NULL::TEXT AS "ASCOMP_FileName",
            NULL::TEXT AS "ASCOMP_CorrectiveAction",
            NULL::TEXT AS "AMST_AdmNo"
        FROM 
            "Adm_Student_Achivements" a
        INNER JOIN "Adm_Student_Achivements_Documents" b ON a."ASTEC_Id" = b."ASTEC_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" e ON e."AMST_Id" = a."AMST_Id" AND e."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = e."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = e."ASMS_Id"
        WHERE 
            a."ASTEC_ActiveFlg" = 1
            AND b."ASTECD_ActiveFlg" = 1
            AND e."ASMAY_Id" = "ASMAY_Id"
            AND c."MI_Id" = "MI_Id"
            AND e."ASMCL_Id" = "ASMCL_Id"
            AND e."ASMS_Id" = "ASMS_Id";

    ELSIF "ReportFlag" = 1 AND "ReportType" = 'Ind' THEN
        RETURN QUERY
        SELECT DISTINCT
            (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "AMST_FirstName",
            e."ASMS_Id",
            a."ASMAY_Id",
            d."ASMCL_Id",
            NULL::TIMESTAMP AS "ASTEC_Date",
            NULL::TEXT AS "ASTEC_Extracurricular",
            d."ASMCL_ClassName",
            e."ASMC_SectionName",
            NULL::BIGINT AS "ASTECD_Id",
            c."AMST_Id",
            NULL::TEXT AS "ASTECD_FileName",
            NULL::TEXT AS "ASTECD_FilePath",
            f."ASCOMP_Id",
            f."ASCOMP_Subject",
            f."ASCOMP_FilePath",
            f."ASCOMP_Date",
            f."ASCOMP_Complaints",
            f."ASCOMP_FileName",
            f."ASCOMP_CorrectiveAction",
            c."AMST_AdmNo"
        FROM 
            "Adm_School_M_Academic_Year" a
        INNER JOIN "Adm_School_Y_Student" b ON a."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Adm_M_Student" c ON b."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
        INNER JOIN "Adm_Student_Complaints" f ON b."AMST_Id" = f."AMST_Id"
        WHERE 
            f."MI_Id" = "MI_Id"
            AND a."ASMAY_Id" = "ASMAY_Id"
            AND b."ASMCL_Id" = "ASMCL_Id"
            AND b."ASMS_Id" = "ASMS_Id";

    ELSIF "ReportFlag" = 2 AND "ReportType" = 'ALL' THEN
        RETURN QUERY
        SELECT 
            (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "AMST_FirstName",
            e."ASMS_Id",
            e."ASMAY_Id",
            e."ASMCL_Id",
            a."ASTEC_Date",
            a."ASTEC_Extracurricular",
            d."ASMCL_ClassName",
            f."ASMC_SectionName",
            b."ASTECD_Id",
            a."AMST_Id",
            b."ASTECD_FileName",
            b."ASTECD_FilePath",
            NULL::BIGINT AS "ASCOMP_Id",
            NULL::TEXT AS "ASCOMP_Subject",
            NULL::TEXT AS "ASCOMP_FilePath",
            NULL::TIMESTAMP AS "ASCOMP_Date",
            NULL::TEXT AS "ASCOMP_Complaints",
            NULL::TEXT AS "ASCOMP_FileName",
            NULL::TEXT AS "ASCOMP_CorrectiveAction",
            NULL::TEXT AS "AMST_AdmNo"
        FROM 
            "Adm_Student_Achivements" a
        INNER JOIN "Adm_Student_Achivements_Documents" b ON a."ASTEC_Id" = b."ASTEC_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" e ON e."AMST_Id" = a."AMST_Id" AND e."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = e."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = e."ASMS_Id"
        WHERE 
            a."ASTEC_ActiveFlg" = 1
            AND b."ASTECD_ActiveFlg" = 1
            AND e."ASMAY_Id" = "ASMAY_Id"
            AND c."MI_Id" = "MI_Id";

    ELSIF "ReportFlag" = 1 AND "ReportType" = 'ALL' THEN
        RETURN QUERY
        SELECT DISTINCT
            (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "AMST_FirstName",
            e."ASMS_Id",
            a."ASMAY_Id",
            d."ASMCL_Id",
            NULL::TIMESTAMP AS "ASTEC_Date",
            NULL::TEXT AS "ASTEC_Extracurricular",
            d."ASMCL_ClassName",
            e."ASMC_SectionName",
            NULL::BIGINT AS "ASTECD_Id",
            c."AMST_Id",
            NULL::TEXT AS "ASTECD_FileName",
            NULL::TEXT AS "ASTECD_FilePath",
            f."ASCOMP_Id",
            f."ASCOMP_Subject",
            f."ASCOMP_FilePath",
            f."ASCOMP_Date",
            f."ASCOMP_Complaints",
            f."ASCOMP_FileName",
            f."ASCOMP_CorrectiveAction",
            c."AMST_AdmNo"
        FROM 
            "Adm_School_M_Academic_Year" a
        INNER JOIN "Adm_School_Y_Student" b ON a."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Adm_M_Student" c ON b."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
        INNER JOIN "Adm_Student_Complaints" f ON b."AMST_Id" = f."AMST_Id"
        WHERE 
            f."MI_Id" = "MI_Id"
            AND a."ASMAY_Id" = "ASMAY_Id";

    END IF;

    RETURN;

END;
$$;