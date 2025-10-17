CREATE OR REPLACE FUNCTION "dbo"."Admission_TC_Get_Exam_SubjectDetails"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "ISMS_ID" BIGINT,
    "ISMS_SUBJECTNAME" VARCHAR,
    "EYCES_SUBJECTORDER" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@ASMCL_Id" TEXT;
    "@ASMS_Id" TEXT;
BEGIN

    SELECT "ASMCL_Id", "ASMS_Id" 
    INTO "@ASMCL_Id", "@ASMS_Id"
    FROM "Adm_School_Y_Student" 
    WHERE "AMST_Id" = "@AMST_Id" AND "ASMAY_Id" = "@ASMAY_Id";

    RETURN QUERY
    SELECT DISTINCT 
        B."ISMS_ID", 
        C."ISMS_SUBJECTNAME",
        B."EYCES_SUBJECTORDER" 
    FROM "EXM"."EXM_YEARLY_CATEGORY_EXAMS" A 
    INNER JOIN "EXM"."EXM_YRLY_CAT_EXAMS_SUBWISE" B ON A."EYCE_ID" = B."EYCE_ID"
    INNER JOIN "IVRM_MASTER_SUBJECTS" C ON C."ISMS_ID" = B."ISMS_ID"
    INNER JOIN "EXM"."EXM_YEARLY_CATEGORY" D ON D."EYC_ID" = A."EYC_ID" 
        AND D."EYC_ACTIVEFLG" = 1 
        AND D."ASMAY_ID" = "@ASMAY_Id"
    INNER JOIN "EXM"."EXM_MASTER_CATEGORY" E ON E."EMCA_ID" = D."EMCA_ID" 
        AND E."EMCA_ACTIVEFLAG" = 1
    INNER JOIN "EXM"."EXM_CATEGORY_CLASS" F ON F."EMCA_ID" = E."EMCA_ID" 
        AND F."ECAC_ACTIVEFLAG" = 1 
        AND F."ASMAY_ID" = "@ASMAY_Id" 
        AND F."ASMCL_Id" = "@ASMCL_Id" 
        AND F."ASMS_Id" = "@ASMS_Id"
    WHERE C."MI_ID" = "@MI_Id" 
        AND E."MI_ID" = "@MI_Id" 
        AND F."MI_ID" = "@MI_Id"  
        AND A."EYCE_ACTIVEFLG" = 1 
        AND B."EYCES_ACTIVEFLG" = 1 
        AND B."EYCES_APLRESULTFLG" = 1
        AND B."ISMS_ID" IN (
            SELECT "ISMS_ID" 
            FROM "EXM"."EXM_STUDENTWISE_SUBJECTS" 
            WHERE "AMST_ID" = "@AMST_Id" 
                AND "ASMAY_ID" = "@ASMAY_Id" 
                AND "ASMCL_Id" = "@ASMCL_Id" 
                AND "ASMS_Id" = "@ASMS_Id"
                AND "ESTSU_ActiveFlg" = 1
        ) 
    ORDER BY B."EYCES_SUBJECTORDER";

    RETURN;

END;
$$;