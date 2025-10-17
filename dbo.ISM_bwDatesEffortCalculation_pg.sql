CREATE OR REPLACE FUNCTION "dbo"."ISM_bwDatesEffortCalculation"(
    p_FromDate TIMESTAMP,
    p_ToDate TIMESTAMP
)
RETURNS TABLE("AllDays" TIMESTAMP)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TOTALCount INT;
    v_FromDate TIMESTAMP;
BEGIN
    v_FromDate := p_FromDate - INTERVAL '1 day';
    v_TOTALCount := EXTRACT(DAY FROM (p_ToDate - v_FromDate));

    RETURN QUERY
    WITH d AS 
    (
        SELECT v_FromDate + (ROW_NUMBER() OVER (ORDER BY oid)) * INTERVAL '1 day' AS AllDays
        FROM pg_class
        LIMIT v_TOTALCount
    )
    SELECT d.AllDays FROM d;
    
    RETURN;
END;
$$;