CREATE OR REPLACE FUNCTION "dbo"."INV_UpdateOPB"(
    p_INVMST_Id bigint,
    p_MI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_tssid BIGINT;
    v_oldqty DOUBLE PRECISION;
    v_oldfqty DOUBLE PRECISION;
    v_newqty DOUBLE PRECISION;
    v_newfqty DOUBLE PRECISION;
    v_batch VARCHAR(50);
    v_storeid BIGINT;
    v_phyprice DOUBLE PRECISION;
    v_sellprice DOUBLE PRECISION;
    v_mfgdate TIMESTAMP;
    v_expdate TIMESTAMP;
    v_item BIGINT;
    v_soldqty DOUBLE PRECISION;
    v_sbatch VARCHAR(50);
    v_sstoreid DOUBLE PRECISION;
    v_opbid BIGINT;
    v_newopbid BIGINT;
    v_sphyprice DOUBLE PRECISION;
    v_ssellprice DOUBLE PRECISION;
    v_smfgdate TIMESTAMP;
    v_sexpdate TIMESTAMP;
    v_sitem BIGINT;
    v_newbatch VARCHAR(50);
    v_newstoreid BIGINT;
    v_newphyprice DOUBLE PRECISION;
    v_newsellprice DOUBLE PRECISION;
    v_newmfgdate TIMESTAMP;
    v_newexpdate TIMESTAMP;
    v_newitem BIGINT;
    v_institution bigint;
    v_newinstitution bigint;
    v_sMI_Id bigint;
    v_PurchaseDate timestamp;
    v_NewPurchaseDate timestamp;
    v_sPurchaseDate timestamp;
    rec RECORD;
BEGIN

    v_newinstitution := p_MI_Id;

    FOR rec IN
        SELECT DISTINCT "INVOB_Id", "INVMST_Id", "INVMI_Id", "INVOB_PurchaseDate", "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty", "INVOB_BatchNo", "INVOB_MfgDate", "INVOB_ExpDate"
        FROM "INV"."INV_OpeningBalance"
        WHERE "INVMST_Id" = p_INVMST_Id AND "MI_Id" = v_newinstitution
    LOOP
        v_newopbid := rec."INVOB_Id";
        v_storeid := rec."INVMST_Id";
        v_item := rec."INVMI_Id";
        v_PurchaseDate := rec."INVOB_PurchaseDate";
        v_phyprice := rec."INVOB_PurchaseRate";
        v_sellprice := rec."INVOB_SaleRate";
        v_newqty := rec."INVOB_Qty";
        v_batch := rec."INVOB_BatchNo";
        v_newmfgdate := rec."INVOB_MfgDate";
        v_newexpdate := rec."INVOB_ExpDate";

        RAISE NOTICE '%', v_oldqty;
        RAISE NOTICE '%', v_newqty;

        SELECT COALESCE("INVSTO_Id", 0),
            COALESCE("INVMI_Id", 0),
            COALESCE("INVMST_Id", 0),
            COALESCE("INVSTO_AvaiableStock", 0),
            COALESCE("INVSTO_SalesRate", 0),
            COALESCE("INVSTO_PurchaseRate", 0),
            COALESCE("INVSTO_BatchNo", '0'),
            COALESCE("MI_Id", 0)
        INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, v_sphyprice, v_sbatch, v_sMI_Id
        FROM "INV"."INV_Stock"
        WHERE "INVMI_Id" = v_item
            AND "INVSTO_SalesRate" = v_sellprice
            AND "INVSTO_PurchaseRate" = v_phyprice
            AND "INVSTO_BatchNo" = v_batch
            AND "INVMST_Id" = v_storeid
            AND "MI_Id" = v_newinstitution
            AND "INVSTO_PurchaseDate" = v_PurchaseDate;

        RAISE NOTICE '%', v_tssid;
        RAISE NOTICE '%', v_item;
        RAISE NOTICE '%', v_newitem;
        RAISE NOTICE '%', v_sitem;
        RAISE NOTICE '%', v_expdate;
        RAISE NOTICE '%', v_sexpdate;
        RAISE NOTICE '%', v_newexpdate;
        RAISE NOTICE '%', v_mfgdate;
        RAISE NOTICE '%', v_smfgdate;
        RAISE NOTICE '%', v_newmfgdate;
        RAISE NOTICE '%', v_sellprice;
        RAISE NOTICE '%', v_ssellprice;
        RAISE NOTICE '%', v_newsellprice;
        RAISE NOTICE '%', v_phyprice;
        RAISE NOTICE '%', v_sphyprice;
        RAISE NOTICE '%', v_newphyprice;
        RAISE NOTICE '%', v_batch;
        RAISE NOTICE '%', v_sbatch;
        RAISE NOTICE '%', v_newbatch;
        RAISE NOTICE '%', v_storeid;
        RAISE NOTICE '%', v_sstoreid;
        RAISE NOTICE '%', v_newstoreid;
        RAISE NOTICE '%', v_opbid;
        RAISE NOTICE '%', v_newopbid;

        IF v_newitem = v_sitem
            AND v_newsellprice = v_ssellprice
            AND v_newphyprice = v_sphyprice
            AND v_newbatch = v_sbatch
            AND v_newstoreid = v_sstoreid
            AND v_institution = v_sMI_Id
        THEN
            RAISE NOTICE 'u';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_newqty - v_oldqty,
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + v_newqty - v_oldqty
            WHERE "INVSTO_Id" = v_tssid 
                AND "MI_Id" = v_sMI_Id 
                AND "INVMST_Id" = v_sstoreid 
                AND "INVMI_Id" = v_sitem 
                AND "INVSTO_BatchNo" = v_sbatch 
                AND "INVSTO_PurchaseDate" = v_PurchaseDate 
                AND "INVSTO_PurchaseRate" = v_sphyprice 
                AND "INVSTO_SalesRate" = v_ssellprice;
        ELSE
            RAISE NOTICE 'i';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_oldqty,
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_oldqty,
                "INVSTO_PurchaseRate" = v_newphyprice,
                "INVSTO_SalesRate" = v_newsellprice
            WHERE "INVSTO_Id" = v_tssid 
                AND "MI_Id" = v_sMI_Id 
                AND "INVMST_Id" = v_sstoreid 
                AND "INVMI_Id" = v_sitem 
                AND "INVSTO_BatchNo" = v_sbatch 
                AND "INVSTO_PurchaseDate" = v_PurchaseDate;
        END IF;

    END LOOP;

    RETURN;
END;
$$;