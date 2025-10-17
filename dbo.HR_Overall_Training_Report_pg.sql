CREATE OR REPLACE FUNCTION "HR_Overall_Training_Report"(
    IN p_MI_Id TEXT,
    IN p_StartDate TIMESTAMP,
    IN p_EndDate TIMESTAMP
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "HREXTTRN_TrainingTopic" TEXT,
    "HREXTTRN_TotalHrs" NUMERIC,
    "HRMETRTY_ExternalTrainingType" TEXT,
    "HRMETRTY_MinimumTrainingHrs" NUMERIC,
    "HREXTTRN_StartDate" TIMESTAMP,
    "HREXTTRN_EndDate" TIMESTAMP,
    "HRMETRTY_Id" INTEGER,
    "Balancehrs" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_Startdate_N VARCHAR(10);
    v_Enddate_N VARCHAR(10);
    v_Betweendates TEXT;
BEGIN
    
    v_Startdate_N := TO_CHAR(p_StartDate, 'YYYY-MM-DD');
    v_Enddate_N := TO_CHAR(p_EndDate, 'YYYY-MM-DD');
    
    IF v_Startdate_N != '' AND v_Enddate_N != '' THEN
        
        v_Betweendates := '((DATE(A."HREXTTRN_StartDate"))>=''' || v_Startdate_N || ''' AND (DATE(A."HREXTTRN_EndDate"))<=''' || v_Enddate_N || ''')';
        
        v_sql := '
        SELECT b."HRME_Id",a."HREXTTRN_TrainingTopic",a."HREXTTRN_TotalHrs",c."HRMETRTY_ExternalTrainingType",c."HRMETRTY_MinimumTrainingHrs",a."HREXTTRN_StartDate",a."HREXTTRN_EndDate",c."HRMETRTY_Id",
        (c."HRMETRTY_MinimumTrainingHrs"-a."HREXTTRN_TotalHrs") as "Balancehrs"
        FROM "HR_External_Training" a
        INNER JOIN "HR_External_Training_Approval" b ON a."HREXTTRN_Id"=b."HREXTTRN_Id"
        INNER JOIN "HR_Master_External_TrainingType" c ON c."HRMETRTY_Id"=a."HRMETRTY_Id"
        WHERE a."MI_Id" IN (' || p_MI_Id || ') and ' || v_Betweendates;
        
        RAISE NOTICE '%', v_sql;
        
        RETURN QUERY EXECUTE v_sql;
        
    END IF;
    
    RETURN;
END;
$$;