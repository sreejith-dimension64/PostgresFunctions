CREATE OR REPLACE FUNCTION "dbo"."ISMEmpwiseDrDaywiseAppEfforts_Report"(
    "@MI_Id" TEXT,
    "@StartDate" VARCHAR(10),
    "@EndDate" VARCHAR(10),
    "@HRME_Id" TEXT
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "TimeTakenInHrs" TEXT,
    "ApprovedTimeInHrs" TEXT,
    "EffortInHrs" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQL TEXT;
BEGIN
    v_SQL := 'SELECT DISTINCT "HRME_Id",
    COALESCE(CAST(CAST("TimeTakenInMins" AS INTEGER)/60 AS VARCHAR) || '':'' || LPAD(CAST(CAST("TimeTakenInMins" AS INTEGER)%60 AS VARCHAR), 2, ''0''), ''0'') AS "TimeTakenInHrs",
    COALESCE(CAST(CAST("ApprovedTimeInMins" AS INTEGER)/60 AS VARCHAR) || '':'' || LPAD(CAST(CAST("ApprovedTimeInMins" AS INTEGER)%60 AS VARCHAR), 2, ''0''), ''0'') AS "ApprovedTimeInHrs",
    COALESCE(CAST(CAST("Rejectedtime" AS INTEGER)/60 AS VARCHAR) || '':'' || LPAD(CAST(CAST("Rejectedtime" AS INTEGER)%60 AS VARCHAR), 2, ''0''), ''0'') AS "EffortInHrs"
    FROM (
        SELECT DISTINCT DR."HRME_Id",
        SUM((COALESCE("ISMDRPT_TimeTakenInHrs", 0)*60)) AS "TimeTakenInMins",
        SUM(COALESCE("ISMDRPT_ApprovedTime", 0)*60) AS "ApprovedTimeInMins",
        (SUM((COALESCE("ISMDRPT_TimeTakenInHrs", 0)*60)) - SUM(COALESCE("ISMDRPT_ApprovedTime", 0)*60)) AS "Rejectedtime"
        FROM "ISM_DailyReport" DR
        INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = DR."HRME_Id"
        WHERE HME."HRME_Id" IN (' || "@HRME_Id" || ') 
        AND (CAST(DR."ISMDRPT_Date" AS DATE) BETWEEN ''' || "@StartDate" || ''' AND ''' || "@EndDate" || ''')
        AND DR."HRME_Id" IN (' || "@HRME_Id" || ') 
        GROUP BY DR."HRME_Id"
    ) AS "New" 
    ORDER BY "HRME_Id"';
    
    RETURN QUERY EXECUTE v_SQL;
END;
$$;