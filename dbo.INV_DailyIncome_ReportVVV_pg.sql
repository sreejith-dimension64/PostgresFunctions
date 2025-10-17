CREATE OR REPLACE FUNCTION "INV_DailyIncome_ReportVVV"(
    "@MI_Id" bigint,
    "@Date" timestamp
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "FYP_Id" bigint,
    "Payment_Mode" text,
    "FYP_Tot_Amount" numeric
) 
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT * FROM (
        SELECT DISTINCT 
            a."AMST_Id",
            "FYP"."FYP_Id",
            (b."AMST_FirstName" || ' ' || b."AMST_MiddleName" || '' || b."AMST_LastName") || ' / ' ||   
            CASE 
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'C' THEN 'Cash'   
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank'  
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'O' THEN 'Online'  
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'R' THEN 'RTGS'  
                WHEN "FYP"."FYP_Bank_Or_Cash" = 'U' THEN 'UPI' 
            END AS "Payment_Mode",
            "FYP"."FYP_Tot_Amount"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FY" ON "FYP"."FYP_Id" = "FY"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" a ON "FY"."ASMAY_Id" = a."ASMAY_Id" AND "FY"."AMST_Id" = a."AMST_Id" 
        INNER JOIN "Adm_M_Student" b ON b."MI_Id" = "FYP"."MI_Id" AND a."AMST_Id" = b."AMST_Id" 
        WHERE "FYP"."MI_Id" = "@MI_Id" AND CAST("FYP"."FYP_Date" AS date) = CAST("@Date" AS date)
        GROUP BY 
            a."AMST_Id",
            (b."AMST_FirstName" || ' ' || b."AMST_MiddleName" || '' || b."AMST_LastName"),
            "FYP"."FYP_Bank_Or_Cash",
            "FYP"."FYP_Tot_Amount",
            "FYP"."FYP_Id"

        UNION

        SELECT DISTINCT 
            a."AMST_Id",
            0::bigint AS "FYP_Id", 
            COALESCE(a."AMST_FirstName", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."AMST_LastName", '') || '/' ||
            f."INVMI_ItemName" || '/' ||
            CAST(e."INVTSL_SalesQty" AS VARCHAR) || '/' ||
            CAST(e."INVTSL_Amount" AS VARCHAR) AS "Description",
            e."INVTSL_Amount" AS "TotalAmount"
        FROM "Adm_M_Student" a 
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "INV"."INV_M_Sales_Student" c ON c."AMST_Id" = b."AMST_Id" 
            AND c."ASMCL_Id" = b."ASMCL_Id" 
            AND c."ASMAY_Id" = b."ASMAY_Id"
            AND c."ASMS_Id" = b."ASMS_Id"
        INNER JOIN "INV"."INV_M_Sales" d ON d."INVMSL_Id" = c."INVMSL_Id"
        INNER JOIN "INV"."INV_T_Sales" e ON e."INVMSL_Id" = c."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Item" f ON f."INVMI_Id" = e."INVMI_Id"
        WHERE a."MI_Id" = "@MI_Id" AND CAST(d."INVMSL_SalesDate" AS date) = CAST("@Date" AS date)
    ) AS "A"
    ORDER BY "FYP_Id" DESC;

END;
$$;