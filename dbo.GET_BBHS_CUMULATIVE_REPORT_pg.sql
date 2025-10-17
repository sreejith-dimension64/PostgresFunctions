CREATE OR REPLACE FUNCTION "dbo"."GET_BBHS_CUMULATIVE_REPORT"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "StudentName" text,
    "AMST_AdmNo" text,
    "ECT_Id" bigint,
    "ECT_TermName" text,
    "EMPSG_Id" bigint,
    "EMPSG_GroupName" text,
    "EMPSG_PercentValue" numeric,
    "EME_ID" bigint,
    "ISMS_Id" bigint,
    "ESTMPPSG_GroupMaxMarks" numeric,
    "ESTMPPSG_GroupObtMarks" numeric,
    "ESTMPPSG_GroupObtGrade" text,
    "IMC_CasteName" text,
    "ISMS_SubjectName" text,
    "EMPS_AppToResultFlg" boolean,
    "displayname" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "AMS"."AMST_Id",
        ("AMS"."AMST_FirstName" || ' ' || "AMST_MiddleName" || ' ' || "AMST_LastName")::"text" AS "StudentName",
        "AMS"."AMST_AdmNo"::"text",
        "ECT"."ECT_Id",
        "ECT"."ECT_TermName"::"text",
        "EMPSG"."EMPSG_Id",
        "EMPSG"."EMPSG_GroupName"::"text",
        "EMPSG"."EMPSG_PercentValue",
        "ECTME"."EME_ID",
        "ESMPS"."ISMS_Id",
        "ESTMPPSG_GroupMaxMarks",
        "ESTMPPSG_GroupObtMarks",
        "ESTMPPSG_GroupObtGrade"::"text",
        "IMC"."IMC_CasteName"::"text",
        "IMS"."ISMS_SubjectName"::"text",
        "EMPS"."EMPS_AppToResultFlg",
        "EMPSG"."EMPSG_GroupName"::"text" AS "displayname"
    FROM 
        "Exm"."Exm_CCE_TERMS" "ECT" 
        INNER JOIN "Exm"."Exm_CCE_TERMS_MP" "ECTM" ON "ECT"."ECT_Id" = "ECTM"."ECT_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS_MP_EXAMS" "ECTME" ON "ECTME"."ECTMP_Id" = "ECTM"."ECTMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" "EMPSGE" ON "EMPSGE"."EME_Id" = "ECTME"."EME_ID"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "EMPSG" ON "EMPSG"."EMPSG_Id" = "EMPSGE"."EMPSG_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "ESMPSG" ON "ESMPSG"."EMPSG_Id" = "EMPSG"."EMPSG_Id" AND "ESMPSG"."EMPSG_Id" = "EMPSG"."EMPSG_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" "ESMPS" ON "ESMPS"."ESTMPPS_Id" = "ESMPSG"."ESTMPPS_Id"
        INNER JOIN "Adm_M_Student" AS "AMS" ON "AMS"."AMST_Id" = "ESMPS"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" AS "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" 
            AND "AMS"."AMST_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "ASYS"."ASMAY_Id" = "@ASMAY_Id" 
            AND "ASYS"."ASMCL_Id" = "@ASMCL_Id" 
            AND "ASYS"."ASMS_Id" = "@ASMS_Id" 
            AND "AMS"."MI_Id" = "@MI_Id"
        INNER JOIN "IVRM_Master_Caste" "IMC" ON "IMC"."IMC_Id" = "AMS"."IC_Id" AND "IMC"."MI_Id" = "AMS"."MI_Id"
        INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" ON "EMPS"."ISMS_Id" = "ESMPS"."ISMS_Id"
    WHERE 
        "ESMPS"."MI_Id" = "@MI_Id" 
        AND "ESMPS"."ASMAY_Id" = "@ASMAY_Id" 
        AND "ESMPS"."ASMCL_Id" = "@ASMCL_Id" 
        AND "ESMPS"."ASMS_Id" = "@ASMS_Id";
END;
$$;