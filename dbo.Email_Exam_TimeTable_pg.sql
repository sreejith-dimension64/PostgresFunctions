CREATE OR REPLACE FUNCTION "dbo"."Email_Exam_TimeTable"(
    "FirstName" VARCHAR(100),
    "EME_ExamName" VARCHAR(100),
    "EXTTS_Date" TIMESTAMP
)
RETURNS TABLE(
    "[NAME]" VARCHAR(100),
    "[EXAMNAME]" VARCHAR(100),
    "[DATE]" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "FirstName" AS "[NAME]",
        "EME_ExamName" AS "[EXAMNAME]",
        "EXTTS_Date" AS "[DATE]";
END;
$$;