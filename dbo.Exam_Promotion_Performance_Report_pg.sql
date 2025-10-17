CREATE OR REPLACE FUNCTION "dbo"."Exam_Promotion_Performance_Report"(
    "p_MI_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_Flag" TEXT
)
RETURNS TABLE(
    "ASMAY_Id" BIGINT,
    "ASMAY_Year" VARCHAR,
    "ASMAY_Order" INTEGER,
    "ISMS_SubjectName" VARCHAR,
    "PassCount" BIGINT,
    "FailedCount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "p_Flag" = 'overall' THEN
        RETURN QUERY
        SELECT 
            "a"."ASMAY_Id",
            "b"."ASMAY_Year",
            "b"."ASMAY_Order",
            NULL::VARCHAR AS "ISMS_SubjectName",
            SUM(CASE WHEN "a"."ESTMPP_Result" = 'Pass' THEN 1 ELSE 0 END) AS "PassCount",
            SUM(CASE WHEN "a"."ESTMPP_Result" != 'Pass' THEN 1 ELSE 0 END) AS "FailedCount"
        FROM "Exm"."Exm_Student_MP_Promotion" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "b" ON "a"."ASMAY_Id" = "b"."ASMAY_Id"
        WHERE "a"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND "a"."mi_id" = "p_MI_Id"::BIGINT
        GROUP BY "a"."ASMAY_Id", "b"."ASMAY_Year", "b"."ASMAY_Order"
        ORDER BY "b"."ASMAY_Order";

    ELSIF "p_Flag" = 'subjwise' THEN
        RETURN QUERY
        SELECT 
            "a"."ASMAY_Id",
            "b"."ASMAY_Year",
            "b"."ASMAY_Order",
            "C"."ISMS_SubjectName",
            SUM(CASE WHEN "a"."ESTMPPS_PassFailFlg" = 'Pass' THEN 1 ELSE 0 END) AS "PassCount",
            SUM(CASE WHEN "a"."ESTMPPS_PassFailFlg" != 'Pass' THEN 1 ELSE 0 END) AS "FailedCount"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "b" ON "a"."ASMAY_Id" = "b"."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" "C" ON "C"."ISMS_Id" = "a"."ISMS_Id"
        WHERE "a"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND "a"."mi_id" = "p_MI_Id"::BIGINT
        GROUP BY "a"."ASMAY_Id", "b"."ASMAY_Year", "b"."ASMAY_Order", "C"."ISMS_SubjectName"
        ORDER BY "b"."ASMAY_Order";

    END IF;

END;
$$;