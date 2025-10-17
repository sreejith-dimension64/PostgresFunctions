CREATE OR REPLACE FUNCTION "dbo"."INV_UpdateSales"(
    p_INVMSL_Id BIGINT,
    p_IMI_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_stssid BIGINT;
    v_qty BIGINT;
    v_tssid BIGINT;
    v_lifo VARCHAR(30);
    v_mfgdate1 INT;
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
    v_tsaid BIGINT;
    v_newtsaid BIGINT;
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
    v_tmsaid BIGINT;
    v_newtmsaid BIGINT;
    v_CMI_Id BIGINT;
    v_newstssid BIGINT;
    v_PurchaseDate TIMESTAMP;
    v_citem BIGINT;
    v_Cstoreid BIGINT;
    v_CBatchNo VARCHAR(100);
    v_SalesDate TIMESTAMP;
    rec_storeids RECORD;
    rec_stock5 RECORD;
    rec_stock7 RECORD;
BEGIN

    FOR rec_storeids IN
        SELECT "ITS"."INVTSL_Id", "INVMST_Id", "INVMI_Id", "INVMSL_SalesDate", "INVTSL_SalesQty", "INVTSL_BatchNo", "INVTSL_SalesPrice"
        FROM "INV"."INV_T_Sales" "ITS"
        INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id"
        WHERE "ITS"."INVMSL_Id" = p_INVMSL_Id AND "MI_Id" = p_IMI_Id
    LOOP
        v_newtsaid := rec_storeids."INVTSL_Id";
        v_newstoreid := rec_storeids."INVMST_Id";
        v_newitem := rec_storeids."INVMI_Id";
        v_SalesDate := rec_storeids."INVMSL_SalesDate";
        v_newqty := rec_storeids."INVTSL_SalesQty";
        v_newbatch := rec_storeids."INVTSL_BatchNo";
        v_newsellprice := rec_storeids."INVTSL_SalesPrice";

        SELECT "INVC_LIFOFIFOFlg" INTO v_lifo
        FROM "INV"."INV_Configuration"
        WHERE "MI_Id" = p_IMI_Id AND "INVMST_Id" = v_newstoreid;

        SELECT SUM("INVSTO_AvaiableStock") INTO v_qty
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = p_IMI_Id AND "INVMI_Id" = v_newitem AND "INVSTO_BatchNo" = v_newbatch AND "INVMST_Id" = v_newstoreid;

        RAISE NOTICE 'oldqty: %', v_oldqty;
        RAISE NOTICE 'newqty: %', v_newqty;

        IF v_newqty > 0 THEN
            IF v_lifo = 'LIFO' THEN
                RAISE NOTICE 'LIFO START';
                
                FOR rec_stock5 IN
                    SELECT "MI_Id", MAX("INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate", "INVMI_Id", "INVMST_Id", "INVSTO_BatchNo", SUM("INVSTO_AvaiableStock") AS "AvaiableStock"
                    FROM "INV"."INV_Stock"
                    WHERE "MI_Id" = p_IMI_Id AND "INVMI_Id" = v_newitem AND "INVMST_Id" = v_newstoreid AND "INVSTO_BatchNo" = v_newbatch
                    GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_BatchNo"
                LOOP
                    v_CMI_Id := rec_stock5."MI_Id";
                    v_PurchaseDate := rec_stock5."INVSTO_PurchaseDate";
                    v_citem := rec_stock5."INVMI_Id";
                    v_Cstoreid := rec_stock5."INVMST_Id";
                    v_CBatchNo := rec_stock5."INVSTO_BatchNo";
                    v_oldqty := rec_stock5."AvaiableStock";

                    UPDATE "INV"."INV_Stock"
                    SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_oldqty - v_newqty,
                        "INVSTO_SalesQty" = "INVSTO_SalesQty" - v_oldqty + v_newqty
                    WHERE "MI_Id" = v_CMI_Id AND "INVMI_Id" = v_citem AND "INVSTO_BatchNo" = v_CBatchNo AND "INVMST_Id" = v_Cstoreid;
                END LOOP;

            ELSE
                RAISE NOTICE 'FIFO START';
                
                FOR rec_stock7 IN
                    SELECT "MI_Id", MIN("INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate", "INVMI_Id", "INVMST_Id", "INVSTO_BatchNo", SUM("INVSTO_AvaiableStock") AS "AvaiableStock"
                    FROM "INV"."INV_Stock"
                    WHERE "MI_Id" = p_IMI_Id AND "INVMI_Id" = v_newitem AND "INVMST_Id" = v_storeid AND "INVSTO_BatchNo" = v_newbatch
                    GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_BatchNo"
                LOOP
                    v_CMI_Id := rec_stock7."MI_Id";
                    v_PurchaseDate := rec_stock7."INVSTO_PurchaseDate";
                    v_citem := rec_stock7."INVMI_Id";
                    v_Cstoreid := rec_stock7."INVMST_Id";
                    v_CBatchNo := rec_stock7."INVSTO_BatchNo";
                    v_oldqty := rec_stock7."AvaiableStock";

                    UPDATE "INV"."INV_Stock"
                    SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_newqty,
                        "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_newqty
                    WHERE "MI_Id" = v_CMI_Id AND "INVMI_Id" = v_citem AND "INVSTO_BatchNo" = v_CBatchNo AND "INVMST_Id" = v_Cstoreid;
                END LOOP;

            END IF;

        END IF;

    END LOOP;

    RETURN;
END;
$$;