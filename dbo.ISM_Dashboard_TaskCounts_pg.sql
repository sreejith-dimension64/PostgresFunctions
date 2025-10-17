CREATE OR REPLACE FUNCTION "dbo"."ISM_Dashboard_TaskCounts" (
    "@MI_Id" BIGINT,
    "@HRME_Id" BIGINT
)
RETURNS TABLE (
    "opencount" BIGINT,
    "completedcount" BIGINT,
    "closedcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN

    RETURN QUERY
    SELECT DISTINCT 

    (CASE WHEN "TC"."ISMTCR_Status"='Open' THEN (SELECT DISTINCT COUNT(COALESCE("ISMTCR_Id",0)) FROM "ISM_TaskCreation" a WHERE a."MI_Id"="@MI_Id" AND a."HRME_Id"="@HRME_Id" AND a."ISMTCR_Status"='Open')
    END)::BIGINT AS "opencount",

    (CASE WHEN "TC"."ISMTCR_Status"='Completed' THEN (SELECT DISTINCT COUNT(COALESCE("ISMTCR_Id",0)) FROM "ISM_TaskCreation" b WHERE b."MI_Id"="@MI_Id" AND b."HRME_Id"="@HRME_Id" AND b."ISMTCR_Status"='Completed')
    END)::BIGINT AS "completedcount",

    (CASE WHEN "TC"."ISMTCR_Status"='Closed' THEN (SELECT DISTINCT COUNT(COALESCE("ISMTCR_Id",0)) FROM "ISM_TaskCreation" c WHERE c."MI_Id"="@MI_Id" AND c."HRME_Id"="@HRME_Id" AND c."ISMTCR_Status"='Closed')
    END)::BIGINT AS "closedcount"

    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_Master_Project" "PR" ON "TC"."ISMMPR_Id"="PR"."ISMMPR_Id" AND "PR"."ISMMPR_ActiveFlg"=1
    INNER JOIN "HR_Master_Priority" "PRI" ON "TC"."HRMPR_Id"="PRI"."HRMPR_Id" AND "PRI"."HRMP_ActiveFlag"=1
    WHERE "TC"."MI_Id"="PR"."MI_Id" AND "TC"."ISMTCR_ActiveFlg"= 1 AND "TC"."MI_Id"="@MI_Id" AND "TC"."HRME_Id"="@HRME_Id";

END;
$$;