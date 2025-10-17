CREATE OR REPLACE FUNCTION "dbo"."CM_Item_Date_Categorywise_OrderDetails" (
    "p_Flag" VARCHAR(10),
    "p_Fromdate" VARCHAR(50),
    "p_Todate" VARCHAR(50),
    "p_ItemName" TEXT,
    "p_Category" TEXT,
    "p_CMMCO_Id" BIGINT,
    "p_MI_id" TEXT
)
RETURNS TABLE (
    "MI_Name" VARCHAR,
    "MI_Logo" VARCHAR,
    "Address" TEXT,
    "CMMFI_FoodItemName" VARCHAR,
    "Total_Quantity" NUMERIC,
    "Total_Amount" NUMERIC,
    "Ordered_Date" DATE,
    "Category_Name" VARCHAR,
    "CMMCO_CounterName" VARCHAR,
    "Grand_Total" VARCHAR,
    "Total_FoodItemNames" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "temp_FoodItemDetails";
    CREATE TEMP TABLE "temp_FoodItemDetails" (
        "MI_Name" VARCHAR,
        "MI_Logo" VARCHAR,
        "Address" TEXT,
        "CMMFI_FoodItemName" VARCHAR,
        "Total_Quantity" NUMERIC,
        "Total_Amount" NUMERIC,
        "Ordered_Date" DATE,
        "Category_Name" VARCHAR,
        "CMMCO_CounterName" VARCHAR
    );

    IF "p_Flag" = 'Date' THEN
    
        INSERT INTO "temp_FoodItemDetails"
        SELECT 
            e."MI_Name",
            e."MI_Logo",
            COALESCE(e."MI_Address1",'') || ' ' || COALESCE(e."MI_Address2",'') || ' ' || COALESCE(e."MI_Address3",'') AS "Address",
            b."CMMFI_FoodItemName",
            SUM(a."CMTRANS_Qty") AS "Total_Quantity",
            SUM(a."CMTRANS_Qty" * a."CMTRANSI_UnitRate") AS "Total_Amount",
            CAST(c."CMTRANS_Updateddate" AS DATE) AS "Ordered_Date",
            CASE WHEN b."CMMFI_FoodItemFlag" = 1 THEN 'Veg' ELSE 'Non Veg' END AS "Category_Name",
            d."CMMCO_CounterName"
        FROM "CM_Transaction_Items" a
        INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
        INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
        INNER JOIN "CM_Master_Counter" d ON d."CMMCO_Id" = c."CMMCO_Id"
        INNER JOIN "Master_Institution" e ON e."MI_Id" = c."MI_Id"
        WHERE CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE)
            AND c."CMMCO_Id" = "p_CMMCO_Id"
        GROUP BY b."CMMFI_FoodItemName", b."CMMFI_FoodItemFlag", CAST(c."CMTRANS_Updateddate" AS DATE),
            d."CMMCO_CounterName", e."MI_Name", e."MI_Logo", e."MI_Address1", e."MI_Address2", e."MI_Address3"
        ORDER BY CAST(c."CMTRANS_Updateddate" AS DATE);

        RETURN QUERY
        SELECT t."MI_Name", t."MI_Logo", t."Address", t."CMMFI_FoodItemName", t."Total_Quantity",
            t."Total_Amount", t."Ordered_Date", t."Category_Name", t."CMMCO_CounterName", 
            NULL::VARCHAR AS "Grand_Total", NULL::VARCHAR AS "Total_FoodItemNames"
        FROM "temp_FoodItemDetails" t
        UNION
        SELECT NULL, NULL, 'Grand Total', CAST(COUNT(t."CMMFI_FoodItemName") AS VARCHAR), SUM(t."Total_Quantity"),
            SUM(t."Total_Amount"), NULL, NULL, NULL, NULL, NULL
        FROM "temp_FoodItemDetails" t;

    ELSIF "p_Flag" = 'item' THEN
    
        INSERT INTO "temp_FoodItemDetails"
        SELECT 
            e."MI_Name",
            e."MI_Logo",
            COALESCE(e."MI_Address1",'') || ' ' || COALESCE(e."MI_Address2",'') || ' ' || COALESCE(e."MI_Address3",'') AS "Address",
            b."CMMFI_FoodItemName",
            SUM(a."CMTRANS_Qty") AS "Total_Quantity",
            SUM(a."CMTRANS_Qty" * a."CMTRANSI_UnitRate") AS "Total_Amount",
            CAST(c."CMTRANS_Updateddate" AS DATE) AS "Ordered_Date",
            CASE WHEN b."CMMFI_FoodItemFlag" = 1 THEN 'Veg' ELSE 'Non Veg' END AS "Category_Name",
            d."CMMCO_CounterName"
        FROM "CM_Transaction_Items" a
        INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
        INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
        INNER JOIN "CM_Master_Counter" d ON d."CMMCO_Id" = c."CMMCO_Id"
        INNER JOIN "Master_Institution" e ON e."MI_Id" = c."MI_Id"
        WHERE b."CMMFI_FoodItemName" = ANY(string_to_array("p_ItemName", ',')) 
            AND c."CMMCO_Id" = "p_CMMCO_Id"
        GROUP BY b."CMMFI_FoodItemName", b."CMMFI_FoodItemFlag", CAST(c."CMTRANS_Updateddate" AS DATE),
            d."CMMCO_CounterName", e."MI_Name", e."MI_Logo", e."MI_Address1", e."MI_Address2", e."MI_Address3"
        ORDER BY CAST(c."CMTRANS_Updateddate" AS DATE);

        RETURN QUERY
        SELECT t."MI_Name", t."MI_Logo", t."Address", t."CMMFI_FoodItemName", t."Total_Quantity",
            t."Total_Amount", t."Ordered_Date", t."Category_Name", t."CMMCO_CounterName",
            NULL::VARCHAR AS "Grand_Total", NULL::VARCHAR AS "Total_FoodItemNames"
        FROM "temp_FoodItemDetails" t
        UNION
        SELECT NULL, NULL, 'Grand Total', CAST(COUNT(t."CMMFI_FoodItemName") AS VARCHAR), SUM(t."Total_Quantity"),
            SUM(t."Total_Amount"), NULL, NULL, NULL, NULL, NULL
        FROM "temp_FoodItemDetails" t;

    ELSIF "p_Flag" = 'Category' THEN
    
        IF "p_Category" = 'Veg' THEN
        
            INSERT INTO "temp_FoodItemDetails"
            SELECT 
                e."MI_Name",
                e."MI_Logo",
                COALESCE(e."MI_Address1",'') || ' ' || COALESCE(e."MI_Address2",'') || ' ' || COALESCE(e."MI_Address3",'') AS "Address",
                b."CMMFI_FoodItemName",
                SUM(a."CMTRANS_Qty") AS "Total_Quantity",
                SUM(a."CMTRANS_Qty" * a."CMTRANSI_UnitRate") AS "Total_Amount",
                CAST(c."CMTRANS_Updateddate" AS DATE) AS "Ordered_Date",
                CASE WHEN b."CMMFI_FoodItemFlag" = 1 THEN 'Veg' ELSE 'Non Veg' END AS "Category_Name",
                d."CMMCO_CounterName"
            FROM "CM_Transaction_Items" a
            INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
            INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
            INNER JOIN "CM_Master_Counter" d ON d."CMMCO_Id" = c."CMMCO_Id"
            INNER JOIN "Master_Institution" e ON e."MI_Id" = c."MI_Id"
            WHERE b."CMMFI_FoodItemFlag" = 1 
                AND c."CMMCO_Id" = "p_CMMCO_Id"
                AND CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE)
            GROUP BY b."CMMFI_FoodItemName", b."CMMFI_FoodItemFlag", CAST(c."CMTRANS_Updateddate" AS DATE),
                d."CMMCO_CounterName", e."MI_Name", e."MI_Logo", e."MI_Address1", e."MI_Address2", e."MI_Address3"
            ORDER BY CAST(c."CMTRANS_Updateddate" AS DATE);

            RETURN QUERY
            SELECT t."MI_Name", t."MI_Logo", t."Address", t."CMMFI_FoodItemName", t."Total_Quantity",
                t."Total_Amount", t."Ordered_Date", t."Category_Name", t."CMMCO_CounterName",
                NULL::VARCHAR AS "Grand_Total", NULL::VARCHAR AS "Total_FoodItemNames"
            FROM "temp_FoodItemDetails" t
            UNION
            SELECT NULL, NULL, 'Grand Total', CAST(COUNT(t."CMMFI_FoodItemName") AS VARCHAR), SUM(t."Total_Quantity"),
                SUM(t."Total_Amount"), NULL, NULL, NULL, NULL, NULL
            FROM "temp_FoodItemDetails" t;
            
        ELSE
        
            INSERT INTO "temp_FoodItemDetails"
            SELECT 
                e."MI_Name",
                e."MI_Logo",
                COALESCE(e."MI_Address1",'') || ' ' || COALESCE(e."MI_Address2",'') || ' ' || COALESCE(e."MI_Address3",'') AS "Address",
                b."CMMFI_FoodItemName",
                SUM(a."CMTRANS_Qty") AS "Total_Quantity",
                SUM(a."CMTRANS_Qty" * a."CMTRANSI_UnitRate") AS "Total_Amount",
                CAST(c."CMTRANS_Updateddate" AS DATE) AS "Ordered_Date",
                CASE WHEN b."CMMFI_FoodItemFlag" = 1 THEN 'Veg' ELSE 'Non Veg' END AS "Category_Name",
                d."CMMCO_CounterName"
            FROM "CM_Transaction_Items" a
            INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
            INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
            INNER JOIN "CM_Master_Counter" d ON d."CMMCO_Id" = c."CMMCO_Id"
            INNER JOIN "Master_Institution" e ON e."MI_Id" = c."MI_Id"
            WHERE b."CMMFI_FoodItemFlag" = 0 
                AND c."CMMCO_Id" = "p_CMMCO_Id"
                AND CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE)
            GROUP BY b."CMMFI_FoodItemName", b."CMMFI_FoodItemFlag", CAST(c."CMTRANS_Updateddate" AS DATE),
                d."CMMCO_CounterName", e."MI_Name", e."MI_Logo", e."MI_Address1", e."MI_Address2", e."MI_Address3"
            ORDER BY CAST(c."CMTRANS_Updateddate" AS DATE);

            RETURN QUERY
            SELECT t."MI_Name", t."MI_Logo", t."Address", t."CMMFI_FoodItemName", t."Total_Quantity",
                t."Total_Amount", t."Ordered_Date", t."Category_Name", t."CMMCO_CounterName",
                NULL::VARCHAR AS "Grand_Total", NULL::VARCHAR AS "Total_FoodItemNames"
            FROM "temp_FoodItemDetails" t
            UNION
            SELECT NULL, NULL, 'Grand Total', CAST(COUNT(t."CMMFI_FoodItemName") AS VARCHAR), SUM(t."Total_Quantity"),
                SUM(t."Total_Amount"), NULL, NULL, NULL, NULL, NULL
            FROM "temp_FoodItemDetails" t;
            
        END IF;

    ELSIF "p_Flag" = 'Collection' THEN
    
        IF "p_Category" = 'Collectionpda' THEN
        
            RETURN QUERY
            SELECT NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::VARCHAR, NULL::NUMERIC,
                SUM(a."CMTRANSI_UnitRate") AS "Total_Amount", NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
                NULL::VARCHAR, NULL::VARCHAR
            FROM "CM_Transaction_Items" a
            INNER JOIN "CM_Transaction" b ON b."CMTRANS_Id" = a."CMTRANS_Id"
            INNER JOIN "CM_Transaction_PaymentMode" e ON e."CMTRANS_Id" = a."CMTRANS_Id"
            WHERE e."CMTRANSPM_PaymentMode" = 'pda' 
                AND b."CMMCO_Id" = "p_CMMCO_Id"
                AND CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE);
                
        ELSIF "p_Category" = 'Collectionwallet' THEN
        
            RETURN QUERY
            SELECT NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::VARCHAR, NULL::NUMERIC,
                SUM(a."CMTRANSI_UnitRate") AS "Total_Amount", NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
                NULL::VARCHAR, NULL::VARCHAR
            FROM "CM_Transaction_Items" a
            INNER JOIN "CM_Transaction" b ON b."CMTRANS_Id" = a."CMTRANS_Id"
            INNER JOIN "CM_Transaction_PaymentMode" e ON e."CMTRANS_Id" = a."CMTRANS_Id"
            WHERE e."CMTRANSPM_PaymentMode" IN ('student_wallet','staff_wallet','student_wallet_clg')
                AND b."CMMCO_Id" = "p_CMMCO_Id"
                AND CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE);
                
        END IF;

    ELSIF "p_Flag" = 'Refund' THEN
    
        IF "p_Category" = 'Refundpda' THEN
        
            RETURN QUERY
            SELECT NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::VARCHAR, NULL::NUMERIC,
                SUM(b."CMTRANS_VoidAmount") AS "Total_Amount", NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
                NULL::VARCHAR, NULL::VARCHAR
            FROM "CM_Transaction_Items" a
            INNER JOIN "CM_Transaction" b ON b."CMTRANS_Id" = a."CMTRANS_Id"
            INNER JOIN "CM_Transaction_PaymentMode" e ON e."CMTRANS_Id" = a."CMTRANS_Id"
            WHERE a."CMTRANSI_VoidItemFlg" = 1 
                AND e."CMTRANSPM_PaymentMode" = 'pda'
                AND b."CMMCO_Id" = "p_CMMCO_Id"
                AND CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE);
                
        ELSIF "p_Category" = 'Refundwallet' THEN
        
            RETURN QUERY
            SELECT NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::VARCHAR, NULL::NUMERIC,
                SUM(b."CMTRANS_VoidAmount") AS "Total_Amount", NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
                NULL::VARCHAR, NULL::VARCHAR
            FROM "CM_Transaction_Items" a
            INNER JOIN "CM_Transaction" b ON b."CMTRANS_Id" = a."CMTRANS_Id"
            INNER JOIN "CM_Transaction_PaymentMode" e ON e."CMTRANS_Id" = a."CMTRANS_Id"
            WHERE a."CMTRANSI_VoidItemFlg" = 1 
                AND e."CMTRANSPM_PaymentMode" IN ('student_wallet','staff_wallet','student_wallet_clg')
                AND b."CMMCO_Id" = "p_CMMCO_Id"
                AND CAST(a."CMTRANSI_Updateddate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE);
                
        END IF;

    ELSIF "p_Flag" = 'Recharge' THEN
    
        RETURN QUERY
        SELECT NULL::VARCHAR, NULL::VARCHAR, NULL::TEXT, NULL::VARCHAR, NULL::NUMERIC,
            SUM(c."PDAS_CYDeposit") AS "Total_Amount", NULL::DATE, NULL::VARCHAR, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR
        FROM "CM_CounterWiseInstitution_Mapping" a
        INNER JOIN "CM_Master_Counter" b ON b."CMMCO_Id" = a."CMMCO_Id"
        INNER JOIN "PDA_Status" c ON c."MI_Id" = a."MI_Id"
        WHERE a."CMMCO_Id" = "p_CMMCO_Id"
            AND CAST(c."UpdatedDate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE);

    ELSE
    
        INSERT INTO "temp_FoodItemDetails"
        SELECT 
            e."MI_Name",
            e."MI_Logo",
            COALESCE(e."MI_Address1",'') || ' ' || COALESCE(e."MI_Address2",'') || ' ' || COALESCE(e."MI_Address3",'') AS "Address",
            b."CMMFI_FoodItemName",
            SUM(a."CMTRANS_Qty") AS "Total_Quantity",
            SUM(a."CMTRANS_Qty" * a."CMTRANSI_UnitRate") AS "Total_Amount",
            CAST(c."CMTRANS_Updateddate" AS DATE) AS "Ordered_Date",
            CASE WHEN b."CMMFI_FoodItemFlag" = 1 THEN 'Veg' ELSE 'Non Veg' END AS "Category_Name",
            d."CMMCO_CounterName"
        FROM "CM_Transaction_Items" a
        INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
        INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
        INNER JOIN "CM_Master_Counter" d ON d."CMMCO_Id" = c."CMMCO_Id"
        INNER JOIN "Master_Institution" e ON e."MI_Id" = c."MI_Id"
        WHERE CAST(c."MI_Id" AS TEXT) = ANY(string_to_array("p_MI_id", ','))
            AND c."CMMCO_Id" = "p_CMMCO_Id"
        GROUP BY b."CMMFI_FoodItemName", b."CMMFI_FoodItemFlag", CAST(c."CMTRANS_Updateddate" AS DATE),
            d."CMMCO_CounterName", e."MI_Name", e."MI_Logo", e."MI_Address1", e."MI_Address2", e."MI_Address3"
        ORDER BY CAST(c."CMTRANS_Updateddate" AS DATE);

        RETURN QUERY
        SELECT t."MI_Name", t."MI_Logo", NULL::TEXT AS "Address", NULL::VARCHAR AS "CMMFI_FoodItemName",
            SUM(t."Total_Quantity") AS "Total_Quantity", SUM(t."Total_Amount") AS "Total_Amount", 
            NULL::DATE AS "Ordered_Date", NULL::VARCHAR AS "Category_Name", NULL::VARCHAR AS "CMMCO_CounterName",
            'Grand Total' AS "Grand_Total", CAST(COUNT(t."CMMFI_FoodItemName") AS VARCHAR) AS "Total_FoodItemNames"
        FROM "temp_FoodItemDetails" t
        GROUP BY t."MI_Name", t."MI_Logo";

    END IF;

    DROP TABLE IF EXISTS "temp_FoodItemDetails";
    
END;
$$;