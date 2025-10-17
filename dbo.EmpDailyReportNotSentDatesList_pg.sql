CREATE OR REPLACE FUNCTION "dbo"."EmpDailyReportNotSentDatesList"(
    p_MI_Id bigint,
    p_HRME_Id bigint,
    p_DrDate varchar(10)
)
RETURNS TABLE(
    "FromDate" date,
    "Remarks" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_StartDate date;
BEGIN
    DROP TABLE IF EXISTS "EmpDrReportsNotSentDates_Temp";

    SELECT CAST("ISMTPL_StartDate" AS date) INTO v_StartDate 
    FROM "ISM_Task_Planner" 
    WHERE "HRME_Id" = p_HRME_Id 
    AND CAST(p_DrDate AS date) BETWEEN CAST("ISMTPL_StartDate" AS date) 
    AND CAST("ISMTPL_EndDate" AS date);

    CREATE TEMP TABLE "EmpDrReportsNotSentDates_Temp" AS
    SELECT "New"."FOMHWDD_FromDate" AS "FromDate", '' AS "Remarks"
    FROM (
        SELECT DISTINCT CAST("FOMHWDD_FromDate" AS date) AS "FOMHWDD_FromDate"
        FROM "FO"."FO_HolidayWorkingDay_Type" "FHWDT"
        INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FHWD" 
            ON "FHWDT"."FOHWDT_Id" = "FHWD"."FOHWDT_Id"
        WHERE "FHWDT"."MI_Id" = p_MI_Id 
        AND "FHWDT"."FOHTWD_HolidayFlag" = 0 
        AND "FHWD"."FOMHWD_ActiveFlg" = 1 
        AND "FHWD"."MI_Id" = p_MI_Id 
        AND "FHWD"."FOMHWD_ActiveFlg" = 1 
        AND (CAST("FOMHWDD_FromDate" AS date) BETWEEN v_StartDate AND (CAST(p_DrDate AS date) - INTERVAL '1 day'))

        EXCEPT

        SELECT DISTINCT CAST("ISMDRPT_Date" AS date) AS "FOMHWDD_FromDate" 
        FROM "ISM_DailyReport" 
        WHERE "HRME_Id" = p_HRME_Id 
        AND (CAST("ISMDRPT_Date" AS date) BETWEEN v_StartDate AND (CAST(p_DrDate AS date) - INTERVAL '1 day'))
    ) AS "New";

    RETURN QUERY
    SELECT t."FromDate", t."Remarks" 
    FROM "EmpDrReportsNotSentDates_Temp" t;

    DROP TABLE IF EXISTS "EmpDrReportsNotSentDates_Temp";
END;
$$;