CREATE OR REPLACE FUNCTION "INV"."INV_DeleteSales"(
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
    v_lifo INT;
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
    v_CMI_Id BIGINT;
    v_newstssid BIGINT;
    v_sMI_Id BIGINT;
    v_SalesDate TIMESTAMP;
    rec RECORD;
BEGIN

    FOR rec IN
        SELECT "ITS"."INVTSL_Id", "INVMST_Id", "INVMI_Id", "INVMSL_SalesDate", "INVTSL_SalesQty", "INVTSL_BatchNo", "INVTSL_SalesPrice"
        FROM "INV"."INV_T_Sales" "ITS"
        INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id"
        WHERE "ITS"."INVMSL_Id" = p_INVMSL_Id AND "MI_Id" = p_IMI_Id
    LOOP
        v_newtsaid := rec."INVTSL_Id";
        v_newstoreid := rec."INVMST_Id";
        v_newitem := rec."INVMI_Id";
        v_SalesDate := rec."INVMSL_SalesDate";
        v_oldqty := rec."INVTSL_SalesQty";
        v_newbatch := rec."INVTSL_BatchNo";
        v_newsellprice := rec."INVTSL_SalesPrice";

        SELECT SUM("INVSTO_AvaiableStock") INTO v_qty
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = p_IMI_Id
            AND "INVMI_Id" = v_newitem
            AND "INVSTO_BatchNo" = v_newbatch
            AND "INVMST_Id" = v_newstoreid;

        IF v_newstoreid <> 0 AND v_newsellprice = 0 THEN
            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_oldqty,
                "INVSTO_SalesQty" = "INVSTO_SalesQty" - v_oldqty
            FROM "INV"."INV_M_Sales" "MS"
            WHERE "INV"."INV_Stock"."MI_Id" = "MS"."MI_Id"
                AND "INV"."INV_Stock"."INVMST_Id" = "MS"."INVMST_Id"
                AND "INV"."INV_Stock"."MI_Id" = p_IMI_Id
                AND "INV"."INV_Stock"."INVMST_Id" = v_newstoreid;
        ELSE
            IF v_sellprice <> 0 THEN
                SELECT COALESCE("INVSTO_Id", 0),
                    COALESCE("INVMI_Id", 0),
                    COALESCE("INVMST_Id", 0),
                    COALESCE("INVSTO_AvaiableStock", 0),
                    COALESCE("INVSTO_SalesRate", 0),
                    COALESCE("INVSTO_PurchaseRate", 0),
                    COALESCE("INVSTO_BatchNo", '0'),
                    "MI_Id"
                INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, v_sphyprice, v_sbatch, v_sMI_Id
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = p_IMI_Id
                    AND "INVMI_Id" = v_newitem
                    AND "INVSTO_SalesRate" = v_newsellprice
                    AND "INVSTO_BatchNo" = v_newbatch
                    AND "INVMST_Id" = v_newstoreid;

                IF v_newitem = v_sitem
                    AND v_newsellprice = v_ssellprice
                    AND v_newbatch = v_sbatch
                    AND v_newstoreid = v_sstoreid THEN
                    UPDATE "INV"."INV_Stock"
                    SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_oldqty,
                        "INVSTO_SalesQty" = "INVSTO_SalesQty" - v_oldqty
                    WHERE "MI_Id" = p_IMI_Id
                        AND "INVSTO_Id" = v_stssid
                        AND "INVMI_Id" = v_newitem
                        AND "INVSTO_SalesRate" = v_newsellprice
                        AND "INVMST_Id" = v_newstoreid
                        AND "INVSTO_BatchNo" = v_newbatch;
                END IF;
            ELSE
                SELECT COALESCE("INVSTO_Id", 0),
                    COALESCE("INVMI_Id", 0),
                    COALESCE("INVMST_Id", 0),
                    COALESCE("INVSTO_AvaiableStock", 0),
                    COALESCE("INVSTO_SalesRate", 0),
                    COALESCE("INVSTO_PurchaseRate", 0),
                    COALESCE("INVSTO_BatchNo", '0')
                INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, v_sphyprice, v_sbatch
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = p_IMI_Id
                    AND "INVMI_Id" = v_newitem
                    AND "INVSTO_SalesRate" = v_newsellprice
                    AND "INVMST_Id" = v_newstoreid;

                IF v_newitem = v_sitem
                    AND v_newsellprice = v_ssellprice
                    AND v_newstoreid = v_sstoreid THEN
                    UPDATE "INV"."INV_Stock"
                    SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_oldqty,
                        "INVSTO_SalesQty" = "INVSTO_SalesQty" - v_oldqty
                    WHERE "MI_Id" = p_IMI_Id
                        AND "INVSTO_Id" = v_stssid
                        AND "INVMI_Id" = v_newitem
                        AND "INVSTO_SalesRate" = v_newsellprice
                        AND "INVMST_Id" = v_newstoreid;
                END IF;
            END IF;
        END IF;

    END LOOP;

    RETURN;
END;
$$;