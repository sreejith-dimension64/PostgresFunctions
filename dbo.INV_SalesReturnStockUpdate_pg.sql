CREATE OR REPLACE FUNCTION "dbo"."INV_SalesReturnStockUpdate"(
    "p_MI_Id" bigint,
    "p_INVMST_Id" bigint,
    "p_INVMSL_Id" bigint,
    "p_INVMI_Id" bigint,
    "p_INVTSL_SalesPrice" decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_stssid" BIGINT;
    "v_qty" BIGINT;
    "v_remqty" BIGINT;
    "v_tssid" BIGINT;
    "v_lifo" varchar(30);
    "v_mfgdate1" INT;
    "v_oldqty" FLOAT;
    "v_oldfqty" FLOAT;
    "v_Returnqty" FLOAT;
    "v_Returnfqty" FLOAT;
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
    "v_tsaid" BIGINT;
    "v_Returntsaid" BIGINT;
    "v_sphyprice" FLOAT;
    "v_ssellprice" FLOAT;
    "v_smfgdate" TIMESTAMP;
    "v_sexpdate" TIMESTAMP;
    "v_sitem" BIGINT;
    "v_Returnbatch" VARCHAR(50);
    "v_Returnstoreid" BIGINT;
    "v_Returnphyprice" FLOAT;
    "v_Returnsellprice" FLOAT;
    "v_Returnmfgdate" TIMESTAMP;
    "v_Returnexpdate" TIMESTAMP;
    "v_Returnitem" BIGINT;
    "v_tmsaid" BIGINT;
    "v_institution" BIGINT;
    "v_sMI_Id" BIGINT;
    "v_CMI_Id" bigint;
    "v_Returntssid" BIGINT;
    "v_Returntmsaid" BIGINT;
    "v_INVSTO_Id" bigint;
    "v_PurchaseDate" date;
    "v_citem" bigint;
    "v_Cstoreid" bigint;
    "v_CBatchNo" varchar(100);
    "v_SalesDate" TIMESTAMP;
    "v_SalesPrice" decimal(18,2);
    "rec_storeids" RECORD;
    "rec_stock" RECORD;
    "rec_stock3" RECORD;
BEGIN

FOR "rec_storeids" IN
    SELECT "TSR"."INVTSLRET_Id", "INVMST_Id", "INVMI_Id", 
           CAST("INVTSLRET_ReturnDate" AS date) AS "INVTSLRET_ReturnDate",
           COALESCE("TSR"."INVTSLRET_SalesReturnQty", 0) AS "INVTSLRET_SalesReturnQty",
           "INVTSLRET_BatchNo", "INVTSLRET_SalesReturnAmount"
    FROM "INV"."INV_M_Sales_Return" "MSR"
    INNER JOIN "INV"."INV_T_Sales_Return" "TSR" ON "MSR"."INVMSLRET_Id" = "TSR"."INVMSLRET_Id"
    WHERE "MSR"."INVMSL_Id" = "p_INVMSL_Id" 
      AND "MSR"."MI_Id" = "p_MI_Id" 
      AND "MSR"."INVMST_Id" = "p_INVMST_Id" 
      AND "TSR"."INVMI_Id" = "p_INVMI_Id"
LOOP
    "v_Returntsaid" := "rec_storeids"."INVTSLRET_Id";
    "v_Returnstoreid" := "rec_storeids"."INVMST_Id";
    "v_Returnitem" := "rec_storeids"."INVMI_Id";
    "v_SalesDate" := "rec_storeids"."INVTSLRET_ReturnDate";
    "v_Returnqty" := "rec_storeids"."INVTSLRET_SalesReturnQty";
    "v_Returnbatch" := "rec_storeids"."INVTSLRET_BatchNo";
    "v_Returnsellprice" := "rec_storeids"."INVTSLRET_SalesReturnAmount";

    SELECT COALESCE("INVSTO_Id", 0),
           COALESCE("INVMI_Id", 0),
           COALESCE("INVMST_Id", 0),
           COALESCE("INVSTO_AvaiableStock", 0),
           COALESCE("INVSTO_SalesRate", 0),
           COALESCE("INVSTO_BatchNo", '0'),
           "MI_Id"
    INTO "v_tssid", "v_sitem", "v_sstoreid", "v_soldqty", "v_ssellprice", "v_sbatch", "v_sMI_Id"
    FROM "INV"."INV_Stock"
    WHERE "MI_Id" = "p_MI_Id"
      AND "INVMST_Id" = "v_Returnstoreid"
      AND "INVMI_Id" = "v_Returnitem"
      AND "INVSTO_SalesRate" = "v_Returnsellprice";

    IF "v_Returnitem" = "v_sitem"
       AND "v_Returnsellprice" = "v_ssellprice"
       AND "v_Returnstoreid" = "v_sstoreid"
       AND "v_sMI_Id" = "p_MI_Id"
    THEN

        SELECT "INVC_LIFOFIFOFlg" INTO "v_lifo"
        FROM "INV"."INV_Configuration"
        WHERE "MI_Id" = "p_MI_Id" 
          AND "INVMST_Id" = "v_Returnstoreid" 
          AND "INVC_ProcessApplFlg" = 1;

        SELECT SUM("INVSTO_AvaiableStock") INTO "v_qty"
        FROM "INV"."INV_Stock"
        WHERE "INVMI_Id" = "p_INVMI_Id" 
          AND "INVMST_Id" = "p_INVMST_Id" 
          AND "MI_Id" = "p_MI_Id" 
          AND "INVSTO_SalesRate" = "p_INVTSL_SalesPrice";

        RAISE NOTICE '%', "v_oldqty";
        RAISE NOTICE '%', "v_Returnqty";

        "v_remqty" := 0;

        RAISE NOTICE 'lifo';

        IF "v_lifo" = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            FOR "rec_stock" IN
                SELECT "MI_Id", "INVSTO_Id", 
                       CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate",
                       SUM(COALESCE("INVSTO_AvaiableStock", 0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = "p_MI_Id" 
                  AND "INVMI_Id" = "p_INVMI_Id" 
                  AND "INVMST_Id" = "p_INVMST_Id" 
                  AND "INVSTO_SalesRate" = "p_INVTSL_SalesPrice" 
                  AND "INVSTO_AvaiableStock" <> 0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                ORDER BY CAST("INVSTO_PurchaseDate" AS date) DESC
            LOOP
                "v_CMI_Id" := "rec_stock"."MI_Id";
                "v_INVSTO_Id" := "rec_stock"."INVSTO_Id";
                "v_PurchaseDate" := "rec_stock"."INVSTO_PurchaseDate";
                "v_citem" := "rec_stock"."INVMI_Id";
                "v_Cstoreid" := "rec_stock"."INVMST_Id";
                "v_SalesPrice" := "rec_stock"."INVSTO_SalesRate";
                "v_soldqty" := "rec_stock"."AvaiableStock";

                IF "v_soldqty" > 0 AND "v_Returnqty" > 0 THEN
                    IF ("v_Returnqty" <= "v_soldqty") THEN
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = ("v_soldqty" + "v_Returnqty"),
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" - "v_Returnqty",
                            "INVSTO_SalesRetQty" = "INVSTO_SalesRetQty" + "v_Returnqty"
                        WHERE "MI_Id" = "p_MI_Id" 
                          AND "INVMI_Id" = "v_Returnitem" 
                          AND "INVMST_Id" = "p_INVMST_Id" 
                          AND "INVSTO_SalesRate" = "v_Returnsellprice" 
                          AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
                          AND "INVSTO_Id" = "v_INVSTO_Id";

                        EXIT;
                    END IF;
                END IF;
            END LOOP;

        ELSE
            RAISE NOTICE 'FIFO START';

            FOR "rec_stock3" IN
                SELECT "MI_Id", "INVSTO_Id", 
                       CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate",
                       SUM("INVSTO_AvaiableStock") AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = "p_MI_Id" 
                  AND "INVMI_Id" = "v_Returnitem" 
                  AND "INVMST_Id" = "p_INVMST_Id" 
                  AND "INVSTO_SalesRate" = "v_Returnsellprice" 
                  AND "INVSTO_AvaiableStock" <> 0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                ORDER BY CAST("INVSTO_PurchaseDate" AS date)
            LOOP
                "v_CMI_Id" := "rec_stock3"."MI_Id";
                "v_INVSTO_Id" := "rec_stock3"."INVSTO_Id";
                "v_PurchaseDate" := "rec_stock3"."INVSTO_PurchaseDate";
                "v_citem" := "rec_stock3"."INVMI_Id";
                "v_Cstoreid" := "rec_stock3"."INVMST_Id";
                "v_SalesPrice" := "rec_stock3"."INVSTO_SalesRate";
                "v_soldqty" := "rec_stock3"."AvaiableStock";

                RAISE NOTICE 'fifo mfg';

                IF "v_soldqty" > 0 AND "v_Returnqty" > 0 THEN
                    IF ("v_Returnqty" <= "v_soldqty") THEN
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = ("v_soldqty" + "v_Returnqty"),
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" - "v_Returnqty",
                            "INVSTO_SalesRetQty" = "INVSTO_SalesRetQty" + "v_Returnqty"
                        WHERE "MI_Id" = "p_MI_Id" 
                          AND "INVMI_Id" = "v_Returnitem" 
                          AND "INVMST_Id" = "p_INVMST_Id" 
                          AND "INVSTO_SalesRate" = "v_Returnsellprice" 
                          AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
                          AND "INVSTO_Id" = "v_INVSTO_Id";

                        EXIT;
                    END IF;
                END IF;
            END LOOP;

        END IF;

    END IF;

END LOOP;

END;
$$;