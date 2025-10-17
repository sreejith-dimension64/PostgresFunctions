CREATE OR REPLACE FUNCTION "dbo"."GetEmployeeDetailsReoprt"(
    "@MI_Id" TEXT,
    "@tableparam" TEXT,
    "@empIds" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "@sqlText" TEXT;
BEGIN
    "@sqlText" := 'SELECT ' || "@tableparam" || ' FROM "dbo"."HR_Master_Employee"
    INNER JOIN "dbo"."HR_Master_Department" ON "dbo"."HR_Master_Employee"."HRMD_Id" = "dbo"."HR_Master_Department"."HRMD_Id"
    INNER JOIN "dbo"."HR_Master_Designation" ON "dbo"."HR_Master_Employee"."HRMDES_Id" = "dbo"."HR_Master_Designation"."HRMDES_Id"
    INNER JOIN "dbo"."HR_Master_EmployeeType" ON "dbo"."HR_Master_Employee"."HRMET_Id" = "dbo"."HR_Master_EmployeeType"."HRMET_Id"
    INNER JOIN "dbo"."HR_Master_Grade" ON "dbo"."HR_Master_Employee"."HRMG_Id" = "dbo"."HR_Master_Grade"."HRMG_Id"
    INNER JOIN "dbo"."HR_Master_GroupType" ON "dbo"."HR_Master_Employee"."HRMGT_Id" = "dbo"."HR_Master_GroupType"."HRMGT_Id"
    INNER JOIN "dbo"."IVRM_Master_Gender" ON "dbo"."HR_Master_Employee"."IVRMMG_Id" = "dbo"."IVRM_Master_Gender"."IVRMMG_Id"
    INNER JOIN "dbo"."IVRM_Master_Marital_Status" ON "dbo"."HR_Master_Employee"."IVRMMMS_Id" = "dbo"."IVRM_Master_Marital_Status"."IVRMMMS_Id"
    INNER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."HR_Master_Employee"."ReligionId" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
    INNER JOIN "dbo"."IVRM_Master_Caste" ON "dbo"."HR_Master_Employee"."CasteId" = "dbo"."IVRM_Master_Caste"."IMC_Id"
    LEFT JOIN "dbo"."HR_Master_Employee_Bank" ON "dbo"."HR_Master_Employee"."HRME_Id" = "dbo"."HR_Master_Employee_Bank"."HRME_Id"
    INNER JOIN "dbo"."HR_Master_EarningsDeductions" ON "dbo"."HR_Master_EarningsDeductions"."HRMED_ActiveFlag" = 1
    AND "dbo"."HR_Master_EarningsDeductions"."HRMED_EDTypeFlag" = ''Basic Pay''
    LEFT JOIN "dbo"."HR_Employee_EarningsDeductions" ON "dbo"."HR_Master_Employee"."HRME_Id" = "dbo"."HR_Employee_EarningsDeductions"."HRME_Id" AND "dbo"."HR_Employee_EarningsDeductions"."HRMED_Id" = "dbo"."HR_Master_EarningsDeductions"."HRMED_Id"
    WHERE "dbo"."HR_Master_Employee"."MI_Id" = ' || "@MI_Id" || ' AND "dbo"."HR_Master_EarningsDeductions"."MI_Id" = ' || "@MI_Id" || '
    AND "dbo"."HR_Master_Employee"."HRME_Id" IN (' || "@empIds" || ') AND "dbo"."HR_Master_Employee"."HRME_ActiveFlag" = 1 AND "dbo"."HR_Master_Employee"."HRME_LeftFlag" = 0
    ORDER BY "dbo"."HR_Master_Employee"."HRME_EmployeeOrder"';
    
    RAISE NOTICE '%', "@sqlText";
    
    RETURN QUERY EXECUTE "@sqlText";
    
    RETURN;
END;
$$;