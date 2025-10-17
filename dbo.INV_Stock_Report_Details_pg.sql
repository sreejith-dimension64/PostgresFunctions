CREATE OR REPLACE FUNCTION "INV"."INV_Stock_Report_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVSTO_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVSTO_CheckedOutQty" NUMERIC,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "INVMS_StoreName" VARCHAR,
    "INVMG_Id" BIGINT,
    "INVMG_GroupName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "optionflag" = 'All' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INV_Stock"."INVSTO_Id",
            "INV_Stock"."INVMST_Id",
            "INV_Stock"."INVMI_Id",
            "INV_Stock"."INVSTO_CheckedOutQty",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode",
            NULL::VARCHAR AS "INVMS_StoreName",
            NULL::BIGINT AS "INVMG_Id",
            NULL::VARCHAR AS "INVMG_GroupName"
        FROM "INV"."INV_Stock"
        WHERE "INV_Stock"."MI_Id" = "MI_Id";

    ELSIF "optionflag" = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVSTO_Id",
            NULL::BIGINT AS "INVMST_Id",
            a."INVMI_Id",
            NULL::NUMERIC AS "INVSTO_CheckedOutQty",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::VARCHAR AS "INVMS_StoreName",
            NULL::BIGINT AS "INVMG_Id",
            NULL::VARCHAR AS "INVMG_GroupName"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE a."INVMI_ActiveFlg" = 1 AND a."MI_Id" = "MI_Id";

    ELSIF "optionflag" = 'Store' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVSTO_Id",
            a."INVMST_Id",
            NULL::BIGINT AS "INVMI_Id",
            NULL::NUMERIC AS "INVSTO_CheckedOutQty",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode",
            a."INVMS_StoreName",
            NULL::BIGINT AS "INVMG_Id",
            NULL::VARCHAR AS "INVMG_GroupName"
        FROM "INV"."INV_Master_Store" a
        INNER JOIN "INV"."INV_Stock" b ON a."INVMST_Id" = b."INVMST_Id"
        WHERE a."INVMS_ActiveFlg" = 1 AND a."MI_Id" = "MI_Id";

    ELSIF "optionflag" = 'Group' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVSTO_Id",
            NULL::BIGINT AS "INVMST_Id",
            NULL::BIGINT AS "INVMI_Id",
            NULL::NUMERIC AS "INVSTO_CheckedOutQty",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode",
            NULL::VARCHAR AS "INVMS_StoreName",
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