CREATE OR REPLACE FUNCTION "INV"."INV_GRNReport_BU" (
    p_MI_Id BIGINT, 
    p_startdate VARCHAR(10), 
    p_enddate VARCHAR(10), 
    p_GRN_Ids VARCHAR(100), 
    p_INVMI_Ids VARCHAR(100), 
    p_INVMS_Ids VARCHAR(100),
    p_optionflag VARCHAR(50)
)
RETURNS TABLE (
    "INVMGRN_Id" BIGINT,
    "INVMS_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMGRN_GRNNo" VARCHAR,
    "INVMGRN_PurchaseDate" TIMESTAMP,
    "INVMS_SupplierName" VARCHAR,
    "INVMS_SupplierCode" VARCHAR,
    "INVMS_SupplierConatctPerson" VARCHAR,
    "INVMS_SupplierConatctNo" VARCHAR,
    "INVMS_EmailId" VARCHAR,
    "INVMS_SupplierAddress" TEXT,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "INVMUOM_UOMName" VARCHAR,
    "INVTGRN_BatchNo" VARCHAR,
    "INVTGRN_Qty" NUMERIC,
    "INVTGRN_PurchaseRate" NUMERIC,
    "INVTGRN_MRP" NUMERIC,
    "INVTGRN_SalesPrice" NUMERIC,
    "INVTGRN_DiscountAmt" NUMERIC,
    "INVTGRN_TaxAmt" NUMERIC,
    "INVTGRN_Amount" NUMERIC,
    "INVTGRN_Naration" TEXT,
    "INVTGRN_MfgDate" TIMESTAMP,
    "INVTGRN_ExpDate" TIMESTAMP,
    "INVTGRN_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_dates TEXT;
BEGIN
    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := ' AND DATE("MGRN"."INVMGRN_PurchaseDate") BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;
    
    IF (p_optionflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "MGRN"."INVMGRN_GRNNo", "MGRN"."INVMGRN_PurchaseDate", 
        "ISP"."INVMS_SupplierName", "ISP"."INVMS_SupplierCode", "ISP"."INVMS_SupplierConatctPerson", "ISP"."INVMS_SupplierConatctNo", 
        "ISP"."INVMS_EmailId", "ISP"."INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
        "TGRN"."INVTGRN_BatchNo", "TGRN"."INVTGRN_Qty", "TGRN"."INVTGRN_PurchaseRate", "TGRN"."INVTGRN_MRP", "TGRN"."INVTGRN_SalesPrice", 
        "TGRN"."INVTGRN_DiscountAmt", "TGRN"."INVTGRN_TaxAmt", "TGRN"."INVTGRN_Amount", "TGRN"."INVTGRN_Naration", "TGRN"."INVTGRN_MfgDate", 
        "TGRN"."INVTGRN_ExpDate", "TGRN"."INVTGRN_ActiveFlg"
        FROM "INV"."INV_M_GRN" "MGRN"
        LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
        WHERE "MGRN"."INVMGRN_ActiveFlg" = TRUE AND "TGRN"."INVTGRN_ActiveFlg" = TRUE AND "MGRN"."MI_Id" = ' || p_MI_Id || v_dates || '
        ORDER BY "MGRN"."INVMGRN_Id" ASC';
        
        RETURN QUERY EXECUTE v_Slqdymaic;
        
    ELSIF p_optionflag = 'Individual' THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "MGRN"."INVMGRN_GRNNo", "MGRN"."INVMGRN_PurchaseDate", 
        "ISP"."INVMS_SupplierName", "ISP"."INVMS_SupplierCode", "ISP"."INVMS_SupplierConatctPerson", "ISP"."INVMS_SupplierConatctNo", 
        "ISP"."INVMS_EmailId", "ISP"."INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
        "TGRN"."INVTGRN_BatchNo", "TGRN"."INVTGRN_Qty", "TGRN"."INVTGRN_PurchaseRate", "TGRN"."INVTGRN_MRP", "TGRN"."INVTGRN_SalesPrice", 
        "TGRN"."INVTGRN_DiscountAmt", "TGRN"."INVTGRN_TaxAmt", "TGRN"."INVTGRN_Amount", "TGRN"."INVTGRN_Naration", "TGRN"."INVTGRN_MfgDate", 
        "TGRN"."INVTGRN_ExpDate", "TGRN"."INVTGRN_ActiveFlg"
        FROM "INV"."INV_M_GRN" "MGRN"
        LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
        WHERE "MGRN"."INVMGRN_ActiveFlg" = TRUE AND "TGRN"."INVTGRN_ActiveFlg" = TRUE 
        AND "MGRN"."INVMGRN_Id" IN (' || p_GRN_Ids || ') AND "MGRN"."MI_Id" = ' || p_MI_Id || v_dates;
        
        RETURN QUERY EXECUTE v_Slqdymaic;
        
    ELSIF p_optionflag = 'Item' THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "MGRN"."INVMGRN_GRNNo", "MGRN"."INVMGRN_PurchaseDate", 
        "ISP"."INVMS_SupplierName", "ISP"."INVMS_SupplierCode", "ISP"."INVMS_SupplierConatctPerson", "ISP"."INVMS_SupplierConatctNo", 
        "ISP"."INVMS_EmailId", "ISP"."INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
        "TGRN"."INVTGRN_BatchNo", "TGRN"."INVTGRN_Qty", "TGRN"."INVTGRN_PurchaseRate", "TGRN"."INVTGRN_MRP", "TGRN"."INVTGRN_SalesPrice", 
        "TGRN"."INVTGRN_DiscountAmt", "TGRN"."INVTGRN_TaxAmt", "TGRN"."INVTGRN_Amount", "TGRN"."INVTGRN_Naration", "TGRN"."INVTGRN_MfgDate", 
        "TGRN"."INVTGRN_ExpDate", "TGRN"."INVTGRN_ActiveFlg"
        FROM "INV"."INV_M_GRN" "MGRN"
        LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
        WHERE "MGRN"."INVMGRN_ActiveFlg" = TRUE AND "TGRN"."INVTGRN_ActiveFlg" = TRUE 
        AND "TGRN"."INVMI_Id" IN (' || p_INVMI_Ids || ') AND "MGRN"."MI_Id" = ' || p_MI_Id || v_dates;
        
        RETURN QUERY EXECUTE v_Slqdymaic;
        
    ELSIF p_optionflag = 'Supplier' THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "MGRN"."INVMGRN_GRNNo", "MGRN"."INVMGRN_PurchaseDate", 
        "ISP"."INVMS_SupplierName", "ISP"."INVMS_SupplierCode", "ISP"."INVMS_SupplierConatctPerson", "ISP"."INVMS_SupplierConatctNo", 
        "ISP"."INVMS_EmailId", "ISP"."INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
        "TGRN"."INVTGRN_BatchNo", "TGRN"."INVTGRN_Qty", "TGRN"."INVTGRN_PurchaseRate", "TGRN"."INVTGRN_MRP", "TGRN"."INVTGRN_SalesPrice", 
        "TGRN"."INVTGRN_DiscountAmt", "TGRN"."INVTGRN_TaxAmt", "TGRN"."INVTGRN_Amount", "TGRN"."INVTGRN_Naration", "TGRN"."INVTGRN_MfgDate", 
        "TGRN"."INVTGRN_ExpDate", "TGRN"."INVTGRN_ActiveFlg"
        FROM "INV"."INV_M_GRN" "MGRN"
        LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
        WHERE "MGRN"."INVMGRN_ActiveFlg" = TRUE AND "TGRN"."INVTGRN_ActiveFlg" = TRUE 
        AND "MGRN"."INVMS_Id" IN (' || p_INVMS_Ids || ') AND "MGRN"."MI_Id" = ' || p_MI_Id || v_dates;
        
        RETURN QUERY EXECUTE v_Slqdymaic;
    END IF;
    
    RETURN;
END;
$$;