CREATE OR REPLACE FUNCTION "dbo"."AssetTag_TransferDetails"(p_MI_Id BIGINT)
RETURNS TABLE(
    "INVATTR_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVAAT_AssetId" VARCHAR,
    "INVAAT_AssetDescription" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMLOFrom_Id" BIGINT,
    "FromLocName" VARCHAR,
    "INVMLOTo_Id" BIGINT,
    "ToLcationName" VARCHAR,
    "INVATTR_CheckoutDate" TIMESTAMP,
    "INVATTR_CheckOutQty" NUMERIC,
    "INVATTR_CheckOutRemarks" TEXT,
    "INVATTR_ActiveFlg" BOOLEAN,
    "INVATTR_ReceivedBy" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "AT1"."INVATTR_Id",
        "AT1"."INVMI_Id",
        "ATG"."INVAAT_AssetId",
        "ATG"."INVAAT_AssetDescription",
        (SELECT DISTINCT "IT1"."INVMI_ItemName" 
         FROM "INV"."INV_Master_Item" "IT1" 
         WHERE "AT1"."INVMI_Id" = "IT1"."INVMI_Id") AS "INVMI_ItemName",
        "AT1"."INVMLOFrom_Id",
        "ML1"."INVMLO_LocationRoomName" AS "FromLocName",
        "AT1"."INVMLOTo_Id",
        (SELECT DISTINCT "INVMLO_LocationRoomName" 
         FROM "INV"."INV_Master_Location" "ML2" 
         WHERE "ML2"."INVMLO_Id" = "AT1"."INVMLOTo_Id") AS "ToLcationName",
        "AT1"."INVATTR_CheckoutDate",
        "AT1"."INVATTR_CheckOutQty",
        "AT1"."INVATTR_CheckOutRemarks",
        "AT1"."INVATTR_ActiveFlg",
        "AT1"."INVATTR_ReceivedBy"
    FROM "INV"."INV_AssetTag_Transfer" "AT1"
    INNER JOIN "INV"."INV_Master_Location" "ML1" ON "AT1"."INVMLOFrom_Id" = "ML1"."INVMLO_Id"
    INNER JOIN "INV"."INV_Asset_AssetTag" "ATG" ON "AT1"."INVAAT_Id" = "ATG"."INVAAT_Id"
    WHERE "AT1"."MI_Id" = p_MI_Id;
END;
$$;