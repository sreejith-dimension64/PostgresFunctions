CREATE OR REPLACE FUNCTION "dbo"."DailyIncome_Expenses_Report"(
    "p_MI_Id" bigint,
    "p_DateSelection" timestamp
)
RETURNS TABLE (
    "OPENINGBALCANCE" numeric
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_NEXTDATE" timestamp;
    "v_DateSelection" timestamp;
BEGIN
    "v_DateSelection" := "p_DateSelection" - INTERVAL '1 day';
    
    RAISE NOTICE 'NEXTDATE: %', "v_NEXTDATE";
    
    DROP TABLE IF EXISTS "temp_INCOME";
    DROP TABLE IF EXISTS "temp_EXPENSES";
    
    CREATE TEMP TABLE "temp_INCOME" AS
    SELECT * FROM (
        SELECT DISTINCT 
            a."AMST_Id",
            FYP."FYP_Id",
            (COALESCE(b."AMST_FirstName", '') || ' ' || COALESCE(b."AMST_MiddleName", '') || '' || COALESCE(b."AMST_LastName", '')) || ' / ' ||   
            CASE 
                WHEN FYP."FYP_Bank_Or_Cash" = 'C' THEN 'Cash'   
                WHEN FYP."FYP_Bank_Or_Cash" = 'B' THEN 'Bank'  
                WHEN FYP."FYP_Bank_Or_Cash" = 'O' THEN 'Online'  
                WHEN FYP."FYP_Bank_Or_Cash" = 'R' THEN 'RTGS'  
                WHEN FYP."FYP_Bank_Or_Cash" = 'U' THEN 'UPI' 
            END AS "Payment_Mode",
            0 AS "INVTSL_Amount",
            FYP."FYP_Tot_Amount",
            FYP."MI_Id",
            CAST(FYP."FYP_Date" AS DATE) AS "FYP_Date"
        FROM "Fee_Y_Payment" FYP
        INNER JOIN "Fee_Y_Payment_School_Student" FY ON FYP."FYP_Id" = FY."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" a ON FY."ASMAY_Id" = a."ASMAY_Id" AND FY."AMST_Id" = a."AMST_Id" 
        INNER JOIN "Adm_M_Student" b ON b."MI_Id" = FYP."MI_Id" AND a."AMST_Id" = b."AMST_Id" 
        WHERE FYP."MI_Id" = "p_MI_Id" AND CAST(FYP."FYP_Date" AS DATE) = CAST("v_DateSelection" AS DATE)
        GROUP BY a."AMST_Id", (b."AMST_FirstName" || ' ' || b."AMST_MiddleName" || '' || b."AMST_LastName"), 
                 FYP."FYP_Bank_Or_Cash", FYP."FYP_Tot_Amount", FYP."FYP_Id", FYP."MI_Id", CAST(FYP."FYP_Date" AS DATE)
        
        UNION
        
        SELECT DISTINCT 
            a."AMST_Id",
            0 AS "FYP_Id", 
            COALESCE(a."AMST_FirstName", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."AMST_LastName", '') || '/' ||
            f."INVMI_ItemName" || '/' ||
            CAST(e."INVTSL_SalesQty" AS VARCHAR) AS "Description",
            0 AS "INVTSL_Amount",
            e."INVTSL_Amount" AS "TotalAmount",
            a."MI_Id",
            CAST("INVMSL_SalesDate" AS DATE) AS "FYP_Date"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "INV"."INV_M_Sales_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMCL_Id" = b."ASMCL_Id" AND c."ASMAY_Id" = b."ASMAY_Id" AND c."ASMS_Id" = b."ASMS_Id"
        INNER JOIN "INV"."INV_M_Sales" d ON d."INVMSL_Id" = c."INVMSL_Id"
        INNER JOIN "INV"."INV_T_Sales" e ON e."INVMSL_Id" = c."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Item" f ON f."INVMI_Id" = e."INVMI_Id"
        WHERE a."MI_Id" = "p_MI_Id" AND CAST("INVMSL_SalesDate" AS DATE) = CAST("v_DateSelection" AS DATE)
    ) AS A
    ORDER BY "FYP_Id" DESC;
    
    DROP TABLE IF EXISTS "temp_TOTALINCOME";
    DROP TABLE IF EXISTS "temp_TOTALEXPENSES";
    
    CREATE TEMP TABLE "temp_TOTALINCOME" AS
    SELECT SUM("FYP_Tot_Amount" + "INVTSL_Amount") AS "TOTALINCOME", "MI_Id"
    FROM "temp_INCOME"
    GROUP BY "MI_Id";
    
    RAISE NOTICE 'AAAA';
    
    CREATE TEMP TABLE "temp_EXPENSES" AS
    SELECT * FROM (
        SELECT 
            CASE WHEN COALESCE(b."PCREQTNDET_Remarks", '') = '' THEN a."PCREQTN_Purpose" ELSE b."PCREQTNDET_Remarks" END AS "Particular",
            b."PCREQTNDET_Amount",
            a."MI_Id",
            CAST("PCREQTN_Date" AS DATE) AS "PCREQTN_Date",
            'E' AS "Type"
        FROM "PC_Requisition" a   
        INNER JOIN "PC_Requisition_Details" b ON a."PCREQTN_Id" = b."PCREQTN_Id"  
        WHERE a."MI_Id" = "p_MI_Id" AND CAST("PCREQTN_Date" AS DATE) = CAST("v_DateSelection" AS DATE)   
        GROUP BY b."PCREQTNDET_Remarks", a."PCREQTN_Purpose", b."PCREQTNDET_Amount", CAST("PCREQTN_Date" AS DATE), a."MI_Id"  
        
        UNION
        
        SELECT 
            a."INVSPT_Remarks" AS "Particular",
            a."INVSPT_Amount",
            a."MI_Id",
            CAST("INVSPT_PaymentDate" AS DATE) AS "PCREQTN_Date",
            'I' AS "Type"
        FROM "INV"."INV_Supplier_Payment" a   
        WHERE a."MI_Id" = "p_MI_Id" AND CAST("INVSPT_PaymentDate" AS DATE) = CAST("v_DateSelection" AS DATE)   
        GROUP BY a."INVSPT_Remarks", a."INVSPT_Amount", CAST("INVSPT_PaymentDate" AS DATE), a."MI_Id"
    ) AS B;
    
    RAISE NOTICE 'CCCC';
    
    DROP TABLE IF EXISTS "temp_ALL_DATES";
    CREATE TEMP TABLE "temp_ALL_DATES" ("Trans_Date" timestamp);
    
    INSERT INTO "temp_ALL_DATES" ("Trans_Date")
    SELECT CAST("FYP_Date" AS DATE) FROM "temp_INCOME"
    UNION 
    SELECT CAST("FYP_Date" AS DATE) FROM "temp_INCOME"
    UNION 
    SELECT CAST("PCREQTN_Date" AS DATE) FROM "temp_EXPENSES"
    UNION 
    SELECT CAST("PCREQTN_Date" AS DATE) FROM "temp_EXPENSES";
    
    RAISE NOTICE 'BBBB';
    RAISE NOTICE 'DDDD';
    
    CREATE TEMP TABLE "temp_TOTALEXPENSES" AS
    SELECT SUM("PCREQTNDET_Amount") AS "TOTALEXPENSES", "MI_Id"
    FROM "temp_EXPENSES"
    GROUP BY "MI_Id";
    
    RETURN QUERY
    SELECT ("TOTALINCOME" - "TOTALEXPENSES") AS "OPENINGBALCANCE"
    FROM "temp_TOTALINCOME" A 
    JOIN "temp_TOTALEXPENSES" B ON A."MI_ID" = B."MI_ID";
    
    DROP TABLE IF EXISTS "temp_INCOME";
    DROP TABLE IF EXISTS "temp_EXPENSES";
    DROP TABLE IF EXISTS "temp_TOTALINCOME";
    DROP TABLE IF EXISTS "temp_TOTALEXPENSES";
    DROP TABLE IF EXISTS "temp_ALL_DATES";
    
    RETURN;
END;
$$;