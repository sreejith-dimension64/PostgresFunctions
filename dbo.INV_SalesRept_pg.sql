CREATE OR REPLACE FUNCTION "dbo"."INV_SalesRept" (
    "p_MI_Id" VARCHAR(20),
    "p_startdate" VARCHAR(10),
    "p_enddate" VARCHAR(10),
    "p_INVMI_Ids" VARCHAR(100),
    "p_INVMC_Ids" VARCHAR(100),
    "p_optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMSL_Id" INTEGER,
    "INVMST_Id" INTEGER,
    "INVMI_Id" INTEGER,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" VARCHAR,
    "INVMC_CustomerName" TEXT,
    "INVMSL_SalesDate" TIMESTAMP,
    "INVTSL_SalesQty" NUMERIC,
    "INVTSL_SalesPrice" NUMERIC,
    "INVTSL_DiscountAmt" NUMERIC,
    "INVTSL_TaxAmt" NUMERIC,
    "INVTSL_Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'AND DATE("INVMSL_SalesDate") BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF ("p_optionflag" = 'All') THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 AND "MSL"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Itm' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MST"."INVMI_Id"::INTEGER, "MI"."INVMI_ItemName", NULL::INTEGER, NULL::TEXT, NULL::VARCHAR, NULL::TEXT, NULL::TIMESTAMP,
SUM("INVTSL_SalesQty")::NUMERIC AS "INVTSL_SalesQty", NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, SUM("INVTSL_Amount")::NUMERIC AS "INVTSL_Amount"
FROM "INV"."INV_T_Sales" "MST"
INNER JOIN "INV"."INV_M_Sales" "MSL" ON "MSL"."INVMSL_Id" = "MST"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 AND "MSL"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates" || '
GROUP BY "MST"."INVMI_Id", "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 AND "MST"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "MSL"."MI_Id" IN (' || "p_MI_Id" || ')' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Cus' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id", NULL::INTEGER, NULL::INTEGER, NULL::TEXT, NULL::VARCHAR, "IMC"."INVMC_CustomerName", NULL::TIMESTAMP,
SUM("INVTSL_SalesQty")::NUMERIC AS "INVTSL_SalesQty", NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, SUM("INVTSL_Amount")::NUMERIC AS "INVTSL_Amount"
FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 AND "MSL"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates" || '
GROUP BY "MSL"."INVMSL_Id", "IMC"."INVMC_CustomerName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Customer' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id", "MSL"."INVMST_Id", "MST"."INVMI_Id", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName", "INVMSL_SalesDate", "MST"."INVTSL_SalesQty", "MST"."INVTSL_SalesPrice", "INVTSL_DiscountAmt", "INVTSL_TaxAmt", "INVTSL_Amount"
FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "MST"."INVMI_Id"
INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id" = "MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC" ON "IMC"."INVMC_Id" = "MSSC"."INVMC_Id"
WHERE "MSL"."INVMSL_ActiveFlg" = 1 AND "MST"."INVTSL_ActiveFlg" = 1 AND "MSSC"."INVMC_Id" IN (' || "p_INVMC_Ids" || ') AND "MSL"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    END IF;

    RETURN;
END;
$$;