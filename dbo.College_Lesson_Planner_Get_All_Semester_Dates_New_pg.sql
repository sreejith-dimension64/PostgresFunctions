CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Get_All_Semester_Dates_New"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMCO_Id" TEXT,
    "AMB_Id" TEXT,
    "AMSE_Id" TEXT,
    "ISMS_Id" TEXT,
    "HRME_Id" TEXT
)
RETURNS TABLE(
    "alldates" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    "FROMDATE" TIMESTAMP;
    "TODATE" TIMESTAMP;
    "FROMDATE_NEW" TIMESTAMP;
    "TODATE_NEW" TIMESTAMP;
    "TOTALCount" INTEGER;
BEGIN
    
    SELECT "ACAYCBS_SemStartDate", "ACAYCBS_SemEndDate" 
    INTO "FROMDATE", "TODATE"
    FROM "clg"."Adm_College_AY_Course" a 
    INNER JOIN "clg"."Adm_College_AY_Course_Branch" b ON a."ACAYC_Id" = b."ACAYC_Id" 
    INNER JOIN "clg"."Adm_College_AY_Course_Branch_Semester" c ON c."ACAYCB_Id" = b."ACAYCB_Id" 
    WHERE c."AMSE_Id" = "AMSE_Id"::BIGINT 
        AND a."AMCO_Id" = "AMCO_Id"::BIGINT
        AND b."AMB_Id" = "AMB_Id"::BIGINT 
        AND a."ACAYC_ActiveFlag" = 1 
        AND b."ACAYCB_ActiveFlag" = 1 
        AND c."ACAYCBS_ActiveFlag" = 1  
        AND a."ASMAY_Id" = "ASMAY_Id"::BIGINT;

    "FROMDATE_NEW" := "FROMDATE" - INTERVAL '1 DAY';
    "TOTALCount" := EXTRACT(DAY FROM ("TODATE" - "FROMDATE"));

    RETURN QUERY
    WITH d AS 
    (
        SELECT ("FROMDATE_NEW" + (n || ' days')::INTERVAL)::TIMESTAMP AS "AllDays"
        FROM generate_series(1, "TOTALCount") AS n
    )
    SELECT CAST(d."AllDays" AS DATE) AS "alldates" 
    FROM d 
    WHERE d."AllDays" NOT IN (
        SELECT A."FOMHWDD_FromDate"  
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" A 
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" B ON A."FOHWDT_Id" = B."FOHWDT_Id" 
        WHERE A."MI_Id" = "MI_Id"::BIGINT 
            AND B."FOHWDT_ActiveFlg" = 1 
            AND B."FOHTWD_HolidayFlag" = 1
    );

END;
$$;