CREATE OR REPLACE FUNCTION "dbo"."AT_AssetsTransferDetails"(p_MI_Id BIGINT)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMLOFrom_Id" BIGINT,
    "FromLocName" VARCHAR,
    "INVMLOTo_Id" BIGINT,
    "ToLcationName" VARCHAR,
    "INVSTO_SalesRate" NUMERIC,
    "INVATR_CheckoutDate" TIMESTAMP,
    "INVATR_CheckOutQty" NUMERIC,
    "INVATR_CheckOutRemarks" TEXT,
    "INVATR_ActiveFlg" BOOLEAN,
    "INVATR_ReceivedBy" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "AT1"."INVMI_Id",
        (SELECT DISTINCT "IT1"."INVMI_ItemName" 
         FROM "INV"."INV_Master_Item" "IT1" 
         WHERE "AT1"."INVMI_Id" = "IT1"."INVMI_Id") AS "INVMI_ItemName",
        "AT1"."INVMLOFrom_Id",
        "ML1"."INVMLO_LocationRoomName" AS "FromLocName",
        "AT1"."INVMLOTo_Id",
        (SELECT DISTINCT "INVMLO_LocationRoomName" 
         FROM "INV"."INV_Master_Location" "ML2" 
         WHERE "ML2"."INVMLO_Id" = "AT1"."INVMLOTo_Id") AS "ToLcationName",
        "AT1"."INVSTO_SalesRate",
        "AT1"."INVATR_CheckoutDate",
        "AT1"."INVATR_CheckOutQty",
        "AT1"."INVATR_CheckOutRemarks",
        "AT1"."INVATR_ActiveFlg",
        "AT1"."INVATR_ReceivedBy"
    FROM "INV"."INV_Asset_Transfer" "AT1"
    INNER JOIN "INV"."INV_Master_Location" "ML1" ON "AT1"."INVMLOFrom_Id" = "ML1"."INVMLO_Id"
    WHERE "AT1"."MI_Id" = p_MI_Id AND "AT1"."INVATR_ActiveFlg" = TRUE;
END;
$$;