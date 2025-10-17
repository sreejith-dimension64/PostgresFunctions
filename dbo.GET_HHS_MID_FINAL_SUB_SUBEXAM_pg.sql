CREATE OR REPLACE FUNCTION "dbo"."GET_HHS_MID_FINAL_SUB_SUBEXAM"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@EME_Id" bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar(100),
    "EMSE_Id" varchar(50),
    "EMSE_SubExamName" varchar(100),
    "EYCES_AplResultFlg" boolean,
    "EYCES_MarksDisplayFlg" boolean,
    "EYCES_GradeDisplayFlg" boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    "isms1_id" bigint;
    "EYCES_AplResultFlg1" boolean;
    "ISMS_SubjectName1" text;
    "EYCES_MarksDisplayFlg1" boolean;
    "EYCES_GradeDisplayFlg1" boolean;
    "orderflag" boolean;
    subexm_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "SubExmListE";
    
    CREATE TEMP TABLE "SubExmListE"(
        "ISMS_Id" bigint,
        "ISMS_SubjectName" varchar(100),
        "EMSE_Id" varchar(50),
        "EMSE_SubExamName" varchar(100),
        "EYCES_AplResultFlg" boolean,
        "EYCES_MarksDisplayFlg" boolean,
        "EYCES_GradeDisplayFlg" boolean
    );

    FOR subexm_rec IN 
        SELECT e."ISMS_Id", f."ISMS_SubjectName", e."EYCES_AplResultFlg", 
               e."EYCES_MarksDisplayFlg", e."EYCES_GradeDisplayFlg", f."ISMS_OrderFlag" 
        FROM "exm"."Exm_Yearly_Category" a 
        INNER JOIN "exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "exm"."Exm_Category_Class" c ON c."EMCA_Id" = a."EMCA_Id" 
        INNER JOIN "exm"."Exm_Yearly_Category_Exams" d ON d."EYC_Id" = a."EYC_Id" 
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = d."EYCE_Id" 
        INNER JOIN "IVRM_Master_Subjects" f ON f."ISMS_Id" = e."ISMS_Id"
        WHERE a."EYC_ActiveFlg" = 1 
          AND b."EMCA_ActiveFlag" = 1 
          AND c."ECAC_ActiveFlag" = 1 
          AND d."EYCE_ActiveFlg" = 1 
          AND e."EYCES_ActiveFlg" = 1 
          AND a."ASMAY_Id" = "@ASMAY_Id" 
          AND c."ASMAY_Id" = "@ASMAY_Id"
          AND c."ASMCL_Id" = "@ASMCL_Id" 
          AND c."ASMS_Id" = "@ASMS_Id" 
          AND d."EME_Id" = "@EME_Id" 
        ORDER BY f."ISMS_OrderFlag"
    LOOP
        "isms1_id" := subexm_rec."ISMS_Id";
        "ISMS_SubjectName1" := subexm_rec."ISMS_SubjectName";
        "EYCES_AplResultFlg1" := subexm_rec."EYCES_AplResultFlg";
        "EYCES_MarksDisplayFlg1" := subexm_rec."EYCES_MarksDisplayFlg";
        "EYCES_GradeDisplayFlg1" := subexm_rec."EYCES_GradeDisplayFlg";
        "orderflag" := subexm_rec."ISMS_OrderFlag";

        INSERT INTO "SubExmListE"("ISMS_Id", "ISMS_SubjectName", "EMSE_Id", "EMSE_SubExamName", 
                                  "EYCES_AplResultFlg", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg")
        SELECT DISTINCT IMS."ISMS_Id", IMS."ISMS_SubjectName", EYSE."EMSE_Id", MSE."EMSE_SubExamName",
                        EYECS."EYCES_AplResultFlg", EYECS."EYCES_MarksDisplayFlg", EYECS."EYCES_GradeDisplayFlg" 
        FROM "exm"."Exm_Yrly_Cat_Exams_Subwise" EYECS 
        INNER JOIN "IVRM_Master_Subjects" IMS ON EYECS."ISMS_Id" = IMS."ISMS_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise_SubExams" EYSE ON EYSE."EYCES_Id" = EYECS."EYCES_Id"
        INNER JOIN "exm"."Exm_Master_SubExam" MSE ON MSE."EMSE_Id" = EYSE."EMSE_Id"
        INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" PS ON PS."ISMS_Id" = IMS."ISMS_Id"
        WHERE PS."MI_Id" = "@MI_Id" 
          AND PS."ASMAY_Id" = "@ASMAY_Id" 
          AND PS."ASMCL_Id" = "@ASMCL_Id" 
          AND PS."ASMS_Id" = "@ASMS_Id"
          AND PS."EME_Id" = "@EME_Id"  
          AND PS."ISMS_Id" = "isms1_id";

        INSERT INTO "SubExmListE"("ISMS_Id", "ISMS_SubjectName", "EMSE_Id", "EMSE_SubExamName", 
                                  "EYCES_AplResultFlg", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg")
        VALUES("isms1_id", "ISMS_SubjectName1", '1001', 'Total', 
               "EYCES_AplResultFlg1", "EYCES_MarksDisplayFlg1", "EYCES_GradeDisplayFlg1");

    END LOOP;

    RETURN QUERY SELECT * FROM "SubExmListE";

END;
$$;