CREATE OR REPLACE FUNCTION "INV"."INV_Sales_Report" (
    "MI_Id" BIGINT, 
    "startdate" VARCHAR(10), 
    "enddate" VARCHAR(10),
    "INVMI_Ids" VARCHAR(100), 
    "INVMC_Ids" VARCHAR(100), 
    "optionflag" VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'and "INVMSL_SalesDate"::date between TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') and TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;
  
    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id","MSL"."INVMST_Id","MST"."INVMI_Id","MI"."INVMI_ItemName","MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName","INVMSL_SalesDate","MST"."INVTSL_SalesQty","MST"."INVTSL_SalesPrice","INVTSL_DiscountAmt","INVTSL_TaxAmt","INVTSL_Amount"

FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="MST"."INVMI_Id"

INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC"  ON "IMC"."INVMC_Id"="MSSC"."INVMC_Id"

WHERE "MSL"."INVMSL_ActiveFlg"=1 AND "MST"."INVTSL_ActiveFlg"=1 AND "MSL"."MI_Id"=' || "MI_Id"::VARCHAR || ' ' || "dates";

        EXECUTE "Slqdymaic";
    
    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id","MSL"."INVMST_Id","MST"."INVMI_Id","MI"."INVMI_ItemName","MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName","INVMSL_SalesDate","MST"."INVTSL_SalesQty","MST"."INVTSL_SalesPrice","INVTSL_DiscountAmt","INVTSL_TaxAmt","INVTSL_Amount"

FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="MST"."INVMI_Id"

INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC"  ON "IMC"."INVMC_Id"="MSSC"."INVMC_Id"

WHERE "MSL"."INVMSL_ActiveFlg"=1 AND "MST"."INVTSL_ActiveFlg"=1 AND "MST"."INVMI_Id" IN (' || "INVMI_Ids" || ') and "MSL"."MI_Id"=' || "MI_Id"::VARCHAR || ' ' || "dates";
 
        EXECUTE "Slqdymaic";
    
    ELSIF "optionflag" = 'Customer' THEN
        "Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id","MSL"."INVMST_Id","MST"."INVMI_Id","MI"."INVMI_ItemName","MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName","INVMSL_SalesDate","MST"."INVTSL_SalesQty","MST"."INVTSL_SalesPrice","INVTSL_DiscountAmt","INVTSL_TaxAmt","INVTSL_Amount"

FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="MST"."INVMI_Id"

INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC"  ON "IMC"."INVMC_Id"="MSSC"."INVMC_Id"

WHERE "MSSC"."INVMC_Id"="IMC"."INVMC_Id" AND "MSSC"."INVMC_Id" IN (' || "INVMC_Ids" || ') and "MSL"."MI_Id"=' || "MI_Id"::VARCHAR || ' ' || "dates";

        EXECUTE "Slqdymaic";
    
    ELSIF "optionflag" = 'Itm' THEN
        "Slqdymaic" := '
SELECT DISTINCT "MST"."INVMI_Id","MI"."INVMI_ItemName", SUM("INVTSL_SalesQty") AS "INVTSL_SalesQty",SUM("INVTSL_Amount") AS "INVTSL_Amount"
FROM "INV"."INV_T_Sales" "MST"
INNER JOIN "INV"."INV_M_Sales" "MSL" ON "MSL"."INVMSL_Id"="MST"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="MST"."INVMI_Id"
WHERE "MSL"."INVMSL_ActiveFlg"=1 AND "MST"."INVTSL_ActiveFlg"=1 AND "MSL"."MI_Id"=' || "MI_Id"::VARCHAR || ' 
GROUP BY "MST"."INVMI_Id","MI"."INVMI_ItemName"';

        EXECUTE "Slqdymaic";
    
    ELSIF "optionflag" = 'Cus' THEN
        IF "INVMC_Ids" IS NOT NULL AND "INVMC_Ids" != '' AND "INVMC_Ids" != '0' THEN
            "Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id","MSL"."INVMST_Id","MST"."INVMI_Id","MI"."INVMI_ItemName","MI"."INVMI_ItemCode",
"IMC"."INVMC_CustomerName","INVMSL_SalesDate","MST"."INVTSL_SalesQty","MST"."INVTSL_SalesPrice","INVTSL_DiscountAmt","INVTSL_TaxAmt","INVTSL_Amount"

FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="MST"."INVMI_Id"

INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC"  ON "IMC"."INVMC_Id"="MSSC"."INVMC_Id"

WHERE "MSL"."INVMSL_ActiveFlg"=1 AND "MST"."INVTSL_ActiveFlg"=1 AND "MSSC"."INVMC_Id" IN (' || "INVMC_Ids" || ') and "MSL"."MI_Id"=' || "MI_Id"::VARCHAR || ' ' || "dates";

            EXECUTE "Slqdymaic";
        ELSE
            "Slqdymaic" := '
SELECT DISTINCT "MSL"."INVMSL_Id","IMC"."INVMC_CustomerName",SUM("INVTSL_SalesQty") AS "INVTSL_SalesQty",SUM("INVTSL_Amount") AS "INVTSL_Amount"

FROM "INV"."INV_M_Sales" "MSL"
INNER JOIN "INV"."INV_T_Sales" "MST" ON "MST"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="MST"."INVMI_Id"

INNER JOIN "INV"."INV_M_Sales_Customer" "MSSC" ON "MSSC"."INVMSL_Id"="MSL"."INVMSL_Id"
INNER JOIN "INV"."INV_Master_Customer" "IMC"  ON "IMC"."INVMC_Id"="MSSC"."INVMC_Id"

WHERE "MSL"."INVMSL_ActiveFlg"=1 AND "MST"."INVTSL_ActiveFlg"=1 AND "MSL"."MI_Id"=' || "MI_Id"::VARCHAR || ' 
GROUP BY "MSL"."INVMSL_Id","IMC"."INVMC_CustomerName"';

            EXECUTE "Slqdymaic";
        END IF;
    END IF;

    RETURN;
END;
$$;