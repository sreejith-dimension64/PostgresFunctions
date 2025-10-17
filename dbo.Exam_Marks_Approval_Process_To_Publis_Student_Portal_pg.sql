CREATE OR REPLACE FUNCTION "dbo"."Exam_Marks_Approval_Process_To_Publis_Student_Portal"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@EME_Id" TEXT
)
RETURNS TABLE(
    "MI_ID" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "EME_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ESTMP_TotalMaxMarks" NUMERIC,
    "ESTMP_TotalObtMarks" NUMERIC,
    "ESTMP_Percentage" NUMERIC,
    "ESTMP_TotalGrade" VARCHAR,
    "ESTMP_SectionRank" BIGINT,
    "ESTMP_ClassRank" BIGINT,
    "ESTMP_SectionPosition" VARCHAR,
    "ESTMP_ClassPosition" VARCHAR,
    "ESTMP_TotalGradePoints" NUMERIC,
    "ESTMP_PublishToStudentFlg" BOOLEAN,
    "ESTMP_Result" VARCHAR,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP,
    "ESTMP_Remarks" VARCHAR,
    "ESTMP_ActiveFlg" BOOLEAN,
    "ESTMPPSTR_PublishToStudent" VARCHAR,
    "ESTMP_ResultDate" TIMESTAMP
) AS $$
DECLARE
BEGIN

    RETURN QUERY
    SELECT 
        "esmp"."MI_ID",
        "esmp"."ASMAY_Id",
        "esmp"."ASMCL_Id",
        "esmp"."ASMS_Id",
        "esmp"."EME_Id",
        "esmp"."AMST_Id",
        "esmp"."ESTMP_TotalMaxMarks",
        "esmp"."ESTMP_TotalObtMarks",
        "esmp"."ESTMP_Percentage",
        "esmp"."ESTMP_TotalGrade",
        "esmp"."ESTMP_SectionRank",
        "esmp"."ESTMP_ClassRank",
        "esmp"."ESTMP_SectionPosition",
        "esmp"."ESTMP_ClassPosition",
        "esmp"."ESTMP_TotalGradePoints",
        "esmp"."ESTMP_PublishToStudentFlg",
        "esmp"."ESTMP_Result",
        "esmp"."CreatedDate",
        "esmp"."UpdatedDate",
        "esmp"."ESTMP_Remarks",
        "esmp"."ESTMP_ActiveFlg",
        "esmp"."ESTMPPSTR_PublishToStudent",
        "esmp"."ESTMP_ResultDate"
    FROM "EXM"."Exm_Student_Marks_Process" "esmp"
    WHERE "esmp"."MI_ID" = "@MI_Id"::BIGINT 
        AND "esmp"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "esmp"."ASMCL_Id" = "@ASMS_Id"::BIGINT 
        AND "esmp"."ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND "esmp"."EME_Id" = "@EME_Id"::BIGINT;

    UPDATE "EXM"."Exm_Student_Marks_Process" 
    SET "ESTMP_PublishToStudentFlg" = TRUE 
    WHERE "MI_ID" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND "EME_Id" = "@EME_Id"::BIGINT;

    RETURN;

END;
$$ LANGUAGE plpgsql;