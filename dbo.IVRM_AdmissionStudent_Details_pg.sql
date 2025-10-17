CREATE OR REPLACE FUNCTION "IVRM_AdmissionStudent_Details" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE (
    "AMST_FirstName" character varying,
    "AMST_MiddleName" character varying,
    "AMST_LastName" character varying,
    "amsT_Date" timestamp,
    "amsT_Sex" character varying,
    "amsT_RegistrationNo" character varying,
    "amsT_AdmNo" character varying,
    "amsT_emailId" character varying,
    "stdmobilenumber" character varying,
    "amsT_Id" bigint,
    "sectionname" character varying,
    "amsT_DOB" timestamp,
    "class" character varying,
    "amsT_SOL" character varying,
    "amsT_Photoname" character varying,
    "studentname" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT
        b."AMST_FirstName" AS "AMST_FirstName",
        b."AMST_MiddleName" AS "AMST_MiddleName",
        b."AMST_LastName" AS "AMST_LastName",
        b."AMST_Date" AS "amsT_Date",
        b."AMST_Sex" AS "amsT_Sex",
        b."AMST_RegistrationNo" AS "amsT_RegistrationNo",
        b."AMST_AdmNo" AS "amsT_AdmNo",
        b."AMST_emailId" AS "amsT_emailId",
        b."AMST_MobileNo" AS "stdmobilenumber",
        b."AMST_Id" AS "amsT_Id",
        e."ASMC_SectionName" AS "sectionname",
        b."AMST_DOB" AS "amsT_DOB",
        c."ASMCL_ClassName" AS "class",
        b."AMST_SOL" AS "amsT_SOL",
        b."AMST_Photoname" AS "amsT_Photoname",
        COALESCE(b."AMST_FirstName", '') || '' || COALESCE(b."AMST_MiddleName", '') || '' || COALESCE(b."AMST_LastName", '') AS "studentname"
    FROM "Adm_School_Y_Student" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Class" c ON a."ASMCL_Id" = c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" d ON a."ASMAY_Id" = d."ASMAY_Id"
    INNER JOIN "Adm_School_M_Section" e ON a."ASMS_Id" = e."ASMS_Id"
    WHERE b."MI_Id" = p_MI_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id 
        AND b."AMST_ActiveFlag" = true 
        AND b."AMST_SOL" != 'Del'
    ORDER BY b."AMST_Id" DESC
    LIMIT 10;

END;
$$;