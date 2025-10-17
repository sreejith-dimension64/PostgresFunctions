CREATE OR REPLACE FUNCTION "dbo"."Exam_Mark_cumalative_Sarvodaya_List"(
    p_EME_Id TEXT
)
RETURNS TABLE(
    "EME_Id" BIGINT,
    "EME_ExamName" TEXT,
    "EMSE_SubExamName" TEXT,
    "EMPSG_GroupName" TEXT,
    "Subject_Flag" INTEGER,
    "ESTMPSSS_MaxMarks" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_ID BIGINT;
BEGIN
    SELECT "AMST_ID" INTO v_AMST_ID 
    FROM "SarvodayaStudentDetails_NEW" 
    WHERE "Subject_Flag" IN (0,2,3,4,5,6,7,8)
    ORDER BY "AMST_ID" DESC 
    LIMIT 1;

    RETURN QUERY
    SELECT 
        s."EME_Id",
        s."EME_ExamName",
        s."EMSE_SubExamName",
        s."EMPSG_GroupName",
        s."Subject_Flag",
        MAX(s."ESTMPSSS_MaxMarks") AS "ESTMPSSS_MaxMarks"
    FROM "SarvodayaStudentDetails_NEW" s
    WHERE s."AMST_ID" = v_AMST_ID 
        AND NOT (s."EME_ExamName" = s."EMSE_SubExamName" AND s."Subject_Flag" = 0)
    GROUP BY s."EME_Id", s."EME_ExamName", s."EMSE_SubExamName", s."EMPSG_GroupName", s."Subject_Flag"
    ORDER BY s."EMPSG_GroupName", s."EME_Id", s."Subject_Flag";

    RETURN;
END;
$$;