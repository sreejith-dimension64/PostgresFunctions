CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_TaskDeatils_view2_Tasks" (
    "p_ISMTPL_Id" bigint
)
RETURNS TABLE (
    "ISMTCR_Id" bigint,
    "ISMTPLTA_StartDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ISMTCR_Id",
        (SELECT "ISMTPLTA_StartDate" 
         FROM "ISM_Task_Planner_Tasks" 
         WHERE "ISMTCR_Id" = a."ISMTCR_Id" 
         ORDER BY "ISMTPLTA_StartDate" 
         LIMIT 1) AS "ISMTPLTA_StartDate",
        (SELECT "ISMTPLTA_StartDate" 
         FROM "ISM_Task_Planner_Tasks" 
         WHERE "ISMTCR_Id" = a."ISMTCR_Id" 
         ORDER BY "ISMTPLTA_EndDate" DESC 
         LIMIT 1) AS "ISMTPLTA_EndDate"
    FROM "ISM_Task_Planner_Tasks" a
    INNER JOIN "ISM_Task_Advance_Planner" b ON a."ISMTCR_Id" = b."ISMTCR_Id"
    WHERE "ISMTPL_Id" = "p_ISMTPL_Id" 
        AND b."ISMTAPL_Periodicity" = 'Daily'
    ORDER BY a."ISMTCR_Id";
END;
$$;