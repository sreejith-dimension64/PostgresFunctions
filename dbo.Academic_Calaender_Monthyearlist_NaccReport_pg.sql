CREATE OR REPLACE FUNCTION "dbo"."Academic_Calaender_Monthyearlist_NaccReport"(
    "ASMAY_Id" VARCHAR,
    "MI_Id" VARCHAR
)
RETURNS TABLE (
    "yearname" INTEGER,
    "monthid" DOUBLE PRECISION,
    "monthyear" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "FROMDATE" TIMESTAMP;
    "TODATE" TIMESTAMP;
    "DATE" TIMESTAMP;
    "MONTH" VARCHAR;
    "MONTHNAME" VARCHAR;
    "YEAR" VARCHAR;
    "DAY" VARCHAR;
    "DAYNAME" VARCHAR;
    "EVENTNAME" VARCHAR;
    "FLAG" VARCHAR;
    "EVENTNAME_NEW" VARCHAR;
BEGIN

    SELECT "ASMAY_From_Date", "ASMAY_To_Date" 
    INTO "FROMDATE", "TODATE"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "MI_Id" AND "ASMAY_Id" = "ASMAY_Id";

    RETURN QUERY
    SELECT DISTINCT 
        EXTRACT(YEAR FROM a."FOMHWDD_FromDate")::INTEGER AS "yearname",
        EXTRACT(MONTH FROM a."FOMHWDD_FromDate") AS "monthid",
        UPPER(TO_CHAR(a."FOMHWDD_FromDate", 'Month') || ' ' || EXTRACT(YEAR FROM a."FOMHWDD_FromDate")::TEXT) AS "monthyear"
    FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a 
    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    WHERE a."mi_id" = "Academic_Calaender_Monthyearlist_NaccReport"."MI_Id" 
        AND a."FOMHWDD_FromDate" BETWEEN "FROMDATE" AND "TODATE"
    ORDER BY EXTRACT(YEAR FROM a."FOMHWDD_FromDate"), EXTRACT(MONTH FROM a."FOMHWDD_FromDate");

END;
$$;