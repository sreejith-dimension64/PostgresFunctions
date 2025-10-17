CREATE OR REPLACE FUNCTION "dbo"."HSMINV_ItemReport_Details"(
    p_MI_Id BIGINT,
    p_optionflag VARCHAR(50),
    p_INVMST_Id BIGINT
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMG_Id" BIGINT,
    "INVMG_GroupName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_INVMST_Id = 0 THEN
        IF (p_optionflag = 'Item') THEN
            RETURN QUERY
            SELECT DISTINCT 
                a."INVMI_Id",
                a."INVMI_ItemName",
                a."INVMI_ItemCode",
                NULL::BIGINT AS "INVMG_Id",
                NULL::TEXT AS "INVMG_GroupName"
            FROM "INV"."INV_Master_Item" a
            INNER JOIN "INV"."INV_Master_UOM" b ON a."INVMUOM_Id" = b."INVMUOM_Id" AND a."MI_Id" = b."MI_Id"
            WHERE a."MI_Id" = p_MI_Id AND a."INVMI_ActiveFlg" = 1
            ORDER BY a."INVMI_ItemName";

        ELSIF (p_optionflag = 'Group') THEN
            RETURN QUERY
            SELECT DISTINCT 
                NULL::BIGINT AS "INVMI_Id",
                NULL::TEXT AS "INVMI_ItemName",
                NULL::TEXT AS "INVMI_ItemCode",
                a."INVMG_Id",
                a."INVMG_GroupName"
            FROM "INV"."INV_Master_Group" a
            INNER JOIN "INV"."INV_Master_Item" b ON a."INVMG_Id" = b."INVMG_Id" AND a."MI_Id" = b."MI_Id"
            WHERE a."MI_Id" = p_MI_Id AND a."INVMG_ActiveFlg" = 1 AND b."INVMI_ActiveFlg" = 1
            ORDER BY a."INVMG_GroupName";

        END IF;
    ELSE
        IF (p_optionflag = 'Item') THEN
            RETURN QUERY
            SELECT DISTINCT 
                a."INVMI_Id",
                a."INVMI_ItemName",
                a."INVMI_ItemCode",
                NULL::BIGINT AS "INVMG_Id",
                NULL::TEXT AS "INVMG_GroupName"
            FROM "INV"."INV_Master_Item" a
            INNER JOIN "INV"."INV_Master_UOM" b ON a."INVMUOM_Id" = b."INVMUOM_Id" AND a."MI_Id" = b."MI_Id"
            INNER JOIN "INV"."INV_T_GRN" c ON c."INVMI_Id" = a."INVMI_Id"
            INNER JOIN "INV"."INV_M_GRN" d ON d."INVMGRN_Id" = c."INVMGRN_Id"
            INNER JOIN "INV"."INV_M_GRN_Store" e ON e."INVMGRN_Id" = c."INVMGRN_Id"
            WHERE a."MI_Id" = p_MI_Id AND a."INVMI_ActiveFlg" = 1 AND e."INVMST_Id" = p_INVMST_Id
            ORDER BY a."INVMI_ItemName";

        ELSIF (p_optionflag = 'Group') THEN
            RETURN QUERY
            SELECT DISTINCT 
                NULL::BIGINT AS "INVMI_Id",
                NULL::TEXT AS "INVMI_ItemName",
                NULL::TEXT AS "INVMI_ItemCode",
                a."INVMG_Id",
                a."INVMG_GroupName"
            FROM "INV"."INV_Master_Group" a
            INNER JOIN "INV"."INV_Master_Item" b ON a."INVMG_Id" = b."INVMG_Id" AND a."MI_Id" = b."MI_Id"
            INNER JOIN "INV"."INV_T_GRN" c ON c."INVMI_Id" = b."INVMI_Id"
            INNER JOIN "INV"."INV_M_GRN" d ON d."INVMGRN_Id" = c."INVMGRN_Id"
            INNER JOIN "INV"."INV_M_GRN_Store" e ON e."INVMGRN_Id" = c."INVMGRN_Id"
            WHERE a."MI_Id" = p_MI_Id AND a."INVMG_ActiveFlg" = 1 AND b."INVMI_ActiveFlg" = 1 AND e."INVMST_Id" = p_INVMST_Id
            ORDER BY a."INVMG_GroupName";

        END IF;
    END IF;

    RETURN;

END;
$$;