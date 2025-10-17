CREATE OR REPLACE FUNCTION "dbo"."Check_Assign_Task_Details" (
    "p_ISMTCR_Id" BIGINT, 
    "p_HRME_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "HRME_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_editable" BOOLEAN;
    "v_count" BIGINT;
    "v_headcount" BIGINT;
BEGIN
    "v_editable" := FALSE;
    
    SELECT COUNT(*) INTO "v_headcount"
    FROM "HR_Master_DepartmentCode_Head"
    WHERE "HRME_ID" = "p_HRME_Id";
    
    IF "v_headcount" = 0 THEN
        SELECT COUNT(*) INTO "v_count"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "ISM_TaskCreation_AssignedTo" "TA" ON "TC"."ISMTCR_Id" = "TA"."ISMTCR_Id"
        WHERE "TC"."HRME_Id" = "p_HRME_Id" 
            AND "TA"."HRME_Id" = "p_HRME_Id" 
            AND "TC"."ISMTCR_Id" = "p_ISMTCR_Id" 
            AND "TC"."ISMTCR_Id" NOT IN (
                SELECT "ISMTCR_Id" 
                FROM "ISM_Task_Planner" "PL" 
                INNER JOIN "ISM_Task_Planner_Tasks" "PT" ON "PL"."ISMTPL_Id" = "PT"."ISMTPL_Id"
            );
        
        IF "v_count" > 0 THEN
            RETURN QUERY
            SELECT "TA"."ISMTCR_Id", "TC"."HRME_Id"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TA" ON "TC"."ISMTCR_Id" = "TA"."ISMTCR_Id"
            WHERE "TC"."HRME_Id" = "p_HRME_Id" 
                AND "TA"."HRME_Id" = "p_HRME_Id" 
                AND "TC"."ISMTCR_Id" = "p_ISMTCR_Id" 
                AND "TC"."ISMTCR_Id" NOT IN (
                    SELECT "ISMTCR_Id" 
                    FROM "ISM_Task_Planner" "PL" 
                    INNER JOIN "ISM_Task_Planner_Tasks" "PT" ON "PL"."ISMTPL_Id" = "PT"."ISMTPL_Id"
                );
        END IF;
    ELSE
        SELECT COUNT(*) INTO "v_count"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "ISM_TaskCreation_AssignedTo" "TA" ON "TC"."ISMTCR_Id" = "TA"."ISMTCR_Id"
        WHERE "TA"."ISMTCRASTO_AssignedBy" = "p_HRME_Id" 
            AND "TC"."ISMTCR_Id" = "p_ISMTCR_Id" 
            AND "TC"."ISMTCR_Id" NOT IN (
                SELECT "ISMTCR_Id" 
                FROM "ISM_Task_Planner" "PL" 
                INNER JOIN "ISM_Task_Planner_Tasks" "PT" ON "PL"."ISMTPL_Id" = "PT"."ISMTPL_Id"
            );
        
        IF "v_count" > 0 THEN
            RETURN QUERY
            SELECT "TA"."ISMTCR_Id", "TC"."HRME_Id"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TA" ON "TC"."ISMTCR_Id" = "TA"."ISMTCR_Id"
            WHERE "TA"."ISMTCRASTO_AssignedBy" = "p_HRME_Id" 
                AND "TC"."ISMTCR_Id" = "p_ISMTCR_Id" 
                AND "TC"."ISMTCR_Id" NOT IN (
                    SELECT "ISMTCR_Id" 
                    FROM "ISM_Task_Planner" "PL" 
                    INNER JOIN "ISM_Task_Planner_Tasks" "PT" ON "PL"."ISMTPL_Id" = "PT"."ISMTPL_Id"
                );
        END IF;
    END IF;
    
    RETURN;
END;
$$;