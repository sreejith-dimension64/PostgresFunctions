CREATE OR REPLACE FUNCTION ay_dates(p_MI_ID bigint)
RETURNS TABLE(fromdate timestamp, todate timestamp)
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE tempx (fromdate timestamp, todate timestamp) ON COMMIT DROP;

    INSERT INTO tempx
    SELECT "ASMAY_From_Date" AS fromdate, "ASMAY_To_Date" AS todate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_ID;

    INSERT INTO tempx
    SELECT "ASMAY_From_Date" AS fromdate, "ASMAY_To_Date" AS todate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_ID;

    RETURN QUERY SELECT tempx.fromdate, tempx.todate FROM tempx;
    
    DROP TABLE IF EXISTS tempx;
END;
$$;