CREATE OR REPLACE FUNCTION "dbo"."ISM_Get_Planner_Extension_Details"(
    p_HRME_Id TEXT,
    p_user_Id TEXT
)
RETURNS TABLE(
    "HRME_Id" VARCHAR,
    "ISMPLE_FromDate" TIMESTAMP,
    "ISMPLE_ToDate" TIMESTAMP,
    "ISMPLE_ActiveFlg" INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * 
    FROM "ISM_PlannerExtension" 
    WHERE "HRME_Id" = p_HRME_Id 
    AND (
        CAST("ISMPLE_FromDate" AS DATE) >= CURRENT_DATE
        AND CAST("ISMPLE_ToDate" AS DATE) <= CURRENT_DATE
    ) 
    AND "ISMPLE_ActiveFlg" = 1;
END;
$$;