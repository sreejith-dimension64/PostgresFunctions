CREATE OR REPLACE FUNCTION "dbo"."INV_GetItem"(
    p_MI_Id bigint,
    p_INVMGRN_Id bigint,
    p_Type varchar(40)
)
RETURNS TABLE(
    "invmI_Id" bigint,
    "invmI_ItemName" text,
    "totalqty" numeric,
    "INVTGRNRET_ReturnQty" numeric,
    "AvailableGRNQty" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS grn_temp1;
    DROP TABLE IF EXISTS grn_temp2;

    CREATE TEMP TABLE grn_temp1 AS
    SELECT 
        a."INVMI_Id" as "invmI_Id",
        a."INVMI_ItemName" as "invmI_ItemName",
        d."INVMUOM_Id" as "invmuoM_Id",
        b."INVTGRN_Qty" as totalqty,
        b."INVMGRN_Id"
    FROM "INV"."INV_Master_Item" a
    INNER JOIN "INV"."INV_T_GRN" b ON a."INVMI_Id" = b."INVMI_Id"
    INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id"
    INNER JOIN "INV"."INV_Master_UOM" d ON a."INVMUOM_Id" = d."INVMUOM_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND b."INVMGRN_Id" = p_INVMGRN_Id 
        AND b."INVTGRN_Qty" > 0;

    CREATE TEMP TABLE grn_temp2 AS
    SELECT 
        a."INVMGRN_Id",
        b."INVMI_Id",
        sum(b."INVTGRNRET_ReturnQty") as "INVTGRNRET_ReturnQty"
    FROM "INV"."INV_M_GRN_Return" a 
    INNER JOIN "INV"."INV_T_GRN_Return" b ON a."INVMGRNRET_Id" = b."INVMGRNRET_Id"
    WHERE a."INVMGRN_Id" = p_INVMGRN_Id
    GROUP BY a."INVMGRN_Id", b."INVMI_Id";

    RETURN QUERY
    SELECT 
        a."invmI_Id",
        a."invmI_ItemName",
        a.totalqty,
        b."INVTGRNRET_ReturnQty",
        (a.totalqty - b."INVTGRNRET_ReturnQty") as "AvailableGRNQty"
    FROM grn_temp1 a
    INNER JOIN grn_temp2 b ON a."invmI_Id" = b."INVMI_Id"
    WHERE a."INVMGRN_Id" = p_INVMGRN_Id 
        AND (a.totalqty - b."INVTGRNRET_ReturnQty") > 0;

    DROP TABLE IF EXISTS grn_temp1;
    DROP TABLE IF EXISTS grn_temp2;
END;
$$;