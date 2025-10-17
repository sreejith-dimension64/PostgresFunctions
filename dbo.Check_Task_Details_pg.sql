CREATE OR REPLACE FUNCTION "dbo"."Check_Task_Details" (
    "@ISMTCR_Id" BIGINT, 
    "@HRME_Id" BIGINT
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "HRME_Id" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@editable" BOOLEAN;
    "@count" BIGINT;
    "@headcount" BIGINT;
BEGIN
    "@editable" := FALSE;
    
    SELECT COUNT(*) INTO "@count"
    FROM "ISM_TaskCreation"
    WHERE "HRME_Id" = "@HRME_Id" 
        AND "ISMTCR_Id" = "@ISMTCR_Id" 
        AND "ISMTCR_Id" NOT IN (
            SELECT "ISMTCR_Id" 
            FROM "ISM_TaskCreation_AssignedTo"
        );
    
    IF "@count" > 0 THEN
        RETURN QUERY
        SELECT * 
        FROM "ISM_TaskCreation"
        WHERE "HRME_Id" = "@HRME_Id" 
            AND "ISMTCR_Id" = "@ISMTCR_Id" 
            AND "ISMTCR_Id" NOT IN (
                SELECT "ISMTCR_Id" 
                FROM "ISM_TaskCreation_AssignedTo"
            );
    END IF;
    
    RETURN;
END;
$$;