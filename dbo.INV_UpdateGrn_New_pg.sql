CREATE OR REPLACE FUNCTION "dbo"."INV_UpdateGrn_New"(
    "p_MI_Id" bigint,
    "p_INVMGRN_Id" bigint,
    "p_INVMST_Id" bigint,
    "p_INVMI_Id" bigint,
    "p_newqty" decimal(18,2)
)
RETURNS void
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
    "v_tgid" BIGINT;
    "v_newtgid" BIGINT;
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
    "v_tmgid" BIGINT;
    "v_newtmgid" BIGINT;
    "v_newMI_Id" BIGINT;
    "v_sMI_Id" BIGINT;
    "v_sPurchaseDate" date;
    "v_PurchaseDate" date;
    "v_sSalesQty" decimal(18,2);
    "rec" RECORD;
BEGIN

    FOR "rec" IN 
        SELECT "INVTGRN_Id", "INVMST_Id", "INVMI_Id", 
               CAST("INVMGRN_PurchaseDate" AS date) AS "INVMGRN_PurchaseDate",
               "INVTGRN_Qty", "INVTGRN_ReturnQty", "INVTGRN_BatchNo", 
               "INVTGRN_PurchaseRate", "INVTGRN_SalesPrice"
        FROM "INV"."INV_T_GRN" "TGR"
        INNER JOIN "INV"."INV_M_GRN" "MGR" ON "TGR"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        INNER JOIN "INV"."INV_M_GRN_Store" "MGRT" ON "MGRT"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        WHERE "MGR"."INVMGRN_Id" = "p_INVMGRN_Id" 
          AND "MGR"."MI_Id" = "p_MI_Id" 
          AND "TGR"."INVMI_Id" = "p_INVMI_Id" 
          AND "MGRT"."INVMST_Id" = "p_INVMST_Id"
    LOOP
        "v_newtgid" := "rec"."INVTGRN_Id";
        "v_newstoreid" := "rec"."INVMST_Id";
        "v_newitem" := "rec"."INVMI_Id";
        "v_PurchaseDate" := "rec"."INVMGRN_PurchaseDate";
        "v_oldqty" := "rec"."INVTGRN_Qty";
        "v_newfqty" := "rec"."INVTGRN_ReturnQty";
        "v_newbatch" := "rec"."INVTGRN_BatchNo";
        "v_newphyprice" := "rec"."INVTGRN_PurchaseRate";
        "v_newsellprice" := "rec"."INVTGRN_SalesPrice";

        RAISE NOTICE '%', "v_oldqty";
        RAISE NOTICE '%', "p_newqty";

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               CAST("INVSTO_PurchaseDate" AS date),
               "MI_Id",
               COALESCE("INVSTO_SalesQty", 0)
        INTO "v_tssid", "v_sitem", "v_sstoreid", "v_soldqty", "v_ssellprice", 
             "v_sphyprice", "v_sPurchaseDate", "v_sMI_Id", "v_sSalesQty"
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = "p_MI_Id"
          AND "INVMST_Id" = "v_newstoreid"
          AND "INVMI_Id" = "v_newitem"
          AND "INVSTO_SalesRate" = "v_newsellprice"
          AND "INVSTO_PurchaseRate" = "v_newphyprice"
          AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate";

        IF ("v_newitem" = "v_sitem")
           AND ("v_newsellprice" = "v_ssellprice")
           AND ("v_newphyprice" = "v_sphyprice")
           AND ("v_PurchaseDate" = "v_sPurchaseDate")
           AND ("v_newstoreid" = "v_sstoreid")
           AND "v_sSalesQty" > 0
           AND ("p_newqty" > "v_sSalesQty")
        THEN
            RAISE NOTICE '1';

            UPDATE "INV"."INV_Stock" 
            SET "INVSTO_AvaiableStock" = "p_newqty" - "v_sSalesQty",
                "INVSTO_PurOBQty" = "p_newqty" - "v_sSalesQty"
            WHERE "MI_Id" = "v_sMI_Id" 
              AND "INVSTO_Id" = "v_tssid" 
              AND "INVMI_Id" = "v_newitem" 
              AND "INVSTO_SalesRate" = "v_newsellprice" 
              AND "INVSTO_PurchaseRate" = "v_newphyprice" 
              AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
              AND "INVMST_Id" = "v_newstoreid";

            UPDATE "INV"."INV_T_GRN" 
            SET "INVTGRN_Qty" = "p_newqty"
            WHERE "INVTGRN_Id" = "v_newtgid" 
              AND "INVMI_Id" = "p_INVMI_Id";

        ELSIF "v_newitem" = "v_sitem"
              AND "v_newstoreid" = "v_sstoreid"
              AND "v_PurchaseDate" = "v_sPurchaseDate"
              AND "v_newsellprice" = "v_ssellprice"
              AND "v_newphyprice" = "v_sphyprice"
              AND "v_sSalesQty" = 0
              AND "p_newqty" > "v_oldqty"
              AND "p_MI_Id" = "v_sMI_Id"
        THEN
            RAISE NOTICE '2';

            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + "p_newqty" - "v_oldqty",
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + "p_newqty" - "v_oldqty"
            WHERE "MI_Id" = "v_sMI_Id" 
              AND "INVSTO_Id" = "v_tssid" 
              AND "INVMI_Id" = "v_newitem" 
              AND "INVSTO_SalesRate" = "v_newsellprice" 
              AND "INVSTO_PurchaseRate" = "v_newphyprice" 
              AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
              AND "INVMST_Id" = "v_newstoreid";

            UPDATE "INV"."INV_T_GRN" 
            SET "INVTGRN_Qty" = "p_newqty"
            WHERE "INVTGRN_Id" = "v_newtgid" 
              AND "INVMI_Id" = "p_INVMI_Id";

        ELSE
            IF "v_newitem" = "v_sitem"
               AND "v_newsellprice" = "v_ssellprice"
               AND "v_newphyprice" = "v_sphyprice"
               AND "v_newstoreid" = "v_sstoreid"
               AND "p_MI_Id" = "v_sMI_Id"
               AND "v_PurchaseDate" = "v_sPurchaseDate"
               AND "v_sSalesQty" = 0
               AND "p_newqty" <= "v_oldqty"
            THEN
                RAISE NOTICE '3';

                UPDATE "INV"."INV_Stock" 
                SET "INVSTO_AvaiableStock" = "p_newqty",
                    "INVSTO_PurOBQty" = "p_newqty"
                WHERE "MI_Id" = "p_MI_Id" 
                  AND "INVSTO_Id" = "v_tssid" 
                  AND "INVMI_Id" = "v_newitem" 
                  AND "INVSTO_SalesRate" = "v_newsellprice" 
                  AND "INVSTO_PurchaseRate" = "v_newphyprice" 
                  AND CAST("INVSTO_PurchaseDate" AS date) = "v_sPurchaseDate" 
                  AND "INVMST_Id" = "v_newstoreid";

                UPDATE "INV"."INV_T_GRN" 
                SET "INVTGRN_Qty" = "p_newqty"
                WHERE "INVTGRN_Id" = "v_newtgid" 
                  AND "INVMI_Id" = "p_INVMI_Id";

            END IF;
        END IF;

    END LOOP;

    RETURN;
END;
$$;