CREATE OR REPLACE FUNCTION "EXAM_STUDENT_DETAILS"(
    p_MI_ID TEXT
)
RETURNS TABLE(
    "ESTMP_TotalMaxMarks" NUMERIC,
    "AMAY_RollNo" VARCHAR,
    "AMST_FirstName" VARCHAR,
    "FullName" TEXT,
    "AMST_LastName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_STUDENT TEXT;
    v_query TEXT;
BEGIN
    v_STUDENT := '
SELECT A."ESTMP_TotalMaxMarks",
       B."AMAY_RollNo",
       C."AMST_FirstName",
       COALESCE(C."AMST_MiddleName", '''') || '''' ||,
       C."AMST_LastName"
FROM "Exm"."Exm_Student_Marks_Process" A 
INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
INNER JOIN "Adm_M_Student" C ON C."ASMST_Id" = A."AMST_Id"
INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = A."ASMAY_Id"
INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = A."ASMCL_Id"
INNER JOIN "Adm_School_M_Class_Category" F ON F."ASMAY_Id" = A."ASMAY_Id"
INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = A."ASMS_Id"
INNER JOIN "EXM"."Exm_Master_Exam" H ON H."EME_Id" = A."EME_Id"
INNER JOIN "Exm"."Exm_Category_Class" I ON I."ASMS_Id" = A."ASMS_Id"
INNER JOIN "EXM"."Exm_Master_Category" J ON J."EMCA_Id" = I."EMCA_Id"
INNER JOIN "Exm"."Exm_Yearly_Category_Exams" K ON K."EME_Id" = A."EME_Id"
INNER JOIN "Exm"."Exm_Yearly_Category" L ON L."EYC_Id" = K."EYC_Id"
WHERE A."MI_Id" IN (' || p_MI_ID || ')';

    RETURN QUERY EXECUTE v_STUDENT;
    
END;
$$;