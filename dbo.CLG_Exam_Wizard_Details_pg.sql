CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_Wizard_Details"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "ECYSE_Id" bigint,
    "EME_Id" bigint,
    "EME_ExamName" varchar,
    "EME_ExamCode" varchar,
    "subjectgrpname" varchar,
    "EMGR_GradeName" varchar,
    "ECYSE_AttendanceFromDate" timestamp,
    "ECYSE_AttendanceToDate" timestamp,
    "ECYSE_SubExamFlg" boolean,
    "ECYSE_SubSubjectFlg" boolean,
    "ECYSE_ActiveFlg" boolean,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "schemetype" varchar,
    "subjectscheme" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "ECYSE"."ECYSE_Id", 
        CAST("ECYSE"."EME_Id" AS bigint) AS "EME_Id", 
        "EME"."EME_ExamName", 
        "EME"."EME_ExamCode", 
        "EMG"."EMG_GroupName" AS "subjectgrpname", 
        "EMGD"."EMGR_GradeName", 
        "ECYSE"."ECYSE_AttendanceFromDate", 
        "ECYSE"."ECYSE_AttendanceToDate", 
        "ECYSE"."ECYSE_SubExamFlg", 
        "ECYSE"."ECYSE_SubSubjectFlg", 
        "ECYSE"."ECYSE_ActiveFlg", 
        "AMC"."AMCO_CourseName", 
        "AMB"."AMB_BranchName", 
        "AMSE"."AMSE_SEMName", 
        "ACST"."ACST_SchmeType" AS "schemetype", 
        "ACSS"."ACSS_SchmeName" AS "subjectscheme"
    FROM "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "ECYSE"
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS "ECYS" 
        ON "ECYSE"."ECYS_Id" = "ECYS"."ECYS_Id" 
        AND "ECYSE"."ECYSE_ActiveFlg" = true
    INNER JOIN "CLG"."Adm_Master_Course" AS "AMC" 
        ON "ECYS"."AMCO_Id" = "AMC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" AS "AMB" 
        ON "ECYS"."AMB_Id" = "AMB"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" AS "AMSE" 
        ON "ECYS"."AMSE_Id" = "AMSE"."AMSE_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" AS "EME" 
        ON "ECYSE"."EME_Id" = "EME"."EME_Id" 
        AND "EME"."EME_ActiveFlag" = true
    INNER JOIN "CLG"."Adm_College_SubjectScheme" AS "ACSS" 
        ON "ECYSE"."ACSS_Id" = "ACSS"."ACSS_Id" 
        AND "ACSS"."ACST_ActiveFlg" = true
    INNER JOIN "CLG"."Adm_College_SchemeType" AS "ACST" 
        ON "ECYSE"."ACST_Id" = "ACST"."ACST_Id" 
        AND "ACST"."ACST_ActiveFlg" = true
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Group" AS "ECYSG" 
        ON "ECYS"."ECYS_Id" = "ECYSG"."ECYS_Id" 
        AND "ECYSG"."ECYSG_ActiveFlag" = true
    INNER JOIN "Exm"."Exm_Master_Group" AS "EMG" 
        ON "ECYSG"."EMG_Id" = "EMG"."EMG_Id" 
        AND "EMG"."EMG_ActiveFlag" = true
    INNER JOIN "Exm"."Exm_Master_Grade" AS "EMGD" 
        ON "ECYSE"."EMGR_Id" = "EMGD"."EMGR_Id" 
        AND "EMGD"."EMGR_ActiveFlag" = true
    WHERE "ECYS"."MI_Id" = p_MI_Id 
        AND "ECYS"."ECYS_ActiveFlag" = true;
END;
$$;