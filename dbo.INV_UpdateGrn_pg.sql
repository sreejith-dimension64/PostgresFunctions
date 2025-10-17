CREATE OR REPLACE FUNCTION "dbo"."INV_UpdateGrn"(
    p_INVMGRN_Id BIGINT,
    p_MI_Id BIGINT
)
RETURNS VOID
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
    v_tgid BIGINT;
    v_newtgid BIGINT;
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
    v_tmgid BIGINT;
    v_newtmgid BIGINT;
    v_newMI_Id BIGINT;
    v_sMI_Id BIGINT;
    v_sPurchaseDate TIMESTAMP;
    v_PurchaseDate TIMESTAMP;
    rec_gettrgnids RECORD;
    rec_stock RECORD;
BEGIN
    v_newMI_Id := p_MI_Id;
    
    FOR rec_gettrgnids IN
        SELECT "INVTGRN_Id", "INVMST_Id", "INVMI_Id", "INVMGRN_PurchaseDate",
               SUM("INVTGRN_Qty" + "INVTGRN_ReturnQty") AS "NewQty",
               "INVTGRN_ReturnQty", "INVTGRN_BatchNo", "INVTGRN_PurchaseRate", "INVTGRN_SalesPrice"
        FROM "INV"."INV_T_GRN" "TGR"
        INNER JOIN "INV"."INV_M_GRN" "MGR" ON "TGR"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        INNER JOIN "INV"."INV_M_GRN_Store" "MGRT" ON "MGRT"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        WHERE "MGR"."INVMGRN_Id" = p_INVMGRN_Id AND "MGR"."MI_Id" = v_newMI_Id
        GROUP BY "INVTGRN_Id", "INVMST_Id", "INVMI_Id", "INVTGRN_ReturnQty", "INVTGRN_BatchNo",
                 "INVTGRN_PurchaseRate", "INVTGRN_SalesPrice", "INVMGRN_PurchaseDate"
    LOOP
        v_newtgid := rec_gettrgnids."INVTGRN_Id";
        v_newstoreid := rec_gettrgnids."INVMST_Id";
        v_newitem := rec_gettrgnids."INVMI_Id";
        v_PurchaseDate := rec_gettrgnids."INVMGRN_PurchaseDate";
        v_newqty := rec_gettrgnids."NewQty";
        v_newfqty := rec_gettrgnids."INVTGRN_ReturnQty";
        v_newbatch := rec_gettrgnids."INVTGRN_BatchNo";
        v_newphyprice := rec_gettrgnids."INVTGRN_PurchaseRate";
        v_newsellprice := rec_gettrgnids."INVTGRN_SalesPrice";

        RAISE NOTICE '%', v_oldqty;
        RAISE NOTICE '%', v_newqty;

        FOR rec_stock IN
            SELECT SUM(COALESCE("INVSTO_AvaiableStock", 0)) AS "INVSTO_AvaiableStock"
            FROM "INV"."INV_Stock"
            WHERE "MI_Id" = p_MI_Id 
                AND "INVMI_Id" = v_newitem 
                AND "INVMST_Id" = v_newstoreid
                AND "INVSTO_SalesRate" = v_newsellprice 
                AND "INVSTO_PurchaseRate" = v_newphyprice
                AND "INVSTO_BatchNo" = v_newbatch 
                AND "INVSTO_AvaiableStock" <> 0
        LOOP
            v_soldqty := rec_stock."INVSTO_AvaiableStock";

            SELECT COALESCE("INVSTO_Id", 0),
                   COALESCE("INVMI_Id", 0),
                   COALESCE("INVMST_Id", 0),
                   COALESCE("INVSTO_AvaiableStock", 0),
                   COALESCE("INVSTO_SalesRate", 0),
                   COALESCE("INVSTO_PurchaseRate", 0),
                   COALESCE("INVSTO_BatchNo", '0'),
                   "INVSTO_PurchaseDate",
                   "MI_Id"
            INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, v_sphyprice, v_sbatch, v_sPurchaseDate, v_sMI_Id
            FROM "INV"."INV_Stock"
            WHERE "MI_Id" = v_newMI_Id
                AND "INVMST_Id" = v_newstoreid
                AND "INVMI_Id" = v_newitem
                AND "INVSTO_SalesRate" = v_newsellprice
                AND "INVSTO_PurchaseRate" = v_newphyprice
                AND "INVSTO_BatchNo" = v_newbatch 
                AND "INVSTO_PurchaseDate" = v_PurchaseDate;

            IF (v_newitem = v_sitem) 
                AND (v_newsellprice = v_ssellprice) 
                AND (v_newphyprice = v_sphyprice) 
                AND (v_newbatch = v_sbatch) 
                AND (v_newstoreid = v_sstoreid) THEN

                RAISE NOTICE 'a';
                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_newqty - v_soldqty,
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + v_newqty - v_soldqty
                WHERE "MI_Id" = v_sMI_Id 
                    AND "INVSTO_Id" = v_tssid 
                    AND "INVMI_Id" = v_sitem 
                    AND "INVSTO_SalesRate" = v_ssellprice 
                    AND "INVSTO_PurchaseRate" = v_sphyprice 
                    AND "INVSTO_PurchaseDate" = v_sPurchaseDate 
                    AND "INVMST_Id" = v_newstoreid 
                    AND "INVSTO_BatchNo" = v_sbatch;
            ELSE
                RAISE NOTICE 'b';

                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_soldqty,
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_soldqty,
                    "INVSTO_PurchaseRate" = v_newsellprice,
                    "INVSTO_SalesRate" = v_newsellprice
                WHERE "MI_Id" = v_sMI_Id 
                    AND "INVSTO_Id" = v_tssid 
                    AND "INVMI_Id" = v_sitem 
                    AND "INVMST_Id" = v_newstoreid;

            END IF;

        END LOOP;

    END LOOP;

    RETURN;
END;
$$;