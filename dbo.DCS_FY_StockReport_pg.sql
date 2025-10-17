CREATE OR REPLACE FUNCTION "dbo"."DCS_FY_StockReport"(
    p_MI_Id bigint,
    p_IMFY_FromDate varchar(10),
    p_IMFY_ToDate varchar(10),
    p_INVMP_Id text
)
RETURNS TABLE(
    "INVMP_Id" bigint,
    "INVMP_ProductName" varchar,
    "INVSTO_PurchaseRate" numeric,
    "INVSTO_SalesRate" numeric,
    "INVSTO_PurchaseDate" timestamp,
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
    v_dates text;
    v_Slqdymaic text;
    v_IMFY_Id bigint;
BEGIN

    SELECT "IMFY_Id" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE CURRENT_TIMESTAMP BETWEEN "IMFY_fromdate" AND "IMFY_Todate";

    IF p_IMFY_FromDate != '' AND p_IMFY_ToDate != '' THEN
        v_dates := ' AND "INVSTO_PurchaseDate"::date >= TO_DATE(''' || p_IMFY_FromDate || ''', ''DD/MM/YYYY'') 
                     AND "INVSTO_PurchaseDate"::date <= TO_DATE(''' || p_IMFY_ToDate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF p_INVMP_Id = '0' THEN
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVMP_Id", "MI"."INVMP_ProductName",
        ("INVSTO_PurchaseRate")::"INVSTO_PurchaseRate",
        ("INVSTO_SalesRate")::"INVSTO_SalesRate",
        "INVSTO_PurchaseDate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",
        (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") AS "INVSTO_CheckedOutQty",
        SUM("INVSTO_DisposedQty") AS "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") AS "INVSTO_ItemConQty",
        SUM("INVSTO_PhyPlusQty") AS "INVSTO_PhyPlusQty",
        SUM("INVSTO_PhyMinQty") AS "INVSTO_PhyMinQty",
        SUM("INVSTO_MatIssPlusQty") AS "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") AS "INVSTO_MatIssMinusQty"
        FROM "DCS"."DCS_Stock" "INS"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" 
            AND "IMS"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Product" "MI" ON "MI"."INVMP_Id"="INS"."INVMP_Id"
        WHERE "INS"."MI_Id"=' || p_MI_Id || ' ' || v_dates || '
        GROUP BY "INS"."INVMP_Id", "MI"."INVMP_ProductName", 
            "INVSTO_PurchaseRate", "INVSTO_SalesRate", "INVSTO_PurchaseDate"
        ORDER BY "MI"."INVMP_ProductName"';
    ELSE
        v_Slqdymaic := '
        SELECT DISTINCT "INS"."INVMP_Id", "MI"."INVMP_ProductName",
        ("INVSTO_PurchaseRate")::"INVSTO_PurchaseRate",
        ("INVSTO_SalesRate")::"INVSTO_SalesRate",
        "INVSTO_PurchaseDate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",
        (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") AS "INVSTO_CheckedOutQty",
        SUM("INVSTO_DisposedQty") AS "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") AS "INVSTO_ItemConQty",
        SUM("INVSTO_PhyPlusQty") AS "INVSTO_PhyPlusQty",
        SUM("INVSTO_PhyMinQty") AS "INVSTO_PhyMinQty",
        SUM("INVSTO_MatIssPlusQty") AS "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") AS "INVSTO_MatIssMinusQty"
        FROM "DCS"."DCS_Stock" "INS"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" 
            AND "IMS"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "INV"."INV_Master_Product" "MI" ON "MI"."INVMP_Id"="INS"."INVMP_Id"
        WHERE "INS"."MI_Id"=' || p_MI_Id || ' AND "INS"."INVMP_Id" IN (' || p_INVMP_Id || ') ' || v_dates || '
        GROUP BY "INS"."INVMP_Id", "MI"."INVMP_ProductName", 
            "INVSTO_PurchaseRate", "INVSTO_SalesRate", "INVSTO_PurchaseDate"
        ORDER BY "MI"."INVMP_ProductName"';
    END IF;

    RETURN QUERY EXECUTE v_Slqdymaic;

END;
$$;