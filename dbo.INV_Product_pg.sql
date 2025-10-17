CREATE OR REPLACE FUNCTION "dbo"."INV_Product"(
    "@MI_Id" BIGINT,
    "@INVMST_Id" BIGINT
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVSTO_PurchaseDate" TIMESTAMP,
    "INVMI_ItemName" VARCHAR,
    "INVSTO_PurchaseRate" NUMERIC,
    "INVSTO_SalesRate" NUMERIC,
    "INVSTO_AvaiableStock" NUMERIC,
    "INVMI_ItemCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."INVMI_Id",
        MAX(b."INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate",
        a."INVMI_ItemName",
        b."INVSTO_PurchaseRate",
        b."INVSTO_SalesRate",
        b."INVSTO_AvaiableStock",
        a."INVMI_ItemCode"
    FROM "INV"."INV_Master_Item" a,
         "INV"."INV_Stock" b,
         "INV"."INV_Master_Store" c
    WHERE a."INVMI_Id" = b."INVMI_Id" 
      AND b."INVMST_Id" = c."INVMST_Id" 
      AND a."MI_Id" = "@MI_Id" 
      AND b."INVSTO_AvaiableStock" <> 0 
      AND b."INVSTO_PurchaseDate" IS NOT NULL 
      AND b."INVMST_Id" = "@INVMST_Id" 
      AND a."INVMI_ActiveFlg" = 1
    GROUP BY 
        a."INVMI_Id",
        a."INVMI_ItemName",
        a."INVMI_ItemCode",
        b."INVSTO_PurchaseRate",
        b."INVSTO_SalesRate",
        b."INVSTO_AvaiableStock"
    ORDER BY "INVSTO_PurchaseDate" ASC;
END;
$$;