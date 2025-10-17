CREATE OR REPLACE FUNCTION "dbo"."INV_FY_StockReport" (
    p_MI_Id bigint,
    p_IMFY_FromDate varchar(10),
    p_IMFY_ToDate varchar(10),
    p_INVMI_Ids text,
    p_INVMST_Ids text,
    p_INVMG_Id text,
    p_optionflag varchar(100),
    p_overallflag varchar(100)
)
RETURNS TABLE (
    "INVSTO_Id" bigint,
    "INVMG_Id" bigint,
    "INVMG_GroupName" varchar,
    "INVMI_ItemName" varchar,
    "INVSTO_BatchNo" varchar,
    "INVSTO_PurchaseDate" timestamp,
    "INVSTO_PurchaseRate" numeric,
    "INVSTO_SalesRate" numeric,
    "SalesQty" numeric,
    "PurOBQty" numeric,
    "INVSTO_AvaiableStock" numeric,
    "INVSTO_CheckedOutQty" numeric,
    "INVSTO_DisposedQty" numeric,
    "obAmount" numeric,
    "INVSTO_ItemConQty" numeric,
    "INVSTO_PhyPlusQty" numeric,
    "INVSTO_PhyMinQty" numeric,
    "INVSTO_MatIssPlusQty" numeric,
    "INVSTO_MatIssMinusQty" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dates varchar(200);
    v_Slqdymaic text;
BEGIN

    IF p_IMFY_FromDate != '' AND p_IMFY_ToDate != '' THEN
        v_dates := ' AND DATE("INVSTO_PurchaseDate") >= TO_DATE(''' || p_IMFY_FromDate || ''', ''DD/MM/YYYY'') AND DATE("INVSTO_PurchaseDate") <= TO_DATE(''' || p_IMFY_ToDate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVSTO_Id", NULL::bigint AS "INVMG_Id", NULL::varchar AS "INVMG_GroupName", "MI"."INVMI_ItemName", "INVSTO_BatchNo", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", "INVSTO_SalesRate",
        ("INVSTO_SalesQty" - "INVSTO_SalesRetQty") AS "SalesQty",
        ("INVSTO_PurOBQty" + "INVSTO_PurRetQty") AS "PurOBQty",
        "INVSTO_AvaiableStock",
        "INVSTO_CheckedOutQty", "INVSTO_DisposedQty",
        ("INVSTO_PurchaseRate" * "INVSTO_AvaiableStock") AS "obAmount",
        "INVSTO_ItemConQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_MatIssPlusQty", "INVSTO_MatIssMinusQty"
        
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        LEFT JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        
        WHERE "INS"."MI_Id" = ' || p_MI_Id || ' ' || v_dates || '
        ORDER BY "MI"."INVMI_ItemName"';
        
        RAISE NOTICE '%', v_Slqdymaic;
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Item') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVSTO_Id", NULL::bigint AS "INVMG_Id", NULL::varchar AS "INVMG_GroupName", "MI"."INVMI_ItemName", "INVSTO_BatchNo", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", "INVSTO_SalesRate",
        ("INVSTO_SalesQty" - "INVSTO_SalesRetQty") AS "SalesQty", ("INVSTO_PurOBQty" + "INVSTO_PurRetQty") AS "PurOBQty",
        "INVSTO_AvaiableStock",
        "INVSTO_CheckedOutQty", "INVSTO_DisposedQty",
        ("INVSTO_PurchaseRate" * "INVSTO_AvaiableStock") AS "obAmount",
        "INVSTO_ItemConQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_MatIssPlusQty", "INVSTO_MatIssMinusQty"
        
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        
        WHERE "INS"."MI_Id" = ' || p_MI_Id || ' AND "INS"."INVMI_Id" IN (' || p_INVMI_Ids || ') ' || v_dates;
        
        RAISE NOTICE '%', v_Slqdymaic;
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Store') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVSTO_Id", NULL::bigint AS "INVMG_Id", NULL::varchar AS "INVMG_GroupName", "MI"."INVMI_ItemName", "INVSTO_BatchNo", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", "INVSTO_SalesRate",
        ("INVSTO_SalesQty" - "INVSTO_SalesRetQty") AS "SalesQty", ("INVSTO_PurOBQty" + "INVSTO_PurRetQty") AS "PurOBQty",
        "INVSTO_AvaiableStock",
        "INVSTO_CheckedOutQty", "INVSTO_DisposedQty",
        ("INVSTO_PurchaseRate" * "INVSTO_AvaiableStock") AS "obAmount",
        "INVSTO_ItemConQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_MatIssPlusQty", "INVSTO_MatIssMinusQty"
        
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        
        WHERE "INS"."MI_Id" = ' || p_MI_Id || ' AND "INS"."INVMST_Id" IN (' || p_INVMST_Ids || ') ' || v_dates;
        
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Group') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVSTO_Id", "MI"."INVMG_Id", "MG"."INVMG_GroupName", "MI"."INVMI_ItemName", "INVSTO_BatchNo", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", "INVSTO_SalesRate",
        ("INVSTO_SalesQty" - "INVSTO_SalesRetQty") AS "SalesQty", ("INVSTO_PurOBQty" + "INVSTO_PurRetQty") AS "PurOBQty",
        "INVSTO_AvaiableStock",
        "INVSTO_CheckedOutQty", "INVSTO_DisposedQty",
        ("INVSTO_PurchaseRate" * "INVSTO_AvaiableStock") AS "obAmount",
        "INVSTO_ItemConQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_MatIssPlusQty", "INVSTO_MatIssMinusQty"
        
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Group" "MG" ON "MI"."INVMG_Id" = "MG"."INVMG_Id"
        
        WHERE "INS"."MI_Id" = ' || p_MI_Id || ' AND "INS"."INVMI_Id" IN
        (SELECT DISTINCT b."INVMI_Id" FROM "INV"."INV_Master_Group" a,
        "INV"."INV_Master_Item" b
        WHERE a."INVMG_Id" = b."INVMG_Id" AND a."MI_Id" = ' || p_MI_Id || ' AND a."INVMG_Id" = ' || p_INVMG_Id || ')
        ' || v_dates;
        
        RAISE NOTICE '%', v_Slqdymaic;
        RETURN QUERY EXECUTE v_Slqdymaic;

    END IF;

    RETURN;

END;
$$;