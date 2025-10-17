CREATE OR REPLACE FUNCTION "dbo"."HR_Training_Calculation"(
    "p_MI_Id" TEXT,
    "p_StartDate" TIMESTAMP,
    "p_EndDate" TIMESTAMP
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "HRME_EmployeeFirstName" VARCHAR,
    "HREXTTRN_TrainingTopic" VARCHAR,
    "HREXTTRN_StartDate" TIMESTAMP,
    "HREXTTRN_EndDate" TIMESTAMP,
    "TrainngDuration" NUMERIC,
    "HRMETRTY_Id" INTEGER,
    "HRMETRTY_ExternalTrainingType" VARCHAR,
    "TotalDuration" NUMERIC,
    "TotalusedDuration" NUMERIC,
    "Balancehrs" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_StartDate_N" VARCHAR(10);
    "v_EndDate_N" VARCHAR(10);
    "v_betweendates" TEXT;
BEGIN

    "v_StartDate_N" := TO_CHAR("p_StartDate"::DATE, 'YYYY-MM-DD');
    "v_EndDate_N" := TO_CHAR("p_EndDate"::DATE, 'YYYY-MM-DD');

    IF "v_StartDate_N" != '' AND "v_StartDate_N" IS NOT NULL AND "v_EndDate_N" != '' AND "v_EndDate_N" IS NOT NULL THEN
        "v_betweendates" := '((ITP."HREXTTRN_StartDate"::DATE)>=''' || "v_StartDate_N" || ''' AND (ITP."HREXTTRN_EndDate"::DATE)<=''' || "v_EndDate_N" || ''')';
    ELSE
        "v_betweendates" := '1=1';
    END IF;

    "v_Slqdymaic" := '
    SELECT DISTINCT HME."HRME_Id", HME."HRME_EmployeeFirstName", ITP."HREXTTRN_TrainingTopic", ITP."HREXTTRN_StartDate", ITP."HREXTTRN_EndDate", 
           ITP."HREXTTRN_TotalHrs" as "TrainngDuration", ITP."HRMETRTY_Id",
           ITC."HRMETRTY_ExternalTrainingType", ITC."HRMETRTY_MinimumTrainingHrs" as "TotalDuration", 
           (ITP."HREXTTRN_TotalHrs") as "TotalusedDuration", 
           (ITC."HRMETRTY_MinimumTrainingHrs" - ITP."HREXTTRN_TotalHrs") as "Balancehrs"
    FROM "HR_External_Training" ITP
    INNER JOIN "HR_Master_External_TrainingType" ITC ON ITC."HRMETRTY_Id" = ITP."HRMETRTY_Id"
    INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = ITP."HRME_Id" AND HME."HRME_ActiveFlag" = true
    WHERE ITP."MI_Id" IN (' || "p_MI_Id" || ') AND ' || "v_betweendates";

    RAISE NOTICE '%', "v_Slqdymaic";

    RETURN QUERY EXECUTE "v_Slqdymaic";

END;
$$;