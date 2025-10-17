CREATE OR REPLACE FUNCTION "dbo"."DCS_SALE_TYPES_DETAILS"(
    "@MI_Id" BIGINT,
    "@DCSMSL_Id" BIGINT
)
RETURNS TABLE(
    "DCSMSL_Id" BIGINT,
    "INVMC_CustomerName" TEXT,
    "INVMC_CustomerAddress" TEXT,
    "INVMC_GSTNO" TEXT,
    "INVMP_ProductName" TEXT,
    "INVTSL_SalesQty" NUMERIC,
    "INVTSL_SalesPrice" NUMERIC,
    "INVTSL_Amount" NUMERIC,
    "INVTSL_Naration" TEXT,
    "INVMS_StoreName" TEXT,
    "INVMS_StoreLocation" TEXT,
    "INVMSL_SalesDate" TIMESTAMP,
    "DCS_Vehicleno" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."DCSMSL_Id",
        a."INVMC_CustomerName",
        a."INVMC_CustomerAddress",
        a."INVMC_GSTNO",
        f."INVMP_ProductName",
        e."INVTSL_SalesQty",
        e."INVTSL_SalesPrice",
        e."INVTSL_Amount",
        e."INVTSL_Naration",
        d."INVMS_StoreName",
        d."INVMS_StoreLocation",
        c."INVMSL_SalesDate",
        c."DCS_Vehicleno"
    FROM "inv"."INV_Master_Customer" a
    INNER JOIN "dcs"."dcs_M_Sales_Customer" b ON a."INVMC_Id" = b."INVMC_Id"
    INNER JOIN "dcs"."dcs_m_sales" c ON c."DCSMSL_Id" = b."DCSMSL_Id"
    INNER JOIN "inv"."INV_Master_Store" d ON d."INVMST_Id" = c."INVMST_Id"
    INNER JOIN "dcs"."dcs_t_sales" e ON e."DCSMSL_Id" = c."DCSMSL_Id"
    INNER JOIN "inv"."INV_Master_Product" f ON f."INVMP_Id" = e."INVMP_Id"
    WHERE c."MI_Id" = "@MI_Id" 
        AND c."DCSMSL_Id" = "@DCSMSL_Id";
    
    RETURN;
END;
$$;