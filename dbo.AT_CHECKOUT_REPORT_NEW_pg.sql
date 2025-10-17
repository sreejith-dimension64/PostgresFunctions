CREATE OR REPLACE FUNCTION "dbo"."AT_CHECKOUT_REPORT_NEW"(
    p_MI_Id BIGINT,
    p_startdate VARCHAR(10),
    p_enddate VARCHAR(10),
    p_IMFY_Id BIGINT,
    p_selectionflag VARCHAR(50),
    p_INVMI_Id TEXT,
    p_INVMLO_Id TEXT,
    p_ASMAY_Id BIGINT,
    p_HRME_Id TEXT
)
RETURNS TABLE(
    "INVACO_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "HRME_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVACO_CheckoutDate" TIMESTAMP,
    "INVACO_CheckOutQty" NUMERIC,
    "INVACO_ReceivedBy" VARCHAR,
    "INVACO_CheckOutRemarks" TEXT,
    "INVACO_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
    v_dates TEXT;
    v_FromDate VARCHAR(10);
    v_ToDate VARCHAR(10);
BEGIN

    IF p_IMFY_Id != 0 THEN
        SELECT TO_CHAR("IMFY_FromDate", 'YYYY-MM-DD'), TO_CHAR("IMFY_ToDate", 'YYYY-MM-DD')
        INTO v_FromDate, v_ToDate
        FROM "IVRM_Master_FinancialYear"
        WHERE "IMFY_Id" = p_IMFY_Id;
    ELSIF p_ASMAY_Id != 0 THEN
        SELECT TO_CHAR("ASMAY_From_Date", 'YYYY-MM-DD'), TO_CHAR("ASMAY_To_Date", 'YYYY-MM-DD')
        INTO v_FromDate, v_ToDate
        FROM "Adm_School_M_Academic_Year"
        WHERE "ASMAY_Id" = p_ASMAY_Id;
    END IF;

    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := 'AND a."INVACO_CheckoutDate"::date BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSIF v_FromDate != '' AND v_ToDate != '' THEN
        v_dates := 'AND a."INVACO_CheckoutDate"::date BETWEEN ''' || v_FromDate || '''::date AND ''' || v_ToDate || '''::date';
    ELSE
        v_dates := '';
    END IF;

    IF p_selectionflag = 'All' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = true
        AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates;
        
        RETURN QUERY EXECUTE v_dynamic;

    ELSIF p_selectionflag = 'Item' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = true AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || '
        AND a."INVMI_Id" IN (' || p_INVMI_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamic;

    ELSIF p_selectionflag = 'Location' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = true
        AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' AND a."INVMLO_Id" IN (' || p_INVMLO_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamic;

    ELSIF p_selectionflag = 'Employee' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = true
        AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' AND a."HRME_Id" IN (' || p_HRME_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamic;

    END IF;

    RETURN;
END;
$$;