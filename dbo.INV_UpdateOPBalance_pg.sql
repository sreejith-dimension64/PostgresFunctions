CREATE OR REPLACE FUNCTION "INV"."INV_UpdateOPBalance"(
    "p_MI_Id" BIGINT,
    "p_INVOB_Id" BIGINT,
    "p_INVMST_Id" BIGINT,
    "p_INVMI_Id" BIGINT,
    "p_INVOB_PurchaseRate" DECIMAL(18,2),
    "p_INVOB_SaleRate" DECIMAL(18,2),
    "p_newqty" DECIMAL(18,2)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_tssid" BIGINT;
    "v_oldqty" FLOAT;
    "v_oldfqty" FLOAT;
    "v_newfqty" FLOAT;
    "v_batch" VARCHAR(50);
    "v_storeid" BIGINT;
    "v_phyprice" FLOAT;
    "v_sellprice" FLOAT;
    "v_mfgdate" TIMESTAMP;
    "v_expdate" TIMESTAMP;
    "v_item" BIGINT;
    "v_soldqty" FLOAT;
    "v_sbatch" VARCHAR(50);
    "v_sstoreid" FLOAT;
    "v_opbid" BIGINT;
    "v_newopbid" BIGINT;
    "v_sphyprice" FLOAT;
    "v_ssellprice" FLOAT;
    "v_smfgdate" TIMESTAMP;
    "v_sexpdate" TIMESTAMP;
    "v_sitem" BIGINT;
    "v_newbatch" VARCHAR(50);
    "v_newstoreid" BIGINT;
    "v_newphyprice" FLOAT;
    "v_newsellprice" FLOAT;
    "v_newmfgdate" TIMESTAMP;
    "v_newexpdate" TIMESTAMP;
    "v_newitem" BIGINT;
    "v_institution" BIGINT;
    "v_sMI_Id" BIGINT;
    "v_PurchaseDate" DATE;
    "v_NewPurchaseDate" DATE;
    "v_sPurchaseDate" DATE;
    "v_sINVSTO_SalesQty" DECIMAL(18,2);
    "rec" RECORD;
BEGIN

    FOR "rec" IN 
        SELECT DISTINCT "INVOB_Id", "INVMST_Id", "INVMI_Id", 
               CAST("INVOB_PurchaseDate" AS DATE) AS "PurchaseDate",
               "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty", 
               "INVOB_BatchNo", "INVOB_MfgDate", "INVOB_ExpDate"
        FROM "INV"."INV_OpeningBalance"
        WHERE "MI_Id" = "p_MI_Id" 
          AND "INVMST_Id" = "p_INVMST_Id" 
          AND "INVMI_Id" = "p_INVMI_Id" 
          AND "INVOB_PurchaseRate" = "p_INVOB_PurchaseRate" 
          AND "INVOB_SaleRate" = "p_INVOB_SaleRate" 
          AND "INVOB_Id" = "p_INVOB_Id"
    LOOP
        "v_opbid" := "rec"."INVOB_Id";
        "v_storeid" := "rec"."INVMST_Id";
        "v_item" := "rec"."INVMI_Id";
        "v_PurchaseDate" := "rec"."PurchaseDate";
        "v_phyprice" := "rec"."INVOB_PurchaseRate";
        "v_sellprice" := "rec"."INVOB_SaleRate";
        "v_oldqty" := "rec"."INVOB_Qty";
        "v_batch" := "rec"."INVOB_BatchNo";
        "v_mfgdate" := "rec"."INVOB_MfgDate";
        "v_expdate" := "rec"."INVOB_ExpDate";

        RAISE NOTICE '%', "v_opbid";
        RAISE NOTICE '%', "v_storeid";
        RAISE NOTICE '%', "v_item";
        RAISE NOTICE '%', "v_sstoreid";
        RAISE NOTICE '%', "v_phyprice";
        RAISE NOTICE '%', CAST("v_PurchaseDate" AS VARCHAR(60));
        RAISE NOTICE '%', "v_sINVSTO_SalesQty";

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               COALESCE("MI_Id", 0),
               CAST("INVSTO_PurchaseDate" AS DATE),
               COALESCE("INVSTO_SalesQty", 0)
        INTO "v_tssid", "v_sitem", "v_sstoreid", "v_soldqty", 
             "v_ssellprice", "v_sphyprice", "v_sMI_Id", 
             "v_sPurchaseDate", "v_sINVSTO_SalesQty"
        FROM "INV"."INV_Stock"
        WHERE "INVMI_Id" = "v_item"
          AND "INVSTO_SalesRate" = "v_sellprice"
          AND "INVSTO_PurchaseRate" = "v_phyprice"
          AND "INVMST_Id" = "v_storeid"
          AND "MI_Id" = "p_MI_Id"
          AND CAST("INVSTO_PurchaseDate" AS DATE) = "v_PurchaseDate";

        RAISE NOTICE '%', "v_sitem";
        RAISE NOTICE '%', "v_ssellprice";
        RAISE NOTICE '%', "v_sphyprice";
        RAISE NOTICE '%', "v_sstoreid";
        RAISE NOTICE '%', "v_sstoreid";
        RAISE NOTICE '%', CAST("v_sPurchaseDate" AS TEXT);
        RAISE NOTICE '%', "v_sINVSTO_SalesQty";

        IF "v_item" = "v_sitem"
           AND "v_sellprice" = "v_ssellprice"
           AND "v_phyprice" = "v_sphyprice"
           AND "v_storeid" = "v_sstoreid"
           AND "v_PurchaseDate" = "v_sPurchaseDate"
           AND "p_MI_Id" = "v_sMI_Id"
           AND "v_sINVSTO_SalesQty" <> 0
           AND "p_newqty" >= "v_soldqty"
        THEN
            RAISE NOTICE '1';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + "p_newqty" - "v_oldqty",
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + "p_newqty" - "v_oldqty"
            WHERE "INVSTO_Id" = "v_tssid" 
              AND "MI_Id" = "p_MI_Id" 
              AND "INVMST_Id" = "p_INVMST_Id"
              AND "INVMI_Id" = "p_INVMI_Id"
              AND CAST("INVSTO_PurchaseDate" AS DATE) = "v_PurchaseDate"
              AND "INVSTO_PurchaseRate" = "p_INVOB_PurchaseRate"
              AND "INVSTO_SalesRate" = "p_INVOB_SaleRate";

            UPDATE "INV"."INV_OpeningBalance"
            SET "INVOB_Qty" = "p_newqty" - "v_oldqty"
            WHERE "MI_Id" = "p_MI_Id" 
              AND "INVMST_Id" = "p_INVMST_Id" 
              AND "INVMI_Id" = "p_INVMI_Id"
              AND "INVOB_PurchaseRate" = "p_INVOB_PurchaseRate"
              AND "INVOB_SaleRate" = "p_INVOB_SaleRate"
              AND "INVOB_Id" = "p_INVOB_Id";

        ELSIF "v_item" = "v_sitem"
              AND "v_storeid" = "v_sstoreid"
              AND "v_PurchaseDate" = "v_sPurchaseDate"
              AND "v_sellprice" = "v_ssellprice"
              AND "v_phyprice" = "v_sphyprice"
              AND "v_sINVSTO_SalesQty" = 0
              AND "p_newqty" > "v_oldqty"
              AND "p_MI_Id" = "v_sMI_Id"
        THEN
            RAISE NOTICE '2';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + "p_newqty" - "v_oldqty",
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + "p_newqty" - "v_oldqty"
            WHERE "INVSTO_Id" = "v_tssid" 
              AND "MI_Id" = "p_MI_Id" 
              AND "INVMST_Id" = "p_INVMST_Id"
              AND "INVMI_Id" = "p_INVMI_Id"
              AND CAST("INVSTO_PurchaseDate" AS DATE) = "v_PurchaseDate"
              AND "INVSTO_PurchaseRate" = "p_INVOB_PurchaseRate"
              AND "INVSTO_SalesRate" = "p_INVOB_SaleRate";

            UPDATE "INV"."INV_OpeningBalance"
            SET "INVOB_Qty" = "INVOB_Qty" + "p_newqty" - "v_oldqty"
            WHERE "MI_Id" = "p_MI_Id" 
              AND "INVMST_Id" = "p_INVMST_Id" 
              AND "INVMI_Id" = "p_INVMI_Id"
              AND "INVOB_PurchaseRate" = "p_INVOB_PurchaseRate"
              AND "INVOB_SaleRate" = "p_INVOB_SaleRate"
              AND "INVOB_Id" = "p_INVOB_Id";

        ELSE
            IF "v_item" = "v_sitem"
               AND "v_sellprice" = "v_ssellprice"
               AND "v_phyprice" = "v_sphyprice"
               AND "v_storeid" = "v_sstoreid"
               AND "p_MI_Id" = "v_sMI_Id"
               AND "v_PurchaseDate" = "v_sPurchaseDate"
               AND "v_sINVSTO_SalesQty" = 0
               AND "p_newqty" < "v_oldqty"
            THEN
                RAISE NOTICE '3';

                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - "p_newqty",
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - "p_newqty"
                WHERE "INVSTO_Id" = "v_tssid" 
                  AND "MI_Id" = "p_MI_Id" 
                  AND "INVMST_Id" = "p_INVMST_Id"
                  AND "INVMI_Id" = "p_INVMI_Id"
                  AND CAST("INVSTO_PurchaseDate" AS DATE) = "v_PurchaseDate"
                  AND "INVSTO_PurchaseRate" = "p_INVOB_PurchaseRate"
                  AND "INVSTO_SalesRate" = "p_INVOB_SaleRate";

                UPDATE "INV"."INV_OpeningBalance"
                SET "INVOB_Qty" = "INVOB_Qty" - "p_newqty"
                WHERE "MI_Id" = "p_MI_Id" 
                  AND "INVMST_Id" = "p_INVMST_Id" 
                  AND "INVMI_Id" = "p_INVMI_Id"
                  AND "INVOB_PurchaseRate" = "p_INVOB_PurchaseRate"
                  AND "INVOB_SaleRate" = "p_INVOB_SaleRate"
                  AND "INVOB_Id" = "p_INVOB_Id";

            END IF;
        END IF;

    END LOOP;

    RETURN;
END;
$$;