CREATE OR REPLACE FUNCTION "dbo"."AT_Checkout_Report"(
    p_MI_Id BIGINT,
    p_startdate VARCHAR(10),
    p_enddate VARCHAR(10),
    p_IMFY_Id VARCHAR(10),
    p_selectionflag VARCHAR(50),
    p_INVMI_Id VARCHAR(50),
    p_INVMLO_Id VARCHAR(50)
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

    SELECT TO_CHAR("IMFY_FromDate"::DATE, 'YYYY-MM-DD'), TO_CHAR("IMFY_ToDate"::DATE, 'YYYY-MM-DD')
    INTO v_FromDate, v_ToDate
    FROM "IVRM_Master_FinancialYear"
    WHERE "IMFY_Id" = p_IMFY_Id::BIGINT;

    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := 'AND "INVACO_CheckoutDate"::DATE BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSIF p_IMFY_Id != '' THEN
        v_dates := 'AND "INVACO_CheckoutDate"::DATE BETWEEN ''' || v_FromDate || '''::DATE AND ''' || v_ToDate || '''::DATE';
    ELSE
        p_IMFY_Id := '';
        p_startdate := '';
        p_enddate := '';
        v_dates := '';
    END IF;

    IF p_selectionflag = 'All' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", 
               a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = TRUE
        AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates;

    ELSIF p_selectionflag = 'Item' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", 
               a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = TRUE 
        AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || '
        AND a."INVMI_Id" IN (' || p_INVMI_Id || ')';

    ELSIF p_selectionflag = 'Location' THEN
        v_dynamic := '
        SELECT a."INVACO_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACO_CheckoutDate", a."INVACO_CheckOutQty", a."INVACO_ReceivedBy", 
               a."INVACO_CheckOutRemarks", a."INVACO_ActiveFlg"
        FROM "INV"."INV_Asset_CheckOut" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" AND a."INVACO_ActiveFlg" = TRUE
        AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || '
        AND a."INVMLO_Id" IN (' || p_INVMLO_Id || ')';
    END IF;

    RETURN QUERY EXECUTE v_dynamic;

END;
$$;