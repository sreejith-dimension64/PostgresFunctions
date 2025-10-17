CREATE OR REPLACE FUNCTION "dbo"."AdmissionClassChange" (
    p_ASMAY_ID TEXT
)
RETURNS TABLE (
    "newclass" VARCHAR,
    "oldclass" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "AMST_FirstName" VARCHAR,
    "ASSCOC_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT c."ASMCL_ClassName" 
         FROM "adm_School_m_class" c 
         WHERE b."ASMCL_Id_New" = c."ASMCL_Id") AS "newclass",
        (SELECT c."ASMCL_ClassName" 
         FROM "adm_School_m_class" c 
         WHERE b."ASMCL_Id_Old" = c."ASMCL_Id") AS "oldclass",
        a."AMST_AdmNo",
        a."AMST_FirstName",
        b."ASSCOC_Remarks"
    FROM "adm_M_Student" a 
    INNER JOIN "dbo"."Adm_School_Student_COC" b ON a."amst_id" = b."amst_id" 
    WHERE a."ASMAY_Id" = p_ASMAY_ID::VARCHAR;
END;
$$;