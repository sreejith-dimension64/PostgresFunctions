CREATE OR REPLACE FUNCTION "dbo"."GET_SREMRS_SUB_SUBEXAM"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS TABLE(
    "EME_Id" bigint,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar(100),
    "EMSE_Id" varchar(50),
    "EMSE_SubExamName" varchar(100),
    "EYCES_AplResultFlg" boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_eme_id1 bigint;
    v_isms1_id bigint;
    v_EYCES_AplResultFlg1 boolean;
    v_ISMS_SubjectName1 varchar;
    v_ISMS_Subjectorder bigint;
    subexm_record RECORD;
BEGIN

    DROP TABLE IF EXISTS "StudentListEA";
    
    CREATE TEMP TABLE "StudentListEA"
    (
        "EME_Id" bigint,
        "ISMS_Id" bigint,
        "ISMS_SubjectName" varchar(100),
        "EMSE_Id" varchar(50),
        "EMSE_SubExamName" varchar(100),
        "EYCES_AplResultFlg" boolean
    );

    FOR subexm_record IN
        SELECT DISTINCT PS."EME_Id", PS."ISMS_Id", IMS."ISMS_SubjectName", EYECS."EYCES_AplResultFlg", IMS."ISMS_OrderFlag"
        FROM "Exm"."Exm_Yearly_Category" EYC
        INNER JOIN "Exm"."Exm_Category_Class" ECC ON ECC."EMCA_Id" = EYC."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" EYE ON EYE."EYC_Id" = EYC."EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" EYECS ON EYECS."EYCE_Id" = EYE."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" IMS ON EYECS."ISMS_Id" = IMS."ISMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" PS ON 
            ECC."MI_Id" = PS."MI_Id" AND 
            ECC."ASMAY_Id" = PS."ASMAY_Id" AND 
            ECC."ASMCL_Id" = PS."ASMCL_Id" AND 
            ECC."ASMS_Id" = PS."ASMS_Id" AND 
            PS."ISMS_Id" = EYECS."ISMS_Id"
        WHERE PS."MI_Id" = p_MI_Id 
            AND PS."ASMAY_Id" = p_ASMAY_Id 
            AND PS."ASMCL_Id" = p_ASMCL_Id 
            AND PS."ASMS_Id" = p_ASMS_Id 
        ORDER BY IMS."ISMS_OrderFlag"
    LOOP
        v_eme_id1 := subexm_record."EME_Id";
        v_isms1_id := subexm_record."ISMS_Id";
        v_ISMS_SubjectName1 := subexm_record."ISMS_SubjectName";
        v_EYCES_AplResultFlg1 := subexm_record."EYCES_AplResultFlg";
        v_ISMS_Subjectorder := subexm_record."ISMS_OrderFlag";

        INSERT INTO "StudentListEA"("EME_Id", "ISMS_Id", "ISMS_SubjectName", "EMSE_Id", "EMSE_SubExamName", "EYCES_AplResultFlg")
        SELECT DISTINCT PS."EME_Id", IMS."ISMS_Id", IMS."ISMS_SubjectName", EYSE."EMSE_Id", MSE."EMSE_SubExamName", EYECS."EYCES_AplResultFlg"
        FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" EYECS
        INNER JOIN "IVRM_Master_Subjects" IMS ON EYECS."ISMS_Id" = IMS."ISMS_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubExams" EYSE ON EYSE."EYCES_Id" = EYECS."EYCES_Id"
        INNER JOIN "Exm"."Exm_Master_SubExam" MSE ON MSE."EMSE_Id" = EYSE."EMSE_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" PS ON PS."ISMS_Id" = IMS."ISMS_Id"
        WHERE PS."MI_Id" = p_MI_Id 
            AND PS."ASMAY_Id" = p_ASMAY_Id 
            AND PS."ASMCL_Id" = p_ASMCL_Id 
            AND PS."ASMS_Id" = p_ASMS_Id
            AND PS."ISMS_Id" = v_isms1_id;

        INSERT INTO "StudentListEA"("EME_Id", "ISMS_Id", "ISMS_SubjectName", "EMSE_Id", "EMSE_SubExamName", "EYCES_AplResultFlg")
        VALUES(v_eme_id1, v_isms1_id, v_ISMS_SubjectName1, '1001', 'Total', v_EYCES_AplResultFlg1);

    END LOOP;

    RETURN QUERY SELECT * FROM "StudentListEA";

END;
$$;