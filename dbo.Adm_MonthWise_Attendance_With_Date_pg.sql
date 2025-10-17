CREATE OR REPLACE FUNCTION "dbo"."Adm_MonthWise_Attendance_With_Date"(
    "MONTH" BIGINT,
    "YEAR" BIGINT
)
RETURNS TABLE("AllDays" TIMESTAMP)
LANGUAGE plpgsql
AS $$
DECLARE
    "FromDate" TIMESTAMP;
    "ToDate" TIMESTAMP;
    "TOTALCount" INT;
BEGIN
    SELECT DATE_TRUNC('year', MAKE_DATE(1900, 1, 1)) + 
           INTERVAL '1 year' * ("YEAR" - 1900) + 
           INTERVAL '1 month' * ("MONTH" - 1) INTO "FromDate";
    
    SELECT DATE_TRUNC('month', "FromDate") + INTERVAL '1 month' - INTERVAL '1 second' INTO "ToDate";
    
    "FromDate" := "FromDate" + INTERVAL '-1 day';
    
    SELECT EXTRACT(DAY FROM ("ToDate"::TIMESTAMP - "FromDate"::TIMESTAMP))::INT INTO "TOTALCount";
    
    RETURN QUERY
    WITH d AS (
        SELECT "FromDate" + INTERVAL '1 day' * ROW_NUMBER() OVER (ORDER BY a) AS "AllDays"
        FROM generate_series(1, "TOTALCount") a
    )
    SELECT d."AllDays" FROM d;
    
    RETURN;
END;
$$;