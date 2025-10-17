CREATE OR REPLACE FUNCTION "dbo"."AT_CHECKIN_REPORT_NEW"(
    p_MI_Id BIGINT,
    p_startdate VARCHAR(10),
    p_enddate VARCHAR(10),
    p_IMFY_Id BIGINT,
    p_selectionflag VARCHAR(50),
    p_INVMI_Id TEXT,
    p_INVMLO_Id TEXT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE(
    "INVACI_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "HRME_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVACI_CheckInDate" TIMESTAMP,
    "INVACI_CheckInQty" NUMERIC,
    "INVACI_ReceivedBy" VARCHAR,
    "INVACI_CheckInRemarks" TEXT,
    "INVACI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
    v_dates TEXT;
    v_FromDate VARCHAR(20);
    v_ToDate VARCHAR(20);
BEGIN

    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := 'AND "INVACI_CheckInDate"::date BETWEEN TO_DATE(''' || p_startdate || ''',''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''',''DD/MM/YYYY'')';
    
    ELSIF p_IMFY_Id != 0 AND p_IMFY_Id IS NOT NULL THEN
        SELECT "IMFY_FromDate"::date::VARCHAR, "IMFY_ToDate"::date::VARCHAR 
        INTO v_FromDate, v_ToDate 
        FROM "IVRM_Master_FinancialYear" 
        WHERE "IMFY_Id" = p_IMFY_Id;
        
        v_dates := 'AND "INVACI_CheckInDate"::date BETWEEN ''' || v_FromDate || '''::date AND ''' || v_ToDate || '''::date';
    
    ELSIF p_ASMAY_Id != 0 AND p_ASMAY_Id IS NOT NULL THEN
        SELECT "ASMAY_From_Date"::date::VARCHAR, "ASMAY_To_Date"::date::VARCHAR 
        INTO v_FromDate, v_ToDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Id" = p_ASMAY_Id;
        
        v_dates := 'AND "INVACI_CheckInDate"::date BETWEEN ''' || v_FromDate || '''::date AND ''' || v_ToDate || '''::date';
    
    ELSE
        v_dates := '';
    END IF;

    IF p_selectionflag = 'All' THEN
        v_dynamic := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
               a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = true 
          AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates;
        
        RETURN QUERY EXECUTE v_dynamic;

    ELSIF p_selectionflag = 'Item' THEN
        v_dynamic := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
               a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = true 
          AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' 
          AND a."INVMI_Id" IN (' || p_INVMI_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamic;

    ELSIF p_selectionflag = 'Location' THEN
        v_dynamic := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
               a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = true 
          AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' 
          AND a."INVMLO_Id" IN (' || p_INVMLO_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamic;

    ELSIF p_selectionflag = 'Staff' THEN
        v_dynamic := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
               b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
               a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
               a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Location" d ON a."INVMLO_Id" = d."INVMLO_Id"
        WHERE a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = true 
          AND a."MI_Id" = ' || p_MI_Id || ' ' || v_dates || ' 
          AND a."INVMLO_Id" IN (' || p_INVMLO_Id || ')';
        
        RETURN QUERY EXECUTE v_dynamic;
    END IF;

    RETURN;
END;
$$;