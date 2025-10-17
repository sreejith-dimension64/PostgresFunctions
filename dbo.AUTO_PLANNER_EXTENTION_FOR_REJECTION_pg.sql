CREATE OR REPLACE FUNCTION "dbo"."AUTO_PLANNER_EXTENTION_FOR_REJECTION"(
    p_HRME_ID bigint,
    p_ISMTPL_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_WRCount bigint;
    v_FOMHWDD_FromDate date;
    v_Rcount bigint;
    v_finaldate timestamp;
    v_Days bigint;
    v_remarks text;
    v_userid bigint;
    v_Rcount2 bigint;
    v_startdate date;
    v_enddate date;
    cur_record RECORD;
BEGIN
    v_Days := 1;

    DROP TABLE IF EXISTS "OfficeWorkingDays_Temp_Planner";

    CREATE TEMP TABLE "OfficeWorkingDays_Temp_Planner"(
        "WorkingDate" date,
        "WDay" bigint
    );

    FOR cur_record IN
        SELECT DISTINCT "FMHD"."FOMHWDD_FromDate"
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD"
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" "FHWT" ON "FMHD"."FOHWDT_Id" = "FHWT"."FOHWDT_Id"
        WHERE "FMHD"."FOMHWDD_FromDate"::date > CURRENT_DATE
    LOOP
        v_FOMHWDD_FromDate := cur_record."FOMHWDD_FromDate";
        
        v_Rcount := 0;

        SELECT COUNT(*)
        INTO v_Rcount
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD"
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" "FHWT" ON "FMHD"."FOHWDT_Id" = "FHWT"."FOHWDT_Id"
        WHERE "FMHD"."FOMHWDD_FromDate"::date = v_FOMHWDD_FromDate AND "FOHTWD_HolidayFlag" = 1;

        IF v_Rcount = 0 THEN
            v_WRCount := 0;
            
            SELECT COUNT(*) 
            INTO v_WRCount
            FROM "OfficeWorkingDays_Temp_Planner";

            INSERT INTO "OfficeWorkingDays_Temp_Planner" ("WorkingDate", "WDay")
            VALUES (v_FOMHWDD_FromDate, v_WRCount + 1);
        END IF;
    END LOOP;

    SELECT "WorkingDate" 
    INTO v_finaldate
    FROM "OfficeWorkingDays_Temp_Planner" 
    WHERE "WDay" = v_Days;

    IF v_finaldate > NOW() THEN
        v_Rcount2 := 0;
        
        SELECT COUNT(*) 
        INTO v_Rcount2
        FROM "ISM_Task_Planner" 
        WHERE "ISMTPL_Id" = p_ISMTPL_Id 
            AND "ISMTPL_ApprovalFlg" = 0 
            AND "ISMTPL_ApprovedBy" > 0;

        IF v_Rcount2 > 0 THEN
            SELECT "ISMTPL_StartDate", "ISMTPL_EndDate"
            INTO v_startdate, v_enddate
            FROM "ISM_Task_Planner" 
            WHERE "ISMTPL_Id" = p_ISMTPL_Id 
                AND "ISMTPL_ApprovalFlg" = 0 
                AND "ISMTPL_ApprovedBy" > 0;

            SELECT "ISMTPLAP_Remarks", "ISMTPLAP_CreatedBy"
            INTO v_remarks, v_userid
            FROM "ISM_Task_Planner_Approved" 
            WHERE "ISMTPL_Id" = p_ISMTPL_Id;

            INSERT INTO "ISM_PlannerExtension" 
            VALUES (
                p_HRME_ID,
                v_startdate::date,
                v_finaldate::date,
                'Auto-Extention-For-Reject:' || v_remarks,
                1,
                v_userid,
                v_userid,
                NOW(),
                NOW()
            );
        END IF;
    END IF;

    RETURN;
END;
$$;