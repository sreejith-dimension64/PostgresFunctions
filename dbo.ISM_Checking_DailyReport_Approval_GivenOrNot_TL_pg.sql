CREATE OR REPLACE FUNCTION "dbo"."ISM_Checking_DailyReport_Approval_GivenOrNot_TL"(
    "MI_Id" TEXT,
    "UserId" TEXT,
    "HRME_Id" TEXT,
    "FROMDATE" VARCHAR(10)
)
RETURNS TABLE(
    "Stauts" TEXT,
    "Date" VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "FROMDate_New" DATE;
    "COUNT" BIGINT;
    "DR_GENERATED_EMP_COUNT" BIGINT;
    "DR_APPROVED_EMP_COUNT" BIGINT;
    "APPROVEDORNOT" TEXT;
BEGIN
    
    /* GETTING LAST WORKING DATE FROM TODAYS DATE   */
    SELECT CAST("FROMDATE" AS DATE) - INTERVAL '1 day' INTO "FROMDate_New";
    
    SELECT COUNT(*) INTO "COUNT"
    FROM "FO"."FO_HolidayWorkingDay_Type" A 
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" B ON A."FOHWDT_Id" = B."FOHWDT_Id"
    WHERE A."MI_Id" = "MI_Id" 
    AND A."FOHTWD_HolidayFlag" = 0 
    AND ("FROMDate_New" BETWEEN B."FOMHWDD_FromDate" AND B."FOMHWDD_ToDate");
    
    WHILE "COUNT" = 0 LOOP
        
        SELECT "FROMDate_New" - INTERVAL '1 day' INTO "FROMDate_New";
        
        SELECT COUNT(*) INTO "COUNT"
        FROM "FO"."FO_HolidayWorkingDay_Type" A 
        INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" B ON A."FOHWDT_Id" = B."FOHWDT_Id"
        WHERE A."MI_Id" = "MI_Id" 
        AND A."FOHTWD_HolidayFlag" = 0 
        AND ("FROMDate_New" BETWEEN B."FOMHWDD_FromDate" AND B."FOMHWDD_ToDate");
        
    END LOOP;
    
    /*  CHECKING APPROVAL STATUS  */
    SELECT COUNT(DISTINCT b."HRME_Id") INTO "DR_APPROVED_EMP_COUNT"
    FROM "ISM_DailyReport_Approval" a 
    INNER JOIN "ISM_DailyReport" b ON a."ISMDRPT_Id" = b."ISMDRPT_Id"
    WHERE b."HRME_Id" IN (
        SELECT DISTINCT UEM."HRME_Id" 
        FROM "ISM_User_Employees_Mapping" UEM
        INNER JOIN "HR_Master_Employee" HRE ON UEM."HRME_Id" = HRE."HRME_Id" 
            AND HRE."HRME_ActiveFlag" = 1 
            AND HRE."HRME_LeftFlag" = 0 
            AND HRE."HRME_ActiveFlag" = 1 
        INNER JOIN "HR_Master_Designation" HMD ON HRE."HRMDES_Id" = HMD."HRMDES_Id" 
            AND HMD."HRMDES_ActiveFlag" = 1
        WHERE UEM."User_Id" = "UserId" 
        AND UEM."ISMUSEMM_ActiveFlag" = 1 
        AND UEM."HRME_Id" != "HRME_Id"
    ) 
    AND b."ISMDRPT_Date" = "FROMDate_New";
    
    SELECT COUNT(DISTINCT "HRME_Id") INTO "DR_GENERATED_EMP_COUNT"
    FROM "ISM_DailyReport" 
    WHERE "HRME_Id" IN (
        SELECT DISTINCT UEM."HRME_Id" 
        FROM "ISM_User_Employees_Mapping" UEM
        INNER JOIN "HR_Master_Employee" HRE ON UEM."HRME_Id" = HRE."HRME_Id" 
            AND HRE."HRME_ActiveFlag" = 1 
            AND HRE."HRME_LeftFlag" = 0 
            AND HRE."HRME_ActiveFlag" = 1 
        INNER JOIN "HR_Master_Designation" HMD ON HRE."HRMDES_Id" = HMD."HRMDES_Id" 
            AND HMD."HRMDES_ActiveFlag" = 1
        WHERE UEM."User_Id" = "UserId" 
        AND UEM."ISMUSEMM_ActiveFlag" = 1 
        AND UEM."HRME_Id" != "HRME_Id"
    ) 
    AND "ISMDRPT_Date" = "FROMDate_New";
    
    RAISE NOTICE 'DR_APPROVED_EMP_COUNT: %', "DR_APPROVED_EMP_COUNT";
    RAISE NOTICE 'DR_GENERATED_EMP_COUNT: %', "DR_GENERATED_EMP_COUNT";
    
    IF "DR_APPROVED_EMP_COUNT" = "DR_GENERATED_EMP_COUNT" THEN
        "APPROVEDORNOT" := 'Approved';
    ELSE
        "APPROVEDORNOT" := 'Pending';
    END IF;
    
    RETURN QUERY
    SELECT "APPROVEDORNOT", TO_CHAR("FROMDate_New", 'YYYY-MM-DD');
    
END;
$$;