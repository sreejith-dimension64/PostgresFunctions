CREATE OR REPLACE FUNCTION "FO"."Fo_Creat_Basit_FO_Data"(p_MI_Id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_daycount BIGINT;
    v_monthcount BIGINT;
    v_typecount BIGINT;
BEGIN

    SELECT COUNT(*) INTO v_daycount FROM "FO"."FO_Master_Day" WHERE "MI_Id" = p_MI_Id;
    
    IF (v_daycount = 0) THEN
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'SUN', 'SUN', 1);
        
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'MON', 'MON', 1);
        
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'TUE', 'TUE', 1);
        
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'WED', 'WED', 1);
        
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'THU', 'THU', 1);
        
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'FRI', 'FRI', 1);
        
        INSERT INTO "FO"."FO_Master_Day"("MI_Id", "ASMCL_Id", "FOMD_DayName", "FOMD_DayCode", "FOMD_ActiveFlag") 
        VALUES (p_MI_Id, 1, 'SAT', 'SAT', 1);
    END IF;

    SELECT COUNT(*) INTO v_monthcount FROM "IVRM_Month";
    
    IF (v_monthcount = 0) THEN
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (1, 'January', 1, 31);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (2, 'February', 1, 28);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (3, 'March', 1, 31);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (4, 'April', 1, 30);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (5, 'May', 1, 31);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (6, 'June', 1, 30);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (7, 'July', 1, 31);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (8, 'August', 1, 31);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (9, 'September', 1, 30);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (10, 'October', 1, 31);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (11, 'November', 1, 30);
        INSERT INTO "IVRM_Month" ("IVRM_Month_Id", "IVRM_Month_Name", "Is_Active", "IVRM_Month_Max_Days") VALUES (12, 'December', 1, 31);
    END IF;

    SELECT COUNT(*) INTO v_typecount FROM "FO"."FO_HolidayWorkingDay_Type" WHERE "MI_Id" = p_MI_Id;
    
    IF (v_typecount = 0) THEN
        INSERT INTO "FO"."FO_HolidayWorkingDay_Type"("MI_Id", "FOHTWD_HolidayWDType", "FOHTWD_HolidayWDTypeFlag", "FOHWDT_ActiveFlg", "FOHTWD_HolidayFlag") 
        VALUES (p_MI_Id, 'PUBLIC HOLIDAY', 'PH', 1, 1);
        
        INSERT INTO "FO"."FO_HolidayWorkingDay_Type"("MI_Id", "FOHTWD_HolidayWDType", "FOHTWD_HolidayWDTypeFlag", "FOHWDT_ActiveFlg", "FOHTWD_HolidayFlag") 
        VALUES (p_MI_Id, 'WEEK END', 'WE', 1, 0);
        
        INSERT INTO "FO"."FO_HolidayWorkingDay_Type"("MI_Id", "FOHTWD_HolidayWDType", "FOHTWD_HolidayWDTypeFlag", "FOHWDT_ActiveFlg", "FOHTWD_HolidayFlag") 
        VALUES (p_MI_Id, 'WEEK DAY', 'WD', 1, 0);
        
        INSERT INTO "FO"."FO_HolidayWorkingDay_Type"("MI_Id", "FOHTWD_HolidayWDType", "FOHTWD_HolidayWDTypeFlag", "FOHWDT_ActiveFlg", "FOHTWD_HolidayFlag") 
        VALUES (p_MI_Id, 'VACATION', 'VH', 1, 0);
    END IF;

    RETURN;

END;
$$;