CREATE OR REPLACE FUNCTION "dbo"."INV_InsertOPB"(
    p_MI_Id bigint,
    p_INVOB_Id bigint,
    p_INVMST_Id bigint,
    p_INVMI_Id bigint,
    p_INVOB_PurchaseRate decimal(18,2),
    p_INVOB_SaleRate decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_tssid BIGINT;
    v_oldqty FLOAT;
    v_oldfqty FLOAT;
    v_newqty FLOAT;
    v_newfqty FLOAT;
    v_batch VARCHAR(50);
    v_storeid BIGINT;
    v_phyprice FLOAT;
    v_sellprice FLOAT;
    v_mfgdate TIMESTAMP;
    v_expdate TIMESTAMP;
    v_item BIGINT;
    v_soldqty FLOAT;
    v_sbatch VARCHAR(50);
    v_sstoreid FLOAT;
    v_opbid BIGINT;
    v_newopbid BIGINT;
    v_sphyprice FLOAT;
    v_ssellprice FLOAT;
    v_smfgdate TIMESTAMP;
    v_sexpdate TIMESTAMP;
    v_sitem BIGINT;
    v_newbatch VARCHAR(50);
    v_newstoreid BIGINT;
    v_newphyprice FLOAT;
    v_newsellprice FLOAT;
    v_newmfgdate TIMESTAMP;
    v_newexpdate TIMESTAMP;
    v_newitem BIGINT;
    v_PurchaseDate date;
    v_newPurchaseDate date;
    v_sPurchaseDate date;
    v_sMI_Id bigint;
    v_newinstitution bigint;
    v_IMFY_Id bigint;
    rec_storeids RECORD;
BEGIN

    RAISE NOTICE 'oldqty: %', v_oldqty;
    RAISE NOTICE 'newqty: %', v_newqty;

    FOR rec_storeids IN
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
        v_newopbid := rec_storeids."INVOB_Id";
        v_newstoreid := rec_storeids."INVMST_Id";
        v_newitem := rec_storeids."INVMI_Id";
        v_newPurchaseDate := rec_storeids."PurchaseDate";
        v_newphyprice := rec_storeids."INVOB_PurchaseRate";
        v_newsellprice := rec_storeids."INVOB_SaleRate";
        v_newqty := rec_storeids."INVOB_Qty";
        v_newbatch := rec_storeids."INVOB_BatchNo";
        v_newmfgdate := rec_storeids."INVOB_MfgDate";
        v_newexpdate := rec_storeids."INVOB_ExpDate";

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               COALESCE("INVSTO_BatchNo", '0'),
               COALESCE(CAST("INVSTO_PurchaseDate" AS date), NULL),
               "MI_Id"
        INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, 
             v_sphyprice, v_sbatch, v_sPurchaseDate, v_sMI_Id
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = p_MI_Id 
          AND "INVMST_Id" = p_INVMST_Id 
          AND "INVMI_Id" = p_INVMI_Id 
          AND "INVSTO_SalesRate" = p_INVOB_SaleRate 
          AND "INVSTO_PurchaseRate" = p_INVOB_PurchaseRate 
          AND "INVSTO_AvaiableStock" <> 0 
          AND CAST("INVSTO_PurchaseDate" AS date) = v_newPurchaseDate;

        IF v_newitem = v_sitem
           AND v_newsellprice = v_ssellprice
           AND v_newphyprice = v_sphyprice
           AND v_newstoreid = v_sstoreid
           AND v_newPurchaseDate = v_sPurchaseDate
           AND p_MI_Id = v_sMI_Id
        THEN
            RAISE NOTICE 'U';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_newqty,
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + v_newqty
            WHERE "INVSTO_Id" = v_tssid 
              AND "MI_Id" = p_MI_Id 
              AND "INVMST_Id" = p_INVMST_Id 
              AND "INVMI_Id" = p_INVMI_Id 
              AND "INVSTO_PurchaseRate" = p_INVOB_PurchaseRate 
              AND "INVSTO_SalesRate" = p_INVOB_SaleRate 
              AND CAST("INVSTO_PurchaseDate" AS date) = v_sPurchaseDate;
        ELSE
            RAISE NOTICE 'i';

            SELECT "IMFY_Id" INTO v_IMFY_Id 
            FROM "IVRM_Master_FinancialYear" 
            WHERE CURRENT_TIMESTAMP BETWEEN "IMFY_fromdate" AND "IMFY_Todate";

            INSERT INTO "INV"."INV_Stock"(
                "MI_Id", "INVMI_Id", "INVSTO_AvaiableStock", "INVSTO_SalesRate", 
                "INVSTO_PurchaseRate", "INVSTO_BatchNo", "INVSTO_PurOBQty", 
                "INVSTO_PurRetQty", "INVSTO_SalesQty", "INVSTO_SalesRetQty", 
                "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVMST_Id", 
                "INVSTO_PurchaseDate", "IMFY_Id", "CreatedDate", "UpdatedDate"
            ) 
            VALUES (
                p_MI_Id, p_INVMI_Id, v_newqty, p_INVOB_SaleRate, 
                p_INVOB_PurchaseRate, v_newbatch, v_newqty, 
                0, 0, 0, 0, 0, p_INVMST_Id, 
                v_newPurchaseDate, v_IMFY_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
        END IF;

    END LOOP;

    RETURN;
END;
$$;