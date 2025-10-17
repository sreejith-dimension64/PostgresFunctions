CREATE OR REPLACE FUNCTION "INV"."INV_STOCKReport" (
    p_MI_Id bigint,
    p_startdate varchar(10),
    p_enddate varchar(10),
    p_INVMI_Ids varchar(100),
    p_optionflag varchar(10)
)
RETURNS TABLE (
    "INVMI_ItemName" varchar,
    "INVMI_ItemCode" varchar,
    "INVSTO_Id" bigint,
    "INVMST_Id" bigint,
    "INVMI_Id" bigint,
    "INVSTO_BatchNo" varchar,
    "INVSTO_PurchaseDate" timestamp,
    "INVSTO_PurOBQty" numeric,
    "INVSTO_PurchaseRate" numeric,
    "INVSTO_SalesRate" numeric,
    "INVSTO_PurRetQty" numeric,
    "INVSTO_SalesQty" numeric,
    "INVSTO_SalesRetQty" numeric,
    "INVSTO_ItemConQty" numeric,
    "INVSTO_MatIssPlusQty" numeric,
    "INVSTO_MatIssMinusQty" numeric,
    "INVSTO_PhyPlusQty" numeric,
    "INVSTO_PhyMinQty" numeric,
    "INVSTO_AvaiableStock" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
    v_dates text;
BEGIN

    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := ' AND CAST("INVSTO_PurchaseDate" AS date) BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT b."INVMI_ItemName", b."INVMI_ItemCode", a."INVSTO_Id", a."INVMST_Id", a."INVMI_Id", a."INVSTO_BatchNo", a."INVSTO_PurchaseDate", a."INVSTO_PurOBQty", a."INVSTO_PurchaseRate", a."INVSTO_SalesRate", a."INVSTO_PurRetQty", a."INVSTO_SalesQty", a."INVSTO_SalesRetQty", a."INVSTO_ItemConQty", a."INVSTO_MatIssPlusQty", a."INVSTO_MatIssMinusQty", a."INVSTO_PhyPlusQty", a."INVSTO_PhyMinQty", a."INVSTO_AvaiableStock"
        FROM "INV"."INV_Stock" a,
        "INV"."INV_Master_Item" b
        WHERE a."INVMI_Id" = b."INVMI_Id" AND a."MI_Id" = ' || p_MI_Id || v_dates || '
        ORDER BY a."INVSTO_PurchaseDate" DESC';
        
        RETURN QUERY EXECUTE v_Slqdymaic;
        
    ELSIF p_optionflag = 'Individual' THEN
        v_Slqdymaic := '
        SELECT DISTINCT b."INVMI_ItemName", b."INVMI_ItemCode", a."INVSTO_Id", a."INVMST_Id", a."INVMI_Id", a."INVSTO_BatchNo", a."INVSTO_PurchaseDate", a."INVSTO_PurOBQty", a."INVSTO_PurchaseRate", a."INVSTO_SalesRate", a."INVSTO_PurRetQty", a."INVSTO_SalesQty", a."INVSTO_SalesRetQty", a."INVSTO_ItemConQty", a."INVSTO_MatIssPlusQty", a."INVSTO_MatIssMinusQty", a."INVSTO_PhyPlusQty", a."INVSTO_PhyMinQty", a."INVSTO_AvaiableStock"
        FROM "INV"."INV_Stock" a,
        "INV"."INV_Master_Item" b
        WHERE a."INVMI_Id" = b."INVMI_Id" AND a."INVMI_Id" IN (' || p_INVMI_Ids || ') AND a."MI_Id" = ' || p_MI_Id || v_dates || '
        ORDER BY a."INVSTO_PurchaseDate" DESC';
        
        RETURN QUERY EXECUTE v_Slqdymaic;
        
    END IF;

    RETURN;

END;
$$;