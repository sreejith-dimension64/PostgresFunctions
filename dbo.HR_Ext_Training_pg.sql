CREATE OR REPLACE FUNCTION "HR_Ext_Training"(
    p_MI_Id TEXT,
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRME_EmployeeFirstName" VARCHAR(600),
    "HREXTTRN_TrainingTopic" TEXT,
    "HREXTTRN_StartDate" TIMESTAMP,
    "HREXTTRN_EndDate" TIMESTAMP,
    "TrainngDuration" NUMERIC,
    "HRMETRTY_Id" BIGINT,
    "HRMETRTY_ExternalTrainingType" TEXT,
    "TotalDuration" NUMERIC,
    "TotalusedDuration" NUMERIC,
    "Balancehrs" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id BIGINT;
    v_HRMET_Id BIGINT;
    v_HRMD_Id BIGINT;
    v_HRME_EmployeeFirstName VARCHAR(600);
    v_sql TEXT;
BEGIN
    FOR v_HRME_Id, v_HRMET_Id, v_HRMD_Id, v_HRME_EmployeeFirstName IN
        SELECT "HRME_Id", "HRMET_Id", "HRMD_Id", "HRME_EmployeeFirstName" 
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = p_MI_Id::BIGINT
    LOOP
        v_sql := '
        SELECT DISTINCT HME."HRME_Id", HME."HRME_EmployeeFirstName", ITP."HREXTTRN_TrainingTopic", ITP."HREXTTRN_StartDate", ITP."HREXTTRN_EndDate", ITP."HREXTTRN_TotalHrs" AS TrainngDuration, ITP."HRMETRTY_Id",  
        ITC."HRMETRTY_ExternalTrainingType", ITC."HRMETRTY_MinimumTrainingHrs" AS TotalDuration, (ITP."HREXTTRN_TotalHrs") AS TotalusedDuration, (ITC."HRMETRTY_MinimumTrainingHrs" - ITP."HREXTTRN_TotalHrs") AS Balancehrs    
        FROM "HR_External_Training" ITP        
        INNER JOIN "HR_Master_External_TrainingType" ITC ON ITC."HRMETRTY_Id" = ITP."HRMETRTY_Id"        
        INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = ITP."HRME_Id" AND HME."HRME_ActiveFlag" = TRUE        
        WHERE ITP."MI_Id" IN (' || p_MI_Id || ') AND ((ITP."HREXTTRN_StartDate"::DATE) >= ''' || p_StartDate || '''::DATE AND (ITP."HREXTTRN_EndDate"::DATE) <= ''' || p_EndDate || '''::DATE)';
    END LOOP;
    
    RETURN QUERY EXECUTE
        'SELECT DISTINCT HME."HRME_Id", HME."HRME_EmployeeFirstName", ITP."HREXTTRN_TrainingTopic", ITP."HREXTTRN_StartDate", ITP."HREXTTRN_EndDate", ITP."HREXTTRN_TotalHrs" AS TrainngDuration, ITP."HRMETRTY_Id",  
        ITC."HRMETRTY_ExternalTrainingType", ITC."HRMETRTY_MinimumTrainingHrs" AS TotalDuration, (ITP."HREXTTRN_TotalHrs") AS TotalusedDuration, (ITC."HRMETRTY_MinimumTrainingHrs" - ITP."HREXTTRN_TotalHrs") AS Balancehrs    
        FROM "HR_External_Training" ITP        
        INNER JOIN "HR_Master_External_TrainingType" ITC ON ITC."HRMETRTY_Id" = ITP."HRMETRTY_Id"        
        INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = ITP."HRME_Id" AND HME."HRME_ActiveFlag" = TRUE        
        WHERE ITP."MI_Id" IN (' || p_MI_Id || ') AND ((ITP."HREXTTRN_StartDate"::DATE) >= $1::DATE AND (ITP."HREXTTRN_EndDate"::DATE) <= $2::DATE)'
    USING p_StartDate, p_EndDate;
    
    RETURN;
END;
$$;