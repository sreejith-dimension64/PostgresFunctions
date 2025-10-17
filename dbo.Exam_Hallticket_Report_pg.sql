CREATE OR REPLACE FUNCTION "dbo"."Exam_Hallticket_Report" (
    "@MI_Id" BIGINT, 
    "@ASMAY_Id" BIGINT, 
    "@ASMCL_Id" BIGINT, 
    "@ASMS_Id" BIGINT, 
    "@EME_Id" BIGINT,
    "@AMST_Id" TEXT
)
RETURNS TABLE (
    "amsT_Id" BIGINT,
    "ismS_SubjectName" VARCHAR,
    "exttS_Date" TIMESTAMP,
    "EME_ExamName" VARCHAR,
    "ETTS_SessionName" VARCHAR,
    "subjectorder" INTEGER,
    "ettS_StartTime" TIME,
    "ettS_EndTime" TIME,
    "Duration" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        "f"."AMST_Id" AS "amsT_Id",
        "c"."ISMS_SubjectName" AS "ismS_SubjectName",
        "a"."EXTTS_Date" AS "exttS_Date",
        "d"."EME_ExamName",
        "e"."ETTS_SessionName",
        "c"."ISMS_OrderFlag" AS "subjectorder",
        "e"."ETTS_StartTime" AS "ettS_StartTime",
        "e"."ETTS_EndTime" AS "ettS_EndTime",
        TO_CHAR(
            ('00:00'::TIME + ("e"."ETTS_EndTime" - "e"."ETTS_StartTime")),
            'HH24:MI'
        ) AS "Duration"
    FROM "exm"."Exm_TimeTable_Subjects" "a"
    INNER JOIN "exm"."Exm_TimeTable" "b" ON "a"."EXTT_Id" = "b"."EXTT_Id"
    INNER JOIN "IVRM_Master_Subjects" "c" ON "a"."ISMS_Id" = "c"."ISMS_Id"
    INNER JOIN "exm"."Exm_Master_Exam" "d" ON "b"."EME_Id" = "d"."EME_Id"
    INNER JOIN "exm"."Exm_TT_M_Session" "e" ON "a"."ETTS_Id" = "e"."ETTS_Id"
    INNER JOIN "exm"."Exm_Studentwise_Subjects" "f" ON "c"."ISMS_Id" = "f"."ISMS_Id"
    WHERE "b"."MI_Id" = "@MI_Id"
        AND "b"."ASMAY_Id" = "@ASMAY_Id"
        AND "b"."ASMCL_Id" = "@ASMCL_Id"
        AND "b"."ASMS_Id" = "@ASMS_Id"
        AND "b"."EME_Id" = "@EME_Id"
        AND "f"."ASMAY_Id" = "@ASMAY_Id"
        AND "f"."ASMCL_Id" = "@ASMCL_Id"
        AND "f"."ASMS_Id" = "@ASMS_Id"
        AND "f"."MI_Id" = "@MI_Id"
        AND "f"."ESTSU_ActiveFlg" = 1
        AND "f"."AMST_Id" IN (
            SELECT CAST(unnest(string_to_array("@AMST_Id", ',')) AS BIGINT)
        )
    ORDER BY
        "a"."EXTTS_Date" ASC,
        "e"."ETTS_StartTime" ASC;
END;
$$;