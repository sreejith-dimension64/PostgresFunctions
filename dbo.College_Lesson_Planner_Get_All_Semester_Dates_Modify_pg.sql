CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Get_All_Semester_Dates_Modify"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ISMS_Id" TEXT,
    "@HRME_Id" TEXT,
    "@ACMS_Id" TEXT
)
RETURNS TABLE(
    "alldates" DATE,
    "DatePart" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@FROMDATE" TIMESTAMP;
    "@TODATE" TIMESTAMP;
    "@FROMDATE_NEW" TIMESTAMP;
    "@TODATE_NEW" TIMESTAMP;
    "@TOTALCount" INT;
BEGIN

    DROP TABLE IF EXISTS datestable;

    SELECT "ACAYCBS_SemStartDate", "ACAYCBS_SemEndDate" 
    INTO "@FROMDATE", "@TODATE"
    FROM "clg"."Adm_College_AY_Course" a 
    INNER JOIN "clg"."Adm_College_AY_Course_Branch" b ON a."ACAYC_Id" = b."ACAYC_Id" 
    INNER JOIN "clg"."Adm_College_AY_Course_Branch_Semester" c ON c."ACAYCB_Id" = b."ACAYCB_Id" 
    WHERE "AMSE_Id" = "@AMSE_Id"::INTEGER 
        AND "AMCO_Id" = "@AMCO_Id"::INTEGER
        AND "AMB_Id" = "@AMB_Id"::INTEGER 
        AND a."ACAYC_ActiveFlag" = 1 
        AND b."ACAYCB_ActiveFlag" = 1 
        AND c."ACAYCBS_ActiveFlag" = 1  
        AND a."ASMAY_Id" = "@ASMAY_Id"::INTEGER;

    SET "@FROMDATE_NEW" = "@FROMDATE" - INTERVAL '1 day';
    SELECT EXTRACT(DAY FROM ("@TODATE" - "@FROMDATE")) INTO "@TOTALCount";

    CREATE TEMP TABLE datestable AS
    WITH d AS (
        SELECT ("@FROMDATE_NEW" + (n || ' days')::INTERVAL)::DATE AS "AllDays"
        FROM generate_series(1, "@TOTALCount") AS n
    )
    SELECT "AllDays"::DATE AS alldates 
    FROM d 
    WHERE "AllDays" NOT IN (
        SELECT A."FOMHWDD_FromDate"  
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" A 
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" B ON A."FOHWDT_Id" = B."FOHWDT_Id" 
        WHERE A."MI_Id" = "@MI_Id"::INTEGER 
            AND B."FOHWDT_ActiveFlg" = 1 
            AND B."FOHTWD_HolidayFlag" = 1
    );

    RETURN QUERY
    SELECT dt.alldates, TO_CHAR(dt.alldates, 'Day') AS "DatePart" 
    FROM datestable dt
    WHERE TO_CHAR(dt.alldates, 'Day') IN (
        SELECT DISTINCT c."TTMD_DayName" 
        FROM "TT_Final_Generation" a 
        INNER JOIN "TT_Final_Generation_Detailed_College" b ON a."TTFG_Id" = b."TTFG_Id" 
        INNER JOIN "TT_Master_Day" c ON c."TTMD_Id" = b."TTMD_Id"
        WHERE "ASMAY_Id" = "@ASMAY_Id"::INTEGER 
            AND "AMCO_Id" = "@AMCO_Id"::INTEGER 
            AND "AMB_Id" = "@AMB_Id"::INTEGER 
            AND "AMSE_Id" = "@AMSE_Id"::INTEGER 
            AND "ACMS_Id" = "@ACMS_Id"::INTEGER 
            AND "ISMS_Id" = "@ISMS_Id"::INTEGER 
            AND "HRME_Id" = "@HRME_Id"::INTEGER
    );

    DROP TABLE IF EXISTS datestable;

END;
$$;