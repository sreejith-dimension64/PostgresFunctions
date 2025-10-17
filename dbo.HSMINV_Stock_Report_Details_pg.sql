CREATE OR REPLACE FUNCTION "INV"."HSMINV_Stock_Report_Details"(
    "p_MI_Id" BIGINT,
    "p_optionflag" VARCHAR(50),
    "p_INVMST_Id" BIGINT
)
RETURNS TABLE(
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
    IF "p_INVMST_Id" = 0 THEN
        IF "p_optionflag" = 'All' THEN
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
            WHERE "MI_Id" = "p_MI_Id";
        
        ELSIF "p_optionflag" = 'Item' THEN
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
            WHERE a."INVMI_ActiveFlg" = 1 AND a."MI_Id" = "p_MI_Id";
        
        ELSIF "p_optionflag" = 'Store' THEN
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
            WHERE a."INVMS_ActiveFlg" = 1 AND a."MI_Id" = "p_MI_Id";
        
        ELSIF "p_optionflag" = 'Group' THEN
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
            WHERE a."INVMG_ActiveFlg" = 1 AND a."MI_Id" = "p_MI_Id";
        END IF;
    ELSE
        IF "p_optionflag" = 'All' THEN
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
            WHERE "MI_Id" = "p_MI_Id" AND "INVMST_Id" = "p_INVMST_Id";
        
        ELSIF "p_optionflag" = 'Item' THEN
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
            WHERE a."INVMI_ActiveFlg" = 1 AND a."MI_Id" = "p_MI_Id" AND b."INVMST_Id" = "p_INVMST_Id";
        
        ELSIF "p_optionflag" = 'Store' THEN
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
            WHERE a."INVMS_ActiveFlg" = 1 AND a."MI_Id" = "p_MI_Id" AND a."INVMST_Id" = "p_INVMST_Id";
        
        ELSIF "p_optionflag" = 'Group' THEN
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
            WHERE a."INVMG_ActiveFlg" = 1 AND a."MI_Id" = "p_MI_Id" AND c."INVMST_Id" = "p_INVMST_Id";
        END IF;
    END IF;
    
    RETURN;
END;
$$;