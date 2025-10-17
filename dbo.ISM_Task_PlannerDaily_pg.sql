CREATE OR REPLACE FUNCTION "dbo"."ISM_Task_PlannerDaily"(@ISMTPL_Id BIGINT)
RETURNS TABLE("AllDates" DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_StartDate DATE;
    v_EndDate DATE;
BEGIN
    SELECT "ISMTPL_StartDate" INTO v_StartDate 
    FROM "ISM_Task_Planner" 
    WHERE "ISMTPL_Id" = @ISMTPL_Id;
    
    SELECT "ISMTPL_EndDate" INTO v_EndDate 
    FROM "ISM_Task_Planner" 
    WHERE "ISMTPL_Id" = @ISMTPL_Id;
    
    RETURN QUERY
    WITH RECURSIVE "ListDates"("AllDates") AS (
        SELECT v_StartDate AS "AllDates"
        UNION ALL
        SELECT ("AllDates" + INTERVAL '1 day')::DATE
        FROM "ListDates"
        WHERE "AllDates" < v_EndDate
    )
    SELECT "AllDates"
    FROM "ListDates";
END;
$$;