CREATE OR REPLACE FUNCTION "ADM_STUDENT_DISPLAY"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_Id BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fathername" VARCHAR,
    "GuardianName" VARCHAR,
    "studentdob" TIMESTAMP,
    "amst_mobile" VARCHAR,
    "AMST_Photoname" VARCHAR,
    "ParentOrGuardianName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        a."AMST_FirstName",
        a."AMST_MiddleName",
        a."AMST_LastName",
        a."AMST_RegistrationNo",
        a."AMST_AdmNo",
        b."AMAY_RollNo",
        c."ASMCL_ClassName" AS classname,
        d."ASMC_SectionName" AS sectionname,
        a."AMST_FatherName" AS fathername,
        E."AMSTG_GuardianName" AS GuardianName,
        a."AMST_DOB" AS studentdob,
        a."AMST_MobileNo" AS amst_mobile,
        a."AMST_Photoname",
        CASE 
            WHEN a."AMST_FatherAliveFlag" = 'True' THEN a."AMST_FatherName"
            WHEN a."AMST_FatherAliveFlag" = 'False' AND a."AMST_MotherAliveFlag" = 'False' THEN E."AMSTG_GuardianName"
            ELSE a."AMST_MotherName" 
        END AS ParentOrGuardianName
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_Y_Student" b ON b."AMST_Id" = a."AMST_Id"
    INNER JOIN "Adm_School_M_Class" c ON b."ASMCL_Id" = c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = b."ASMS_Id"
    INNER JOIN "Adm_Master_Student_Guardian" E ON E."AMST_Id" = A."AMST_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND b."ASMAY_Id" = p_ASMAY_Id 
        AND a."AMST_Id" = p_AMST_Id;
END;
$$;