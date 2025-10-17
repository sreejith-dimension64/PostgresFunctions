CREATE OR REPLACE FUNCTION "dbo"."EXM_student_details"(
    "ASMAY_Id" TEXT,
    "asmcl_id" TEXT,
    "ASMS_Id" TEXT,
    "EME_Id" TEXT,
    "amst_id" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "studentname" TEXT,
    "EME_ExamName" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ESTMP_TotalMaxMarks" NUMERIC,
    "ESTMP_TotalObtMarks" NUMERIC,
    "ESTMP_Percentage" NUMERIC,
    "ESTMP_TotalGrade" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT DISTINCT ASYS."AMST_Id",
        (COALESCE(AMST."AMST_FirstName",'''') || '' '' || COALESCE(AMST."AMST_MiddleName",'''') || '' '' || COALESCE(AMST."AMST_LastName",'''')) AS studentname,
        EME."EME_ExamName",
        CLS."ASMCL_ClassName" AS "ASMCL_ClassName",
        ASS."ASMC_SectionName" AS "ASMC_SectionName",
        ESMP."ESTMP_TotalMaxMarks",
        ESMP."ESTMP_TotalObtMarks",
        ESMP."ESTMP_Percentage",
        ESMP."ESTMP_TotalGrade"
    FROM "Exm"."Exm_Student_Marks_Process" ESMP
    INNER JOIN "Adm_School_Y_Student" ASYS ON ESMP."AMST_Id" = ASYS."AMST_Id"
    INNER JOIN "Adm_M_Student" AMST ON AMST."AMST_Id" = ASYS."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" ASM ON ASM."ASMAY_Id" = ASYS."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" CLS ON CLS."ASMCL_Id" = ASYS."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ASS ON ASS."ASMS_Id" = ASYS."ASMS_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" EME ON EME."EME_Id" = ESMP."EME_Id"
    INNER JOIN "Exm"."Exm_Category_Class" ECC ON ECC."ASMAY_Id" = ASM."ASMAY_Id" 
        AND ECC."ASMCL_Id" = CLS."ASMCL_Id" 
        AND ECC."ASMS_Id" = ASS."ASMS_Id" 
        AND ECC."ECAC_ActiveFlag" = 1
    INNER JOIN "EXM"."Exm_Master_Category" EMC ON EMC."EMCA_Id" = ECC."EMCA_Id" 
        AND EMC."EMCA_ActiveFlag" = 1
    INNER JOIN "Exm"."Exm_Yearly_Category" EYC ON EYC."EMCA_Id" = EMC."EMCA_Id" 
        AND EYC."ASMAY_id" = ASM."ASMAY_Id" 
        AND EYC."EYC_ActiveFlg" = 1
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" EYCE ON EYCE."EYC_ID" = EYC."EYC_ID"
    WHERE ESMP."ASMAY_Id" = ' || "ASMAY_Id" || '
        AND ESMP."ASMCL_Id" = ' || "asmcl_id" || '
        AND ESMP."ASMS_Id" = ' || "ASMS_Id" || '
        AND ASYS."AMAY_ActiveFlag" = 1
        AND AMST."AMST_ACTIVEFLAG" = 1
        AND AMST."AMST_SOL" = ''S''
        AND ASYS."ASMAY_Id" = ' || "ASMAY_Id" || '
        AND ASYS."ASMCL_Id" = ' || "asmcl_id" || '
        AND ASYS."ASMS_Id" = ' || "ASMS_Id" || '
        AND ESMP."EME_Id" IN (' || "EME_Id" || ')
        AND ASYS."AMAY_ActiveFlag" = 1
        AND ESMP."AMST_Id" IN (' || "amst_id" || ')
        AND ASYS."AMST_Id" IN (' || "amst_id" || ')
        AND ESMP."MI_ID" = ' || "mi_id" || '
    ORDER BY EME."EME_ExamName"';

    RETURN QUERY EXECUTE v_sql;
    
    RETURN;
END;
$$;