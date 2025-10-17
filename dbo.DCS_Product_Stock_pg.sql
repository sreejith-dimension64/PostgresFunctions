CREATE OR REPLACE FUNCTION "dbo"."DCS_Product_Stock"(
    "@MI_Id" BIGINT,
    "@INVMST_Id" BIGINT
)
RETURNS TABLE(
    "INVMP_Id" BIGINT,
    "INVSTO_PurchaseDate" TIMESTAMP,
    "INVMP_ProductName" VARCHAR,
    "INVSTO_PurchaseRate" NUMERIC,
    "INVSTO_SalesRate" NUMERIC,
    "INVSTO_AvaiableStock" NUMERIC,
    "INVMP_ProductCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."INVMP_Id",
        MAX(b."INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate",
        a."INVMP_ProductName",
        b."INVSTO_PurchaseRate",
        b."INVSTO_SalesRate",
        b."INVSTO_AvaiableStock",
        a."INVMP_ProductCode"
    FROM "INV"."INV_Master_Product" a,
         "DCS"."DCS_Stock" b,
         "INV"."INV_Master_Store" c
    WHERE a."INVMP_Id" = b."INVMP_Id" 
      AND b."INVMST_Id" = c."INVMST_Id" 
      AND a."MI_Id" = "@MI_Id" 
      AND b."INVSTO_AvaiableStock" <> 0 
      AND b."INVSTO_PurchaseDate" IS NOT NULL 
      AND b."INVMST_Id" = "@INVMST_Id" 
      AND a."INVMP_ActiveFlg" = 1
    GROUP BY 
        a."INVMP_Id",
        a."INVMP_ProductName",
        a."INVMP_ProductCode",
        b."INVSTO_PurchaseRate",
        b."INVSTO_SalesRate",
        b."INVSTO_AvaiableStock"
    ORDER BY "INVSTO_PurchaseDate" ASC;
END;
$$;