CREATE OR REPLACE FUNCTION "dbo"."INV_ITEM_SUPPLIER_LIST"(
    p_MI_Id BIGINT,
    p_optionflag VARCHAR(50)
)
RETURNS TABLE(
    "INVMGRN_Id" BIGINT,
    "INVMGRN_GRNNo" VARCHAR,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "INVMS_Id" BIGINT,
    "INVMS_SupplierName" VARCHAR,
    "INVMS_SupplierCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_optionflag = 'Individual' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INV_M_GRN"."INVMGRN_Id",
            "INV_M_GRN"."INVMGRN_GRNNo",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR
        FROM "INV"."INV_M_GRN"
        WHERE "INV_M_GRN"."MI_Id" = 4 
            AND "INV_M_GRN"."INVMGRN_ActiveFlg" = 1
        ORDER BY "INV_M_GRN"."INVMGRN_Id";
        
    ELSIF p_optionflag = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            NULL::VARCHAR,
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id" 
            AND a."MI_Id" = b."MI_Id"
        WHERE a."INVMI_ActiveFlg" = 1 
            AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVMI_ItemName";
        
    ELSIF p_optionflag = 'Supplier' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            "INV_Master_Supplier"."INVMS_Id",
            "INV_Master_Supplier"."INVMS_SupplierName",
            "INV_Master_Supplier"."INVMS_SupplierCode"
        FROM "INV"."INV_Master_Supplier"
        WHERE "INV_Master_Supplier"."MI_Id" = p_MI_Id 
            AND "INV_Master_Supplier"."INVMS_ActiveFlg" = 1
        ORDER BY "INV_Master_Supplier"."INVMS_SupplierName";
        
    END IF;

END;
$$;