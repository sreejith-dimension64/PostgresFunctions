CREATE OR REPLACE FUNCTION "dbo"."HR_EmployeeSalaryDetails"(
    "year" TEXT,
    "month" TEXT,
    "MI_ID" TEXT,
    "HRME_Id" BIGINT,
    "HRES_Id" BIGINT,
    "fromdate" TIMESTAMP,
    "todate" TIMESTAMP
)
RETURNS TABLE(
    "hreS_Id" BIGINT,
    "hreS_WorkingDays" INTEGER,
    "hreS_FromDate" TIMESTAMP,
    "hreS_ToDate" TIMESTAMP,
    "hrmE_Id" BIGINT,
    "hrmE_DOJ" TIMESTAMP,
    "hrmE_EmployeeFirstName" TEXT,
    "hrmE_EmployeeCode" TEXT,
    "hrmE_EmployeeOrder" INTEGER,
    "hrmdeS_DesignationName" TEXT,
    "hrmG_GradeName" TEXT,
    "hrmG_Order" INTEGER,
    "hrmD_Id" BIGINT,
    "hrmE_FPFNotApplicableFlg" BOOLEAN,
    "hreS_AccountNo" BIGINT,
    "hrmE_PFAccNo" TEXT,
    "hrmeB_AccountNo" TEXT,
    "hrmbD_BranchName" TEXT,
    "hrmbD_IFSCCode" TEXT,
    "Age" NUMERIC,
    "HRES_WorkingDays" INTEGER,
    "HRELT_TotDays" NUMERIC(18,2),
    "LOPAmount" NUMERIC(18,2),
    "Previousmonthlop" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "count" BIGINT;
    "SUMAMOUNT" DECIMAL(18,2);
    "PENSIONAMOUNT" DECIMAL(18,2);
    "HRME_ID_CUR1" BIGINT;
    "HRES_ID_CUR1" BIGINT;
    "BASICPAY" DECIMAL(18,2);
    "DA" DECIMAL(18,2);
    "PERSONALPAY" DECIMAL(18,2);
    "CLAMT" DECIMAL(18,2);
    "AGE" NUMERIC;
    "HRES_WorkingDays" INTEGER;
    "HRME_FPFNotApplicableFlg" BOOLEAN;
    "RETIREDATE" DATE;
    "MONTHID" BIGINT;
    "flag" BOOLEAN;
    "WorkingDay" BIGINT;
    "REFDATE" DATE;
    "WorkedDays" BIGINT;
    "PFAMOUNT" DECIMAL(18,2);
    "SCHOOLPF" DECIMAL(18,2);
    "PFSAL" DECIMAL(18,2);
    "EDLISAL" DECIMAL(18,2);
    "PENSIONSAL" DECIMAL(18,2);
    "HRELT_TotDays" DECIMAL(18,2);
    "Previousmonthlop" DECIMAL(18,2);
    "Previousemonthfromdate" TIMESTAMP;
    "Previousemonthenddate" TIMESTAMP;
BEGIN

    SELECT COUNT(*) INTO "count" FROM "HR_Master_Employee_Bank" WHERE "HRME_Id" = "HR_EmployeeSalaryDetails"."HRME_Id";

    DROP TABLE IF EXISTS "AgeWorkingday";
    
    CREATE TEMP TABLE "AgeWorkingday" ("Age" BIGINT, "HRES_WorkingDays" BIGINT, "HRME_Id" BIGINT);

    SELECT "HRES_WorkingDays" INTO "WorkedDays" 
    FROM "HR_Employee_Salary" 
    WHERE "HRME_Id" = "HR_EmployeeSalaryDetails"."HRME_Id" 
        AND "HRES_Year" = "HR_EmployeeSalaryDetails"."year" 
        AND "HRES_Month" = "HR_EmployeeSalaryDetails"."month";

    SELECT "IVRM_Month_Id" INTO "MONTHID" 
    FROM "IVRM_Month" 
    WHERE "IVRM_Month_Name" = "HR_EmployeeSalaryDetails"."month";

    SELECT ("HRME_DOB" + INTERVAL '58 years' - INTERVAL '1 day')::DATE INTO "RETIREDATE"
    FROM "HR_Master_Employee" 
    WHERE "HRME_ID" = "HR_EmployeeSalaryDetails"."HRME_Id" 
        AND "HRME_ActiveFlag" = TRUE;

    IF (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE = "RETIREDATE" THEN
        
        RAISE NOTICE '1 condition';
        
        "REFDATE" := "RETIREDATE";
        "HRES_WorkingDays" := EXTRACT(DAY FROM "RETIREDATE")::INTEGER;
        
        IF "HRES_WorkingDays" > 30 THEN
            "HRES_WorkingDays" := 30;
        END IF;

    ELSIF "RETIREDATE" < (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE THEN
        
        "Flag" := FALSE;
        
        IF EXTRACT(MONTH FROM "RETIREDATE")::INTEGER = "MONTHID" AND EXTRACT(YEAR FROM "RETIREDATE")::INTEGER = "year"::INTEGER THEN
            "HRES_WorkingDays" := EXTRACT(DAY FROM "RETIREDATE")::INTEGER;
            "Flag" := FALSE;
        ELSE
            "HRES_WorkingDays" := 0;
            "Flag" := TRUE;
        END IF;

        IF "HRES_WorkingDays" <= 30 THEN
            IF "Flag" = FALSE THEN
                "HRES_WorkingDays" := EXTRACT(DAY FROM "RETIREDATE")::INTEGER;
                SELECT ("HRME_DOB" + INTERVAL '58 years')::DATE INTO "REFDATE"
                FROM "HR_Master_Employee" 
                WHERE "HRME_ID" = "HR_EmployeeSalaryDetails"."HRME_Id" 
                    AND "HRME_ActiveFlag" = TRUE;
            ELSE
                "HRES_WorkingDays" := 0;
                SELECT (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE INTO "REFDATE";
            END IF;
        ELSIF "HRES_WorkingDays" > 30 THEN
            "HRES_WorkingDays" := 30;
            SELECT (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE INTO "REFDATE";
        ELSE
            "HRES_WorkingDays" := 0;
            SELECT (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE INTO "REFDATE";
        END IF;

        RAISE NOTICE '2 condition';

    ELSIF "RETIREDATE" > (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE THEN
        
        RAISE NOTICE '3 condition';
        
        "HRES_WorkingDays" := "WorkedDays";
        
        IF "HRES_WorkingDays" > 30 THEN
            "HRES_WorkingDays" := 30;
        END IF;

        SELECT (DATE_TRUNC('month', (("year"::INTEGER || '-' || "MONTHID" || '-01')::DATE)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE INTO "REFDATE";

    END IF;

    RAISE NOTICE '%', "REFDATE";

    SELECT 
        1.0 * EXTRACT(YEAR FROM AGE("REFDATE", "HRME_DOB"))
        + CASE 
            WHEN "REFDATE" >= MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER, EXTRACT(MONTH FROM "HRME_DOB")::INTEGER, EXTRACT(DAY FROM "HRME_DOB")::INTEGER) THEN 
                (1.0 * ("REFDATE" - MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER, EXTRACT(MONTH FROM "HRME_DOB")::INTEGER, EXTRACT(DAY FROM "HRME_DOB")::INTEGER))
                / (MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER + 1, 1, 1) - MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER, 1, 1)))
            ELSE  
                -1 * (-1.0 * ("REFDATE" - MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER, EXTRACT(MONTH FROM "HRME_DOB")::INTEGER, EXTRACT(DAY FROM "HRME_DOB")::INTEGER))
                / (MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER + 1, 1, 1) - MAKE_DATE(EXTRACT(YEAR FROM "REFDATE")::INTEGER, 1, 1)))
        END,
        "HRME_FPFNotApplicableFlg"
    INTO "AGE", "HRME_FPFNotApplicableFlg"
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = "HR_EmployeeSalaryDetails"."HRME_Id";

    "HRELT_TotDays" := 0;
    
    SELECT COALESCE(SUM("HRELT_TotDays"), 0) INTO "HRELT_TotDays"
    FROM "HR_Emp_Leave_Trans" a
    INNER JOIN "HR_Emp_Leave_Trans_Details" b ON a."HRELT_Id" = b."HRELT_Id"
    INNER JOIN "HR_Master_Leave" c ON b."HRML_Id" = c."HRML_Id"
    WHERE a."HRELT_FromDate" >= "HR_EmployeeSalaryDetails"."fromdate" 
        AND a."HRELT_ToDate" <= "HR_EmployeeSalaryDetails"."todate" 
        AND b."HRELTD_LWPFlag" = TRUE 
        AND "HRELT_ActiveFlag" = TRUE
        AND a."HRME_Id" = "HR_EmployeeSalaryDetails"."HRME_Id";

    "Previousemonthfromdate" := DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '1 month');
    "Previousemonthenddate" := (DATE_TRUNC('month', CURRENT_TIMESTAMP) - INTERVAL '1 second')::DATE;

    "Previousmonthlop" := 0;

    SELECT COALESCE(SUM("HRELT_TotDays"), 0) INTO "Previousmonthlop"
    FROM "HR_Emp_Leave_Trans" a
    INNER JOIN "HR_Emp_Leave_Trans_Details" b ON a."HRELT_Id" = b."HRELT_Id"
    INNER JOIN "HR_Master_Leave" c ON b."HRML_Id" = c."HRML_Id"
    WHERE a."HRELT_FromDate" >= "Previousemonthfromdate" 
        AND a."HRELT_ToDate" <= "Previousemonthenddate" 
        AND b."HRELTD_LWPFlag" = TRUE
        AND a."HRME_Id" = "HR_EmployeeSalaryDetails"."HRME_Id";

    IF "count" > 0 THEN
        RETURN QUERY
        SELECT 
            a."HRES_Id" AS "hreS_Id",
            a."HRES_WorkingDays" AS "hreS_WorkingDays",
            a."HRES_FromDate" AS "hreS_FromDate",
            a."HRES_ToDate" AS "hreS_ToDate",
            b."HRME_Id" AS "hrmE_Id",
            b."HRME_DOJ" AS "hrmE_DOJ",
            CONCAT(COALESCE(b."HRME_EmployeeFirstName", ''), ' ', COALESCE(b."HRME_EmployeeMiddleName", ''), ' ', COALESCE(b."HRME_EmployeeLastName", '')) AS "hrmE_EmployeeFirstName",
            b."HRME_EmployeeCode" AS "hrmE_EmployeeCode",
            COALESCE(b."HRME_EmployeeOrder", 0) AS "hrmE_EmployeeOrder",
            c."HRMDES_DesignationName" AS "hrmdeS_DesignationName",
            d."HRMG_GradeName" AS "hrmG_GradeName",
            d."HRMG_Order" AS "hrmG_Order",
            b."HRMD_Id" AS "hrmD_Id",
            COALESCE(b."HRME_FPFNotApplicableFlg", FALSE) AS "hrmE_FPFNotApplicableFlg",
            COALESCE(a."HRES_AccountNo", 0) AS "hreS_AccountNo",
            b."HRME_PFAccNo" AS "hrmE_PFAccNo",
            e."HRMEB_AccountNo" AS "hrmeB_AccountNo",
            f."HRMBD_BranchName" AS "hrmbD_BranchName",
            f."HRMBD_IFSCCode" AS "hrmbD_IFSCCode",
            "AGE" AS "Age",
            "HRES_WorkingDays" AS "HRES_WorkingDays",
            "HRELT_TotDays" AS "HRELT_TotDays",
            (a."HRES_DailyRates" * "HRELT_TotDays") AS "LOPAmount",
            COALESCE("Previousmonthlop", 0) AS "Previousmonthlop"
        FROM "HR_Employee_Salary" a
        INNER JOIN "hr_Master_Employee" b ON a."hrme_id" = b."hrme_id"
        INNER JOIN "HR_Master_Designation" c ON c."HRMDES_Id" = a."HRMDES_Id"
        INNER JOIN "HR_Master_Grade" d ON d."HRMG_Id" = b."HRMG_Id"
        INNER JOIN "HR_Master_Employee_Bank" e ON e."HRME_Id" = b."HRME_Id"
        INNER JOIN "HR_Master_BankDeatils" f ON f."HRMBD_Id" = e."HRMBD_Id"
        WHERE a."HRES_Id" = "HR_EmployeeSalaryDetails"."HRES_Id";
    ELSE
        RETURN QUERY
        SELECT 
            a."HRES_Id" AS "hreS_Id",
            a."HRES_WorkingDays" AS "hreS_WorkingDays",
            a."HRES_FromDate" AS "hreS_FromDate",
            a."HRES_ToDate" AS "hreS_ToDate",
            b."HRME_Id" AS "hrmE_Id",
            b."HRME_DOJ" AS "hrmE_DOJ",
            CONCAT(COALESCE(b."HRME_EmployeeFirstName", ''), ' ', COALESCE(b."HRME_EmployeeMiddleName", ''), ' ', COALESCE(b."HRME_EmployeeLastName", '')) AS "hrmE_EmployeeFirstName",
            b."HRME_EmployeeCode" AS "hrmE_EmployeeCode",
            COALESCE(b."HRME_EmployeeOrder", 0) AS "hrmE_EmployeeOrder",
            c."HRMDES_DesignationName" AS "hrmdeS_DesignationName",
            d."HRMG_GradeName" AS "hrmG_GradeName",
            d."HRMG_Order" AS "hrmG_Order",
            b."HRMD_Id" AS "hrmD_Id",
            COALESCE(b."HRME_FPFNotApplicableFlg", FALSE) AS "hrmE_FPFNotApplicableFlg",
            COALESCE(a."HRES_AccountNo", 0) AS "hreS_AccountNo",
            b."HRME_PFAccNo" AS "hrmE_PFAccNo",
            NULL::TEXT AS "hrmeB_AccountNo",
            NULL::TEXT AS "hrmbD_BranchName",
            NULL::TEXT AS "hrmbD_IFSCCode",
            "AGE" AS "Age",
            "HRES_WorkingDays" AS "HRES_WorkingDays",
            "HRELT_TotDays" AS "HRELT_TotDays",
            (a."HRES_DailyRates" * "HRELT_TotDays") AS "LOPAmount",
            COALESCE("Previousmonthlop", 0) AS "Previousmonthlop"
        FROM "HR_Employee_Salary" a
        INNER JOIN "hr_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "HR_Master_Designation" c ON c."HRMDES_Id" = a."HRMDES_Id"
        INNER JOIN "HR_Master_Grade" d ON d."HRMG_Id" = b."HRMG_Id"
        WHERE a."HRES_Id" = "HR_EmployeeSalaryDetails"."HRES_Id";
    END IF;

    RETURN;
END;
$$;