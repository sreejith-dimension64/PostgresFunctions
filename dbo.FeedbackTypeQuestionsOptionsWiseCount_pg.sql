CREATE OR REPLACE FUNCTION "dbo"."FeedbackTypeQuestionsOptionsWiseCount"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint
)
RETURNS TABLE(
    "FMTY_FeedbackTypeName" VARCHAR,
    "FMQE_FeedbackQuestions" VARCHAR,
    "FMOP_FeedbackOptions" VARCHAR,
    "TotalCount" BIGINT,
    "StuOptionsCount" BIGINT,
    "ParentsOptionsCount" BIGINT,
    "result_set" INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "FMT"."FMTY_FeedbackTypeName",
        "FMQ"."FMQE_FeedbackQuestions",
        "FMO"."FMOP_FeedbackOptions",
        COUNT("FMO"."FMOP_FeedbackOptions") AS "TotalCount",
        NULL::BIGINT AS "StuOptionsCount",
        NULL::BIGINT AS "ParentsOptionsCount",
        1 AS "result_set"
    FROM "clg"."Feedback_College_Student_Transaction" "FCST"
    INNER JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FCST"."FMTY_Id"
    INNER JOIN "Feedback_Master_Questions" "FMQ" ON "FMQ"."FMQE_Id" = "FCST"."FMQE_Id"
    INNER JOIN "Feedback_Master_Options" "FMO" ON "FMO"."FMOP_Id" = "FCST"."FMOP_Id"
    WHERE "FCST"."MI_Id" = "p_MI_Id" 
        AND "FMT"."MI_Id" = "p_MI_Id" 
        AND "FMQ"."MI_Id" = "p_MI_Id" 
        AND "FMO"."MI_Id" = "p_MI_Id" 
        AND "FCST"."ASMAY_Id" = "p_ASMAY_Id"
    GROUP BY "FMT"."FMTY_FeedbackTypeName", "FMQ"."FMQE_FeedbackQuestions", "FMO"."FMOP_FeedbackOptions";

    RETURN QUERY
    SELECT DISTINCT 
        "FMT"."FMTY_FeedbackTypeName",
        "FMQ"."FMQE_FeedbackQuestions",
        "FMO"."FMOP_FeedbackOptions",
        NULL::BIGINT AS "TotalCount",
        COUNT("FMO"."FMOP_FeedbackOptions") AS "StuOptionsCount",
        NULL::BIGINT AS "ParentsOptionsCount",
        2 AS "result_set"
    FROM "clg"."Feedback_College_Student_Transaction" "FCST"
    INNER JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FCST"."FMTY_Id"
    INNER JOIN "Feedback_Master_Questions" "FMQ" ON "FMQ"."FMQE_Id" = "FCST"."FMQE_Id"
    INNER JOIN "Feedback_Master_Options" "FMO" ON "FMO"."FMOP_Id" = "FCST"."FMOP_Id"
    WHERE "FCST"."MI_Id" = "p_MI_Id" 
        AND "FMT"."MI_Id" = "p_MI_Id" 
        AND "FMQ"."MI_Id" = "p_MI_Id" 
        AND "FMO"."MI_Id" = "p_MI_Id" 
        AND "FCST"."ASMAY_Id" = "p_ASMAY_Id"
        AND "FCST"."FCSTR_StudParFlg" = 'Student'
    GROUP BY "FMT"."FMTY_FeedbackTypeName", "FMQ"."FMQE_FeedbackQuestions", "FMO"."FMOP_FeedbackOptions";

    RETURN QUERY
    SELECT DISTINCT 
        "FMT"."FMTY_FeedbackTypeName",
        "FMQ"."FMQE_FeedbackQuestions",
        "FMO"."FMOP_FeedbackOptions",
        NULL::BIGINT AS "TotalCount",
        NULL::BIGINT AS "StuOptionsCount",
        COUNT("FMO"."FMOP_FeedbackOptions") AS "ParentsOptionsCount",
        3 AS "result_set"
    FROM "clg"."Feedback_College_Student_Transaction" "FCST"
    INNER JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FCST"."FMTY_Id"
    INNER JOIN "Feedback_Master_Questions" "FMQ" ON "FMQ"."FMQE_Id" = "FCST"."FMQE_Id"
    INNER JOIN "Feedback_Master_Options" "FMO" ON "FMO"."FMOP_Id" = "FCST"."FMOP_Id"
    WHERE "FCST"."MI_Id" = "p_MI_Id" 
        AND "FMT"."MI_Id" = "p_MI_Id" 
        AND "FMQ"."MI_Id" = "p_MI_Id" 
        AND "FMO"."MI_Id" = "p_MI_Id" 
        AND "FCST"."ASMAY_Id" = "p_ASMAY_Id"
        AND "FCST"."FCSTR_StudParFlg" = 'PARENTS'
    GROUP BY "FMT"."FMTY_FeedbackTypeName", "FMQ"."FMQE_FeedbackQuestions", "FMO"."FMOP_FeedbackOptions";

    RETURN;
END;
$$;