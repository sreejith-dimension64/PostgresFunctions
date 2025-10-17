CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_Category" (
    "ISMTPL_Id" bigint
)
RETURNS TABLE (
    "ISMMTCAT_TaskCategoryName" VARCHAR,
    "ISMMTCAT_CompulsoryFlg" VARCHAR,
    "ISMMTCAT_TaskPercentage" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        b."ISMMTCAT_TaskCategoryName",
        b."ISMMTCAT_CompulsoryFlg",
        b."ISMMTCAT_TaskPercentage" 
    FROM "ISM_Task_Planner_Category" a 
    INNER JOIN "ISM_Master_TaskCategory" b ON a."ISMMTCAT_Id" = b."ISMMTCAT_Id" 
    WHERE a."ISMTPL_Id" = "ISMTPL_Id";

END;
$$;