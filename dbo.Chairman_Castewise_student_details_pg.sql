CREATE OR REPLACE FUNCTION "dbo"."Chairman_Castewise_student_details"(
    p_MI_Id INT,
    p_ASMAY_Id INT,
    p_ASMCL_Id INT,
    p_ASMS_Id INT,
    p_IMC_Id INT
)
RETURNS TABLE (
    "AMST_Id" INT,
    "name" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_Sex" VARCHAR,
    "AMST_MobileNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."AMST_Id",
        (REPLACE(REPLACE(REPLACE(COALESCE(a."AMST_FirstName",''),'.',''),'$',''),'0','') || ' ' || 
         REPLACE(REPLACE(REPLACE(COALESCE(a."AMST_MiddleName",''),'.',''),'$',''),'0','') || ' ' || 
         REPLACE(REPLACE(REPLACE(COALESCE(a."AMST_LastName",''),'.',''),'$',''),'0',''))::TEXT AS "name",
        a."AMST_AdmNo",
        a."AMST_RegistrationNo",
        a."AMST_Sex",
        a."AMST_MobileNo"
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id"
    INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IC_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."AMST_SOL" = 'S' 
        AND a."AMST_ActiveFlag" = 1 
        AND b."AMAY_ActiveFlag" = 1 
        AND b."ASMAY_Id" = p_ASMAY_Id
        AND b."ASMS_Id" = p_ASMS_Id 
        AND b."ASMCL_Id" = p_ASMCL_Id 
        AND c."IMC_Id" = p_IMC_Id
    GROUP BY 
        b."AMST_Id",
        a."AMST_FirstName",
        a."AMST_MiddleName",
        a."AMST_LastName",
        a."AMST_AdmNo",
        a."AMST_RegistrationNo",
        a."AMST_Sex",
        a."AMST_MobileNo"
    ORDER BY b."AMST_Id";
    
    RETURN;
END;
$$;