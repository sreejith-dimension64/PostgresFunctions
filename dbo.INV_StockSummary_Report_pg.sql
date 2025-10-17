CREATE OR REPLACE FUNCTION "dbo"."INV_StockSummary_Report"(
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
    "INVMI_ItemCode" varchar,
    "INVMI_ItemName" varchar,
    "INVSTO_BatchNo" varchar,
    "INVSTO_SalesRate" numeric,
    "SalesQty" numeric,
    "INVSTO_AvaiableStock" numeric,
    "StockValue" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dates text;
    v_Slqdymaic text;
    v_IMFY_Id bigint;
BEGIN

    SELECT "IMFY_Id" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE CURRENT_TIMESTAMP BETWEEN "IMFY_fromdate" AND "IMFY_Todate";

    IF p_IMFY_FromDate != '' AND p_IMFY_ToDate != '' THEN
        v_dates := ' AND "INVSTO_PurchaseDate"::date >= TO_DATE(''' || p_IMFY_FromDate || ''', ''DD/MM/YYYY'') AND "INVSTO_PurchaseDate"::date <= TO_DATE(''' || p_IMFY_ToDate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MI"."INVMI_Id",
            "MI"."INVMI_ItemCode",
            "MI"."INVMI_ItemName",
            "INS"."INVSTO_BatchNo",
            SUM("INS"."INVSTO_SalesRate") AS "INVSTO_SalesRate",
            (SUM("INS"."INVSTO_SalesQty") - SUM("INS"."INVSTO_SalesRetQty")) AS "SalesQty",
            SUM("INS"."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
            CAST((SUM("INS"."INVSTO_SalesRate") * SUM("INS"."INVSTO_AvaiableStock")) AS decimal(32,2)) AS "StockValue"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        WHERE "INS"."IMFY_Id" = ' || v_IMFY_Id || ' AND "INS"."MI_Id" = ' || p_MI_Id || v_dates || '
        GROUP BY "MI"."INVMI_Id", "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "INS"."INVSTO_BatchNo"
        ORDER BY "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Item') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MI"."INVMI_Id",
            "MI"."INVMI_ItemCode",
            "MI"."INVMI_ItemName",
            "INS"."INVSTO_BatchNo",
            SUM("INS"."INVSTO_SalesRate") AS "INVSTO_SalesRate",
            (SUM("INS"."INVSTO_SalesQty") - SUM("INS"."INVSTO_SalesRetQty")) AS "SalesQty",
            SUM("INS"."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
            CAST((SUM("INS"."INVSTO_SalesRate") * SUM("INS"."INVSTO_AvaiableStock")) AS decimal(32,2)) AS "StockValue"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        WHERE "INS"."IMFY_Id" = ' || v_IMFY_Id || ' AND "INS"."MI_Id" = ' || p_MI_Id || ' AND "INS"."INVMI_Id" IN (' || p_INVMI_Ids || ') ' || v_dates || '
        GROUP BY "MI"."INVMI_Id", "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "INS"."INVSTO_BatchNo"
        ORDER BY "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Store') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MI"."INVMI_Id",
            "MI"."INVMI_ItemCode",
            "MI"."INVMI_ItemName",
            "INS"."INVSTO_BatchNo",
            SUM("INS"."INVSTO_SalesRate") AS "INVSTO_SalesRate",
            (SUM("INS"."INVSTO_SalesQty") - SUM("INS"."INVSTO_SalesRetQty")) AS "SalesQty",
            SUM("INS"."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
            CAST((SUM("INS"."INVSTO_SalesRate") * SUM("INS"."INVSTO_AvaiableStock")) AS decimal(32,2)) AS "StockValue"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        WHERE "INS"."IMFY_Id" = ' || v_IMFY_Id || ' AND "INS"."MI_Id" = ' || p_MI_Id || ' AND "INS"."INVMST_Id" IN (' || p_INVMST_Ids || ') ' || v_dates || '
        GROUP BY "MI"."INVMI_Id", "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "INS"."INVSTO_BatchNo"
        ORDER BY "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF (p_optionflag = 'Group') THEN
        v_Slqdymaic := '
        SELECT DISTINCT "MI"."INVMI_Id",
            "MI"."INVMI_ItemCode",
            "MI"."INVMI_ItemName",
            "INS"."INVSTO_BatchNo",
            SUM("INS"."INVSTO_SalesRate") AS "INVSTO_SalesRate",
            (SUM("INS"."INVSTO_SalesQty") - SUM("INS"."INVSTO_SalesRetQty")) AS "SalesQty",
            SUM("INS"."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
            CAST((SUM("INS"."INVSTO_SalesRate") * SUM("INS"."INVSTO_AvaiableStock")) AS decimal(32,2)) AS "StockValue"
        FROM "INV"."INV_Stock" "INS"
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."MI_Id" = "INS"."MI_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "INS"."INVMST_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "INS"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Group" "MG" ON "MI"."INVMG_Id" = "MG"."INVMG_Id"
        WHERE "INS"."IMFY_Id" = ' || v_IMFY_Id || ' AND "INS"."MI_Id" = ' || p_MI_Id || ' AND "INS"."INVMI_Id" IN 
        (SELECT DISTINCT b."INVMI_Id" FROM "INV"."INV_Master_Group" a
        INNER JOIN "INV"."INV_Master_Item" b ON a."INVMG_Id" = b."INVMG_Id" 
        WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."INVMG_Id" = ' || p_INVMG_Id || ') ' || v_dates || '
        GROUP BY "MI"."INVMI_Id", "MI"."INVMI_ItemCode", "MI"."INVMI_ItemName", "INS"."INVSTO_BatchNo", "MG"."INVMG_GroupName"
        ORDER BY "MG"."INVMG_GroupName"';

        RETURN QUERY EXECUTE v_Slqdymaic;

    END IF;

    RETURN;

END;
$$;