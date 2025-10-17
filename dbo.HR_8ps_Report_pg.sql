CREATE OR REPLACE FUNCTION "dbo"."HR_8ps_Report"(
    "p_YEAR" BIGINT,
    "p_Flag" VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_monthname" VARCHAR(50);
    "v_hrmeage" INT;
    "v_HRME_FPFNotApplicableFlg" BOOLEAN;
    "v_HRME_Id" BIGINT;
    "v_HRME_EmployeeFirstName" TEXT;
    "v_HRME_PFAccNo" VARCHAR(255);
    "v_HRESD_Amount" DECIMAL(18,2);
    "v_SumofAmount" DECIMAL(18,2);
    "v_sumcondition" DECIMAL(18,2);
    "v_pensionamout" DECIMAL(18,2);
    "v_Totalpensionamout" DECIMAL(18,2);
    "v_totalsumcondition" DECIMAL(18,2);
    "v_HRES_Month" VARCHAR(500);
    "rec" RECORD;
BEGIN

    IF("p_Flag" = 'MonthWise') THEN
    BEGIN
        DROP TABLE IF EXISTS "FinalmonthTable";
        
        CREATE TEMP TABLE "FinalmonthTable" (
            "pensionamout" DECIMAL(18,2),
            "Monthname" VARCHAR(255)
        );

        FOR "rec" IN 
            SELECT DISTINCT a."HRME_Id", "HRES_Month" 
            FROM "HR_Master_Employee" a
            INNER JOIN "HR_Employee_Salary" b ON a."HRME_Id" = b."HRME_Id" 
            WHERE "HRME_ActiveFlag" = 1 
            AND "HRES_Year" = "p_YEAR" 
            AND "HRES_Month" IN (SELECT "monthname" FROM "Monthrecord")
            ORDER BY a."HRME_Id"
        LOOP
            "v_HRME_Id" := "rec"."HRME_Id";
            "v_HRES_Month" := "rec"."HRES_Month";

            SELECT 
                EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "HRME_DOB"))::INT,
                "HRME_FPFNotApplicableFlg"
            INTO 
                "v_hrmeage",
                "v_HRME_FPFNotApplicableFlg"
            FROM "HR_Master_Employee" 
            WHERE "HRME_ID" = "v_HRME_Id" AND "HRME_ActiveFlag" = 1;

            "v_SumofAmount" := 0;

            SELECT COALESCE(SUM("HRESD_Amount"), 0) 
            INTO "v_SumofAmount"
            FROM "HR_Employee_Salary" a
            INNER JOIN "HR_Employee_Salary_Details" b ON a."HRES_Id" = b."HRES_Id"
            INNER JOIN "HR_Master_EarningsDeductions" c ON b."HRMED_Id" = c."HRMED_Id"
            WHERE a."HRME_Id" = "v_HRME_Id" 
            AND a."HRES_Year" = "p_YEAR" 
            AND "HRMED_EDTypeFlag" IN ('Basic Pay','DA','PP','CL AMT');

            "v_sumcondition" := 0;

            IF ("v_SumofAmount" > 15000) THEN
                "v_sumcondition" := 15000;
            ELSE
                "v_sumcondition" := "v_SumofAmount";
            END IF;

            IF ("v_hrmeage" > 58) THEN
                "v_pensionamout" := 0.00;
            ELSIF ("v_SumofAmount" < 15000 AND "v_HRME_FPFNotApplicableFlg" = TRUE) THEN
                "v_pensionamout" := ROUND((8.33 / 100) * "v_SumofAmount", 2);
            ELSIF ("v_HRME_FPFNotApplicableFlg" = TRUE) THEN
                "v_pensionamout" := 1250.00;
            ELSE
                "v_pensionamout" := 0.00;
            END IF;

            INSERT INTO "FinalmonthTable" VALUES("v_pensionamout", "v_HRES_Month");

        END LOOP;

        PERFORM * FROM (
            SELECT a."Monthname", SUM("pensionamout") AS "pensionamout", b."monthid" 
            FROM "FinalmonthTable" a
            INNER JOIN "Monthrecord" b ON a."Monthname" = b."monthname"
            GROUP BY a."Monthname", b."monthid" 
            ORDER BY "monthid"
        ) result;

        DROP TABLE IF EXISTS "FinalmonthTable";
    END;

    ELSE
    BEGIN
        DROP TABLE IF EXISTS "FinalTable";
        
        CREATE TEMP TABLE "FinalTable" (
            "sumcondition" DECIMAL(18,2),
            "pensionamout" DECIMAL(18,2),
            "Employeename" VARCHAR(255),
            "AccNumber" VARCHAR(255)
        );

        FOR "rec" IN 
            SELECT DISTINCT 
                a."HRME_Id",
                CONCAT(COALESCE(a."HRME_EmployeeFirstName",''), ' ', COALESCE(a."HRME_EmployeeMiddleName",''), ' ', COALESCE(a."HRME_EmployeeLastName",'')) AS "HRME_EmployeeFirstName",
                "HRME_PFAccNo" 
            FROM "HR_Master_Employee" a
            INNER JOIN "HR_Employee_Salary" b ON a."HRME_Id" = b."HRME_Id" 
            WHERE "HRME_ActiveFlag" = 1 AND "HRES_Year" = "p_YEAR"
            ORDER BY a."HRME_Id"
        LOOP
            "v_HRME_Id" := "rec"."HRME_Id";
            "v_HRME_EmployeeFirstName" := "rec"."HRME_EmployeeFirstName";
            "v_HRME_PFAccNo" := "rec"."HRME_PFAccNo";

            SELECT 
                EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "HRME_DOB"))::INT,
                "HRME_FPFNotApplicableFlg"
            INTO 
                "v_hrmeage",
                "v_HRME_FPFNotApplicableFlg"
            FROM "HR_Master_Employee" 
            WHERE "HRME_ID" = "v_HRME_Id" AND "HRME_ActiveFlag" = 1;

            "v_SumofAmount" := 0;

            SELECT COALESCE(SUM("HRESD_Amount"), 0) 
            INTO "v_SumofAmount"
            FROM "HR_Employee_Salary" a
            INNER JOIN "HR_Employee_Salary_Details" b ON a."HRES_Id" = b."HRES_Id"
            INNER JOIN "HR_Master_EarningsDeductions" c ON b."HRMED_Id" = c."HRMED_Id"
            WHERE a."HRME_Id" = "v_HRME_Id" 
            AND a."HRES_Year" = "p_YEAR" 
            AND "HRMED_EDTypeFlag" IN ('Basic Pay','DA','PP','CL AMT');

            "v_sumcondition" := 0;

            IF ("v_SumofAmount" > 180000) THEN
                "v_sumcondition" := 180000;
            ELSE
                "v_sumcondition" := "v_SumofAmount";
            END IF;

            RAISE NOTICE 'SumofAmount: %', "v_SumofAmount";
            RAISE NOTICE 'sumcondition: %', "v_sumcondition";

            IF ("v_hrmeage" > 58) THEN
                "v_pensionamout" := 0.00;
            ELSIF ("v_SumofAmount" < 180000 AND "v_HRME_FPFNotApplicableFlg" = TRUE) THEN
                "v_pensionamout" := ROUND((8.33 / 100) * "v_SumofAmount", 2);
            ELSIF ("v_HRME_FPFNotApplicableFlg" = TRUE) THEN
                "v_pensionamout" := 15000.00;
            ELSE
                "v_pensionamout" := 0.00;
            END IF;

            INSERT INTO "FinalTable" VALUES("v_sumcondition", "v_pensionamout", "v_HRME_EmployeeFirstName", "v_HRME_PFAccNo");

        END LOOP;

        PERFORM * FROM "FinalTable";

        DROP TABLE IF EXISTS "FinalTable";
    END;

    END IF;

END;
$$;