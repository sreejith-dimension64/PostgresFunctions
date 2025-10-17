CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_GetStudentWiseSubject_Total"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id bigint,
    p_EME_Id bigint,
    p_ACST_Id bigint,
    p_ACSS_Id bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "count_value" bigint,
    "category" text,
    "ECYSES_SubjectOrder" integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ECYS_Id integer;
    v_ECYSE_Id bigint;
    v_ACST_Id bigint;
    v_ACSS_Id bigint;
BEGIN
    v_ACST_Id := p_ACST_Id;
    v_ACSS_Id := p_ACSS_Id;

    DROP TABLE IF EXISTS temp_TotalStudents;
    DROP TABLE IF EXISTS temp_PassedTotalStudents;

    SELECT "ACST_Id" INTO v_ACST_Id 
    FROM "clg"."Adm_College_SchemeType" 
    WHERE "MI_Id" = p_MI_Id
    LIMIT 1;

    SELECT "ACSS_Id" INTO v_ACSS_Id 
    FROM "clg"."Adm_College_SubjectScheme" 
    WHERE "MI_Id" = p_MI_Id
    LIMIT 1;

    SELECT "ECYS_Id" INTO v_ECYS_Id 
    FROM "clg"."Exm_Col_Yearly_Scheme"
    WHERE "MI_Id" = p_MI_Id 
        AND "AMCO_Id" = p_AMCO_Id
        AND "AMB_Id" = p_AMB_Id 
        AND "AMSE_Id" = p_AMSE_Id 
        AND "ACSS_Id" = v_ACSS_Id 
        AND "ACST_Id" = v_ACST_Id
        AND "ECYS_ActiveFlag" = true
    LIMIT 1;

    SELECT "ECYSE_Id" INTO v_ECYSE_Id 
    FROM "clg"."Exm_Col_Yearly_Scheme_Exams" 
    WHERE "ECYS_Id" = v_ECYS_Id 
        AND "AMCO_Id" = p_AMCO_Id
        AND "AMB_Id" = p_AMB_Id 
        AND "AMSE_Id" = p_AMSE_Id 
        AND "ACSS_Id" = v_ACSS_Id 
        AND "ACST_Id" = v_ACST_Id 
        AND "EME_Id" = p_EME_Id;

    RAISE NOTICE 'ECYSE_Id: %', v_ECYSE_Id;

    CREATE TEMP TABLE temp_TotalStudents AS
    SELECT DISTINCT 
        a."ISMS_Id", 
        COUNT(a."AMCST_Id") as "countTotalStudents",
        'TotalStudents' as "TotalStudents",
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "clg"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "clg"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSES_AplResultFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMB_Id" = p_AMB_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id
    GROUP BY "CEYCES"."ECYSES_SubjectOrder", a."ISMS_Id";

    CREATE TEMP TABLE temp_PassedTotalStudents AS
    SELECT DISTINCT 
        a."ISMS_Id", 
        COUNT(a."AMCST_Id") as "countPassedTotalStudents",
        'PassedStudents' as "PassedStudents",
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "clg"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "clg"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMB_Id" = p_AMB_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" = 'Pass'
    GROUP BY a."ISMS_Id", "CEYCES"."ECYSES_SubjectOrder";

    RETURN QUERY
    SELECT DISTINCT 
        t."ISMS_Id",
        t."countTotalStudents",
        t."TotalStudents",
        t."ECYSES_SubjectOrder"
    FROM temp_TotalStudents t

    UNION

    SELECT DISTINCT 
        a."ISMS_Id", 
        COUNT(a."AMCST_Id"),
        'AppearedStudents'::text,
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "clg"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "clg"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMB_Id" = p_AMB_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" <> 'AB'
    GROUP BY a."ISMS_Id", "CEYCES"."ECYSES_SubjectOrder"

    UNION

    SELECT DISTINCT 
        a."ISMS_Id", 
        COUNT(a."AMCST_Id"),
        'AbsentStudents'::text,
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "clg"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "clg"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMB_Id" = p_AMB_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" = 'AB'
    GROUP BY a."ISMS_Id", "CEYCES"."ECYSES_SubjectOrder"

    UNION

    SELECT DISTINCT 
        a."ISMS_Id", 
        COUNT(a."AMCST_Id"),
        'FailedStudents'::text,
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "clg"."Exm_Col_Student_Marks_Process_Subjectwise" a
    INNER JOIN "clg"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ISMS_Id" = a."ISMS_Id"
        AND "CEYCES"."ECYSES_ActiveFlg" = true 
        AND "CEYCES"."ECYSE_Id" = v_ECYSE_Id
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id
        AND a."AMCO_Id" = p_AMCO_Id 
        AND a."AMB_Id" = p_AMB_Id 
        AND a."AMSE_Id" = p_AMSE_Id
        AND a."ACMS_Id" = p_ACMS_Id 
        AND a."EME_Id" = p_EME_Id 
        AND a."ECSTMPS_PassFailFlg" = 'Fail'
    GROUP BY a."ISMS_Id", "CEYCES"."ECYSES_SubjectOrder"

    UNION

    SELECT 
        p."ISMS_Id",
        p."countPassedTotalStudents",
        p."PassedStudents",
        p."ECYSES_SubjectOrder"
    FROM temp_PassedTotalStudents p

    UNION

    SELECT DISTINCT 
        aa."ISMS_Id",
        ROUND((bb."countPassedTotalStudents"::decimal(18,1) / aa."countTotalStudents") * 100, 0)::bigint,
        'Percentage'::text,
        aa."ECYSES_SubjectOrder"
    FROM temp_TotalStudents aa 
    INNER JOIN temp_PassedTotalStudents bb ON aa."ISMS_Id" = bb."ISMS_Id"
    ORDER BY "ECYSES_SubjectOrder";

    DROP TABLE IF EXISTS temp_TotalStudents;
    DROP TABLE IF EXISTS temp_PassedTotalStudents;

    RETURN;
END;
$$;