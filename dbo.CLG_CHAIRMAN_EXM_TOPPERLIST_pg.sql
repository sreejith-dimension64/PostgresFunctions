CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_EXM_TOPPERLIST"(
    IN "@MI_Id" bigint,
    IN "@ASMAY_Id" bigint,
    IN "@AMCO_Id" bigint
)
RETURNS TABLE(
    "AMB_BranchName" VARCHAR,
    "AMB_Id" BIGINT,
    "AMSE_SEMName" VARCHAR,
    "AMSE_Id" BIGINT,
    "EME_ExamName" VARCHAR,
    "EME_Id" BIGINT,
    "MONTH_NAME" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "ACMS_Id" BIGINT,
    "ECSTMP_SemRank" VARCHAR,
    "ECSTMP_Percentage" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "C"."AMB_BranchName",
        "C"."AMB_Id",
        "D"."AMSE_SEMName",
        "D"."AMSE_Id",
        "F"."EME_ExamName",
        "F"."EME_Id",
        "A"."ECSTMP_SectionRank" AS "MONTH_NAME",
        "G"."ACMS_SectionName",
        "G"."ACMS_Id",
        "A"."ECSTMP_SemRank",
        "A"."ECSTMP_Percentage"
    FROM "CLG"."Exm_Col_Student_Marks_Process" AS "A"
    INNER JOIN "CLG"."Adm_Master_Course" AS "B" ON "A"."AMCO_Id" = "B"."AMCO_Id" AND "B"."AMCO_ActiveFlag" = 1 AND "B"."MI_Id" = 19
    INNER JOIN "CLG"."Adm_Master_Branch" AS "C" ON "A"."AMB_Id" = "C"."AMB_Id" AND "C"."AMB_ActiveFlag" = 1 AND "C"."MI_Id" = 19
    INNER JOIN "CLG"."Adm_Master_Semester" AS "D" ON "D"."AMSE_Id" = "A"."AMSE_Id" AND "D"."AMSE_ActiveFlg" = 1 AND "D"."MI_Id" = 19
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "G" ON "G"."ACMS_Id" = "A"."ACMS_Id" AND "G"."ACMS_ActiveFlag" = 1 AND "G"."MI_Id" = 19
    INNER JOIN "EXM"."Exm_Master_Exam" AS "F" ON "F"."EME_Id" = "A"."EME_Id" AND "F"."EME_ActiveFlag" = 1 AND "F"."MI_Id" = 19
    WHERE "A"."MI_Id" = 19 AND "A"."ASMAY_Id" = 43 AND "A"."AMCO_Id" = 4;
END;
$$;