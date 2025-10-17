CREATE OR REPLACE FUNCTION "INV"."INV_GetItemDetails"(
    "p_MI_Id" bigint,
    "p_INVMGRN_Id" bigint,
    "p_INVMI_Id" bigint,
    "p_Type" varchar(40)
)
RETURNS TABLE(
    "invmI_Id" bigint,
    "invmI_ItemName" text,
    "invmuoM_Id" bigint,
    "invmuoM_UOMName" text,
    "invmuoM_UOMAliasName" text,
    "invtgrN_PurchaseRate" numeric,
    "invtgrN_Qty" numeric,
    "INVTGRN_Qty1" numeric,
    "invtgrnreT_ReturnQty" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_count" bigint;
BEGIN
    SELECT COUNT(*) INTO "v_count"
    FROM "INV"."INV_M_GRN_Return" a
    INNER JOIN "INV"."INV_T_GRN_Return" b ON a."INVMGRNRET_Id" = b."INVMGRNRET_Id"
    WHERE a."INVMGRN_Id" = "p_INVMGRN_Id" AND b."INVMI_Id" = "p_INVMI_Id";

    IF "v_count" > 0 THEN
        RETURN QUERY
        SELECT 
            a."INVMI_Id" AS "invmI_Id",
            a."INVMI_ItemName" AS "invmI_ItemName",
            b."INVMUOM_Id" AS "invmuoM_Id",
            b."INVMUOM_UOMName" AS "invmuoM_UOMName",
            b."INVMUOM_UOMAliasName" AS "invmuoM_UOMAliasName",
            c."INVTGRN_PurchaseRate" AS "invtgrN_PurchaseRate",
            c."INVTGRN_Qty" - SUM(f."INVTGRNRET_ReturnQty") AS "invtgrN_Qty",
            c."INVTGRN_Qty" AS "INVTGRN_Qty1",
            SUM(f."INVTGRNRET_ReturnQty") AS "invtgrnreT_ReturnQty"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Master_UOM" b ON a."INVMUOM_Id" = b."INVMUOM_Id"
        INNER JOIN "INV"."INV_T_GRN" c ON c."INVMI_Id" = a."INVMI_Id"
        LEFT JOIN "INV"."INV_M_GRN_Return" e ON e."INVMGRN_Id" = c."INVMGRN_Id"
        INNER JOIN "INV"."INV_T_GRN_Return" f ON f."INVMGRNRET_Id" = e."INVMGRNRET_Id"
        WHERE c."INVMGRN_Id" = "p_INVMGRN_Id" 
            AND c."INVMI_Id" = "p_INVMI_Id" 
            AND f."INVMI_Id" = "p_INVMI_Id" 
            AND a."MI_Id" = "p_MI_Id" 
            AND b."MI_Id" = "p_MI_Id"
        GROUP BY a."INVMI_Id", a."INVMI_ItemName", b."INVMUOM_Id", b."INVMUOM_UOMName", b."INVMUOM_UOMAliasName", c."INVTGRN_PurchaseRate", c."INVTGRN_Qty";
    ELSE
        RETURN QUERY
        SELECT 
            a."INVMI_Id" AS "invmI_Id",
            a."INVMI_ItemName" AS "invmI_ItemName",
            b."INVMUOM_Id" AS "invmuoM_Id",
            b."INVMUOM_UOMName" AS "invmuoM_UOMName",
            b."INVMUOM_UOMAliasName" AS "invmuoM_UOMAliasName",
            c."INVTGRN_PurchaseRate" AS "invtgrN_PurchaseRate",
            c."INVTGRN_Qty" AS "invtgrN_Qty",
            c."INVTGRN_Qty" AS "INVTGRN_Qty1",
            NULL::numeric AS "invtgrnreT_ReturnQty"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Master_UOM" b ON a."INVMUOM_Id" = b."INVMUOM_Id"
        INNER JOIN "INV"."INV_T_GRN" c ON c."INVMI_Id" = a."INVMI_Id"
        WHERE c."INVMGRN_Id" = "p_INVMGRN_Id" 
            AND c."INVMI_Id" = "p_INVMI_Id" 
            AND a."MI_Id" = "p_MI_Id" 
            AND b."MI_Id" = "p_MI_Id";
    END IF;

    RETURN;
END;
$$;