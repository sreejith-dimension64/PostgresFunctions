CREATE OR REPLACE FUNCTION "dbo"."Academic_Calaender_NaccReport"(
    "p_ASMAY_Id" TEXT,
    "p_MI_Id" TEXT
)
RETURNS TABLE(
    "yearname" TEXT,
    "monthid" TEXT,
    "monthyearname" TEXT,
    "daynames" TEXT,
    "datesnames" TEXT,
    "dayaname" TEXT,
    "eventname" TEXT,
    "flag" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_FROMDATE" TIMESTAMP;
    "v_TODATE" TIMESTAMP;
    "v_DATE" TIMESTAMP;
    "v_MONTH" TEXT;
    "v_MONTHNAME" TEXT;
    "v_YEAR" TEXT;
    "v_DAY" TEXT;
    "v_DAYNAME" TEXT;
    "v_EVENTNAME" TEXT;
    "v_FLAG" TEXT;
    "rec" RECORD;
BEGIN

    SELECT "ASMAY_From_Date", "ASMAY_To_Date" 
    INTO "v_FROMDATE", "v_TODATE"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_MI_Id" AND "ASMAY_Id" = "p_ASMAY_Id";

    DROP TABLE IF EXISTS "calendereventsdetails";

    CREATE TEMP TABLE "calendereventsdetails"(
        "yearname" TEXT,
        "monthid" TEXT,
        "monthyearname" TEXT,
        "daynames" TEXT,
        "datesnames" TEXT,
        "dayaname" TEXT,
        "eventname" TEXT,
        "flag" TEXT
    );

    FOR "rec" IN 
        SELECT DISTINCT 
            EXTRACT(YEAR FROM "a"."FOMHWDD_FromDate")::TEXT AS "year_val",
            EXTRACT(MONTH FROM "a"."FOMHWDD_FromDate")::TEXT AS "month_val",
            TO_CHAR("a"."FOMHWDD_FromDate", 'Month') AS "monthname_val",
            EXTRACT(DAY FROM "a"."FOMHWDD_FromDate")::TEXT AS "day_val",
            "a"."FOMHWDD_FromDate" AS "date_val",
            "a"."FOMHWDD_Name" AS "dayname_val",
            "b"."FOHTWD_HolidayFlag"::TEXT AS "flag_val"
        FROM "fo"."FO_Master_HolidayWorkingDay_Dates" "a" 
        INNER JOIN "fo"."FO_HolidayWorkingDay_Type" "b" ON "a"."FOHWDT_Id" = "b"."FOHWDT_Id"
        WHERE "a"."mi_id" = "p_MI_Id" 
            AND "a"."FOMHWDD_FromDate" BETWEEN "v_FROMDATE" AND "v_TODATE"
        ORDER BY 
            EXTRACT(YEAR FROM "a"."FOMHWDD_FromDate"),
            EXTRACT(MONTH FROM "a"."FOMHWDD_FromDate"),
            EXTRACT(DAY FROM "a"."FOMHWDD_FromDate")
    LOOP
        "v_YEAR" := "rec"."year_val";
        "v_MONTH" := "rec"."month_val";
        "v_MONTHNAME" := "rec"."monthname_val";
        "v_DAY" := "rec"."day_val";
        "v_DATE" := "rec"."date_val";
        "v_DAYNAME" := "rec"."dayname_val";
        "v_FLAG" := "rec"."flag_val";

        RAISE NOTICE '%', "v_DATE";

        "v_EVENTNAME" := '';

        SELECT COALESCE("B"."COEME_EventName", '') 
        INTO "v_EVENTNAME"
        FROM "COE"."COE_Events" "A" 
        INNER JOIN "COE"."COE_Master_Events" "B" ON "A"."COEME_Id" = "B"."COEME_Id"
        WHERE "A"."MI_Id" = "p_MI_Id" 
            AND "A"."ASMAY_Id" = "p_ASMAY_Id"
            AND "v_DATE" BETWEEN "A"."COEE_EStartDate" AND "A"."COEE_EEndDate"
        LIMIT 1;

        IF ("v_FLAG" = '1') THEN
            "v_DAYNAME" := "v_DAYNAME" || '*';
        END IF;

        INSERT INTO "calendereventsdetails" 
        VALUES(
            "v_YEAR",
            "v_MONTH",
            "v_MONTHNAME",
            "v_DAY",
            TO_CHAR("v_DATE", 'DD/MM/YYYY'),
            "v_DAYNAME",
            "v_EVENTNAME",
            "v_FLAG"
        );

    END LOOP;

    RETURN QUERY SELECT * FROM "calendereventsdetails";

    DROP TABLE IF EXISTS "calendereventsdetails";

END;
$$;