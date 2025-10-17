CREATE OR REPLACE FUNCTION "dbo"."ISM_GET_Previous_Date_DR_Approval"(
    "p_MI_Id" BIGINT,
    OUT "p_FROMDATE" DATE
)
RETURNS DATE
LANGUAGE plpgsql
AS $$
DECLARE
    "v_FROMDate_New" DATE;
    "v_COUNT" BIGINT;
BEGIN

    SELECT CURRENT_DATE - INTERVAL '1 day' INTO "v_FROMDate_New";

    SELECT COUNT(*) INTO "v_COUNT"
    FROM "FO"."FO_HolidayWorkingDay_Type" "A"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "B" ON "A"."FOHWDT_Id" = "B"."FOHWDT_Id"
    WHERE "A"."MI_Id" = "p_MI_Id" 
    AND "A"."FOHTWD_HolidayFlag" = 0 
    AND "v_FROMDate_New" BETWEEN "B"."FOMHWDD_FromDate" AND "B"."FOMHWDD_ToDate";

    WHILE "v_COUNT" = 0 LOOP

        SELECT "v_FROMDate_New" - INTERVAL '1 day' INTO "v_FROMDate_New";

        SELECT COUNT(*) INTO "v_COUNT"
        FROM "FO"."FO_HolidayWorkingDay_Type" "A"
        INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "B" ON "A"."FOHWDT_Id" = "B"."FOHWDT_Id"
        WHERE "A"."MI_Id" = "p_MI_Id" 
        AND "A"."FOHTWD_HolidayFlag" = 0 
        AND "v_FROMDate_New" BETWEEN "B"."FOMHWDD_FromDate" AND "B"."FOMHWDD_ToDate";

    END LOOP;

    "p_FROMDATE" := "v_FROMDate_New";

END;
$$;