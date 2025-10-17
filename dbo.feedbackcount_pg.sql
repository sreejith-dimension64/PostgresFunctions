CREATE OR REPLACE FUNCTION "dbo"."feedbackcount"(
    "HRME_Id" bigint
)
RETURNS TABLE("totalcount" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT COUNT("a"."ISMDRF_Id") AS "totalcount"
    FROM "ISM_DailyReport_FeedBack" "a", "HR_Master_Employee" "b" 
    WHERE "a"."ISMDRF_Send_HRME_Id" = "b"."HRME_Id" 
    AND "a"."ISMDRF_RCV_HRME_Id" = 1538 
    AND "a"."ISMDRF_OpenFeedback" = 1;
END;
$$;