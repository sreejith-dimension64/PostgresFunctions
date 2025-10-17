CREATE OR REPLACE FUNCTION "ADM_Complaints_Achivements_Student_Portal"(
    "ASMAY_Id" BIGINT,
    "AMST_Id" BIGINT,
    "MI_Id" BIGINT,
    "FLAG" VARCHAR(255)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "AMST_FirstName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASTEC_Date" TIMESTAMP,
    "ASTEC_Extracurricular" TEXT,
    "ASTECD_Id" BIGINT,
    "ASTECD_FileName" VARCHAR,
    "ASTECD_FilePath" VARCHAR,
    "ASCOMP_Id" BIGINT,
    "ASCOMP_Subject" VARCHAR,
    "ASCOMP_FilePath" VARCHAR,
    "ASCOMP_Date" TIMESTAMP,
    "ASCOMP_Complaints" TEXT,
    "ASCOMP_FileName" VARCHAR,
    "ASCOMP_CorrectiveAction" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "FLAG" = 'Achievements' THEN
        RETURN QUERY
        SELECT 
            a."AMST_Id",
            e."ASMS_Id",
            e."ASMAY_Id",
            e."ASMCL_Id",
            (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "AMST_FirstName",
            NULL::VARCHAR AS "AMST_AdmNo",
            d."ASMCL_ClassName",
            f."ASMC_SectionName",
            a."ASTEC_Date",
            a."ASTEC_Extracurricular",
            b."ASTECD_Id",
            b."ASTECD_FileName",
            b."ASTECD_FilePath",
            NULL::BIGINT AS "ASCOMP_Id",
            NULL::VARCHAR AS "ASCOMP_Subject",
            NULL::VARCHAR AS "ASCOMP_FilePath",
            NULL::TIMESTAMP AS "ASCOMP_Date",
            NULL::TEXT AS "ASCOMP_Complaints",
            NULL::VARCHAR AS "ASCOMP_FileName",
            NULL::TEXT AS "ASCOMP_CorrectiveAction"
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
            AND a."AMST_Id" = "AMST_Id"
            AND c."MI_Id" = "MI_Id";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            c."AMST_Id",
            e."ASMS_Id",
            a."ASMAY_Id",
            d."ASMCL_Id",
            (c."AMST_FirstName" || ' ' || c."AMST_MiddleName" || ' ' || c."AMST_LastName") AS "AMST_FirstName",
            c."AMST_AdmNo",
            d."ASMCL_ClassName",
            e."ASMC_SectionName",
            NULL::TIMESTAMP AS "ASTEC_Date",
            NULL::TEXT AS "ASTEC_Extracurricular",
            NULL::BIGINT AS "ASTECD_Id",
            NULL::VARCHAR AS "ASTECD_FileName",
            NULL::VARCHAR AS "ASTECD_FilePath",
            f."ASCOMP_Id",
            f."ASCOMP_Subject",
            f."ASCOMP_FilePath",
            f."ASCOMP_Date",
            f."ASCOMP_Complaints",
            f."ASCOMP_FileName",
            f."ASCOMP_CorrectiveAction"
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
            AND b."AMST_Id" = "AMST_Id";
    END IF;

    RETURN;

END;
$$;