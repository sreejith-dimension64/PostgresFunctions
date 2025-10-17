CREATE OR REPLACE FUNCTION "dbo"."AssetTagDispose_Report" (
    "MI_Id" BIGINT,
    "startdate" VARCHAR(10),
    "enddate" VARCHAR(10),
    "INVAAT_Ids" VARCHAR(100),
    "INVMI_Ids" VARCHAR(100),
    "INVMST_Ids" VARCHAR(100),
    "INVMLO_Ids" VARCHAR(100),
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVATDI_Id" BIGINT,
    "INVAAT_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVAAT_AssetId" VARCHAR,
    "INVAAT_AssetDescription" TEXT,
    "INVAAT_ModelNo" VARCHAR,
    "INVAAT_SerialNo" VARCHAR,
    "INVATDI_DisposedDate" TIMESTAMP,
    "INVATDI_DisposedRemarks" TEXT,
    "INVATDI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND DATE("INVATDI_DisposedDate") BETWEEN TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATD"."INVATDI_Id", "ATD"."INVAAT_Id", "ATD"."INVMST_Id", "ATD"."INVMI_Id", "ATD"."INVMLO_Id", 
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATD"."INVATDI_DisposedDate", "ATD"."INVATDI_DisposedRemarks", "ATD"."INVATDI_ActiveFlg"
        FROM "INV"."INV_AssetTag_Dispose" "ATD"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATD"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATD"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATD"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATD"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATD"."INVATDI_ActiveFlg" = TRUE AND "ATD"."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATD"."INVATDI_Id", "ATD"."INVAAT_Id", "ATD"."INVMST_Id", "ATD"."INVMI_Id", "ATD"."INVMLO_Id", 
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATD"."INVATDI_DisposedDate", "ATD"."INVATDI_DisposedRemarks", "ATD"."INVATDI_ActiveFlg"
        FROM "INV"."INV_AssetTag_Dispose" "ATD"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATD"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATD"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATD"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATD"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATD"."INVATDI_ActiveFlg" = TRUE AND "ATD"."INVMI_Id" IN (' || "INVMI_Ids" || ') AND "ATD"."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Store' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATD"."INVATDI_Id", "ATD"."INVAAT_Id", "ATD"."INVMST_Id", "ATD"."INVMI_Id", "ATD"."INVMLO_Id", 
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATD"."INVATDI_DisposedDate", "ATD"."INVATDI_DisposedRemarks", "ATD"."INVATDI_ActiveFlg"
        FROM "INV"."INV_AssetTag_Dispose" "ATD"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATD"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATD"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATD"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATD"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATD"."INVATDI_ActiveFlg" = TRUE AND "ATD"."INVMST_Id" IN (' || "INVMST_Ids" || ') AND "ATD"."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Location' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATD"."INVATDI_Id", "ATD"."INVAAT_Id", "ATD"."INVMST_Id", "ATD"."INVMI_Id", "ATD"."INVMLO_Id", 
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATD"."INVATDI_DisposedDate", "ATD"."INVATDI_DisposedRemarks", "ATD"."INVATDI_ActiveFlg"
        FROM "INV"."INV_AssetTag_Dispose" "ATD"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATD"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATD"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATD"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATD"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATD"."INVATDI_ActiveFlg" = TRUE AND "ATD"."INVMLO_Id" IN (' || "INVMLO_Ids" || ') AND "ATD"."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Tag' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ATD"."INVATDI_Id", "ATD"."INVAAT_Id", "ATD"."INVMST_Id", "ATD"."INVMI_Id", "ATD"."INVMLO_Id", 
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo", 
        "ATD"."INVATDI_DisposedDate", "ATD"."INVATDI_DisposedRemarks", "ATD"."INVATDI_ActiveFlg"
        FROM "INV"."INV_AssetTag_Dispose" "ATD"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATD"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATD"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATD"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATD"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATD"."INVATDI_ActiveFlg" = TRUE AND "ATD"."INVAAT_Id" IN (' || "INVAAT_Ids" || ') AND "ATD"."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    END IF;

    RETURN;
END;
$$;