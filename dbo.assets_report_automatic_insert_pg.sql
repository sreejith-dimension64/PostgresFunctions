CREATE OR REPLACE FUNCTION "dbo"."assets_report_automatic_insert"(
    p_MI_Id BIGINT,
    p_coyear VARCHAR(60)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_LFromDate VARCHAR(10);
    v_LToDate VARCHAR(10);
    v_IMFY_Id BIGINT;
    v_Slqdymaic1 TEXT;
    v_Slqdymaic2 TEXT;
BEGIN

    SELECT TO_CHAR("IMFY_FromDate"::DATE, 'YYYY-MM-DD'), TO_CHAR("IMFY_ToDate"::DATE, 'YYYY-MM-DD')
    INTO v_LFromDate, v_LToDate
    FROM "IVRM_Master_FinancialYear"
    WHERE "IMFY_FinancialYear" = p_coyear;

    SELECT "IMFY_Id"
    INTO v_IMFY_Id
    FROM "IVRM_Master_FinancialYear"
    WHERE "IMFY_FromDate" < CURRENT_DATE AND "IMFY_ToDate" > CURRENT_DATE;

    DROP TABLE IF EXISTS "LocationWiseCheckOut_Temp";

    DROP TABLE IF EXISTS "LocationWiseDispose_Temp";

    v_Slqdymaic1 := '
    CREATE TEMP TABLE "LocationWiseCheckOut_Temp" AS
    SELECT DISTINCT a."MI_Id", a."INVMLO_Id", a."INVMI_Id", a."INVACO_CheckoutDate", b."INVMI_ItemName", SUM(a."CheckOutQty") AS "checkoutQty"
    FROM "ALLStockCheckout_Temp" a
    INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id"
    INNER JOIN "INV"."INV_Master_Location" c ON a."INVMLO_Id" = c."INVMLO_Id"
    WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."INVACO_CheckoutDate"::DATE BETWEEN ''' || v_LFromDate || ''' AND ''' || v_LToDate || '''
    GROUP BY a."INVMLO_Id", a."INVMI_Id", a."INVACO_CheckoutDate", b."INVMI_ItemName", a."MI_Id"
    HAVING SUM(a."CheckOutQty") > 0';

    EXECUTE v_Slqdymaic1;

    v_Slqdymaic2 := '
    CREATE TEMP TABLE "LocationWiseDispose_Temp" AS
    SELECT DISTINCT a."MI_Id", a."INVMLO_Id", a."INVMI_Id", b."INVMI_ItemName", SUM(COALESCE(a."INVADI_DisposedQty", 0)) AS "DisposedQty"
    FROM "INV"."INV_Asset_Dispose" a
    INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id"
    INNER JOIN "INV"."INV_Master_Location" c ON a."INVMLO_Id" = c."INVMLO_Id"
    WHERE a."MI_Id" = ' || p_MI_Id || '
    AND a."INVADI_ActiveFlg" = 1 AND a."INVADI_DisposedDate"::DATE BETWEEN ''' || v_LFromDate || ''' AND ''' || v_LToDate || ''' 
    AND c."MI_Id" = ' || p_MI_Id || '
    GROUP BY a."INVMLO_Id", a."INVMI_Id", b."INVMI_ItemName", a."MI_Id"';

    EXECUTE v_Slqdymaic2;

    INSERT INTO "ALLStockCheckout_Temp"("MI_Id", "INVMLO_Id", "INVMI_Id", "INVACO_CheckoutDate", "INVMI_ItemName", "checkoutQty", "createddate", "UpdatedDate", "IMFY_Id", "IMFY_Id_new")
    SELECT a."MI_Id", a."INVMLO_Id", a."INVMI_Id", CURRENT_TIMESTAMP, a."INVMI_ItemName", (a."checkoutQty" - COALESCE(b."DisposedQty", 0)) AS "checkoutQty", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_IMFY_Id, v_IMFY_Id
    FROM "LocationWiseCheckOut_Temp" a
    LEFT JOIN "LocationWiseDispose_Temp" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."INVMI_Id" = b."INVMI_Id";

    RETURN;

END;
$$;