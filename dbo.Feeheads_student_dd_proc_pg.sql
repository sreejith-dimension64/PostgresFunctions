CREATE OR REPLACE FUNCTION "dbo"."Feeheads_student_dd_proc"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE (
    studentname text,
    "AMST_Id" bigint,
    "MI_Id" bigint,
    "ASMAY_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE("AMST_FirstName", '') || COALESCE("AMST_MiddleName", '') || COALESCE("AMST_LastName", '')) as studentname,
        "AMST_Id",
        "MI_Id",
        "ASMAY_Id"
    FROM "Adm_M_Student"
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id;
END;
$$;