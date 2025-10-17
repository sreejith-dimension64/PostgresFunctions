CREATE OR REPLACE FUNCTION "dbo"."HR_Training_CalculationBKP"(
    "@MI_Id" TEXT,
    "@StartDate" TIMESTAMP,
    "@EndDate" TIMESTAMP
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdynamic" TEXT;
    "@flag" VARCHAR(200);
    "@StartDate_N" VARCHAR(10);
    "@EndDate_N" VARCHAR(10);
    "@betweendates" TEXT;
BEGIN
    "@StartDate_N" := '';
    "@EndDate_N" := '';
    "@betweendates" := '';
    
    "@StartDate" := "@StartDate";
    "@EndDate" := "@EndDate";
    
    "@flag" := 'Notoverall';
    "@flag" := 'overall';
    
    IF "@StartDate_N" != '' AND "@EndDate_N" != '' THEN
        "@betweendates" := '((CAST("ITP"."HREXTTRN_StartDate" AS DATE))>=''' || "@StartDate_N" || ''' AND (CAST("ITP"."HREXTTRN_EndDate" AS DATE))<=''' || "@EndDate_N" || ''')';
    ELSE
        "@betweendates" := '';
    END IF;
    
    IF "@flag" = 'Notoverall' THEN
        "@Slqdynamic" := '
SELECT "HME"."HRME_EmployeeFirstName","ITP"."HREXTTRN_TrainingTopic","ITP"."HREXTTRN_StartDate","ITP"."HREXTTRN_EndDate","ITP"."HREXTTRN_TotalHrs","ITC"."HRMETRTY_ExternalTrainingType","ITC"."HRMETRTY_MinimumTrainingHrs"
FROM "HR_External_Training" "ITP"
INNER JOIN "HR_Master_External_TrainingType" "ITC" ON "ITC"."HRMETRTY_Id"="ITP"."HRMETRTY_Id"
INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag"=true
WHERE "ITP"."MI_Id" IN (' || "@MI_Id" || ') ' || "@betweendates" || '';
        
        EXECUTE "@Slqdynamic";
        RAISE NOTICE '%', "@Slqdynamic";
        
    ELSIF "@flag" = 'overall' THEN
        "@Slqdynamic" := '
SELECT "ITP"."HREXTTRN_TrainingTopic","ITP"."HREXTTRN_StartDate","ITP"."HREXTTRN_EndDate","ITP"."HREXTTRN_TotalHrs","ITC"."HRMETRTY_ExternalTrainingType","ITC"."HRMETRTY_MinimumTrainingHrs"
FROM "HR_External_Training" "ITP"
INNER JOIN "HR_Master_External_TrainingType" "ITC" ON "ITC"."HRMETRTY_Id"="ITP"."HRMETRTY_Id"
INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag"=true
WHERE "ITP"."MI_Id" IN (' || "@MI_Id" || ') ' || "@betweendates" || '';
        
        EXECUTE "@Slqdynamic";
        RAISE NOTICE '%', "@Slqdynamic";
    END IF;
    
    RETURN;
END;
$$;