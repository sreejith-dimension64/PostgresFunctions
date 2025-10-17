CREATE OR REPLACE FUNCTION "dbo"."CLG_Portal_ExamDetails"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE(
    "EME_ExamName" VARCHAR,
    "ECSTMP_Percentage" NUMERIC,
    "AMSE_SEMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."EME_ExamName",
        a."ECSTMP_Percentage",
        c."AMSE_SEMName"
    FROM "clg"."Exm_Col_Student_Marks_Process" a
    INNER JOIN "Exm"."Exm_Master_Exam" b ON a."EME_Id" = b."EME_Id"
    INNER JOIN "clg"."Adm_Master_Semester" c ON c."AMSE_Id" = a."AMSE_Id"
    WHERE a."AMCST_Id" = p_AMCST_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."MI_Id" = p_MI_Id;
END;
$$;