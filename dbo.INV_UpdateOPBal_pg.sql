CREATE OR REPLACE FUNCTION "INV"."INV_UpdateOPBal"(
    p_MI_Id bigint,
    p_INVOB_Id bigint,
    p_INVMST_Id bigint,
    p_INVMI_Id bigint,
    p_INVOB_PurchaseRate decimal(18,2),
    p_INVOB_SaleRate decimal(18,2),
    p_newqty decimal(18,2),
    p_INVOB_PurchaseDate date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_tssid bigint;
    v_oldqty double precision;
    v_oldfqty double precision;
    v_newfqty double precision;
    v_batch varchar(50);
    v_storeid bigint;
    v_phyprice double precision;
    v_sellprice double precision;
    v_mfgdate timestamp;
    v_expdate timestamp;
    v_item bigint;
    v_soldqty double precision;
    v_sbatch varchar(50);
    v_sstoreid double precision;
    v_opbid bigint;
    v_newopbid bigint;
    v_sphyprice double precision;
    v_ssellprice double precision;
    v_smfgdate timestamp;
    v_sexpdate timestamp;
    v_sitem bigint;
    v_newbatch varchar(50);
    v_newstoreid bigint;
    v_newphyprice double precision;
    v_newsellprice double precision;
    v_newmfgdate timestamp;
    v_newexpdate timestamp;
    v_newitem bigint;
    v_institution bigint;
    v_sMI_Id bigint;
    v_PurchaseDate date;
    v_NewPurchaseDate date;
    v_sPurchaseDate date;
    v_sINVSTO_SalesQty decimal(18,2);
    
    cur_storeids CURSOR FOR
        SELECT DISTINCT "INVOB_Id", "INVMST_Id", "INVMI_Id", 
               CAST("INVOB_PurchaseDate" AS date) AS "PurchaseDate",
               "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty", 
               "INVOB_BatchNo", "INVOB_MfgDate", "INVOB_ExpDate"
        FROM "INV"."INV_OpeningBalance"
        WHERE "MI_Id" = p_MI_Id 
          AND "INVMST_Id" = p_INVMST_Id 
          AND "INVMI_Id" = p_INVMI_Id 
          AND "INVOB_PurchaseRate" = p_INVOB_PurchaseRate 
          AND "INVOB_SaleRate" = p_INVOB_SaleRate 
          AND "INVOB_Id" = p_INVOB_Id;
BEGIN

    FOR v_opbid, v_storeid, v_item, v_PurchaseDate, v_phyprice, v_sellprice, v_oldqty, v_batch, v_mfgdate, v_expdate IN 
        SELECT DISTINCT "INVOB_Id", "INVMST_Id", "INVMI_Id", 
               CAST("INVOB_PurchaseDate" AS date) AS "PurchaseDate",
               "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty", 
               "INVOB_BatchNo", "INVOB_MfgDate", "INVOB_ExpDate"
        FROM "INV"."INV_OpeningBalance"
        WHERE "MI_Id" = p_MI_Id 
          AND "INVMST_Id" = p_INVMST_Id 
          AND "INVMI_Id" = p_INVMI_Id 
          AND "INVOB_PurchaseRate" = p_INVOB_PurchaseRate 
          AND "INVOB_SaleRate" = p_INVOB_SaleRate 
          AND "INVOB_Id" = p_INVOB_Id
    LOOP

        RAISE NOTICE 'BEFORE';
        RAISE NOTICE '%', v_opbid;
        RAISE NOTICE '%', v_storeid;
        RAISE NOTICE '%', v_item;
        RAISE NOTICE '%', v_sstoreid;
        RAISE NOTICE '%', v_phyprice;
        RAISE NOTICE '%', CAST(v_PurchaseDate AS varchar(60));
        RAISE NOTICE '%', v_sINVSTO_SalesQty;
        RAISE NOTICE 'AFTER';

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               COALESCE("MI_Id", 0),
               CAST("INVSTO_PurchaseDate" AS date),
               COALESCE("INVSTO_SalesQty", 0)
        INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, 
             v_sphyprice, v_sMI_Id, v_sPurchaseDate, v_sINVSTO_SalesQty
        FROM "INV"."INV_Stock"
        WHERE "INVMI_Id" = v_item
          AND "INVSTO_SalesRate" = v_sellprice
          AND "INVSTO_PurchaseRate" = v_phyprice
          AND "INVMST_Id" = v_storeid
          AND "MI_Id" = p_MI_Id
          AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate;

        RAISE NOTICE 'AFTER - 1';
        RAISE NOTICE '%', v_sitem;
        RAISE NOTICE '%', v_ssellprice;
        RAISE NOTICE '%', v_sphyprice;
        RAISE NOTICE '%', v_sstoreid;
        RAISE NOTICE '%', v_sstoreid;
        RAISE NOTICE '%', CAST(v_sPurchaseDate AS text);
        RAISE NOTICE '%', v_sINVSTO_SalesQty;
        RAISE NOTICE 'AFTER - 2';

        IF v_item = v_sitem
           AND v_sellprice = v_ssellprice
           AND v_phyprice = v_sphyprice
           AND v_storeid = v_sstoreid
           AND v_PurchaseDate = v_sPurchaseDate
           AND p_MI_Id = v_sMI_Id
           AND v_sINVSTO_SalesQty <> 0
           AND p_newqty > v_sINVSTO_SalesQty
        THEN
            RAISE NOTICE '1';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = p_newqty - v_sINVSTO_SalesQty,
                "INVSTO_PurOBQty" = p_newqty - v_sINVSTO_SalesQty,
                "INVSTO_PurchaseDate" = p_INVOB_PurchaseDate
            WHERE "INVSTO_Id" = v_tssid 
              AND "MI_Id" = p_MI_Id 
              AND "INVMST_Id" = p_INVMST_Id 
              AND "INVMI_Id" = p_INVMI_Id 
              AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
              AND "INVSTO_PurchaseRate" = p_INVOB_PurchaseRate 
              AND "INVSTO_SalesRate" = p_INVOB_SaleRate;

            UPDATE "INV"."INV_OpeningBalance" 
            SET "INVOB_Qty" = p_newqty,
                "INVOB_PurchaseDate" = p_INVOB_PurchaseDate
            WHERE "MI_Id" = p_MI_Id 
              AND "INVMST_Id" = p_INVMST_Id 
              AND "INVMI_Id" = p_INVMI_Id 
              AND "INVOB_PurchaseRate" = p_INVOB_PurchaseRate 
              AND "INVOB_SaleRate" = p_INVOB_SaleRate 
              AND "INVOB_Id" = p_INVOB_Id;

        ELSIF v_item = v_sitem
              AND v_storeid = v_sstoreid
              AND v_PurchaseDate = v_sPurchaseDate
              AND v_sellprice = v_ssellprice
              AND v_phyprice = v_sphyprice
              AND v_sINVSTO_SalesQty = 0
              AND p_newqty > v_oldqty
              AND p_MI_Id = v_sMI_Id
        THEN
            RAISE NOTICE 'AA';
            RAISE NOTICE '2';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + p_newqty - v_oldqty,
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + p_newqty - v_oldqty,
                "INVSTO_PurchaseDate" = p_INVOB_PurchaseDate
            WHERE "INVSTO_Id" = v_tssid 
              AND "MI_Id" = p_MI_Id 
              AND "INVMST_Id" = p_INVMST_Id 
              AND "INVMI_Id" = p_INVMI_Id 
              AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
              AND "INVSTO_PurchaseRate" = p_INVOB_PurchaseRate 
              AND "INVSTO_SalesRate" = p_INVOB_SaleRate;

            RAISE NOTICE 'bbfore';

            UPDATE "INV"."INV_OpeningBalance" 
            SET "INVOB_Qty" = p_newqty,
                "INVOB_PurchaseDate" = p_INVOB_PurchaseDate
            WHERE "MI_Id" = p_MI_Id 
              AND "INVMST_Id" = p_INVMST_Id 
              AND "INVMI_Id" = p_INVMI_Id 
              AND "INVOB_PurchaseRate" = p_INVOB_PurchaseRate 
              AND "INVOB_SaleRate" = p_INVOB_SaleRate 
              AND "INVOB_Id" = p_INVOB_Id;

        ELSE
            IF v_item = v_sitem
               AND v_sellprice = v_ssellprice
               AND v_phyprice = v_sphyprice
               AND v_storeid = v_sstoreid
               AND p_MI_Id = v_sMI_Id
               AND v_PurchaseDate = v_sPurchaseDate
               AND v_sINVSTO_SalesQty = 0
               AND p_newqty <= v_oldqty
            THEN
                RAISE NOTICE '3';

                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = p_newqty,
                    "INVSTO_PurOBQty" = p_newqty,
                    "INVSTO_PurchaseDate" = p_INVOB_PurchaseDate
                WHERE "INVSTO_Id" = v_tssid 
                  AND "MI_Id" = p_MI_Id 
                  AND "INVMST_Id" = p_INVMST_Id 
                  AND "INVMI_Id" = p_INVMI_Id 
                  AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                  AND "INVSTO_PurchaseRate" = p_INVOB_PurchaseRate 
                  AND "INVSTO_SalesRate" = p_INVOB_SaleRate;

                RAISE NOTICE 'before';

                UPDATE "INV"."INV_OpeningBalance" 
                SET "INVOB_Qty" = p_newqty,
                    "INVOB_PurchaseDate" = p_INVOB_PurchaseDate
                WHERE "MI_Id" = p_MI_Id 
                  AND "INVMST_Id" = p_INVMST_Id 
                  AND "INVMI_Id" = p_INVMI_Id 
                  AND "INVOB_PurchaseRate" = p_INVOB_PurchaseRate 
                  AND "INVOB_SaleRate" = p_INVOB_SaleRate 
                  AND "INVOB_Id" = p_INVOB_Id;
            END IF;
        END IF;

        RAISE NOTICE 'AFTER - 10';

    END LOOP;

END;
$$;