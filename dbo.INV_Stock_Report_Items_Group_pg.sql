CREATE OR REPLACE FUNCTION "dbo"."INV_Stock_Report_Items_Group"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMG_Id" BIGINT,
    "INVMG_GroupName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "optionflag" = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT AS "INVMG_Id",
            NULL::TEXT AS "INVMG_GroupName"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE a."INVMI_ActiveFlg" = 1 AND a."MI_Id" = "MI_Id";
        
    ELSIF "optionflag" = 'Group' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            a."INVMG_Id",
            a."INVMG_GroupName"
        FROM "INV"."INV_Master_Group" a
        INNER JOIN "INV"."INV_Master_Item" b ON a."INVMG_Id" = b."INVMG_Id"
        INNER JOIN "INV"."INV_Stock" c ON b."INVMI_Id" = c."INVMI_Id"
        WHERE a."INVMG_ActiveFlg" = 1 AND a."MI_Id" = "MI_Id";
        
    END IF;

    RETURN;

END;
$$;