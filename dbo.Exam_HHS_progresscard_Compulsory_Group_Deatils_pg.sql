CREATE OR REPLACE FUNCTION "dbo"."Exam_HHS_progresscard_Compulsory_Group_Deatils"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "per" NUMERIC(18,2),
    "obtmarks" NUMERIC(18,2),
    "maxmarks" NUMERIC,
    "EME_ExamName" VARCHAR,
    "EME_Id" INTEGER,
    "ESG_SubjectGroupName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@EMCA_Id" TEXT;
BEGIN

    SELECT DISTINCT A."EMCA_Id" INTO "@EMCA_Id"
    FROM "EXM"."Exm_Master_Category" A 
    INNER JOIN "EXM"."Exm_Category_Class" B ON A."EMCA_Id" = B."EMCA_Id" 
    WHERE B."ASMAY_Id" = "@ASMAY_Id" 
    AND B."ASMCL_Id" = "@ASMCL_Id" 
    AND B."ASMS_Id" = "@ASMS_Id" 
    AND B."ECAC_ActiveFlag" = 1 
    AND A."EMCA_ActiveFlag" = 1;

    RETURN QUERY
    SELECT 
        CAST(ROUND(((SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_ObtainedMarks")::NUMERIC / 
            NULLIF(SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_MaxMarks")::NUMERIC, 0)) * 100), 2) AS NUMERIC(18,2)) AS "per",
        CAST((SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_ObtainedMarks")::NUMERIC / 3) AS NUMERIC(18,2)) AS "obtmarks",
        SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_MaxMarks") AS "maxmarks",
        "EME_ExamName",
        "Exm"."Exm_Subject_Group_Exams"."EME_Id",
        "Exm"."Exm_Subject_Group"."ESG_SubjectGroupName"
    FROM "Exm"."Exm_Subject_Group" 
    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
        ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
    INNER JOIN "Exm"."Exm_Subject_Group_Exams" 
        ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group"."ESG_Id"
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Student_Marks_Process_Subjectwise"."ISMS_Id" 
    INNER JOIN "exm"."Exm_Master_Exam" 
        ON "exm"."Exm_Master_Exam"."EME_Id" = "Exm"."Exm_Student_Marks_Process_Subjectwise"."EME_Id"
        AND "Exm"."Exm_Master_Exam"."EME_Id" = "Exm"."Exm_Subject_Group_Exams"."EME_Id"
    WHERE "Exm"."Exm_Subject_Group"."MI_Id" = "@MI_Id"
    AND "Exm"."Exm_Subject_Group"."ASMAY_Id" = "@ASMAY_Id"
    AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y'
    AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."AMST_Id" = "@AMST_Id"
    AND "Exm"."Exm_Subject_Group"."EMCA_Id" = "@EMCA_Id"
    GROUP BY "EME_ExamName", "Exm"."Exm_Subject_Group_Exams"."EME_Id", "Exm"."Exm_Subject_Group"."ESG_SubjectGroupName";

END;
$$;