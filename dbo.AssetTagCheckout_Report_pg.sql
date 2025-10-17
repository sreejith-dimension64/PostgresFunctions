CREATE OR REPLACE FUNCTION "dbo"."AssetTagCheckout_Report"(
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
    "INVATCO_Id" BIGINT,
    "INVAAT_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "INVMS_StoreName" TEXT,
    "INVMI_ItemName" TEXT,
    "INVMLO_LocationRoomName" TEXT,
    "INVATCO_CheckoutDate" TIMESTAMP,
    "INVATCO_ReceivedBy" TEXT,
    "INVATCO_CheckOutRemarks" TEXT,
    "INVAAT_AssetId" TEXT,
    "INVAAT_AssetDescription" TEXT,
    "INVAAT_ModelNo" TEXT,
    "INVAAT_SerialNo" TEXT,
    "INVATCO_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" TEXT;
BEGIN
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := ' AND CAST("INVATCO_CheckoutDate" AS DATE) BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF "p_optionflag" = 'All' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCO"."INVATCO_Id", "ATCO"."INVAAT_Id", "ATCO"."INVMST_Id", "ATCO"."INVMI_Id", "ATCO"."INVMLO_Id",
               "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
               "INVATCO_CheckoutDate", "INVATCO_ReceivedBy", "INVATCO_CheckOutRemarks",
               "INVAAT_AssetId", "INVAAT_AssetDescription", "INVAAT_ModelNo", "INVAAT_SerialNo", "INVATCO_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckOut" "ATCO"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCO"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCO"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCO"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCO"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCO"."INVATCO_ActiveFlg" = TRUE AND "ATCO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCO"."INVATCO_Id", "ATCO"."INVAAT_Id", "ATCO"."INVMST_Id", "ATCO"."INVMI_Id", "ATCO"."INVMLO_Id",
               "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
               "INVATCO_CheckoutDate", "INVATCO_ReceivedBy", "INVATCO_CheckOutRemarks",
               "INVAAT_AssetId", "INVAAT_AssetDescription", "INVAAT_ModelNo", "INVAAT_SerialNo", "INVATCO_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckOut" "ATCO"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCO"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCO"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCO"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCO"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCO"."INVATCO_ActiveFlg" = TRUE AND "ATCO"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "ATCO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Store' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCO"."INVATCO_Id", "ATCO"."INVAAT_Id", "ATCO"."INVMST_Id", "ATCO"."INVMI_Id", "ATCO"."INVMLO_Id",
               "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
               "INVATCO_CheckoutDate", "INVATCO_ReceivedBy", "INVATCO_CheckOutRemarks",
               "INVAAT_AssetId", "INVAAT_AssetDescription", "INVAAT_ModelNo", "INVAAT_SerialNo", "INVATCO_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckOut" "ATCO"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCO"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCO"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCO"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCO"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCO"."INVATCO_ActiveFlg" = TRUE AND "ATCO"."INVMST_Id" IN (' || "p_INVMST_Ids" || ') AND "ATCO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Location' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCO"."INVATCO_Id", "ATCO"."INVAAT_Id", "ATCO"."INVMST_Id", "ATCO"."INVMI_Id", "ATCO"."INVMLO_Id",
               "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
               "INVATCO_CheckoutDate", "INVATCO_ReceivedBy", "INVATCO_CheckOutRemarks",
               "INVAAT_AssetId", "INVAAT_AssetDescription", "INVAAT_ModelNo", "INVAAT_SerialNo", "INVATCO_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckOut" "ATCO"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCO"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCO"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCO"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCO"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCO"."INVATCO_ActiveFlg" = TRUE AND "ATCO"."INVMLO_Id" IN (' || "p_INVMLO_Ids" || ') AND "ATCO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Tag' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "ATCO"."INVATCO_Id", "ATCO"."INVAAT_Id", "ATCO"."INVMST_Id", "ATCO"."INVMI_Id", "ATCO"."INVMLO_Id",
               "MST"."INVMS_StoreName", "MI"."INVMI_ItemName", "MLO"."INVMLO_LocationRoomName",
               "INVATCO_CheckoutDate", "INVATCO_ReceivedBy", "INVATCO_CheckOutRemarks",
               "INVAAT_AssetId", "INVAAT_AssetDescription", "INVAAT_ModelNo", "INVAAT_SerialNo", "INVATCO_ActiveFlg"
        FROM "INV"."INV_AssetTag_CheckOut" "ATCO"
        INNER JOIN "INV"."INV_Asset_AssetTag" "AAT" ON "ATCO"."INVAAT_Id" = "AAT"."INVAAT_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "ATCO"."INVMI_Id" = "MI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" "MST" ON "ATCO"."INVMST_Id" = "MST"."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Location" "MLO" ON "ATCO"."INVMLO_Id" = "MLO"."INVMLO_Id"
        WHERE "ATCO"."INVATCO_ActiveFlg" = TRUE AND "ATCO"."INVAAT_Id" IN (' || "p_INVAAT_Ids" || ') AND "ATCO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    END IF;

    RETURN;
END;
$$;