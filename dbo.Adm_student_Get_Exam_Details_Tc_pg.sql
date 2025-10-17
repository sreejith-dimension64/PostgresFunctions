CREATE OR REPLACE FUNCTION "dbo"."Adm_student_Get_Exam_Details_Tc"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "EME_Id" INTEGER,
    "EME_ExamName" VARCHAR,
    "EME_ExamOrder" INTEGER,
    "ESTMP_Result" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMCL_Id TEXT;
    v_ASMS_Id TEXT;
    v_EMCA_Id TEXT;
BEGIN
    
    SELECT DISTINCT "ASMCL_Id", "ASMS_Id" 
    INTO v_ASMCL_Id, v_ASMS_Id
    FROM "Adm_School_Y_Student" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
        AND "AMST_Id" = p_AMST_Id 
        AND "AMAY_ActiveFlag" = 1
    LIMIT 1;

    SELECT DISTINCT "EMCA_Id" 
    INTO v_EMCA_Id
    FROM "Exm"."Exm_Category_Class" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = v_ASMCL_Id 
        AND "ASMS_Id" = v_ASMS_Id 
        AND "ECAC_ActiveFlag" = 1
    LIMIT 1;

    RETURN QUERY
    SELECT A."EME_Id", 
           C."EME_ExamName", 
           C."EME_ExamOrder", 
           D."ESTMP_Result" 
    FROM "Exm"."Exm_Yearly_Category_Exams" A 
    INNER JOIN "Exm"."Exm_Yearly_Category" B ON A."EYC_Id" = B."EYC_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" C ON C."EME_Id" = A."EME_Id"
    INNER JOIN "Exm"."Exm_Student_Marks_Process" D ON D."EME_Id" = C."EME_Id" 
        AND D."ASMAY_Id" = p_ASMAY_Id 
        AND D."AMST_Id" = p_AMST_Id
    WHERE B."EMCA_Id" = v_EMCA_Id 
        AND B."ASMAY_Id" = p_ASMAY_Id 
        AND B."EYC_ActiveFlg" = 1 
        AND A."EYCE_ActiveFlg" = 1 
        AND C."MI_Id" = p_MI_Id
    ORDER BY C."EME_ExamOrder" DESC
    LIMIT 1;

END;
$$;