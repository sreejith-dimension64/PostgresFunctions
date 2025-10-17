CREATE OR REPLACE FUNCTION "dbo"."INV_Stock_Report_Items"(
    p_MI_Id bigint
)
RETURNS TABLE (
    "INVMI_Id" bigint,
    "INVMI_ItemName" varchar,
    "INVMI_ItemCode" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "INV_Master_Item"."INVMI_Id",
        "INV_Master_Item"."INVMI_ItemName",
        "INV_Master_Item"."INVMI_ItemCode"
    FROM "INV"."INV_Master_Item"
    WHERE "INV_Master_Item"."INVMI_Id" IN (
        SELECT DISTINCT "INV_Stock"."INVMI_Id" 
        FROM "INV"."INV_Stock" 
        WHERE "INV_Stock"."MI_Id" = p_MI_Id
    );
END;
$$;