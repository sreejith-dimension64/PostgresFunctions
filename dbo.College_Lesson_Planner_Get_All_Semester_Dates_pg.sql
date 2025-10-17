CREATE OR REPLACE FUNCTION "dbo"."College_Lesson_Planner_Get_All_Semester_Dates"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT
)
RETURNS TABLE(
    "alldates" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_FROMDATE" TIMESTAMP;
    "v_TODATE" TIMESTAMP;
    "v_FROMDATE_NEW" TIMESTAMP;
    "v_TODATE_NEW" TIMESTAMP;
    "v_TOTALCount" INTEGER;
BEGIN

    SELECT 
        "ACAYCBS_SemStartDate", 
        "ACAYCBS_SemEndDate" 
    INTO 
        "v_FROMDATE", 
        "v_TODATE"
    FROM 
        "clg"."Adm_College_AY_Course" a 
        INNER JOIN "clg"."Adm_College_AY_Course_Branch" b ON a."ACAYC_Id" = b."ACAYC_Id" 
        INNER JOIN "clg"."Adm_College_AY_Course_Branch_Semester" c ON c."ACAYCB_Id" = b."ACAYCB_Id" 
    WHERE 
        "AMSE_Id" = "p_AMSE_Id" 
        AND "AMCO_Id" = "p_AMCO_Id"
        AND "AMB_Id" = "p_AMB_Id" 
        AND a."ACAYC_ActiveFlag" = 1 
        AND b."ACAYCB_ActiveFlag" = 1 
        AND c."ACAYCBS_ActiveFlag" = 1  
        AND a."ASMAY_Id" = "p_ASMAY_Id";

    "v_FROMDATE_NEW" := "v_FROMDATE" - INTERVAL '1 day';
    "v_TOTALCount" := ("v_TODATE"::DATE - "v_FROMDATE"::DATE);

    RETURN QUERY
    WITH d AS (
        SELECT 
            ("v_FROMDATE_NEW"::DATE + (ROW_NUMBER() OVER (ORDER BY oid))::INTEGER) AS "AllDays"
        FROM 
            pg_class
        LIMIT "v_TOTALCount"
    )
    SELECT 
        "AllDays"::DATE
    FROM 
        d 
    WHERE 
        "AllDays" NOT IN (
            SELECT 
                A."FOMHWDD_FromDate"  
            FROM 
                "FO"."FO_Master_HolidayWorkingDay_Dates" A 
                INNER JOIN "FO"."FO_HolidayWorkingDay_Type" B ON A."FOHWDT_Id" = B."FOHWDT_Id" 
            WHERE 
                A."MI_Id" = "p_MI_Id" 
                AND B."FOHWDT_ActiveFlg" = 1 
                AND B."FOHTWD_HolidayFlag" = 1
        );

END;
$$;