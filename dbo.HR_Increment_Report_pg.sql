CREATE OR REPLACE FUNCTION "dbo"."HR_Increment_Report"(
    "p_MI_Id" TEXT,
    "p_HRME_Id" TEXT,
    "p_FROMDATE" VARCHAR(10),
    "p_TODATE" VARCHAR(10),
    "p_monthid" TEXT,
    "p_yearid" TEXT,
    "p_type" VARCHAR(500),
    "p_option" VARCHAR(500)
)
RETURNS TABLE(
    "HREIC_Id" BIGINT,
    "HRME_Id" BIGINT,
    "EmployeeName" TEXT,
    "HRMED_Name" TEXT,
    "HREIC_IncrementDate" DATE,
    "HREIC_IncrementDueDate" DATE,
    "HREIC_LastIncrementDate" DATE,
    "HREIC_NextIncrementGivenDate" DATE,
    "HREICED_Amount" NUMERIC,
    "HREICED_Percentage" NUMERIC,
    "HREICED_PreviousAmount" NUMERIC,
    "HREED_Amount" NUMERIC,
    "Incrementamount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_DYNAMIC" TEXT;
    "v_lastnumber" INTEGER;
    "v_HREIC_Id" BIGINT;
    "v_HRME_Id1" BIGINT;
    "v_Incrementamount" BIGINT;
    "v_HREICED_PreviousAmount" DECIMAL(18,2);
    "hrmeincrement_rec" RECORD;
BEGIN
    
    DROP TABLE IF EXISTS "Increment_temp";
    
    IF("p_option" = 'DATEWISE') THEN
        
        IF("p_type" = 'Individual') THEN
            
            "v_DYNAMIC" := '
            CREATE TEMP TABLE "Increment_temp" AS
            SELECT A."HREIC_Id", D."HRME_Id", 
                COALESCE(D."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(D."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(D."HRME_EmployeeLastName", '''') AS "EmployeeName",
                E."HRMED_Name", A."HREIC_IncrementDate",
                A."HREIC_IncrementDueDate", A."HREIC_LastIncrementDate", A."HREIC_NextIncrementGivenDate", B."HREICED_Amount",
                B."HREICED_Percentage", B."HREICED_PreviousAmount", C."HREED_Amount", 
                ROUND(((B."HREICED_PreviousAmount" * B."HREICED_Percentage") / 100), 0) AS "Incrementamount"
            FROM "HR_Employee_Increment" A
            INNER JOIN "HR_Employee_Increment_EDHeads" B ON A."HREIC_Id" = B."HREIC_Id" AND A."MI_Id" = B."MI_Id"
            INNER JOIN "HR_Employee_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id" AND A."HRME_Id" = C."HRME_Id" AND A."MI_Id" = C."MI_Id"
            INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id" AND A."MI_Id" = D."MI_Id"
            INNER JOIN "HR_Master_EarningsDeductions" E ON E."HRMED_Id" = B."HRMED_Id" AND B."MI_Id" = E."MI_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND A."HRME_Id" IN (' || "p_HRME_Id" || ') 
                AND (CAST(A."HREIC_IncrementDate" AS DATE) BETWEEN ''' || "p_FROMDATE" || ''' AND ''' || "p_TODATE" || ''')
                AND D."HRME_ActiveFlag" = true AND D."HRME_LeftFlag" = false';
                
        ELSIF("p_type" = 'All') THEN
            
            "v_DYNAMIC" := '
            CREATE TEMP TABLE "Increment_temp" AS
            SELECT A."HREIC_Id", D."HRME_Id", 
                COALESCE(D."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(D."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(D."HRME_EmployeeLastName", '''') AS "EmployeeName",
                E."HRMED_Name", A."HREIC_IncrementDate",
                A."HREIC_IncrementDueDate", A."HREIC_LastIncrementDate", A."HREIC_NextIncrementGivenDate", B."HREICED_Amount",
                B."HREICED_Percentage", B."HREICED_PreviousAmount", C."HREED_Amount", 
                ROUND(((B."HREICED_PreviousAmount" * B."HREICED_Percentage") / 100), 0) AS "Incrementamount"
            FROM "HR_Employee_Increment" A
            INNER JOIN "HR_Employee_Increment_EDHeads" B ON A."HREIC_Id" = B."HREIC_Id" AND A."MI_Id" = B."MI_Id"
            INNER JOIN "HR_Employee_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id" AND A."HRME_Id" = C."HRME_Id" AND A."MI_Id" = C."MI_Id"
            INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id" AND A."MI_Id" = D."MI_Id"
            INNER JOIN "HR_Master_EarningsDeductions" E ON E."HRMED_Id" = B."HRMED_Id" AND B."MI_Id" = E."MI_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' 
                AND (CAST(A."HREIC_IncrementDate" AS DATE) BETWEEN ''' || "p_FROMDATE" || ''' AND ''' || "p_TODATE" || ''')
                AND D."HRME_ActiveFlag" = true AND D."HRME_LeftFlag" = false';
                
        END IF;
        
    ELSIF("p_option" = 'MONTHWISE') THEN
        
        IF("p_type" = 'Individual') THEN
            
            "v_DYNAMIC" := '
            CREATE TEMP TABLE "Increment_temp" AS
            SELECT A."HREIC_Id", D."HRME_Id", 
                COALESCE(D."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(D."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(D."HRME_EmployeeLastName", '''') AS "EmployeeName",
                E."HRMED_Name", A."HREIC_IncrementDate",
                A."HREIC_IncrementDueDate", A."HREIC_LastIncrementDate", A."HREIC_NextIncrementGivenDate", B."HREICED_Amount",
                B."HREICED_Percentage", B."HREICED_PreviousAmount", C."HREED_Amount", 
                ROUND(((B."HREICED_PreviousAmount" * B."HREICED_Percentage") / 100), 0) AS "Incrementamount"
            FROM "HR_Employee_Increment" A
            INNER JOIN "HR_Employee_Increment_EDHeads" B ON A."HREIC_Id" = B."HREIC_Id" AND A."MI_Id" = B."MI_Id"
            INNER JOIN "HR_Employee_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id" AND A."HRME_Id" = C."HRME_Id" AND A."MI_Id" = C."MI_Id"
            INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id" AND A."MI_Id" = D."MI_Id"
            INNER JOIN "HR_Master_EarningsDeductions" E ON E."HRMED_Id" = B."HRMED_Id" AND B."MI_Id" = E."MI_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND A."HRME_Id" IN (' || "p_HRME_Id" || ') 
                AND EXTRACT(MONTH FROM A."HREIC_IncrementDate") IN (' || "p_monthid" || ')
                AND EXTRACT(YEAR FROM A."HREIC_IncrementDate") = ' || "p_yearid" || ' 
                AND D."HRME_ActiveFlag" = true AND D."HRME_LeftFlag" = false';
                
        ELSIF("p_type" = 'All') THEN
            
            "v_DYNAMIC" := '
            CREATE TEMP TABLE "Increment_temp" AS
            SELECT A."HREIC_Id", D."HRME_Id", 
                COALESCE(D."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(D."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(D."HRME_EmployeeLastName", '''') AS "EmployeeName",
                E."HRMED_Name", A."HREIC_IncrementDate",
                A."HREIC_IncrementDueDate", A."HREIC_LastIncrementDate", A."HREIC_NextIncrementGivenDate", B."HREICED_Amount",
                B."HREICED_Percentage", B."HREICED_PreviousAmount", C."HREED_Amount", 
                ROUND(((B."HREICED_PreviousAmount" * B."HREICED_Percentage") / 100), 0) AS "Incrementamount"
            FROM "HR_Employee_Increment" A
            INNER JOIN "HR_Employee_Increment_EDHeads" B ON A."HREIC_Id" = B."HREIC_Id" AND A."MI_Id" = B."MI_Id"
            INNER JOIN "HR_Employee_EarningsDeductions" C ON C."HRMED_Id" = B."HRMED_Id" AND A."HRME_Id" = C."HRME_Id" AND A."MI_Id" = C."MI_Id"
            INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id" AND A."MI_Id" = D."MI_Id"
            INNER JOIN "HR_Master_EarningsDeductions" E ON E."HRMED_Id" = B."HRMED_Id" AND B."MI_Id" = E."MI_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' 
                AND EXTRACT(MONTH FROM A."HREIC_IncrementDate") IN (' || "p_monthid" || ')
                AND EXTRACT(YEAR FROM A."HREIC_IncrementDate") = ' || "p_yearid" || ' 
                AND D."HRME_ActiveFlag" = true AND D."HRME_LeftFlag" = false';
                
        END IF;
        
    END IF;
    
    EXECUTE "v_DYNAMIC";
    
    FOR "hrmeincrement_rec" IN 
        SELECT "HREIC_Id", "HRME_Id", CAST("Incrementamount" AS BIGINT) AS "Incrementamount", "HREICED_PreviousAmount"
        FROM "Increment_temp"
    LOOP
        "v_HREIC_Id" := "hrmeincrement_rec"."HREIC_Id";
        "v_HRME_Id1" := "hrmeincrement_rec"."HRME_Id";
        "v_Incrementamount" := "hrmeincrement_rec"."Incrementamount";
        "v_HREICED_PreviousAmount" := "hrmeincrement_rec"."HREICED_PreviousAmount";
        
        SELECT RIGHT(RTRIM(CAST(ROUND("v_Incrementamount", 0) AS TEXT)), 1)::INTEGER 
        INTO "v_lastnumber"
        FROM "Increment_temp" 
        WHERE "HRME_Id" = "v_HRME_Id1" AND "HREIC_Id" = "v_HREIC_Id"
        LIMIT 1;
        
        IF("v_lastnumber" < 5) THEN
            
            UPDATE "Increment_temp" 
            SET "Incrementamount" = (ROUND("v_Incrementamount", 0) - "v_lastnumber"),
                "HREED_Amount" = ("v_HREICED_PreviousAmount" + (ROUND("v_Incrementamount", 0) - "v_lastnumber"))
            WHERE "HRME_Id" = "v_HRME_Id1" AND "HREIC_Id" = "v_HREIC_Id";
            
        ELSIF("v_lastnumber" >= 5) THEN
            
            UPDATE "Increment_temp" 
            SET "Incrementamount" = (ROUND("v_Incrementamount", 0) - "v_lastnumber") + 10,
                "HREED_Amount" = ("v_HREICED_PreviousAmount" + (ROUND("v_Incrementamount", 0) - "v_lastnumber") + 10)
            WHERE "HRME_Id" = "v_HRME_Id1" AND "HREIC_Id" = "v_HREIC_Id";
            
        END IF;
        
    END LOOP;
    
    RETURN QUERY
    SELECT 
        "HREIC_Id",
        "HRME_Id",
        "EmployeeName",
        "HRMED_Name",
        CAST("HREIC_IncrementDate" AS DATE),
        CAST("HREIC_IncrementDueDate" AS DATE),
        CAST("HREIC_LastIncrementDate" AS DATE),
        CAST("HREIC_NextIncrementGivenDate" AS DATE),
        "HREICED_Amount",
        "HREICED_Percentage",
        "HREICED_PreviousAmount",
        "HREED_Amount",
        CAST("Incrementamount" AS BIGINT)
    FROM "Increment_temp";
    
END;
$$;