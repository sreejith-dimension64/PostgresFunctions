CREATE OR REPLACE FUNCTION "dbo"."ISM_Rejected_Taskcount_Details"(
    "@hrme_id" BIGINT,
    "@MONTHID" VARCHAR(2),
    "@YEAR" VARCHAR(4)
)
RETURNS TABLE("rejectedcount" BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT("a"."ISMTCR_Id") AS "rejectedcount"
    FROM "ISM_TaskCreation_Response" "a"
    INNER JOIN "ISM_TaskCreation" "b" ON "a"."ISMTCR_Id" = "b"."ISMTCR_Id"
    INNER JOIN "ISM_DailyReport" "c" ON "c"."ISMTCR_Id" = "a"."ISMTCR_Id"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "d" ON "d"."ISMTCR_Id" = "a"."ISMTCR_Id"
    WHERE "a"."HRME_Id" = "@hrme_id"
        AND EXTRACT(MONTH FROM "a"."ISMTCRRES_ResponseDate")::VARCHAR = "@MONTHID"
        AND EXTRACT(YEAR FROM "a"."ISMTCRRES_ResponseDate")::VARCHAR = "@YEAR"
        AND "a"."ISMTCRRES_ActiveFlg" = 1
        AND "a"."ISMTCRRES_ResponsePageName" = 'Daily Report'
        AND "c"."ISMDRPT_ApprovedFlg" = 0;
END;
$$;