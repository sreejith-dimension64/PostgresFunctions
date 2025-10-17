CREATE OR REPLACE FUNCTION "dbo"."AssetTagTransfer_Report" (
    "MI_Id" BIGINT,
    "startdate" VARCHAR(10),
    "enddate" VARCHAR(10),
    "INVAAT_Ids" VARCHAR(100),
    "INVMI_Ids" VARCHAR(100),
    "INVMLO_Ids" VARCHAR(100),
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVATTR_Id" BIGINT,
    "INVAAT_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLOFrom_Id" BIGINT,
    "INVMLOTo_Id" BIGINT,
    "fromLoaction" VARCHAR,
    "toLoaction" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVAAT_AssetId" VARCHAR,
    "INVAAT_AssetDescription" TEXT,
    "INVAAT_ModelNo" VARCHAR,
    "INVAAT_SerialNo" VARCHAR,
    "INVATTR_CheckoutDate" TIMESTAMP,
    "INVATTR_ReceivedBy" VARCHAR,
    "INVATTR_CheckOutRemarks" TEXT,
    "INVATTR_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND DATE("INVATTR_CheckoutDate") BETWEEN TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;
    
    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATTR"."INVATTR_Id", "ATTR"."INVAAT_Id", "ATTR"."INVMI_Id", "ATTR"."INVMLOFrom_Id", "ATTR"."INVMLOTo_Id",
        "MFL"."INVMLO_LocationRoomName" AS "fromLoaction",
        "MTL"."INVMLO_LocationRoomName" AS "toLoaction", 
        "MI"."INVMI_ItemName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATTR"."INVATTR_CheckoutDate", "ATTR"."INVATTR_ReceivedBy", "ATTR"."INVATTR_CheckOutRemarks", "ATTR"."INVATTR_ActiveFlg"
        FROM "INV"."INV_AssetTag_Transfer" "ATTR"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATTR"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATTR"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" "MFL" ON "ATTR"."INVMLOFrom_Id" = "MFL"."INVMLO_Id"
        INNER JOIN "INV"."INV_Master_Location" "MTL" ON "ATTR"."INVMLOTo_Id" = "MTL"."INVMLO_Id"
        WHERE "ATTR"."INVATTR_ActiveFlg" = true AND "ATTR"."MI_Id" = ' || "MI_Id" || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATTR"."INVATTR_Id", "ATTR"."INVAAT_Id", "ATTR"."INVMI_Id", "ATTR"."INVMLOFrom_Id", "ATTR"."INVMLOTo_Id",
        "MFL"."INVMLO_LocationRoomName" AS "fromLoaction",
        "MTL"."INVMLO_LocationRoomName" AS "toLoaction", 
        "MI"."INVMI_ItemName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATTR"."INVATTR_CheckoutDate", "ATTR"."INVATTR_ReceivedBy", "ATTR"."INVATTR_CheckOutRemarks", "ATTR"."INVATTR_ActiveFlg"
        FROM "INV"."INV_AssetTag_Transfer" "ATTR"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATTR"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATTR"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" "MFL" ON "ATTR"."INVMLOFrom_Id" = "MFL"."INVMLO_Id"
        INNER JOIN "INV"."INV_Master_Location" "MTL" ON "ATTR"."INVMLOTo_Id" = "MTL"."INVMLO_Id"
        WHERE "ATTR"."INVATTR_ActiveFlg" = true AND "ATTR"."INVMI_Id" IN (' || "INVMI_Ids" || ') AND "ATTR"."MI_Id" = ' || "MI_Id" || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Location' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATTR"."INVATTR_Id", "ATTR"."INVAAT_Id", "ATTR"."INVMI_Id", "ATTR"."INVMLOFrom_Id", "ATTR"."INVMLOTo_Id",
        "MFL"."INVMLO_LocationRoomName" AS "fromLoaction",
        "MTL"."INVMLO_LocationRoomName" AS "toLoaction", 
        "MI"."INVMI_ItemName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATTR"."INVATTR_CheckoutDate", "ATTR"."INVATTR_ReceivedBy", "ATTR"."INVATTR_CheckOutRemarks", "ATTR"."INVATTR_ActiveFlg"
        FROM "INV"."INV_AssetTag_Transfer" "ATTR"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATTR"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATTR"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" "MFL" ON "ATTR"."INVMLOFrom_Id" = "MFL"."INVMLO_Id"
        INNER JOIN "INV"."INV_Master_Location" "MTL" ON "ATTR"."INVMLOTo_Id" = "MTL"."INVMLO_Id"
        WHERE "ATTR"."INVATTR_ActiveFlg" = true AND "ATTR"."INVMLO_Id" IN (' || "INVMLO_Ids" || ') AND "ATTR"."MI_Id" = ' || "MI_Id" || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Tag' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATTR"."INVATTR_Id", "ATTR"."INVAAT_Id", "ATTR"."INVMI_Id", "ATTR"."INVMLOFrom_Id", "ATTR"."INVMLOTo_Id",
        "MFL"."INVMLO_LocationRoomName" AS "fromLoaction",
        "MTL"."INVMLO_LocationRoomName" AS "toLoaction", 
        "MI"."INVMI_ItemName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATTR"."INVATTR_CheckoutDate", "ATTR"."INVATTR_ReceivedBy", "ATTR"."INVATTR_CheckOutRemarks", "ATTR"."INVATTR_ActiveFlg"
        FROM "INV"."INV_AssetTag_Transfer" "ATTR"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATTR"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATTR"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" "MFL" ON "ATTR"."INVMLOFrom_Id" = "MFL"."INVMLO_Id"
        INNER JOIN "INV"."INV_Master_Location" "MTL" ON "ATTR"."INVMLOTo_Id" = "MTL"."INVMLO_Id"
        WHERE "ATTR"."INVATTR_ActiveFlg" = true AND "ATTR"."INVAAT_Id" IN (' || "INVAAT_Ids" || ') AND "ATTR"."MI_Id" = ' || "MI_Id" || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
    END IF;
    
    RETURN;
END;
$$;