CREATE OR REPLACE FUNCTION "dbo"."EXM_STUDENT_SUBWISE_REPORT"(
    "@MI_id" TEXT,
    "@ASMAY_ID" TEXT,
    "@ASMCL_ID" TEXT,
    "@ASMS_ID" TEXT,
    "@AMST_ID" TEXT,
    "@EME_ID" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "EMPS_MaxMarks" NUMERIC,
    "EMPS_MinMarks" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" VARCHAR,
    "ESTMPS_ClassAverage" NUMERIC,
    "ESTMPS_SectionAverage" NUMERIC,
    "ESTMPS_ClassHighest" NUMERIC,
    "ESTMPS_SectionHighest" NUMERIC,
    "ESTMPS_ClassRank" INTEGER,
    "ESTMPS_SectionRank" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT 
    "ASYS"."AMST_Id",
    (COALESCE("AMST_FirstName",'') || ' ' || 
     COALESCE("AMST_MiddleName",'') || ' ' || 
     COALESCE("AMST_LastName",'')) AS studentname,
    "ESTMPS"."ISMS_Id",
    "ISMS_SubjectName",
    "EMPS_MaxMarks",
    "EMPS_MinMarks",
    "ESTMPS_ObtainedMarks",
    "ESTMPS_ObtainedGrade",
    "ESTMPS_ClassAverage",
    "ESTMPS_SectionAverage",
    "ESTMPS_ClassHighest",
    "ESTMPS_SectionHighest",
    "ESTMPS_ClassRank",
    "ESTMPS_SectionRank"
FROM "EXM"."Exm_Student_Marks_Process_Subjectwise" "ESTMPS"
INNER JOIN "exm"."Exm_Studentwise_Subjects" "ESS" ON "ESS"."ASMAY_Id" = "ESTMPS"."ASMAY_Id"
INNER JOIN "IVRM_Master_Subjects" "SUB" ON "SUB"."ISMS_Id" = "ESTMPS"."ISMS_Id" AND "SUB"."ISMS_Id" = "ESS"."ISMS_Id"
INNER JOIN "exm"."Exm_Master_Exam" "EXM" ON "EXM"."EME_Id" = "ESTMPS"."EME_Id"
INNER JOIN "exm"."Exm_Yearly_Category" "EYC" ON "EYC"."ASMAY_Id" = "ESTMPS"."ASMAY_Id"
INNER JOIN "exm"."Exm_Master_Category" "EMC" ON "EMC"."EMCA_Id" = "EYC"."EMCA_Id"
INNER JOIN "exm"."Exm_Category_Class" "ECC" ON "ECC"."EMCA_Id" = "EMC"."EMCA_Id" AND "ECC"."ECAC_ActiveFlag" = 1
INNER JOIN "exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id" AND "EYCE"."EME_Id" = "EXM"."EME_Id" AND "EYCE"."EYCE_ActiveFlg" = 1
INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" AND "EYCES"."ISMS_Id" = "SUB"."ISMS_Id"
INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" "EYCESS" ON "EYCESS"."EYCES_Id" = "EYCES"."EYCES_Id"
INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" ON "EMPS"."ISMS_Id" = "SUB"."ISMS_Id"
INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "ESTMPS"."AMST_Id"
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ESTMPS"."AMST_Id"
INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ESTMPS"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ESTMPS"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ESTMPS"."ASMAY_Id"
WHERE "ASYS"."ASMAY_Id"::TEXT = "@ASMAY_Id" 
  AND "ASYS"."ASMCL_Id"::TEXT = "@ASMCL_Id" 
  AND "ASYS"."ASMS_Id"::TEXT = "@ASMS_Id"
  AND "ESS"."ASMAY_Id"::TEXT = "@ASMAY_Id" 
  AND "ESS"."ASMCL_Id"::TEXT = "@ASMCL_Id" 
  AND "ESS"."ASMS_Id"::TEXT = "@ASMS_Id"
  AND "ESTMPS"."ASMAY_Id"::TEXT = "@ASMAY_Id" 
  AND "ESTMPS"."ASMCL_Id"::TEXT = "@ASMCL_Id" 
  AND "ESTMPS"."ASMS_Id"::TEXT = "@ASMS_Id"
  AND "ESTMPS"."MI_ID"::TEXT = "@mi_id" 
  AND "ASYS"."AMST_ID"::TEXT = "@AMST_ID" 
  AND "ESTMPS"."AMST_Id"::TEXT = "@AMST_ID" 
  AND "ASMC"."ASMCL_Id"::TEXT = "@ASMCL_ID" 
  AND "ASMS"."ASMS_id"::TEXT = "@ASMS_ID";

END;
$$;