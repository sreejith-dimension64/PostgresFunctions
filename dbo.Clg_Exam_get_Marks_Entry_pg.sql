CREATE OR REPLACE FUNCTION "dbo"."Clg_Exam_get_Marks_Entry"(
    p_AMCO_ID bigint,
    p_AMB_ID bigint,
    p_AMSE_ID bigint,
    p_MI_Id bigint,
    p_EME_Id bigint,
    p_ISMS_Id bigint,
    p_ACMS_Id bigint
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
        COALESCE(i."ECSTM_Flg", '') as "ECSTM_Flg",
        COALESCE(i."ECSTM_Marks", 0) as "ECSTM_Marks"
    FROM "clg"."Adm_Master_College_Student" as e
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks" as i 
        ON e."AMCST_Id" = i."AMCST_Id" 
        AND i."MI_Id" = p_MI_Id 
        AND i."AMCO_Id" = p_AMCO_ID 
        AND i."AMB_Id" = p_AMB_ID 
        AND i."AMSE_Id" = p_AMSE_ID
        AND i."ISMS_Id" = p_ISMS_Id 
        AND i."EME_Id" = p_EME_Id
    JOIN "clg"."Adm_College_Yearly_Student" as f 
        ON f."AMCST_Id" = e."AMCST_Id" 
        AND e."AMCST_ActiveFlag" = 1 
        AND e."mi_id" = p_MI_Id 
        AND e."AMCST_SOL" = 'S' 
        AND f."ACYST_ActiveFlag" = 1
    LEFT OUTER JOIN "IVRM_Master_Subjects" as g 
        ON g."ISMS_Id" = p_ISMS_Id 
        AND g."Mi_id" = p_MI_Id 
        AND g."ISMS_ActiveFlag" = 1 
        AND g."ISMS_ExamFlag" = 1
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" as h 
        ON h."ISMS_Id" = g."ISMS_Id" 
        AND h."ECYSES_ActiveFlg" = 1
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" as j 
        ON j."ECYSE_Id" = h."ECYSE_Id" 
        AND j."EME_Id" = p_EME_Id 
        AND j."ECYSE_ActiveFlg" = 1
    WHERE e."AMCST_Id" IN (
        SELECT i2."AMCST_Id" 
        FROM "clg"."Exm_Col_Studentwise_Subjects" i2 
        WHERE i2."MI_Id" = p_MI_Id 
        AND i2."AMCO_Id" = p_AMCO_ID 
        AND i2."AMB_Id" = p_AMB_ID 
        AND i2."AMSE_Id" = p_AMSE_ID
        AND i2."ISMS_Id" = p_ISMS_Id 
        AND i2."ACMS_Id" = p_ACMS_Id
    )
    ORDER BY f."ACYST_RollNo" ASC;
END;
$$;