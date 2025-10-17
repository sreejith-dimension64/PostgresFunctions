CREATE OR REPLACE FUNCTION "dbo"."College_MulitpleExam_Cumulative_Report"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ACMS_Id" TEXT,
    "@FLAG" TEXT,
    "@EME_Id" TEXT,
    "@ACSS_Id" TEXT,
    "@ACST_Id" TEXT
)
RETURNS TABLE(
    "AMCST_Id" INTEGER,
    "REGNO" VARCHAR,
    "ADMNO" VARCHAR,
    "STUDENTNAME" TEXT,
    "ECSTMPS_MaxMarks" NUMERIC,
    "ECSTMPS_ObtainedMarks" NUMERIC,
    "EME_Id" INTEGER,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_SubjectCode" VARCHAR,
    "ECSTMPS_PassFailFlg" VARCHAR,
    "ISMS_OrderFlag" INTEGER,
    "EME_ExamOrder" INTEGER,
    "ISMS_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        B."AMCST_Id",
        COALESCE(A."AMCST_RegistrationNo", '') AS "REGNO",
        COALESCE(A."AMCST_AdmNo", '') AS "ADMNO",
        (CASE WHEN A."AMCST_FirstName" = '' OR A."AMCST_FirstName" IS NULL THEN '' ELSE A."AMCST_FirstName" END ||
         CASE WHEN A."AMCST_MiddleName" = '' OR A."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || A."AMCST_MiddleName" END ||
         CASE WHEN A."AMCST_LastName" = '' OR A."AMCST_LastName" IS NULL THEN '' ELSE ' ' || A."AMCST_LastName" END) AS "STUDENTNAME",
        I."ECSTMPS_MaxMarks",
        I."ECSTMPS_ObtainedMarks",
        GG."EME_Id",
        FF."ISMS_SubjectName",
        FF."ISMS_SubjectCode",
        I."ECSTMPS_PassFailFlg",
        FF."ISMS_OrderFlag",
        GG."EME_ExamOrder",
        FF."ISMS_Id"
    FROM "CLG"."Adm_Master_College_Student" A
    INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = B."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = B."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = B."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" F ON F."ACMS_Id" = B."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" G ON G."ASMAY_Id" = B."ASMAY_Id"
    INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" H ON H."AMCST_Id" = B."AMCST_Id" 
        AND H."AMCO_Id" = C."AMCO_Id" 
        AND H."AMB_Id" = D."AMB_Id" 
        AND H."AMSE_Id" = E."AMSE_Id" 
        AND H."ACMS_Id" = F."ACMS_Id"
        AND H."ASMAY_Id" = G."ASMAY_Id"
    INNER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" I ON I."AMCST_Id" = B."AMCST_Id" 
        AND I."AMCO_Id" = C."AMCO_Id" 
        AND I."AMB_Id" = D."AMB_Id" 
        AND I."AMSE_Id" = E."AMSE_Id" 
        AND I."ACMS_Id" = F."ACMS_Id"
        AND I."ASMAY_Id" = G."ASMAY_Id"
    INNER JOIN "IVRM_Master_Subjects" FF ON FF."ISMS_Id" = I."ISMS_Id" AND FF."ISMS_Id" = H."ISMS_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" GG ON GG."EME_Id" = I."EME_Id"
    WHERE B."AMCO_Id" = CAST("@AMCO_Id" AS INTEGER)
        AND B."AMB_Id" = CAST("@AMB_Id" AS INTEGER)
        AND B."AMSE_Id" = CAST("@AMSE_Id" AS INTEGER)
        AND B."ACMS_Id" = CAST("@ACMS_Id" AS INTEGER)
        AND B."ASMAY_Id" = CAST("@ASMAY_Id" AS INTEGER)
        AND H."AMCO_Id" = CAST("@AMCO_Id" AS INTEGER)
        AND H."AMB_Id" = CAST("@AMB_Id" AS INTEGER)
        AND H."AMSE_Id" = CAST("@AMSE_Id" AS INTEGER)
        AND H."ACMS_Id" = CAST("@ACMS_Id" AS INTEGER)
        AND H."ASMAY_Id" = CAST("@ASMAY_Id" AS INTEGER)
        AND I."AMCO_Id" = CAST("@AMCO_Id" AS INTEGER)
        AND I."AMB_Id" = CAST("@AMB_Id" AS INTEGER)
        AND I."AMSE_Id" = CAST("@AMSE_Id" AS INTEGER)
        AND I."ACMS_Id" = CAST("@ACMS_Id" AS INTEGER)
        AND I."ASMAY_Id" = CAST("@ASMAY_Id" AS INTEGER)
        AND I."MI_Id" = CAST("@MI_Id" AS INTEGER)
        AND H."MI_Id" = CAST("@MI_Id" AS INTEGER)
        AND I."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::INTEGER[])
    ORDER BY B."AMCST_Id", GG."EME_ExamOrder", FF."ISMS_OrderFlag";
END;
$$;