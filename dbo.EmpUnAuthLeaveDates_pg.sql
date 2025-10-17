CREATE OR REPLACE FUNCTION "dbo"."EmpUnAuthLeaveDates"(
    p_MI_Id bigint,
    p_HRMLY_Id bigint,
    p_StartDate date,
    p_EndDate date
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
    DROP TABLE IF EXISTS "EmpUnAuthLeaveDates_Temp";
    
    CREATE TEMP TABLE "EmpUnAuthLeaveDates_Temp"(
        "HRME_Id" bigint,
        "DrNotSentDates" date
    );

    FOR v_HRME_Id IN 
        SELECT DISTINCT "HRME_Id" 
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = p_MI_Id 
            AND "HRME_ActiveFlag" = 1 
            AND "HRME_LeftFlag" = 0
    LOOP
        FOR v_FOMHWDD_FromDate IN
            SELECT DISTINCT CAST(A."FOMHWDD_FromDate" AS date) AS "FromDate"
            FROM "fo"."FO_Master_HolidayWorkingDay_Dates" A
            JOIN "fo"."FO_HolidayWorkingDay_Type" B 
                ON A."FOHWDT_Id" = B."FOHWDT_Id" 
                AND A."MI_Id" = B."MI_Id" 
                AND A."FOMHWD_ActiveFlg" = 1 
                AND B."FOHWDT_ActiveFlg" = 1 
                AND B."FOHTWD_HolidayFlag" != 1 
                AND A."HRMLY_Id" = p_HRMLY_Id 
                AND CAST(A."FOMHWDD_FromDate" AS date) >= p_StartDate 
                AND CAST(A."FOMHWDD_ToDate" AS date) <= p_EndDate 
                AND CAST(A."FOMHWDD_FromDate" AS date) NOT IN (
                    SELECT CAST("FOEP_PunchDate" AS date) 
                    FROM "FO"."FO_Emp_Punch" 
                    WHERE "MI_Id" = p_MI_Id 
                        AND CAST("FOEP_PunchDate" AS date) >= p_StartDate 
                        AND CAST("FOEP_PunchDate" AS date) <= p_EndDate 
                        AND "HRME_Id" = v_HRME_Id
                ) 
                AND CAST(A."FOMHWDD_FromDate" AS date) NOT IN (
                    SELECT CAST("HRELT_FromDate" AS date) 
                    FROM "HR_Emp_Leave_Trans" 
                    WHERE "MI_Id" = p_MI_Id 
                        AND "HRME_Id" = v_HRME_Id 
                        AND "HRELT_Status" = 'Approved'
                )
        LOOP
            SELECT COUNT(*) INTO v_Rcount
            FROM "EmpUnAuthLeaveDates_Temp" 
            WHERE "HRME_Id" = v_HRME_Id 
                AND "DrNotSentDates" = v_FOMHWDD_FromDate;

            IF (v_Rcount = 0) THEN
                INSERT INTO "EmpUnAuthLeaveDates_Temp" 
                VALUES(v_HRME_Id, v_FOMHWDD_FromDate);
            END IF;
        END LOOP;
    END LOOP;

    RETURN QUERY 
    SELECT "HRME_Id", "DrNotSentDates" 
    FROM "EmpUnAuthLeaveDates_Temp";
END;
$$;