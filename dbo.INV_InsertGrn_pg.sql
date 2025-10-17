CREATE OR REPLACE FUNCTION "dbo"."INV_InsertGrn"(
    p_INVMGRN_Id bigint,
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
    v_newMGRN_Id bigint;
    v_IMFY_Id bigint;
    v_sPurchaseDate timestamp;
    v_PurchaseDate timestamp;
    rec RECORD;
BEGIN

    v_newMI_Id := p_MI_Id;

    FOR rec IN 
        SELECT "INVTGRN_Id", "INVMST_Id", "INVMI_Id", "INVMGRN_PurchaseDate", 
               SUM("INVTGRN_Qty" + "INVTGRN_ReturnQty") AS "NewQty", 
               "INVTGRN_ReturnQty", "INVTGRN_BatchNo", "INVTGRN_PurchaseRate", "INVTGRN_SalesPrice"
        FROM "INV"."INV_T_GRN" "TGR"
        INNER JOIN "INV"."INV_M_GRN" "MGR" ON "TGR"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        INNER JOIN "INV"."INV_M_GRN_Store" "MGRT" ON "MGRT"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        WHERE "MGR"."INVMGRN_Id" = p_INVMGRN_Id AND "MGR"."MI_Id" = v_newMI_Id
        GROUP BY "INVTGRN_Id", "INVMST_Id", "INVMI_Id", "INVTGRN_ReturnQty", 
                 "INVTGRN_BatchNo", "INVTGRN_PurchaseRate", "INVTGRN_SalesPrice", "INVMGRN_PurchaseDate"
    LOOP
        v_newtgid := rec."INVTGRN_Id";
        v_newstoreid := rec."INVMST_Id";
        v_newitem := rec."INVMI_Id";
        v_PurchaseDate := rec."INVMGRN_PurchaseDate";
        v_newqty := rec."NewQty";
        v_newfqty := rec."INVTGRN_ReturnQty";
        v_newbatch := rec."INVTGRN_BatchNo";
        v_newphyprice := rec."INVTGRN_PurchaseRate";
        v_newsellprice := rec."INVTGRN_SalesPrice";

        RAISE NOTICE '---1--';

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
          AND "INVSTO_PurchaseDate" = v_PurchaseDate 
          AND "INVSTO_SalesRate" = v_ssellprice
        LIMIT 1;

        IF (v_newitem = v_sitem) AND (v_newsellprice = v_ssellprice) AND (v_newphyprice = v_sphyprice) 
           AND (v_newstoreid = v_sstoreid) AND (v_sPurchaseDate = v_PurchaseDate) THEN
            
            RAISE NOTICE '--2---';
            
            UPDATE "INV"."INV_Stock"
            SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_newqty,
                "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + v_newqty,
                "INVSTO_PurRetQty" = v_newfqty
            WHERE "MI_Id" = v_sMI_Id 
              AND "INVSTO_Id" = v_tssid 
              AND "INVMI_Id" = v_sitem 
              AND "INVSTO_SalesRate" = v_ssellprice 
              AND "INVSTO_PurchaseRate" = v_sphyprice 
              AND "INVSTO_PurchaseDate" = v_sPurchaseDate 
              AND "INVMST_Id" = v_newstoreid;
        ELSE
            
            SELECT "IMFY_Id" INTO v_IMFY_Id 
            FROM "IVRM_Master_FinancialYear" 
            WHERE CURRENT_TIMESTAMP BETWEEN "IMFY_fromdate" AND "IMFY_Todate"
            LIMIT 1;
            
            RAISE NOTICE '--3---';
            
            INSERT INTO "INV"."INV_Stock"(
                "MI_Id", "INVMI_Id", "INVSTO_PurchaseDate", "INVSTO_AvaiableStock", 
                "INVSTO_SalesRate", "INVSTO_PurchaseRate", "INVSTO_BatchNo", 
                "INVSTO_PurOBQty", "INVSTO_PurRetQty", "INVSTO_SalesQty", 
                "INVSTO_SalesRetQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", 
                "INVMST_Id", "IMFY_Id", "CreatedDate", "UpdatedDate"
            )
            VALUES (
                v_newMI_Id, v_newitem, v_PurchaseDate, v_newqty, 
                v_newsellprice, v_newphyprice, v_newbatch, 
                v_newqty, 0, 0, 0, 0, 0, 
                v_newstoreid, v_IMFY_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
        END IF;

    END LOOP;

    RETURN;

END;
$$;