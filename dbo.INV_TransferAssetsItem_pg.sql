CREATE OR REPLACE FUNCTION "dbo"."INV_TransferAssetsItem"(
    "p_MI_Id" BIGINT,
    "p_INVATR_Id" BIGINT,
    "p_INVMLOFrom_Id" BIGINT,
    "p_INVMLOTo_Id" BIGINT,
    "p_INVMI_Id" BIGINT,
    "p_INVSTO_SalesRate" DECIMAL(18,2),
    "p_INVATR_CheckOutQty" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_tssid" BIGINT;
    "v_newqty" FLOAT;
    "v_newlocFromid" BIGINT;
    "v_newlocToid" BIGINT;
    "v_newitem" BIGINT;
    "v_checkoutDate" DATE;
    "v_newprice" FLOAT;
    "v_snewqty" FLOAT;
    "v_snewlocFromid" BIGINT;
    "v_snewlocToid" BIGINT;
    "v_snewitem" BIGINT;
    "v_scheckoutDate" DATE;
    "v_snewprice" FLOAT;
    "v_sMI_Id" BIGINT;
    "v_SalesRate" FLOAT;
    "v_INVATR_Id" BIGINT;
    "v_INVACO_CheckoutDate" TIMESTAMP;
    "v_INVACO_IdT" BIGINT;
    "v_INVACO_IdF" BIGINT;
    "transfer_rec" RECORD;
BEGIN

    FOR "transfer_rec" IN
        SELECT DISTINCT "INVATR_Id", "INVMLOFrom_Id", "INVMI_Id", "INVSTO_SalesRate", "INVMLOTo_Id", 
               CAST("INVATR_CheckoutDate" AS DATE) AS "INVATR_CheckoutDate", "INVATR_CheckOutQty"
        FROM "INV"."INV_Asset_Transfer"
        WHERE "MI_Id" = "p_MI_Id" 
          AND "INVMLOFrom_Id" = "p_INVMLOFrom_Id" 
          AND "INVMLOTo_Id" = "p_INVMLOTo_Id" 
          AND "INVMI_Id" = "p_INVMI_Id" 
          AND "INVSTO_SalesRate" = "p_INVSTO_SalesRate" 
          AND "INVATR_Id" = "p_INVATR_Id"
    LOOP
        "v_INVATR_Id" := "transfer_rec"."INVATR_Id";
        "v_newlocFromid" := "transfer_rec"."INVMLOFrom_Id";
        "v_newitem" := "transfer_rec"."INVMI_Id";
        "v_SalesRate" := "transfer_rec"."INVSTO_SalesRate";
        "v_newlocToid" := "transfer_rec"."INVMLOTo_Id";
        "v_checkoutDate" := "transfer_rec"."INVATR_CheckoutDate";
        "v_newqty" := "transfer_rec"."INVATR_CheckOutQty"::FLOAT;

        SELECT COALESCE("INVACO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMLO_Id", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE(CAST("INVACO_CheckoutDate" AS DATE), NULL),
               "MI_Id"
        INTO "v_tssid", "v_snewitem", "v_snewlocFromid", "v_snewprice", "v_scheckoutDate", "v_sMI_Id"
        FROM "INV"."INV_Asset_CheckOut"
        WHERE "MI_Id" = "p_MI_Id" 
          AND "INVMI_Id" = "p_INVMI_Id" 
          AND "INVSTO_SalesRate" = "p_INVSTO_SalesRate" 
          AND "INVMLO_Id" = "p_INVMLOFrom_Id"
        LIMIT 1;

        IF "v_newitem" = "v_snewitem"
           AND "v_SalesRate" = "v_snewprice"
           AND "v_checkoutDate" = "v_scheckoutDate"
           AND "p_MI_Id" = "v_sMI_Id"
        THEN
            RAISE NOTICE 'U';

            SELECT "INVACO_CheckoutDate", "INVACO_Id"
            INTO "v_INVACO_CheckoutDate", "v_INVACO_IdT"
            FROM "INV"."INV_Asset_CheckOut"
            WHERE "MI_Id" = "p_MI_Id" 
              AND "INVMI_Id" = "v_newitem" 
              AND "INVMLO_Id" = "p_INVMLOTo_Id"
            ORDER BY "INVACO_CheckoutDate" DESC
            LIMIT 1;

            UPDATE "INV"."INV_Asset_CheckOut"
            SET "INVACO_CheckOutQty" = "INVACO_CheckOutQty" + "p_INVATR_CheckOutQty"::FLOAT
            WHERE "MI_Id" = "p_MI_Id" 
              AND "INVMI_Id" = "v_newitem" 
              AND "INVMLO_Id" = "p_INVMLOTo_Id" 
              AND "INVACO_Id" = "v_INVACO_IdT";

            SELECT "INVACO_CheckoutDate", "INVACO_Id"
            INTO "v_INVACO_CheckoutDate", "v_INVACO_IdF"
            FROM "INV"."INV_Asset_CheckOut"
            WHERE "MI_Id" = "p_MI_Id" 
              AND "INVMI_Id" = "v_newitem" 
              AND "INVMLO_Id" = "p_INVMLOFrom_Id" 
              AND "INVACO_CheckOutQty" <> 0
            ORDER BY "INVACO_CheckoutDate" DESC
            LIMIT 1;

            UPDATE "INV"."INV_Asset_CheckOut"
            SET "INVACO_CheckOutQty" = "INVACO_CheckOutQty" - "p_INVATR_CheckOutQty"::FLOAT
            WHERE "MI_Id" = "p_MI_Id" 
              AND "INVMI_Id" = "v_newitem" 
              AND "INVMLO_Id" = "p_INVMLOFrom_Id" 
              AND "INVACO_Id" = "v_INVACO_IdF";

        END IF;

    END LOOP;

    RETURN;
END;
$$;