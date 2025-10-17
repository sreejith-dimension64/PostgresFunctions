CREATE OR REPLACE FUNCTION "dbo"."Exam_Promotion_Marks_Approval_Process_To_Publis_Student_Portal"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT
)
RETURNS TABLE(
    "MI_ID" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ESTMPP_Id" BIGINT,
    "ESTMPP_TotalMaxMarks" NUMERIC,
    "ESTMPP_TotalObtMarks" NUMERIC,
    "ESTMPP_Percentage" NUMERIC,
    "ESTMPP_TotalGrade" TEXT,
    "ESTMPP_ClassRank" INTEGER,
    "ESTMPP_SectionRank" INTEGER,
    "ESTMPP_Result" TEXT,
    "ESTMPP_PublishToStudentFlg" BOOLEAN,
    "ESTMPP_Remarks" TEXT,
    "ESTMPP_ActiveFlg" BOOLEAN,
    "ESTMPP_CreatedBy" BIGINT,
    "ESTMPP_UpdatedBy" BIGINT,
    "ESTMPP_CreatedDate" TIMESTAMP,
    "ESTMPP_UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        emp."MI_ID",
        emp."ASMAY_Id",
        emp."ASMCL_Id",
        emp."ASMS_Id",
        emp."AMST_Id",
        emp."ESTMPP_Id",
        emp."ESTMPP_TotalMaxMarks",
        emp."ESTMPP_TotalObtMarks",
        emp."ESTMPP_Percentage",
        emp."ESTMPP_TotalGrade",
        emp."ESTMPP_ClassRank",
        emp."ESTMPP_SectionRank",
        emp."ESTMPP_Result",
        emp."ESTMPP_PublishToStudentFlg",
        emp."ESTMPP_Remarks",
        emp."ESTMPP_ActiveFlg",
        emp."ESTMPP_CreatedBy",
        emp."ESTMPP_UpdatedBy",
        emp."ESTMPP_CreatedDate",
        emp."ESTMPP_UpdatedDate"
    FROM "EXM"."Exm_Student_MP_Promotion" emp
    WHERE emp."MI_ID" = "@MI_Id"::BIGINT 
        AND emp."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND emp."ASMCL_Id" = "@ASMS_Id"::BIGINT 
        AND emp."ASMS_Id" = "@ASMS_Id"::BIGINT;

    UPDATE "EXM"."Exm_Student_MP_Promotion" 
    SET "ESTMPP_PublishToStudentFlg" = TRUE 
    WHERE "MI_ID" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;
$$;