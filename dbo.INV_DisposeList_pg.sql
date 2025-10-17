CREATE OR REPLACE FUNCTION "dbo"."INV_DisposeList"(
    p_MI_Id bigint
)
RETURNS TABLE (
    "invadI_Id" bigint,
    "invmsT_Id" bigint,
    "invmS_StoreName" text,
    "invmI_Id" bigint,
    "invmI_ItemName" text,
    "invstO_SalesRate" numeric,
    "invmlO_Id" bigint,
    "invmlO_LocationRoomName" text,
    "invadI_DisposedDate" timestamp,
    "invadI_DisposedQty" numeric,
    "invadI_DisposedRemarks" text,
    "invadI_ActiveFlg" boolean,
    "INVSTO_SalesRate" numeric,
    "invstO_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."invadI_Id", 
        a."invmsT_Id", 
        b."invmS_StoreName", 
        a."invmI_Id", 
        c."invmI_ItemName", 
        a."invstO_SalesRate", 
        a."invmlO_Id", 
        d."invmlO_LocationRoomName",
        a."invadI_DisposedDate", 
        a."invadI_DisposedQty", 
        a."invadI_DisposedRemarks", 
        a."invadI_ActiveFlg",
        a."INVSTO_SalesRate",
        (SELECT e."invstO_Id" 
         FROM "INV"."INV_Stock" e 
         WHERE e."INVMST_Id" = a."INVMST_Id" 
           AND a."INVMI_Id" = e."INVMI_Id" 
           AND e."INVSTO_PurchaseRate" = a."INVSTO_SalesRate" 
         ORDER BY e."INVSTO_Id" DESC 
         LIMIT 1) AS "invstO_Id"
    FROM "INV"."INV_Asset_Dispose" a
    INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
    INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
    INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
    WHERE a."MI_Id" = p_MI_Id;
END;
$$;