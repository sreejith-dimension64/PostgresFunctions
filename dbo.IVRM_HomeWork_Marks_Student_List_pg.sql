CREATE OR REPLACE FUNCTION "dbo"."IVRM_HomeWork_Marks_Student_List"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "studentname" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT  
        a."AMST_Id", 
        (COALESCE(b."AMST_FirstName", '') || COALESCE(b."AMST_MiddleName", '') || COALESCE(b."AMST_LastName", '')) as studentname 
    FROM "Adm_School_Y_Student" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id" AND c."MI_Id" = p_MI_Id
    INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id" AND d."MI_Id" = p_MI_Id
    WHERE a."ASMAY_Id" = p_ASMAY_Id 
        AND a."AMAY_ActiveFlag" = 1 
        AND b."AMST_ActiveFlag" = 1 
        AND b."AMST_SOL" = 'S' 
        AND b."MI_Id" = p_MI_Id 
        AND a."ASMCL_Id" = p_ASMCL_Id 
        AND a."ASMS_Id" = p_ASMS_Id;

END;
$$;