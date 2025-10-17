CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_SUBJECTWISE_PASSFAIL_COUNT"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "AMCO_Id" bigint
)
RETURNS TABLE(
    "AMB_BranchName" VARCHAR,
    "AMB_Id" bigint,
    "AMSE_SEMName" VARCHAR,
    "AMSE_Id" bigint,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_Id" bigint,
    "EME_ExamName" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "ACMS_Id" bigint,
    "Pass" bigint,
    "Fail" bigint,
    "total" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d."AMB_BranchName",
        d."AMB_Id",
        d."AMSE_SEMName",
        d."AMSE_Id",
        d."ISMS_SubjectName",
        d."ISMS_Id",
        d."EME_ExamName",
        d."ACMS_SectionName",
        d."ACMS_Id",
        COALESCE(d."Pass", 0) AS "Pass",
        COALESCE(d."Fail", 0) AS "Fail",
        d."total"
    FROM (
        SELECT 
            "C"."AMB_BranchName",
            "C"."AMB_Id",
            "D"."AMSE_SEMName",
            "D"."AMSE_Id",
            "E"."ISMS_SubjectName",
            "E"."ISMS_Id",
            "F"."EME_ExamName",
            "F"."EME_Id",
            "A"."ECSTMPS_PassFailFlg" AS "MONTH_NAME",
            "G"."ACMS_SectionName",
            "G"."ACMS_Id",
            COUNT("A"."ECSTMPS_PassFailFlg") AS "TOTAL_PRESENT",
            COUNT("A"."AMCST_Id") AS "total"
        FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" AS "A"
        INNER JOIN "CLG"."Adm_Master_Course" AS "B" ON "A"."AMCO_Id" = "B"."AMCO_Id" 
            AND "B"."AMCO_ActiveFlag" = 1 AND "B"."MI_Id" = "MI_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS "C" ON "A"."AMB_Id" = "C"."AMB_Id" 
            AND "C"."AMB_ActiveFlag" = 1 AND "C"."MI_Id" = "MI_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS "D" ON "D"."AMSE_Id" = "A"."AMSE_Id" 
            AND "D"."AMSE_ActiveFlg" = 1 AND "D"."MI_Id" = "MI_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS "G" ON "G"."ACMS_Id" = "A"."ACMS_Id" 
            AND "G"."ACMS_ActiveFlag" = 1 AND "G"."MI_Id" = "MI_Id"
        INNER JOIN "IVRM_Master_Subjects" AS "E" ON "A"."ISMS_Id" = "E"."ISMS_Id" 
            AND "E"."ISMS_ActiveFlag" = 1 AND "E"."MI_Id" = "MI_Id"
        INNER JOIN "EXM"."Exm_Master_Exam" AS "F" ON "F"."EME_Id" = "A"."EME_Id" 
            AND "F"."EME_ActiveFlag" = 1 AND "F"."MI_Id" = "MI_Id"
        WHERE "A"."MI_Id" = "MI_Id" 
            AND "A"."ASMAY_Id" = "ASMAY_Id"
            AND "A"."AMCO_Id" = "AMCO_Id"
        GROUP BY 
            "C"."AMB_BranchName", "C"."AMB_Id", "D"."AMSE_SEMName", "D"."AMSE_Id", 
            "E"."ISMS_SubjectName", "E"."ISMS_Id", "F"."EME_ExamName", "F"."EME_Id", 
            "A"."ECSTMPS_PassFailFlg", "G"."ACMS_SectionName", "G"."ACMS_Id"
    ) AS "subquery"
    CROSSTAB(
        'SELECT "AMB_BranchName", "AMB_Id", "AMSE_SEMName", "AMSE_Id", "ISMS_SubjectName", 
                "ISMS_Id", "EME_ExamName", "ACMS_SectionName", "ACMS_Id", "MONTH_NAME", "TOTAL_PRESENT", "total"
         FROM subquery',
        'SELECT DISTINCT "MONTH_NAME" FROM subquery ORDER BY 1'
    ) AS d(
        "AMB_BranchName" VARCHAR, "AMB_Id" bigint, "AMSE_SEMName" VARCHAR, "AMSE_Id" bigint,
        "ISMS_SubjectName" VARCHAR, "ISMS_Id" bigint, "EME_ExamName" VARCHAR, 
        "ACMS_SectionName" VARCHAR, "ACMS_Id" bigint, "total" bigint, "Pass" bigint, "Fail" bigint
    );
END;
$$;