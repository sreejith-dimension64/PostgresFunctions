CREATE OR REPLACE FUNCTION "dbo"."Clg_Student_Feedback_Transaction"(
    "@MI_Id" bigint,
    "@AMCST_Id" bigint
)
RETURNS TABLE(
    "FCSTR_FeedbackDate" TIMESTAMP,
    "FCSTR_FeedBack" TEXT,
    "FMTY_FeedbackTypeName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "A"."FCSTR_FeedbackDate",
        "A"."FCSTR_FeedBack",
        "C"."FMTY_FeedbackTypeName"
    FROM "CLG"."Feedback_College_Student_Transaction" "A"
    INNER JOIN "Feedback_Master_Questions" "B" ON "A"."FMQE_Id" = "B"."FMQE_Id"
    INNER JOIN "Feedback_Master_Type" "C" ON "C"."FMTY_Id" = "A"."FMTY_Id"
    WHERE "A"."MI_Id" = "@MI_Id" 
        AND "A"."AMCST_Id" = "@AMCST_Id" 
        AND "B"."FMQE_ManualEntryFlg" = 1;
END;
$$;