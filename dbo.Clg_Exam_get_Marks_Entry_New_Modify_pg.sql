CREATE OR REPLACE FUNCTION "dbo"."Clg_Exam_get_Marks_Entry_New_Modify"(
    p_AMCO_ID TEXT,
    p_AMB_ID TEXT,
    p_AMSE_ID TEXT,
    p_MI_Id TEXT,
    p_EME_Id TEXT,
    p_ISMS_Id TEXT,
    p_ACMS_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ACSS_Id TEXT,
    p_ACST_Id TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "AMCST_FirstName" VARCHAR,
    "AMCST_MiddleName" VARCHAR,
    "AMCST_LastName" VARCHAR,
    "AMCST_AdmNo" VARCHAR,
    "AMCST_RegistrationNo" VARCHAR,
    "ACYST_RollNo" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "ECYSES_MaxMarks" NUMERIC,
    "ECYSES_MarksEntryMax" NUMERIC,
    "ECYSES_MinMarks" NUMERIC,
    "ECSTM_Flg" VARCHAR,
    "ECSTM_Marks" NUMERIC,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order TEXT;
    v_ordertype TEXT;
    v_SQL TEXT;
BEGIN

    SELECT "ExmConfig_Recordsearchtype" INTO v_order 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id::BIGINT;

    IF v_order = 'Name' THEN
        v_ordertype := 'e."AMCST_FirstName",e."AMCST_MiddleName",e."AMCST_LastName"';
    ELSIF v_order = 'AdmNo' THEN
        v_ordertype := 'e."AMCST_AdmNo"';
    ELSIF v_order = 'RollNo' THEN
        v_ordertype := '"AMAY_RollNo"';
    ELSIF v_order = 'RegNo' THEN
        v_ordertype := 'e."AMCST_RegistrationNo"';
    ELSE
        v_ordertype := 'f."ACYST_RollNo"';
    END IF;

    v_SQL := '
SELECT DISTINCT e."AMCST_Id",e."AMCST_FirstName",e."AMCST_MiddleName",e."AMCST_LastName",e."AMCST_AdmNo",e."AMCST_RegistrationNo",f."ACYST_RollNo",g."ISMS_SubjectName",h."ECYSES_MaxMarks",
h."ECYSES_MarksEntryMax",h."ECYSES_MinMarks",COALESCE(i."ECSTM_Flg",'''') AS  "ECSTM_Flg" , COALESCE(i."ECSTM_Marks",0) AS  "ECSTM_Marks", 
f."AMCO_Id", f."AMB_Id" , f."AMSE_Id", f."ACMS_Id"
FROM "clg"."Adm_Master_College_Student" AS e 
INNER JOIN "clg"."Adm_College_Yearly_Student" AS f ON  f."AMCST_Id" = e."AMCST_Id" AND e."AMCST_ActiveFlag" = 1 AND e."mi_id"=' || p_MI_Id || '  AND e."AMCST_SOL" =''S''
AND e."ACSS_Id"=' || p_ACSS_Id || ' AND e."ACST_Id"=' || p_ACST_Id || ' AND f."ACYST_ActiveFlag" = 1 AND f."ASMAY_Id"=' || p_ASMAY_Id || ' AND f."AMCO_Id"=' || p_AMCO_ID || ' AND f."AMB_Id" IN (' || p_AMB_ID || ') 
AND f."AMSE_Id"=' || p_AMSE_ID || ' AND f."ACMS_Id" in(' || p_ACMS_Id || ') AND f."ACYST_ActiveFlag"=1
LEFT JOIN "CLG"."Exm_Col_Student_Marks" AS i ON  f."AMCST_Id"=i."AMCST_Id" AND i."MI_Id" = ' || p_MI_Id || ' AND i."AMCO_Id" = ' || p_AMCO_ID || ' AND i."AMB_Id" IN (' || p_AMB_ID || ') 
AND i."AMSE_Id"=' || p_AMSE_ID || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || '  AND i."ASMAY_Id"=' || p_ASMAY_Id || '
INNER JOIN "IVRM_Master_Subjects"  AS g ON g."ISMS_Id"=' || p_ISMS_Id || ' AND g."Mi_id"=' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = 1 AND g."ISMS_ExamFlag" = 1
INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS h ON h."ISMS_Id" = g."ISMS_Id"  AND h."ECYSES_ActiveFlg"=1
INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS j ON j."ECYSE_Id"=h."ECYSE_Id" AND j."EME_Id" = ' || p_EME_Id || ' AND j."ECYSE_ActiveFlg"=1 AND j."AMCO_Id"=' || p_AMCO_ID || ' 
AND j."AMB_Id" IN (' || p_AMB_ID || ') AND j."AMSE_Id"=' || p_AMSE_ID || ' AND J."ACSS_Id"=' || p_ACSS_Id || ' AND J."ACST_Id" = ' || p_ACST_Id || '  WHERE f."AMCST_Id" in (SELECT "AMCST_Id"  from "clg"."Exm_Col_Studentwise_Subjects" i WHERE i."MI_Id" = ' || p_MI_Id || ' AND "AMCO_Id" = ' || p_AMCO_ID || ' 
AND i."AMB_Id" IN (' || p_AMB_ID || ') AND i."AMSE_Id"=' || p_AMSE_ID || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."ACMS_Id" in(' || p_ACMS_Id || ') AND i."ASMAY_Id"=' || p_ASMAY_Id || ' AND i."ECSTSU_ActiveFlg"=1)
ORDER BY f."AMCO_Id", f."AMB_Id" , f."AMSE_Id", f."ACMS_Id", ' || v_ordertype;

    RETURN QUERY EXECUTE v_SQL;

END;
$$;