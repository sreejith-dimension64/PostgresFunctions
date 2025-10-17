CREATE OR REPLACE FUNCTION "dbo"."Clg_Exam_get_Marks_Entry_New"(
    "@AMCO_ID" bigint,
    "@AMB_ID" bigint,
    "@AMSE_ID" bigint,
    "@MI_Id" bigint,
    "@EME_Id" bigint,
    "@ISMS_Id" bigint,
    "@ACMS_Id" bigint,
    "@ASMAY_Id" bigint
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "AMCST_FirstName" varchar,
    "AMCST_MiddleName" varchar,
    "AMCST_LastName" varchar,
    "AMCST_AdmNo" varchar,
    "ACYST_RollNo" varchar,
    "ISMS_SubjectName" varchar,
    "ECYSES_MaxMarks" numeric,
    "ECYSES_MarksEntryMax" numeric,
    "ECYSES_MinMarks" numeric,
    "ECSTM_Flg" varchar,
    "ECSTM_Marks" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."AMCST_Id",
        e."AMCST_FirstName",
        e."AMCST_MiddleName",
        e."AMCST_LastName",
        e."AMCST_AdmNo",
        f."ACYST_RollNo",
        g."ISMS_SubjectName",
        h."ECYSES_MaxMarks",
        h."ECYSES_MarksEntryMax",
        h."ECYSES_MinMarks",
        COALESCE(i."ECSTM_Flg", '') AS "ECSTM_Flg",
        COALESCE(i."ECSTM_Marks", 0) AS "ECSTM_Marks"
    FROM "clg"."Adm_Master_College_Student" AS e
    INNER JOIN "clg"."Adm_College_Yearly_Student" AS f 
        ON f."AMCST_Id" = e."AMCST_Id" 
        AND e."AMCST_ActiveFlag" = 1 
        AND e."mi_id" = "@MI_Id" 
        AND e."AMCST_SOL" = 'S'
        AND f."ACYST_ActiveFlag" = 1 
        AND f."ASMAY_Id" = "@ASMAY_Id" 
        AND f."AMCO_Id" = "@AMCO_ID" 
        AND f."AMB_Id" = "@AMB_ID" 
        AND f."AMSE_Id" = "@AMSE_ID" 
        AND f."ACMS_Id" = "@ACMS_Id" 
        AND f."ACYST_ActiveFlag" = 1
    LEFT JOIN "CLG"."Exm_Col_Student_Marks" AS i 
        ON f."AMCST_Id" = i."AMCST_Id" 
        AND i."MI_Id" = "@MI_Id" 
        AND i."AMCO_Id" = "@AMCO_ID" 
        AND i."AMB_Id" = "@AMB_ID"
        AND i."AMSE_Id" = "@AMSE_ID" 
        AND i."ISMS_Id" = "@ISMS_Id" 
        AND i."EME_Id" = "@EME_Id" 
        AND i."ASMAY_Id" = "@ASMAY_Id"
    INNER JOIN "IVRM_Master_Subjects" AS g 
        ON g."ISMS_Id" = "@ISMS_Id" 
        AND g."Mi_id" = "@MI_Id" 
        AND g."ISMS_ActiveFlag" = 1 
        AND g."ISMS_ExamFlag" = 1
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS h 
        ON h."ISMS_Id" = g."ISMS_Id" 
        AND h."ECYSES_ActiveFlg" = 1
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS j 
        ON j."ECYSE_Id" = h."ECYSE_Id" 
        AND j."EME_Id" = "@EME_Id" 
        AND j."ECYSE_ActiveFlg" = 1
    WHERE f."AMCST_Id" IN (
        SELECT i."AMCST_Id" 
        FROM "clg"."Exm_Col_Studentwise_Subjects" i 
        WHERE i."MI_Id" = "@MI_Id" 
        AND "AMCO_Id" = "@AMCO_ID" 
        AND i."AMB_Id" = "@AMB_ID"
        AND i."AMSE_Id" = "@AMSE_ID" 
        AND i."ISMS_Id" = "@ISMS_Id" 
        AND i."ACMS_Id" = "@ACMS_Id" 
        AND i."ASMAY_Id" = "@ASMAY_Id" 
        AND i."ECSTSU_ActiveFlg" = 1
    )
    ORDER BY f."ACYST_RollNo" ASC;
END;
$$;