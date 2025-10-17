CREATE OR REPLACE FUNCTION "dbo"."AssetTag_Report"(
    p_MI_Id BIGINT,
    p_startdate VARCHAR(10),
    p_enddate VARCHAR(10),
    p_INVMI_Ids VARCHAR(100),
    p_INVMST_Ids VARCHAR(100),
    p_optionflag VARCHAR(50)
)
RETURNS TABLE(
    "INVAAT_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMS_StoreName" TEXT,
    "INVMI_ItemName" TEXT,
    "INVAAT_AssetId" TEXT,
    "INVAAT_AssetDescription" TEXT,
    "INVAAT_ManufacturedDate" TIMESTAMP,
    "INVAAT_SKU" TEXT,
    "INVAAT_ModelNo" TEXT,
    "INVAAT_SerialNo" TEXT,
    "INVAAT_PurchaseDate" TIMESTAMP,
    "INVAAT_WarantyPeriod" TEXT,
    "INVAAT_WarantyExpiryDate" TIMESTAMP,
    "INVAAT_UnderAMCFlg" BOOLEAN,
    "INVAAT_AMCExpiryDate" TIMESTAMP,
    "INVAAT_ActiveFlg" BOOLEAN,
    "INVAAT_ManufacturerName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_dates TEXT;
BEGIN
    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := ' AND DATE("INVAAT_PurchaseDate") BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        v_Slqdymaic := '
        SELECT DISTINCT AAT."INVAAT_Id", AAT."INVMST_Id", AAT."INVMI_Id", MST."INVMS_StoreName", MI."INVMI_ItemName", 
        AAT."INVAAT_AssetId", AAT."INVAAT_AssetDescription", AAT."INVAAT_ManufacturedDate", AAT."INVAAT_SKU", 
        AAT."INVAAT_ModelNo", AAT."INVAAT_SerialNo", AAT."INVAAT_PurchaseDate", AAT."INVAAT_WarantyPeriod", 
        AAT."INVAAT_WarantyExpiryDate", AAT."INVAAT_UnderAMCFlg", AAT."INVAAT_AMCExpiryDate", AAT."INVAAT_ActiveFlg", 
        AAT."INVAAT_ManufacturerName"
        FROM "INV"."INV_Asset_AssetTag" AAT
        INNER JOIN "INV"."INV_Master_Item" MI ON AAT."INVMI_Id" = MI."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" MST ON AAT."INVMST_Id" = MST."INVMST_Id"
        WHERE AAT."INVAAT_ActiveFlg" = true AND AAT."MI_Id" = ' || p_MI_Id || ' ' || v_dates;

        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF p_optionflag = 'Item' THEN
        v_Slqdymaic := '
        SELECT DISTINCT AAT."INVAAT_Id", NULL::BIGINT, AAT."INVMI_Id", NULL::TEXT, MI."INVMI_ItemName", 
        AAT."INVAAT_AssetId", AAT."INVAAT_AssetDescription", AAT."INVAAT_ManufacturedDate", AAT."INVAAT_SKU", 
        AAT."INVAAT_ModelNo", AAT."INVAAT_SerialNo", AAT."INVAAT_PurchaseDate", AAT."INVAAT_WarantyPeriod", 
        AAT."INVAAT_WarantyExpiryDate", AAT."INVAAT_UnderAMCFlg", AAT."INVAAT_AMCExpiryDate", AAT."INVAAT_ActiveFlg", 
        AAT."INVAAT_ManufacturerName"
        FROM "INV"."INV_Asset_AssetTag" AAT
        INNER JOIN "INV"."INV_Master_Item" MI ON AAT."INVMI_Id" = MI."INVMI_Id"
        WHERE AAT."INVAAT_ActiveFlg" = true AND AAT."INVMI_Id" IN (' || p_INVMI_Ids || ') AND AAT."MI_Id" = ' || p_MI_Id || ' ' || v_dates;

        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF p_optionflag = 'Store' THEN
        v_Slqdymaic := '
        SELECT DISTINCT AAT."INVAAT_Id", AAT."INVMST_Id", AAT."INVMI_Id", MST."INVMS_StoreName", MI."INVMI_ItemName", 
        AAT."INVAAT_AssetId", AAT."INVAAT_AssetDescription", AAT."INVAAT_ManufacturedDate", AAT."INVAAT_SKU", 
        AAT."INVAAT_ModelNo", AAT."INVAAT_SerialNo", AAT."INVAAT_PurchaseDate", AAT."INVAAT_WarantyPeriod", 
        AAT."INVAAT_WarantyExpiryDate", AAT."INVAAT_UnderAMCFlg", AAT."INVAAT_AMCExpiryDate", AAT."INVAAT_ActiveFlg", 
        AAT."INVAAT_ManufacturerName"
        FROM "INV"."INV_Asset_AssetTag" AAT
        INNER JOIN "INV"."INV_Master_Item" MI ON AAT."INVMI_Id" = MI."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" MST ON AAT."INVMST_Id" = MST."INVMST_Id"
        WHERE AAT."INVAAT_ActiveFlg" = true AND AAT."INVMST_Id" IN (' || p_INVMST_Ids || ') AND AAT."MI_Id" = ' || p_MI_Id || ' ' || v_dates;

        RETURN QUERY EXECUTE v_Slqdymaic;

    END IF;

    RETURN;
END;
$$;