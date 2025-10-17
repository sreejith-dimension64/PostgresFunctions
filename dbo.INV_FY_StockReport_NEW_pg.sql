CREATE OR REPLACE FUNCTION "dbo"."INV_FY_StockReport_NEW"(
    p_MI_Id bigint,
    p_IMFY_FromDate varchar(10),
    p_IMFY_ToDate varchar(10),
    p_INVMI_Ids text,
    p_INVMST_Ids text,
    p_INVMG_Id text,
    p_optionflag varchar(100)
)
RETURNS TABLE(
    "INVMI_Id" bigint,
    "INVMG_Id" bigint,
    "INVMG_GroupName" varchar,
    "INVMI_ItemName" varchar,
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
    v_IMFY_Id bigint;
BEGIN

    SELECT "IMFY_Id" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE CURRENT_TIMESTAMP BETWEEN "IMFY_fromdate" AND "IMFY_Todate";

    IF COALESCE(p_IMFY_FromDate, '') != '' AND COALESCE(p_IMFY_ToDate, '') != '' THEN
        v_dates := ' AND CAST("INVSTO_PurchaseDate" AS DATE) >= TO_DATE(''' || p_IMFY_FromDate || ''', ''DD/MM/YYYY'') AND CAST("INVSTO_PurchaseDate" AS DATE) <= TO_DATE(''' || p_IMFY_ToDate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MI"."INVMI_Id", NULL::bigint AS "INVMG_Id", NULL::varchar AS "INVMG_GroupName", "MI"."INVMI_ItemName", 
        SUM("INVSTO_PurchaseRate") AS "INVSTO_PurchaseRate", SUM("INVSTO_SalesRate") AS "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",
        (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") AS "INVSTO_CheckedOutQty",
        SUM("INVSTO_DisposedQty") AS "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_AvaiableStock")) AS "obAmount",
        SUM("INVSTO_ItemConQty") AS "INVSTO_ItemConQty",
        SUM("INVSTO_PhyPlusQty") AS "INVSTO_PhyPlusQty", SUM("INVSTO_PhyMinQty") AS "INVSTO_PhyMinQty", 
        SUM("INVSTO_MatIssPlusQty") AS "INVSTO_MatIssPlusQty", SUM("INVSTO_MatIssMinusQty") AS "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id"="INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" AND "IMS"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."IMFY_Id"=' || v_IMFY_Id || ' AND "INS"."MI_Id"=' || p_MI_Id || v_dates || '
        GROUP BY "INS"."INVMI_Id", "MI"."INVMI_ItemName"
        ORDER BY "MI"."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Item') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVMI_Id", NULL::bigint AS "INVMG_Id", NULL::varchar AS "INVMG_GroupName", "MI"."INVMI_ItemName", 
        SUM("INVSTO_PurchaseRate") AS "INVSTO_PurchaseRate", SUM("INVSTO_SalesRate") AS "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty", (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") AS "INVSTO_CheckedOutQty", SUM("INVSTO_DisposedQty") AS "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_AvaiableStock")) AS "obAmount",
        SUM("INVSTO_ItemConQty") AS "INVSTO_ItemConQty", SUM("INVSTO_PhyPlusQty") AS "INVSTO_PhyPlusQty", 
        SUM("INVSTO_PhyMinQty") AS "INVSTO_PhyMinQty", SUM("INVSTO_MatIssPlusQty") AS "INVSTO_MatIssPlusQty", 
        SUM("INVSTO_MatIssMinusQty") AS "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id"="INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" AND "IMS"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."IMFY_Id"=' || v_IMFY_Id || ' AND "INS"."MI_Id"=' || p_MI_Id || ' AND "INS"."INVMI_Id" IN (' || p_INVMI_Ids || ') ' || v_dates || '
        GROUP BY "INS"."INVMI_Id", "MI"."INVMI_ItemName"
        ORDER BY "MI"."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Store') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVMI_Id", NULL::bigint AS "INVMG_Id", NULL::varchar AS "INVMG_GroupName", "MI"."INVMI_ItemName", 
        SUM("INVSTO_PurchaseRate") AS "INVSTO_PurchaseRate", SUM("INVSTO_SalesRate") AS "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty", (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") AS "INVSTO_CheckedOutQty", SUM("INVSTO_DisposedQty") AS "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_AvaiableStock")) AS "obAmount",
        SUM("INVSTO_ItemConQty") AS "INVSTO_ItemConQty", SUM("INVSTO_PhyPlusQty") AS "INVSTO_PhyPlusQty", 
        SUM("INVSTO_PhyMinQty") AS "INVSTO_PhyMinQty", SUM("INVSTO_MatIssPlusQty") AS "INVSTO_MatIssPlusQty", 
        SUM("INVSTO_MatIssMinusQty") AS "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id"="INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" AND "IMS"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."IMFY_Id"=' || v_IMFY_Id || ' AND "INS"."MI_Id"=' || p_MI_Id || ' AND "INS"."INVMST_Id" IN (' || p_INVMST_Ids || ') ' || v_dates || '
        GROUP BY "INS"."INVMI_Id", "MI"."INVMI_ItemName"
        ORDER BY "MI"."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Group') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MI"."INVMI_Id", "MI"."INVMG_Id", "MG"."INVMG_GroupName", "MI"."INVMI_ItemName", 
        SUM("INVSTO_PurchaseRate") AS "INVSTO_PurchaseRate", SUM("INVSTO_SalesRate") AS "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty", (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") AS "INVSTO_CheckedOutQty", SUM("INVSTO_DisposedQty") AS "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_AvaiableStock")) AS "obAmount",
        SUM("INVSTO_ItemConQty") AS "INVSTO_ItemConQty", SUM("INVSTO_PhyPlusQty") AS "INVSTO_PhyPlusQty", 
        SUM("INVSTO_PhyMinQty") AS "INVSTO_PhyMinQty", SUM("INVSTO_MatIssPlusQty") AS "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") AS "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id"="INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" AND "IMS"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Group" "MG" ON "MI"."INVMG_Id"="MG"."INVMG_Id"
        WHERE "INS"."IMFY_Id"=' || v_IMFY_Id || ' AND "INS"."MI_Id"=' || p_MI_Id || ' AND "INS"."INVMI_Id" IN 
        (SELECT DISTINCT b."INVMI_Id" FROM "INV"."INV_Master_Group" a
        INNER JOIN "INV"."INV_Master_Item" b ON a."INVMG_Id"=b."INVMG_Id"
        WHERE a."MI_Id"=' || p_MI_Id || ' AND a."INVMG_Id"=' || p_INVMG_Id || ')
        ' || v_dates || '
        GROUP BY "MI"."INVMG_Id", "MG"."INVMG_GroupName", "INS"."INVMI_Id", "MI"."INVMI_ItemName"
        ORDER BY "MG"."INVMG_GroupName"';
        
        RETURN QUERY EXECUTE v_Slqdymaic;
    END IF;

    RETURN;
END;
$$;