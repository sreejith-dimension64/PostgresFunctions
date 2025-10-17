CREATE OR REPLACE FUNCTION "dbo"."INV_DeleteOPB"(
    "p_INVMST_Id" bigint,
    "p_MI_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_tssid" BIGINT;
    "v_oldqty" FLOAT;
    "v_oldfqty" FLOAT;
    "v_newqty" FLOAT;
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
    "v_PurchaseDate" TIMESTAMP;
    "v_NewPurchaseDate" TIMESTAMP;
    "v_institution" BIGINT;
    "v_newinstitution" BIGINT;
    "v_sMI_Id" BIGINT;
    "rec" RECORD;
BEGIN
    "v_newinstitution" := "p_MI_Id";

    FOR "rec" IN
        SELECT DISTINCT "INVOB_Id", "INVMST_Id", "INVMI_Id", "INVOB_PurchaseDate", "INVOB_PurchaseRate", 
                       "INVOB_SaleRate", "INVOB_Qty", "INVOB_BatchNo", "INVOB_MfgDate", "INVOB_ExpDate"
        FROM "INV"."INV_OpeningBalance"
        WHERE "INVMST_Id" = "p_INVMST_Id" AND "MI_Id" = "v_newinstitution"
    LOOP
        "v_newopbid" := "rec"."INVOB_Id";
        "v_storeid" := "rec"."INVMST_Id";
        "v_item" := "rec"."INVMI_Id";
        "v_PurchaseDate" := "rec"."INVOB_PurchaseDate";
        "v_phyprice" := "rec"."INVOB_PurchaseRate";
        "v_sellprice" := "rec"."INVOB_SaleRate";
        "v_newqty" := "rec"."INVOB_Qty";
        "v_batch" := "rec"."INVOB_BatchNo";
        "v_newmfgdate" := "rec"."INVOB_MfgDate";
        "v_newexpdate" := "rec"."INVOB_ExpDate";

        RAISE NOTICE '%', "v_oldqty";
        RAISE NOTICE '%', "v_newqty";

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               COALESCE("INVSTO_BatchNo", '0'),
               COALESCE("MI_Id", 0)
        INTO "v_tssid", "v_sitem", "v_sstoreid", "v_soldqty", "v_ssellprice", "v_sphyprice", "v_sbatch", "v_sMI_Id"
        FROM "INV"."INV_Stock"
        WHERE "INVMI_Id" = "v_item"
          AND "INVSTO_SalesRate" = "v_sellprice"
          AND "INVSTO_PurchaseRate" = "v_phyprice"
          AND "INVSTO_BatchNo" = "v_batch"
          AND "INVMST_Id" = "v_storeid"
          AND "MI_Id" = "v_newinstitution"
          AND "INVSTO_PurchaseDate" = "v_PurchaseDate";

        IF "v_item" = "v_sitem"
           AND "v_sellprice" = "v_ssellprice"
           AND "v_phyprice" = "v_sphyprice"
           AND "v_batch" = "v_sbatch"
           AND "v_storeid" = "v_sstoreid"
           AND "v_institution" = "v_sMI_Id"
           AND "v_PurchaseDate" = "v_PurchaseDate"
        THEN
            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - "v_oldqty",
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - "v_oldqty"
            WHERE "INVSTO_Id" = "v_tssid" 
              AND "MI_Id" = "v_sMI_Id" 
              AND "INVMST_Id" = "v_sstoreid" 
              AND "INVMI_Id" = "v_sitem" 
              AND "INVSTO_BatchNo" = "v_sbatch" 
              AND "INVSTO_PurchaseDate" = "v_PurchaseDate" 
              AND "INVSTO_PurchaseRate" = "v_sphyprice" 
              AND "INVSTO_SalesRate" = "v_ssellprice";
        ELSE
            IF "v_item" = "v_sitem"
               AND "v_sellprice" = "v_ssellprice"
               AND "v_batch" = "v_sbatch"
               AND "v_storeid" = "v_sstoreid"
               AND "v_institution" = "v_sMI_Id"
            THEN
                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - "v_oldqty",
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - "v_oldqty"
                WHERE "INVSTO_Id" = "v_tssid" 
                  AND "MI_Id" = "v_sMI_Id" 
                  AND "INVMI_Id" = "v_sitem" 
                  AND "INVSTO_SalesRate" = "v_ssellprice" 
                  AND "INVSTO_BatchNo" = "v_batch";
            ELSE
                IF "v_item" = "v_sitem"
                   AND "v_sellprice" = "v_ssellprice"
                   AND "v_storeid" = "v_sstoreid"
                   AND "v_institution" = "v_sMI_Id"
                THEN
                    UPDATE "INV"."INV_Stock"
                    SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - "v_oldqty",
                        "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - "v_oldqty"
                    WHERE "INVSTO_Id" = "v_tssid" 
                      AND "MI_Id" = "v_sMI_Id" 
                      AND "INVMI_Id" = "v_sitem" 
                      AND "INVSTO_SalesRate" = "v_ssellprice";
                ELSE
                    IF "v_item" = "v_sitem"
                       AND "v_storeid" = "v_sstoreid"
                       AND "v_institution" = "v_sMI_Id"
                    THEN
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - "v_oldqty",
                            "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - "v_oldqty"
                        WHERE "INVSTO_Id" = "v_tssid" 
                          AND "MI_Id" = "v_sMI_Id" 
                          AND "INVMST_Id" = "v_sstoreid" 
                          AND "INVMI_Id" = "v_sitem";
                    END IF;
                END IF;
            END IF;
        END IF;

    END LOOP;

    RETURN;
END;
$$;