CREATE OR REPLACE FUNCTION "dbo"."Exam_Staffload_Year_Insti"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT
)
RETURNS TABLE(
    "ISMS_SubjectName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT E."ISMS_SubjectName"
    FROM "Exm"."Exm_Student_Marks" A
    INNER JOIN "Adm_School_M_class" B ON B."ASMCL_Id" = A."ASMCL_Id"
    INNER JOIN "Adm_School_M_section" C ON C."ASMS_Id" = A."ASMS_Id"
    INNER JOIN "ApplicationUser" D ON D."Id" = A."Id"
    INNER JOIN "IVRM_Master_Subjects" E ON E."ISMS_ID" = A."ISMS_ID"
    WHERE A."MI_ID" = p_MI_ID AND A."asmay_id" = p_ASMAY_ID
    GROUP BY D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", E."ISMS_SubjectName";
END;
$$;