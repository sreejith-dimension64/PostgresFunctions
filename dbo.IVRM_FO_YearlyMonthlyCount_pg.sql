CREATE OR REPLACE FUNCTION "dbo"."IVRM_FO_YearlyMonthlyCount"(
    "MI_Id" bigint,
    "Type" varchar(200),
    "Flag" varchar(200)
)
RETURNS TABLE(
    "CYear" bigint,
    "HRME_Id" bigint,
    "IVRM_Month_Name" varchar,
    "EMPCount" bigint,
    "WorkingDaysCount" bigint,
    "PresentCount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "From_Date" date;
    "To_Date" date;
    "ASMAY_Id" bigint;
    "HRMLY_Id" bigint;
BEGIN

    SELECT 
        "ASMAY_From_Date"::date,
        "ASMAY_To_Date"::date,
        "ASMAY_Id"
    INTO 
        "From_Date",
        "To_Date",
        "ASMAY_Id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "IVRM_FO_YearlyMonthlyCount"."MI_Id" 
        AND CURRENT_DATE BETWEEN "ASMAY_From_Date"::date AND "ASMAY_To_Date"::date;

    SELECT "HRMLY_Id" 
    INTO "HRMLY_Id"
    FROM "HR_Master_LeaveYear" 
    WHERE "MI_Id" = "IVRM_FO_YearlyMonthlyCount"."MI_Id" 
        AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_DATE);

    IF ("Type" = 'Monthly') THEN
        IF ("Flag" = 'Staff') THEN
            RETURN QUERY
            WITH "StaffFOWorkingDays" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "FOMHWDD_FromDate") AS bigint) AS "CYear",
                    "IVRM_Month_Id",
                    "IVRM_Month_Name",
                    COUNT(DISTINCT "FOMHWDD_FromDate"::date) AS "WorkingDaysCount"
                FROM "FO"."FO_HolidayWorkingDay_Type" "WT"
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "DD" 
                    ON "WT"."FOHWDT_Id" = "DD"."FOHWDT_Id" 
                    AND "HRMLY_Id" = "IVRM_FO_YearlyMonthlyCount"."HRMLY_Id"
                INNER JOIN "ivrm_month" "IM" 
                    ON "IM"."IVRM_Month_Name" = TO_CHAR("FOMHWDD_FromDate", 'Month')
                WHERE "WT"."MI_Id" = "IVRM_FO_YearlyMonthlyCount"."MI_Id" 
                    AND "FOHWDT_ActiveFlg" = 1 
                    AND "DD"."MI_Id" = "IVRM_FO_YearlyMonthlyCount"."MI_Id" 
                    AND "FOMHWD_ActiveFlg" = 1 
                GROUP BY CAST(EXTRACT(YEAR FROM "FOMHWDD_FromDate") AS bigint), 
                         "IVRM_Month_Id", 
                         "IVRM_Month_Name"
            ),
            "StaffCount" AS (
                SELECT 
                    "IVRM_Month_Id",
                    "IVRM_Month_Name",
                    COUNT(*) AS "EMPCount"
                FROM "HR_Master_Employee" "HM"
                INNER JOIN "IVRM_Month" "IM" 
                    ON "IM"."IVRM_Month_Name" = TO_CHAR("HM"."HRME_DOJ", 'Month')
                WHERE "MI_Id" = "IVRM_FO_YearlyMonthlyCount"."MI_Id" 
                    AND "HRME_ActiveFlag" = 1 
                    AND "HRME_LeftFlag" = 0  
                GROUP BY "IVRM_Month_Name", "IVRM_Month_Id"
            ),
            "StaffWorkingDays" AS (
                SELECT 
                    "EP"."HRME_Id",
                    "IVRM_Month_Id",
                    "IVRM_Month_Name",
                    COUNT(DISTINCT "EP"."FOEP_PunchDate"::date) AS "PresentCount"
                FROM "FO"."FO_Emp_Punch" "EP"
                INNER JOIN "IVRM_Month" "IM" 
                    ON "IM"."IVRM_Month_Name" = TO_CHAR("EP"."FOEP_PunchDate", 'Month')
                WHERE "EP"."MI_Id" = "IVRM_FO_YearlyMonthlyCount"."MI_Id" 
                    AND "EP"."FOEP_PunchDate"::date BETWEEN "IVRM_FO_YearlyMonthlyCount"."From_Date" 
                        AND "IVRM_FO_YearlyMonthlyCount"."To_Date"
                GROUP BY "EP"."HRME_Id", "IVRM_Month_Id", "IVRM_Month_Name"
            )
            SELECT 
                "D"."CYear",
                "E"."HRME_Id",
                "A"."IVRM_Month_Name",
                "EMPCount",
                "D"."WorkingDaysCount",
                "PresentCount"
            FROM "StaffCount" "A"
            INNER JOIN "StaffFOWorkingDays" "D" 
                ON "A"."IVRM_Month_Id" = "D"."IVRM_Month_Id"
            INNER JOIN "StaffWorkingDays" "E" 
                ON "A"."IVRM_Month_Id" = "E"."IVRM_Month_Id"
            ORDER BY "A"."IVRM_Month_Id"
            LIMIT 100;
        END IF;
    END IF;

END;
$$;