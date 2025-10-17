CREATE OR REPLACE FUNCTION "dbo"."HR_7ps_Report"(
    "p_HRME_ID" VARCHAR,
    "p_YEAR" BIGINT
)
RETURNS TABLE (
    "sumcondition" DECIMAL(18,2),
    "pensionamout" DECIMAL(18,2),
    "monthname" VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_monthname" VARCHAR(50);
    "v_hrmeage" INT;
    "v_HRME_FPFNotApplicableFlg" BOOLEAN;
    "v_HRESD_Amount" DECIMAL(18,2);
    "v_HRME_Id" VARCHAR;
    "v_SumofAmount" DECIMAL(18,2);
    "v_sumcondition" DECIMAL(18,2);
    "v_pensionamout" DECIMAL(18,2);
    "v_query" TEXT;
BEGIN

    CREATE TEMP TABLE IF NOT EXISTS "FinalTable" (
        "sumcondition" DECIMAL(18,2),
        "pensionamout" DECIMAL(18,2),
        "monthname" VARCHAR(255)
    ) ON COMMIT DROP;

    DELETE FROM "FinalTable";

    EXECUTE 'SELECT EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "HRME_DOB")), "HRME_FPFNotApplicableFlg" 
             FROM "HR_Master_Employee" 
             WHERE "HRME_ID" IN (' || "p_HRME_ID" || ') AND "HRME_ActiveFlag" = TRUE LIMIT 1'
    INTO "v_hrmeage", "v_HRME_FPFNotApplicableFlg";

    FOR "v_monthname" IN SELECT "monthname" FROM "Monthrecord"
    LOOP
        
        "v_SumofAmount" := 0;

        IF ("v_monthname" = 'January' OR "v_monthname" = 'February') THEN
            
            "v_query" := 'SELECT DISTINCT "HRESD_Amount", "HRME_Id" 
                         FROM "HR_Employee_Salary" a
                         INNER JOIN "HR_Employee_Salary_Details" b ON a."HRES_Id" = b."HRES_Id"
                         INNER JOIN "HR_Master_EarningsDeductions" c ON b."HRMED_Id" = c."HRMED_Id"
                         WHERE "HRME_Id" IN (' || "p_HRME_ID" || ') 
                         AND a."HRES_Month" = ''' || "v_monthname" || ''' 
                         AND a."HRES_Year" = ' || ("p_YEAR" + 1)::TEXT || ' 
                         AND "HRMED_EDTypeFlag" IN (''Basic Pay'',''DA'',''PP'',''CL AMT'')';
            
            FOR "v_HRESD_Amount", "v_HRME_Id" IN EXECUTE "v_query"
            LOOP
                "v_SumofAmount" := "v_SumofAmount" + "v_HRESD_Amount";
            END LOOP;
            
        ELSE
            
            "v_query" := 'SELECT DISTINCT "HRESD_Amount", "HRME_Id" 
                         FROM "HR_Employee_Salary" a
                         INNER JOIN "HR_Employee_Salary_Details" b ON a."HRES_Id" = b."HRES_Id"
                         INNER JOIN "HR_Master_EarningsDeductions" c ON b."HRMED_Id" = c."HRMED_Id"
                         WHERE "HRME_Id" IN (' || "p_HRME_ID" || ') 
                         AND a."HRES_Month" = ''' || "v_monthname" || ''' 
                         AND a."HRES_Year" = ' || "p_YEAR"::TEXT || ' 
                         AND "HRMED_EDTypeFlag" IN (''Basic Pay'',''DA'',''PP'',''CL AMT'')';
            
            FOR "v_HRESD_Amount", "v_HRME_Id" IN EXECUTE "v_query"
            LOOP
                "v_SumofAmount" := "v_SumofAmount" + "v_HRESD_Amount";
            END LOOP;
            
        END IF;

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

        INSERT INTO "FinalTable" VALUES(ROUND("v_sumcondition", 0), ROUND("v_pensionamout", 0), "v_monthname");

    END LOOP;

    RETURN QUERY SELECT * FROM "FinalTable";

END;
$$;