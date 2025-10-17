CREATE OR REPLACE FUNCTION "dbo"."INV_StockRegister_Report" (
    p_MI_Id bigint,
    p_startdate varchar(10),
    p_enddate varchar(10),
    p_INVMI_Ids varchar(100),
    p_optionflag varchar(10)
)
RETURNS TABLE (
    "INVSTO_PurchaseDate" varchar(10),
    "INVMI_ItemName" text,
    "INVMI_ItemCode" text,
    "INVMI_Id" bigint,
    "INVSTO_BatchNo" text,
    "INVSTO_PurOBQty" numeric,
    "INVSTO_PurchaseRate" numeric,
    "Value" numeric,
    "INVSTO_SalesRate" numeric,
    "INVSTO_SalesQty" numeric,
    "INVSTO_AvaiableStock" numeric,
    "TotalValue" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
    v_dates text;
BEGIN

    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := ' AND "INVSTO_PurchaseDate"::date BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
    
        v_Slqdymaic := '
        SELECT TO_CHAR("INVSTO_PurchaseDate", ''DD-MM-YYYY'') AS "INVSTO_PurchaseDate",
               "IMI"."INVMI_ItemName",
               "IMI"."INVMI_ItemCode",
               "ST"."INVMI_Id",
               "ST"."INVSTO_BatchNo",
               "ST"."INVSTO_PurOBQty",
               "ST"."INVSTO_PurchaseRate",
               ("ST"."INVSTO_PurOBQty" * "ST"."INVSTO_PurchaseRate") AS "Value",
               "ST"."INVSTO_SalesRate",
               ("ST"."INVSTO_SalesQty" - "ST"."INVSTO_SalesRetQty") AS "INVSTO_SalesQty",
               "ST"."INVSTO_AvaiableStock",
               ("ST"."INVSTO_AvaiableStock" * "ST"."INVSTO_SalesQty") AS "TotalValue"
        FROM "INV"."INV_Stock" "ST"
        INNER JOIN "INV"."INV_Master_Item" "IMI" ON "ST"."INVMI_Id" = "IMI"."INVMI_Id"
        WHERE "ST"."MI_Id" = ' || p_MI_Id || v_dates || '
        ORDER BY "ST"."INVSTO_PurchaseDate" DESC
        LIMIT 100';
    
    ELSIF p_optionflag = 'Individual' THEN
    
        v_Slqdymaic := '
        SELECT TO_CHAR("INVSTO_PurchaseDate", ''DD-MM-YYYY'') AS "INVSTO_PurchaseDate",
               "IMI"."INVMI_ItemName",
               "IMI"."INVMI_ItemCode",
               "ST"."INVMI_Id",
               "ST"."INVSTO_BatchNo",
               "ST"."INVSTO_PurOBQty",
               "ST"."INVSTO_PurchaseRate",
               ("ST"."INVSTO_PurOBQty" * "ST"."INVSTO_PurchaseRate") AS "Value",
               "ST"."INVSTO_SalesRate",
               ("ST"."INVSTO_SalesQty" - "ST"."INVSTO_SalesRetQty") AS "INVSTO_SalesQty",
               "ST"."INVSTO_AvaiableStock",
               ("ST"."INVSTO_AvaiableStock" * "ST"."INVSTO_SalesQty") AS "TotalValue"
        FROM "INV"."INV_Stock" "ST"
        INNER JOIN "INV"."INV_Master_Item" "IMI" ON "ST"."INVMI_Id" = "IMI"."INVMI_Id"
        WHERE "ST"."INVMI_Id" IN (' || p_INVMI_Ids || ') AND "ST"."MI_Id" = ' || p_MI_Id || v_dates || '
        ORDER BY "ST"."INVSTO_PurchaseDate" DESC
        LIMIT 100';
    
    END IF;

    RETURN QUERY EXECUTE v_Slqdymaic;

END;
$$;