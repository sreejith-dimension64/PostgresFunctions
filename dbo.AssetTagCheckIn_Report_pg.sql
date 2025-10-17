CREATE OR REPLACE FUNCTION "dbo"."AssetTagCheckIn_Report"(
    "p_MI_Id" BIGINT,
    "p_startdate" VARCHAR(10),
    "p_enddate" VARCHAR(10),
    "p_INVAAT_Ids" VARCHAR(100),
    "p_INVMI_Ids" VARCHAR(100),
    "p_INVMST_Ids" VARCHAR(100),
    "p_INVMLO_Ids" VARCHAR(100),
    "p_optionflag" VARCHAR(50)
)
RETURNS TABLE(
    "INVATCI_Id" BIGINT,
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
    "INVATCI_CheckInDate" TIMESTAMP,
    "INVATCI_ReceivedBy" VARCHAR,
    "INVATCI_CheckInRemarks" TEXT,
    "INVATCI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := ' AND DATE("ATCI"."INVATCI_CheckInDate") BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF "p_optionflag" = 'All' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCI"."INVATCI_Id", "ATCI"."INVAAT_Id", "ATCI"."INVMST_Id", "ATCI"."INVMI_Id", "ATCI"."INVMLO_Id",
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo",
        "ATCI"."INVATCI_CheckInDate", "ATCI"."INVATCI_ReceivedBy", "ATCI"."INVATCI_CheckInRemarks", "ATCI"."INVATCI_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckIn" "ATCI"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCI"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCI"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCI"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCI"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCI"."INVATCI_ActiveFlg" = TRUE AND "ATCI"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCI"."INVATCI_Id", "ATCI"."INVAAT_Id", "ATCI"."INVMST_Id", "ATCI"."INVMI_Id", "ATCI"."INVMLO_Id",
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo",
        "ATCI"."INVATCI_CheckInDate", "ATCI"."INVATCI_ReceivedBy", "ATCI"."INVATCI_CheckInRemarks", "ATCI"."INVATCI_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckIn" "ATCI"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCI"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCI"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCI"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCI"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCI"."INVATCI_ActiveFlg" = TRUE AND "ATCI"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "ATCI"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

    ELSIF "p_optionflag" = 'Store' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCI"."INVATCI_Id", "ATCI"."INVAAT_Id", "ATCI"."INVMST_Id", "ATCI"."INVMI_Id", "ATCI"."INVMLO_Id",
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo",
        "ATCI"."INVATCI_CheckInDate", "ATCI"."INVATCI_ReceivedBy", "ATCI"."INVATCI_CheckInRemarks", "ATCI"."INVATCI_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckIn" "ATCI"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCI"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCI"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCI"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCI"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCI"."INVATCI_ActiveFlg" = TRUE AND "ATCI"."INVMST_Id" IN (' || "p_INVMST_Ids" || ') AND "ATCI"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

    ELSIF "p_optionflag" = 'Location' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCI"."INVATCI_Id", "ATCI"."INVAAT_Id", "ATCI"."INVMST_Id", "ATCI"."INVMI_Id", "ATCI"."INVMLO_Id",
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo",
        "ATCI"."INVATCI_CheckInDate", "ATCI"."INVATCI_ReceivedBy", "ATCI"."INVATCI_CheckInRemarks", "ATCI"."INVATCI_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckIn" "ATCI"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCI"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCI"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCI"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCI"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCI"."INVATCI_ActiveFlg" = TRUE AND "ATCI"."INVMLO_Id" IN (' || "p_INVMLO_Ids" || ') AND "ATCI"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

    ELSIF "p_optionflag" = 'Tag' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCI"."INVATCI_Id", "ATCI"."INVAAT_Id", "ATCI"."INVMST_Id", "ATCI"."INVMI_Id", "ATCI"."INVMLO_Id",
        "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
        "AAT"."INVAAT_AssetId", "AAT"."INVAAT_AssetDescription", "AAT"."INVAAT_ModelNo", "AAT"."INVAAT_SerialNo",
        "ATCI"."INVATCI_CheckInDate", "ATCI"."INVATCI_ReceivedBy", "ATCI"."INVATCI_CheckInRemarks", "ATCI"."INVATCI_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckIn" "ATCI"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCI"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCI"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCI"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCI"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCI"."INVATCI_ActiveFlg" = TRUE AND "ATCI"."INVAAT_Id" IN (' || "p_INVAAT_Ids" || ') AND "ATCI"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";
    END IF;

    RETURN QUERY EXECUTE "v_Slqdymaic";

END;
$$;