CREATE OR REPLACE FUNCTION "dbo"."AssertLocationWiseReport"(
    p_MI_Id bigint,
    p_Startdate date,
    p_EndDate date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_INVMLO_Id bigint;
    v_LocationRoomName text;
    v_INVMI_Id bigint;
    v_INVMST_Id bigint;
    v_CheckOutQty decimal(18,2);
    v_DisposedQty decimal(18,2);
    v_ReminingQty decimal(18,2);
    v_ReceivedBy varchar(200);
    v_CheckOutRemarks text;
    v_ActiveFlg boolean;
    v_HRME_Id bigint;
    v_SalesRate decimal(18,2);
    v_CheckoutDate_New date;
    v_PurchaseDate timestamp;
    v_PurchaseRate decimal(18,2);
    v_BatchNo varchar(60);
    v_SSalesRate decimal(18,2);
    v_PurOBQty decimal(18,2);
    v_PurRetQty decimal(18,2);
    v_SalesQty decimal(18,2);
    v_SalesRetQty decimal(18,2);
    v_ItemConQty decimal(18,2);
    v_MatIssPlusQty decimal(18,2);
    v_MatIssMinusQty decimal(18,2);
    v_PhyPlusQty decimal(18,2);
    v_PhyMinQty decimal(18,2);
    v_AvaiableStock decimal(18,2);
    v_IMFY_Id_N bigint;
    v_IMFY_Id bigint;
    v_TFCheckOutQty decimal(18,2);
    v_TTCheckOutQty decimal(18,2);
    v_INVMLOFrom_Id bigint;
    v_INVMLOTo_Id bigint;
    v_SRounct int;
    v_ACRounct int;
    v_SMI_Id bigint;
    v_SINVMST_Id bigint;
    v_SINVMI_Id bigint;
    v_SCheckoutDate timestamp;
    v_SCheckOutQty decimal(18,2);
    rec_locatio record;
    rec_item record;
BEGIN

    v_CheckOutQty := 0;
    v_DisposedQty := 0;
    v_CheckOutRemarks := '';

    FOR rec_locatio IN
        SELECT DISTINCT a."INVMLO_Id", b."INVMLO_LocationRoomName"
        FROM "INV"."INV_Asset_CheckOut" a
        INNER JOIN "INV"."INV_Master_Location" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."MI_Id" = p_MI_Id AND a."INVACO_ActiveFlg" = true AND a."INVACO_CheckoutDate"::date BETWEEN p_Startdate AND p_EndDate
        ORDER BY a."INVMLO_Id"
    LOOP
        v_INVMLO_Id := rec_locatio."INVMLO_Id";
        v_LocationRoomName := rec_locatio."INVMLO_LocationRoomName";

        FOR rec_item IN
            SELECT "INVMI_Id", "INVMST_Id", COALESCE("INVACO_CheckOutQty", 0) AS "CheckOutQty"
            FROM "INV"."INV_Asset_CheckOut"
            WHERE "MI_Id" = p_MI_Id AND "INVMLO_Id" = v_INVMLO_Id AND "INVACO_CheckoutDate"::date BETWEEN p_Startdate AND p_EndDate AND "INVACO_ActiveFlg" = true
        LOOP
            v_INVMI_Id := rec_item."INVMI_Id";
            v_INVMST_Id := rec_item."INVMST_Id";
            v_CheckOutQty := rec_item."CheckOutQty";

            SELECT COALESCE(SUM("INVADI_DisposedQty"), 0) INTO v_DisposedQty
            FROM "INV"."INV_Asset_Dispose"
            WHERE "INVMLO_Id" = v_INVMLO_Id AND "INVMI_Id" = v_INVMI_Id AND "INVADI_ActiveFlg" = true 
                AND "INVMST_Id" = v_INVMST_Id AND "INVADI_DisposedDate"::date BETWEEN p_Startdate AND p_EndDate 
                AND "MI_Id" = p_MI_Id;

            v_ReminingQty := 0;
            v_ReminingQty := (v_CheckOutQty - v_DisposedQty);

            v_CheckoutDate_New := make_date(EXTRACT(YEAR FROM p_EndDate)::int, EXTRACT(MONTH FROM p_EndDate)::int + 1, 1);

            SELECT COUNT(*) INTO v_ACRounct
            FROM "INV"."INV_Asset_CheckOut_Temp"
            WHERE "MI_Id" = p_MI_Id AND "INVMST_Id" = v_INVMST_Id AND "INVMI_Id" = v_INVMI_Id 
                AND "INVMLO_Id" = v_INVMLO_Id AND "INVACO_CheckoutDate"::date = v_CheckoutDate_New 
                AND "INVACO_CheckOutQty" = v_ReminingQty
                AND "INVACO_ReceivedBy" = v_ReceivedBy AND "INVACO_CheckOutRemarks" = v_CheckOutRemarks 
                AND "HRME_Id" = v_HRME_Id AND "INVSTO_SalesRate" = v_SalesRate;

            IF (v_ACRounct = 0) THEN

                SELECT "INVACO_ReceivedBy", COALESCE("INVACO_CheckOutRemarks", ''), "INVACO_ActiveFlg", "HRME_Id", "INVSTO_SalesRate"
                INTO v_ReceivedBy, v_CheckOutRemarks, v_ActiveFlg, v_HRME_Id, v_SalesRate
                FROM "INV"."INV_Asset_CheckOut"
                WHERE "MI_Id" = p_MI_Id AND "INVMST_Id" = v_INVMST_Id AND "INVMLO_Id" = v_INVMLO_Id 
                    AND "INVACO_ActiveFlg" = true AND "INVMI_Id" = v_INVMI_Id;

                INSERT INTO "INV"."INV_Asset_CheckOut_Temp"(
                    "MI_Id", "INVMST_Id", "INVMI_Id", "INVMLO_Id", "INVACO_CheckoutDate", "INVACO_CheckOutQty", 
                    "INVACO_ReceivedBy", "INVACO_CheckOutRemarks", "INVACO_ActiveFlg", "CreatedDate", "UpdatedDate", 
                    "HRME_Id", "INVSTO_SalesRate"
                )
                VALUES(
                    p_MI_Id, v_INVMST_Id, v_INVMI_Id, v_INVMLO_Id, v_CheckoutDate_New, v_ReminingQty, 
                    v_ReceivedBy, v_CheckOutRemarks, v_ActiveFlg, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                    v_HRME_Id, v_SalesRate
                );

            END IF;

        END LOOP;

    END LOOP;

    RETURN;
END;
$$;