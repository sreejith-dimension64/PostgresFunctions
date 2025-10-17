CREATE OR REPLACE FUNCTION "dbo"."EmpDrReportsNotSentDates"(
    "MI_Id" bigint,
    "HRMLY_Id" bigint,
    "StartDate" date,
    "EndDate" date
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "DrNotSentDates" date
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id bigint;
    v_FOMHWDD_FromDate date;
    v_Rcount int;
BEGIN
    DROP TABLE IF EXISTS "EmpDailyReportNotSentDates_Temp";
    
    CREATE TEMP TABLE "EmpDailyReportNotSentDates_Temp"(
        "HRME_Id" bigint,
        "DrNotSentDates" date
    );

    FOR v_HRME_Id IN 
        SELECT DISTINCT "HRME_Id" 
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = "MI_Id" 
        AND "HRME_ActiveFlag" = 1 
        AND "HRME_LeftFlag" = 0
    LOOP
        FOR v_FOMHWDD_FromDate IN 
            SELECT DISTINCT CAST(A."FOMHWDD_FromDate" AS date) AS "FromDate" 
            FROM "fo"."FO_Master_HolidayWorkingDay_Dates" A
            INNER JOIN "FO"."FO_HolidayWorkingDay_Type" B 
                ON A."FOHWDT_Id" = B."FOHWDT_Id" 
                AND A."MI_Id" = B."MI_Id" 
                AND A."MI_Id" = "MI_Id" 
                AND B."FOHTWD_HolidayFlag" != 1 
                AND A."HRMLY_Id" = "HRMLY_Id" 
                AND CAST(A."FOMHWDD_FromDate" AS date) >= "StartDate" 
                AND CAST(A."FOMHWDD_FromDate" AS date) <= "EndDate" 
                AND CAST(A."FOMHWDD_FromDate" AS date) NOT IN (
                    SELECT CAST("ISMDRPT_Date" AS date) 
                    FROM "ISM_DailyReport" 
                    WHERE "MI_Id" = "MI_Id" 
                    AND "ISMDRPT_ActiveFlg" = 1 
                    AND CAST("ISMDRPT_Date" AS date) >= "StartDate" 
                    AND CAST("ISMDRPT_Date" AS date) <= "EndDate"
                    AND "HRME_Id" = v_HRME_Id
                )
        LOOP
            SELECT COUNT(*) INTO v_Rcount
            FROM "EmpDailyReportNotSentDates_Temp" 
            WHERE "HRME_Id" = v_HRME_Id 
            AND "DrNotSentDates" = v_FOMHWDD_FromDate;

            IF (v_Rcount = 0) THEN
                INSERT INTO "EmpDailyReportNotSentDates_Temp" 
                VALUES(v_HRME_Id, v_FOMHWDD_FromDate);
            END IF;
        END LOOP;
    END LOOP;

    RETURN QUERY SELECT * FROM "EmpDailyReportNotSentDates_Temp";
END;
$$;