CREATE OR REPLACE FUNCTION "dbo"."INV_SALES_FOR_INVOICE_Report"(
    "@MI_Id" TEXT,
    "@FromDate" VARCHAR(30),
    "@ToDate" VARCHAR(30)
)
RETURNS TABLE(
    "INVMSL_SalesNo" VARCHAR,
    "INVMSL_SalesDate" TIMESTAMP,
    "INVMSL_TotTaxAmt" NUMERIC,
    "INVMSL_TotDiscount" NUMERIC,
    "INVMSL_TotalAmount" NUMERIC,
    "INVMSL_SalesValue" NUMERIC,
    "INVMSL_Id" BIGINT,
    "INVMSL_PaidFlg" BOOLEAN,
    "INVMST_Id" BIGINT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMMCLT_Address" TEXT,
    "ISMMCLT_Code" VARCHAR,
    "ISMMCLT_Desc" TEXT,
    "INVMS_StoreName" VARCHAR,
    "INVMSL_Remarks" TEXT,
    "INVTSL_SalesQty" NUMERIC,
    "INVTSL_SalesPrice" NUMERIC,
    "INVTSL_DiscountAmt" NUMERIC,
    "INVTSL_TaxAmt" NUMERIC,
    "INVTSL_Amount" NUMERIC,
    "INVMI_ItemName" VARCHAR,
    "INVMUOM_UOMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SqlDynamic" TEXT;
    "v_Content" TEXT;
BEGIN

    IF ("@FromDate" != '' AND "@ToDate" != '') THEN
        "v_Content" := ' and A."INVMSL_SalesDate" between  ''' || "@FromDate" || ''' and ''' || "@ToDate" || ''' ';
    ELSE
        "v_Content" := '';
    END IF;

    "v_SqlDynamic" := '
    SELECT DISTINCT A."INVMSL_SalesNo",A."INVMSL_SalesDate",A."INVMSL_TotTaxAmt",A."INVMSL_TotDiscount",A."INVMSL_TotalAmount",A."INVMSL_SalesValue",A."INVMSL_Id",A."INVMSL_PaidFlg",A."INVMST_Id",c."ISMMCLT_Id",c."ISMMCLT_ClientName",C."ISMMCLT_Address",c."ISMMCLT_Code",c."ISMMCLT_Desc",D."INVMS_StoreName",A."INVMSL_Remarks", 
    TS."INVTSL_SalesQty",TS."INVTSL_SalesPrice",TS."INVTSL_DiscountAmt",TS."INVTSL_TaxAmt",TS."INVTSL_Amount",MI."INVMI_ItemName",UOM."INVMUOM_UOMName"
    FROM "INV"."INV_M_Sales" AS A
    INNER JOIN "INV"."INV_M_Sales_Client" AS B ON A."INVMSL_Id"=B."INVMSL_Id"
    INNER JOIN "ISM_Master_Client" AS C ON C."ISMMCLT_Id"=B."ISMMCLT_Id" and C."MI_Id" IN (' || "@MI_Id" || ')
    INNER JOIN "INV"."INV_Master_Store" AS D ON D."INVMST_Id"=A."INVMST_Id" and D."MI_Id" IN (' || "@MI_Id" || ')
    INNER JOIN "INV"."INV_T_Sales" TS ON TS."INVMSL_Id"=A."INVMSL_Id" 
    INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id"=TS."INVMI_Id" and MI."MI_Id" IN (' || "@MI_Id" || ')
    INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id"=TS."INVMUOM_Id" and UOM."MI_Id" IN (' || "@MI_Id" || ')
    WHERE A."INVMSL_ActiveFlg"=1 AND B."INVMSLCL_ActiveFlg"=1 AND A."MI_Id" IN (' || "@MI_Id" || ') ' || "v_Content";

    RETURN QUERY EXECUTE "v_SqlDynamic";

END;
$$;