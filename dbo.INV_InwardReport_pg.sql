CREATE OR REPLACE FUNCTION "dbo"."INV_InwardReport"(
    "MI_Id" TEXT,
    "Type" TEXT,
    "StartDate" VARCHAR(10),
    "EndDate" VARCHAR(10),
    "INVMI_Id" TEXT,
    "INVMS_Id" TEXT
)
RETURNS TABLE(
    "INVMGRN_GRNNo" VARCHAR,
    "GRNDate" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMS_SupplierName" VARCHAR,
    "INVMGRN_InvoiceNo" VARCHAR,
    "INVMS_GSTNo" VARCHAR,
    "INVMI_HSNCode" VARCHAR,
    "INVMUOM_UOMName" VARCHAR,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVTGRN_Qty" NUMERIC,
    "INVTGRN_PurchaseRate" NUMERIC,
    "INVTGRN_MRP" NUMERIC,
    "INVTGRN_DiscountAmt" NUMERIC,
    "INVTGRN_TaxAmt" NUMERIC,
    "INVTGRN_Amount" NUMERIC,
    "INVMPO_ReferenceNo" VARCHAR,
    "INVSPT_PaymentReference" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic TEXT;
    content TEXT;
BEGIN

    IF ("StartDate" != '' AND "EndDate" != '') THEN
        content := ' and "IMG"."INVMGRN_PurchaseDate"::date between ''' || "StartDate" || '''::date and ''' || "EndDate" || '''::date ';
    ELSE
        content := '';
    END IF;

    IF ("Type" = 'All') THEN
        sqldynamic := '
        SELECT DISTINCT "IMG"."INVMGRN_GRNNo", TO_CHAR("IMG"."INVMGRN_Date", ''DD/MM/YYYY'') AS "GRNDate",
        "IMI"."INVMI_ItemCode", "IMI"."INVMI_ItemName", "IMS"."INVMS_SupplierName", "IMG"."INVMGRN_InvoiceNo",
        "IMS"."INVMS_GSTNo", "IMI"."INVMI_HSNCode", "IMU"."INVMUOM_UOMName",
        (SELECT DISTINCT "IML"."INVMLO_LocationRoomName" 
         FROM "INV"."INV_AssetTag_CheckOut" "AC" 
         INNER JOIN "INV"."INV_Master_Location" "IML" ON "AC"."INVMLO_Id"="IML"."INVMLO_Id" 
         WHERE "AC"."INVMI_Id"="IMI"."INVMI_Id" LIMIT 1) AS "INVMLO_LocationRoomName",
        "ITG"."INVTGRN_Qty", "ITG"."INVTGRN_PurchaseRate", "ITG"."INVTGRN_MRP", "ITG"."INVTGRN_DiscountAmt",
        "ITG"."INVTGRN_TaxAmt", "ITG"."INVTGRN_Amount", "IMPO"."INVMPO_ReferenceNo",
        (SELECT DISTINCT "ISP"."INVSPT_PaymentReference" 
         FROM "INV"."INV_Supplier_Payment" "ISP" 
         INNER JOIN "INV"."INV_Supplier_Payment_GRN" "ISPG" ON "ISPG"."INVSPT_Id"="ISP"."INVSPT_Id" 
         WHERE "ISPG"."INVSPTGRN_ActiveFlg"=1 AND "ISP"."INVSPT_ActiveFlg"=1 
         AND "ISPG"."INVMGRN_Id"="IMG"."INVMGRN_Id" AND "ISP"."INVMS_Id"="IMS"."INVMS_Id") AS "INVSPT_PaymentReference"
        FROM "INV"."INV_Master_Item" "IMI"
        INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id"="IMI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id"="ITG"."INVMUOM_Id" AND "IMI"."MI_Id"="IMU"."MI_Id"
        INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id"="ITG"."INVMGRN_Id" AND "IMG"."MI_Id"="IMI"."MI_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "IMS" ON "IMS"."INVMS_Id"="IMG"."INVMS_Id" AND "IMS"."MI_Id" IN (' || "MI_Id" || ')
        LEFT JOIN "INV"."INV_T_PurchaseOrder_Approval" "ITPA" ON "ITPA"."INVMI_Id"="ITG"."INVMI_Id" AND "ITPA"."INVMUOM_Id"="ITG"."INVMUOM_Id" AND "ITPA"."INVTPOAPP_RejectFlg"=0 AND "ITPA"."INVTPOAPP_ActiveFlg"=1
        LEFT JOIN "INV"."INV_M_PurchaseOrder_Approval" "IMPA" ON "IMPA"."INVMPOAPP_Id"="ITPA"."INVMPOAPP_Id" AND "IMPA"."INVMPOAPP_ActiveFlg"=1
        LEFT JOIN "INV"."INV_M_PurchaseOrder" "IMPO" ON "IMPO"."INVMS_Id"="IMS"."INVMS_Id" AND "IMPO"."INVMPO_Id"="IMPA"."INVMPO_Id" AND "IMPO"."INVMPO_ActiveFlg"=1 AND "IMPO"."INVMPO_FinalProcessFlag"=1
        WHERE "IMI"."INVMI_ActiveFlg"=1 AND "IMG"."INVMGRN_ActiveFlg"=1 AND "ITG"."INVTGRN_ActiveFlg"=1 
        AND "IMS"."INVMS_ActiveFlg"=1 AND "IMI"."MI_Id" IN (' || "MI_Id" || ') AND "IMG"."MI_Id" IN (' || "MI_Id" || ') ' || content;

    ELSIF ("Type" = 'Item-Wise') THEN
        sqldynamic := '
        SELECT DISTINCT "IMG"."INVMGRN_GRNNo", TO_CHAR("IMG"."INVMGRN_Date", ''DD/MM/YYYY'') AS "GRNDate",
        "IMI"."INVMI_ItemCode", "IMI"."INVMI_ItemName", "IMS"."INVMS_SupplierName", "IMG"."INVMGRN_InvoiceNo",
        "IMS"."INVMS_GSTNo", "IMI"."INVMI_HSNCode", "IMU"."INVMUOM_UOMName",
        (SELECT DISTINCT "IML"."INVMLO_LocationRoomName" 
         FROM "INV"."INV_AssetTag_CheckOut" "AC" 
         INNER JOIN "INV"."INV_Master_Location" "IML" ON "AC"."INVMLO_Id"="IML"."INVMLO_Id" 
         WHERE "AC"."INVMI_Id"="IMI"."INVMI_Id" LIMIT 1) AS "INVMLO_LocationRoomName",
        "ITG"."INVTGRN_Qty", "ITG"."INVTGRN_PurchaseRate", "ITG"."INVTGRN_MRP", "ITG"."INVTGRN_DiscountAmt",
        "ITG"."INVTGRN_TaxAmt", "ITG"."INVTGRN_Amount", "IMPO"."INVMPO_ReferenceNo",
        (SELECT DISTINCT "ISP"."INVSPT_PaymentReference" 
         FROM "INV"."INV_Supplier_Payment" "ISP" 
         INNER JOIN "INV"."INV_Supplier_Payment_GRN" "ISPG" ON "ISPG"."INVSPT_Id"="ISP"."INVSPT_Id" 
         WHERE "ISPG"."INVSPTGRN_ActiveFlg"=1 AND "ISP"."INVSPT_ActiveFlg"=1 
         AND "ISPG"."INVMGRN_Id"="IMG"."INVMGRN_Id" AND "ISP"."INVMS_Id"="IMS"."INVMS_Id") AS "INVSPT_PaymentReference"
        FROM "INV"."INV_Master_Item" "IMI"
        INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id"="IMI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id"="ITG"."INVMUOM_Id" AND "IMI"."MI_Id"="IMU"."MI_Id"
        INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id"="ITG"."INVMGRN_Id" AND "IMG"."MI_Id"="IMI"."MI_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "IMS" ON "IMS"."INVMS_Id"="IMG"."INVMS_Id" AND "IMS"."MI_Id" IN (' || "MI_Id" || ')
        LEFT JOIN "INV"."INV_T_PurchaseOrder_Approval" "ITPA" ON "ITPA"."INVMI_Id"="ITG"."INVMI_Id" AND "ITPA"."INVMUOM_Id"="ITG"."INVMUOM_Id" AND "ITPA"."INVTPOAPP_RejectFlg"=0 AND "ITPA"."INVTPOAPP_ActiveFlg"=1
        LEFT JOIN "INV"."INV_M_PurchaseOrder_Approval" "IMPA" ON "IMPA"."INVMPOAPP_Id"="ITPA"."INVMPOAPP_Id" AND "IMPA"."INVMPOAPP_ActiveFlg"=1 AND "IMPA"."MI_Id" IN (' || "MI_Id" || ')
        LEFT JOIN "INV"."INV_M_PurchaseOrder" "IMPO" ON "IMPO"."INVMS_Id"="IMS"."INVMS_Id" AND "IMPO"."INVMPO_Id"="IMPA"."INVMPO_Id" AND "IMPO"."INVMPO_ActiveFlg"=1 AND "IMPO"."INVMPO_FinalProcessFlag"=1
        WHERE "IMI"."INVMI_ActiveFlg"=1 AND "IMG"."INVMGRN_ActiveFlg"=1 AND "ITG"."INVTGRN_ActiveFlg"=1 
        AND "IMS"."INVMS_ActiveFlg"=1 AND "IMI"."MI_Id" IN (' || "MI_Id" || ') AND "IMG"."MI_Id" IN (' || "MI_Id" || ') 
        AND "IMI"."INVMI_Id" IN (' || "INVMI_Id" || ') ' || content;

    ELSIF ("Type" = 'Supplier') THEN
        sqldynamic := '
        SELECT DISTINCT "IMG"."INVMGRN_GRNNo", TO_CHAR("IMG"."INVMGRN_Date", ''DD/MM/YYYY'') AS "GRNDate",
        "IMI"."INVMI_ItemCode", "IMI"."INVMI_ItemName", "IMS"."INVMS_SupplierName", "IMG"."INVMGRN_InvoiceNo",
        "IMS"."INVMS_GSTNo", "IMI"."INVMI_HSNCode", "IMU"."INVMUOM_UOMName",
        (SELECT DISTINCT "IML"."INVMLO_LocationRoomName" 
         FROM "INV"."INV_AssetTag_CheckOut" "AC" 
         INNER JOIN "INV"."INV_Master_Location" "IML" ON "AC"."INVMLO_Id"="IML"."INVMLO_Id" 
         WHERE "AC"."INVMI_Id"="IMI"."INVMI_Id" LIMIT 1) AS "INVMLO_LocationRoomName",
        "ITG"."INVTGRN_Qty", "ITG"."INVTGRN_PurchaseRate", "ITG"."INVTGRN_MRP", "ITG"."INVTGRN_DiscountAmt",
        "ITG"."INVTGRN_TaxAmt", "ITG"."INVTGRN_Amount", "IMPO"."INVMPO_ReferenceNo",
        (SELECT DISTINCT "ISP"."INVSPT_PaymentReference" 
         FROM "INV"."INV_Supplier_Payment" "ISP" 
         INNER JOIN "INV"."INV_Supplier_Payment_GRN" "ISPG" ON "ISPG"."INVSPT_Id"="ISP"."INVSPT_Id" 
         WHERE "ISPG"."INVSPTGRN_ActiveFlg"=1 AND "ISP"."INVSPT_ActiveFlg"=1 
         AND "ISPG"."INVMGRN_Id"="IMG"."INVMGRN_Id" AND "ISP"."INVMS_Id"="IMS"."INVMS_Id") AS "INVSPT_PaymentReference"
        FROM "INV"."INV_Master_Item" "IMI"
        INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id"="IMI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id"="ITG"."INVMUOM_Id" AND "IMI"."MI_Id"="IMU"."MI_Id"
        INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id"="ITG"."INVMGRN_Id" AND "IMG"."MI_Id"="IMI"."MI_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "IMS" ON "IMS"."INVMS_Id"="IMG"."INVMS_Id" AND "IMS"."MI_Id" IN (' || "MI_Id" || ') AND "IMS"."INVMS_Id" IN (' || "INVMS_Id" || ')
        LEFT JOIN "INV"."INV_T_PurchaseOrder_Approval" "ITPA" ON "ITPA"."INVMI_Id"="ITG"."INVMI_Id" AND "ITPA"."INVMUOM_Id"="ITG"."INVMUOM_Id" AND "ITPA"."INVTPOAPP_RejectFlg"=0 AND "ITPA"."INVTPOAPP_ActiveFlg"=1
        LEFT JOIN "INV"."INV_M_PurchaseOrder_Approval" "IMPA" ON "IMPA"."INVMPOAPP_Id"="ITPA"."INVMPOAPP_Id" AND "IMPA"."INVMPOAPP_ActiveFlg"=1 AND "IMS"."INVMS_Id" IN (' || "INVMS_Id" || ')
        LEFT JOIN "INV"."INV_M_PurchaseOrder" "IMPO" ON "IMPO"."INVMS_Id"="IMS"."INVMS_Id" AND "IMPO"."INVMPO_Id"="IMPA"."INVMPO_Id" AND "IMPO"."INVMPO_ActiveFlg"=1 AND "IMPO"."INVMPO_FinalProcessFlag"=1
        WHERE "IMI"."INVMI_ActiveFlg"=1 AND "IMG"."INVMGRN_ActiveFlg"=1 AND "ITG"."INVTGRN_ActiveFlg"=1 
        AND "IMS"."INVMS_ActiveFlg"=1 AND "IMI"."MI_Id" IN (' || "MI_Id" || ') AND "IMG"."MI_Id" IN (' || "MI_Id" || ') ' || content;

    END IF;

    RETURN QUERY EXECUTE sqldynamic;

END;
$$;