CREATE OR REPLACE FUNCTION "dbo"."exm_subject_wise_report"(
    "ASMAY_ID" TEXT,
    "MI_id" TEXT,
    "ASMCL_id" TEXT,
    "ASMS_id" TEXT,
    "AMST_ID" TEXT,
    "EME_id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "ISMS_Id" INTEGER,
    "ISMS_SubjectName" TEXT,
    "ISMS_SubjectCode" TEXT,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MaxMarks" NUMERIC,
    "EYCES_MinMarks" NUMERIC,
    "ESTMPS_MaxMarks" NUMERIC,
    "ESTMPS_ClassAverage" NUMERIC,
    "ESTMPS_SectionAverage" NUMERIC,
    "ESTMPS_ClassHighest" NUMERIC,
    "ESTMPS_SectionHighest" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" TEXT,
    "ESTMPS_PassFailFlg" TEXT,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCES_GradeDisplayFlg" BOOLEAN,
    "ESTMPS_ClassRank" INTEGER,
    "ESTMPS_SectionRank" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT DISTINCT  ADM."AMST_Id",EYCES."ISMS_Id",  IMS."ISMS_SubjectName",   IMS."ISMS_SubjectCode",EYCES."EYCES_AplResultFlg",EYCES."EYCES_MaxMarks",EYCES."EYCES_MinMarks",
ESMTMPS."ESTMPS_MaxMarks",ESMTMPS."ESTMPS_ClassAverage",ESMTMPS."ESTMPS_SectionAverage",  
ESMTMPS."ESTMPS_ClassHighest",ESMTMPS."ESTMPS_SectionHighest",  
ESMTMPS."ESTMPS_ObtainedMarks",ESMTMPS."ESTMPS_ObtainedGrade",ESMTMPS."ESTMPS_PassFailFlg",
 EYCES."EYCES_SubjectOrder", EYCES."EYCES_MarksDisplayFlg", EYCES."EYCES_GradeDisplayFlg", EYCES."EYCES_AplResultFlg",ESMTMPS."ESTMPS_SectionHighest"
,ESMTMPS."ESTMPS_ClassHighest",ESMTMPS."ESTMPS_SectionHighest",ESMTMPS."ESTMPS_ClassRank",ESMTMPS."ESTMPS_SectionRank"
FROM   "Adm_M_Student"                                 ADM
INNER JOIN  "Adm_School_Y_Student"                     ASYS   ON  ADM."AMST_Id"= ASYS."AMST_id"
INNER JOIN  "exm"."Exm_Master_Exam"                      EME    ON  EME."MI_ID"= ADM."MI_Id"
INNER JOIN  "exm"."Exm_Yearly_Category"                  EYC    ON   EYC."ASMAY_Id"=ASYS."ASMAY_Id"
INNER JOIN  "exm"."Exm_Master_Category"                  EMC    ON  EMC."EMCA_Id"=EYC."EMCA_Id"
INNER JOIN  "exm"."Exm_Category_Class"                   ECC    ON   ECC."EMCA_Id"=EMC."EMCA_Id" AND ECC."ECAC_ActiveFlag"=1
INNER JOIN  "exm"."Exm_Yearly_Category_Exams"            EYCE   ON EYCE."EYC_Id"=EYC."EYC_Id" AND EYCE."EYCE_ActiveFlg"=1 AND  EYCE."EME_Id"=EME."EME_Id"
INNER JOIN  "exm"."Exm_Yrly_Cat_Exams_Subwise"           EYCES  ON EYCES."EYCE_Id"=EYCE."EYCE_Id" AND EYCES."EYCES_ActiveFlg" = 1 AND EYCES."EYCES_ActiveFlg"=1
INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ESMTMPS ON ESMTMPS."ISMS_Id"= EYCES."isms_id"
INNER JOIN  "IVRM_Master_Subjects"                     IMS    ON IMS."ISMS_ID"= EYCES."ISMS_Id"
INNER JOIN  "Exm"."Exm_Studentwise_Subjects"             ESS    ON ESS."ISMS_Id" = ESMTMPS."ISMS_Id" AND ESS."AMST_Id"=ADM."AMST_Id"
INNER JOIN  "Adm_School_M_Class"                       CLS    ON   ASYS."ASMCL_Id" = CLS."ASMCL_Id"
INNER JOIN   "Adm_School_M_Section"                    SEC    ON    SEC."ASMS_id"=ESMTMPS."ASMS_ID"
WHERE   ADM."AMST_ActiveFlag" = 1 AND ADM."AMST_SOL" =''S'' AND ASYS."AMAY_ActiveFlag" = 1 
AND ASYS."ASMAY_Id" =' || "ASMAY_ID" || ' AND ASYS."ASMCL_Id" =' || "ASMCL_id" || ' AND ASYS."ASMS_Id" =' || "ASMS_id" || ' AND
ECC."ASMAY_Id" =' || "ASMAY_ID" || ' AND ECC."ASMCL_Id" =' || "ASMCL_id" || ' AND ECC."ASMS_Id" =' || "ASMAY_ID" || ' AND  ECC."MI_Id" =' || "MI_ID" || ' AND ECC."ECAC_ActiveFlag"=1  AND
 EYC."ASMAY_Id" =' || "ASMAY_ID" || '  AND    EYC."MI_Id" = ' || "MI_ID" || ' AND   EYC."EYC_ActiveFlg"=1 AND
  ESMTMPS."ASMCL_Id" =' || "ASMCL_id" || ' AND  ESMTMPS."ASMS_Id" = ' || "ASMAY_ID" || '
AND  ESMTMPS."ASMAY_Id" =' || "ASMAY_ID" || ' AND  ESMTMPS."MI_Id" =' || "MI_id" || ' AND EME."eme_id"=' || "EME_id" || ' AND
SEC."MI_id"=' || "MI_id" || ' AND   ESS."MI_Id" = ' || "MI_ID" || ' AND   ESS."ASMAY_Id" = ' || "ASMAY_ID" || ' AND   ESS."ASMCL_Id" =' || "ASMCL_id" || '
AND   ESS."ASMS_Id" =' || "ASMS_id" || ' AND   ESS."ESTSU_ActiveFlg"=1 AND ASYS."amst_id"=' || "ASMS_id" || ' AND ADM."amst_id"=' || "ASMS_id";

    RETURN QUERY EXECUTE v_sql;
END;
$$;