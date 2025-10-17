CREATE OR REPLACE FUNCTION "dbo"."AssetTag_Item_Qty" (
    p_MI_Id BIGINT,
    p_INVMST_Id BIGINT
)
RETURNS TABLE (
    "INVMI_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVSTO_PurchaseRate" NUMERIC,
    "INVSTO_SalesRate" NUMERIC,
    "ActualQty" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        a."INVMI_Id",
        a."INVMST_Id",
        b."INVMS_StoreName",
        c."INVMI_ItemName",
        a."INVSTO_PurchaseRate",
        a."INVSTO_SalesRate",
        CAST(ROUND(a."INVSTO_AvaiableStock" - COALESCE(a."INVSTO_DisposedQty", 0), 0) AS INTEGER) AS "ActualQty"
    FROM "INV"."INV_Stock" a
    INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
    INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
    WHERE a."MI_Id" = p_MI_Id AND b."INVMST_Id" = p_INVMST_Id;

END;
$$;