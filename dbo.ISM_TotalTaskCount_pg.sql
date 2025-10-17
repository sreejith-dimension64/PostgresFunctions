CREATE OR REPLACE FUNCTION "dbo"."ISM_TotalTaskCount"(
    "MI_Id" VARCHAR(200),
    "HRME_Id" VARCHAR(200),
    "UserId" VARCHAR(200)
)
RETURNS TABLE("TotalCount" BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT "TC"."ISMTCR_Id") AS "TotalCount" 
    FROM "ISM_TaskCreation" "TC"
    LEFT JOIN "ISM_TaskCreation_AssignedTo" "TA" ON "TC"."ISMTCR_Id" = "TA"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" "TT" ON "TC"."ISMTCR_Id" = "TT"."ISMTCR_Id" AND "TC"."HRME_Id" = "TT"."HRME_Id"
    WHERE "TC"."HRME_Id" = "ISM_TotalTaskCount"."HRME_Id" AND "TC"."ISMTCR_ActiveFlg" = 1;
END;
$$;