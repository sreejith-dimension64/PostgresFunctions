CREATE OR REPLACE FUNCTION "dbo"."INV_ClosingStockConsolidated_Report"(
    p_MI_Id bigint,
    p_FromDate date,
    p_Todate date,
    p_Type varchar(200)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FYCount bigint;
    v_PrevFYDateSame bigint;
    v_PrevFYDateDiff bigint;
    v_PrevFYStartdate date;
BEGIN
    v_FYCount := 0;
    v_PrevFYDateSame := 0;
    v_PrevFYDateDiff := 0;

    SELECT COUNT(*) INTO v_FYCount 
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_FromDate" >= p_FromDate AND "IMFY_ToDate" <= p_Todate;

    RAISE NOTICE '%', v_FYCount;

    IF (v_FYCount = 0) THEN
        RAISE NOTICE 'Create the Financial Year in Master Page';
    ELSIF (v_FYCount <> 0) THEN
        SELECT COUNT(*) INTO v_PrevFYDateSame 
        FROM "INV"."INV_OpeningBalance" 
        WHERE "MI_Id" = p_MI_Id AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day';
        
        SELECT COUNT(*) INTO v_PrevFYDateDiff 
        FROM "INV"."INV_OpeningBalance" 
        WHERE "MI_Id" = p_MI_Id AND CAST("INVOB_OBDate" AS date) <> p_FromDate - INTERVAL '1 day';
    END IF;

    IF (v_PrevFYDateSame <> 0) THEN

        IF p_Type = 'ItemWise' THEN

            DROP TABLE IF EXISTS "PrevFYItemWiseQty_Temp";
            CREATE TEMP TABLE "PrevFYItemWiseQty_Temp" AS
            SELECT DISTINCT "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", 
                   COALESCE(SUM("INVOB_Qty"), 0) AS "INVOB_Qty"
            FROM "INV"."INV_Master_Item" "IMI"
            INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "IMI"."INVMI_Id"
            WHERE "INVMI_ActiveFlg" = 1 AND "IOB"."INVOB_ActiveFlg" = 1 
                AND "IMI"."MI_Id" = p_MI_Id AND "IOB"."MI_Id" = p_MI_Id 
                AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day'
            GROUP BY "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName";

            DROP TABLE IF EXISTS "CurrentFYItemWiseQty_Temp";
            CREATE TEMP TABLE "CurrentFYItemWiseQty_Temp" AS
            SELECT DISTINCT "INVMI_Id", "INVMI_ItemCode", "INVMI_ItemName",
                   ("INVSTO_PurOBQty" + "INVSTO_SalesRetQty" + "INVSTO_MatIssPlusQty") - 
                   ("INVSTO_PurRetQty" + "INVSTO_ItemConQty" + "INVSTO_DisposedQty" + "INVSTO_SalesQty" + "INVSTO_MatIssMinusQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "INS"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName",
                       COALESCE(SUM("INVSTO_PurOBQty"), 0) AS "INVSTO_PurOBQty",
                       COALESCE(SUM("INVSTO_AvaiableStock"), 0) AS "INVSTO_AvaiableStock",
                       COALESCE(SUM("INVSTO_SalesRetQty"), 0) AS "INVSTO_SalesRetQty",
                       COALESCE(SUM("INVSTO_MatIssPlusQty"), 0) AS "INVSTO_MatIssPlusQty",
                       COALESCE(SUM("INVSTO_PurRetQty"), 0) AS "INVSTO_PurRetQty",
                       COALESCE(SUM("INVSTO_ItemConQty"), 0) AS "INVSTO_ItemConQty",
                       COALESCE(SUM("INVSTO_DisposedQty"), 0) AS "INVSTO_DisposedQty",
                       COALESCE(SUM("INVSTO_SalesQty"), 0) AS "INVSTO_SalesQty",
                       COALESCE(SUM("INVSTO_MatIssMinusQty"), 0) AS "INVSTO_MatIssMinusQty"
                FROM "INV"."INV_Stock" "INS"
                INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "INS"."INVMI_Id"
                WHERE "IMI"."MI_Id" = p_MI_Id 
                    AND CAST("INS"."INVSTO_PurchaseDate" AS date) BETWEEN p_FromDate AND p_Todate
                GROUP BY "INS"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName"
            ) AS "New";

            UPDATE "CurrentFYItemWiseQty_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "PrevFYItemWiseQty_Temp" "PT"
            WHERE "CY"."INVMI_Id" = "PT"."INVMI_Id";

            RETURN QUERY SELECT * FROM "CurrentFYItemWiseQty_Temp";

        ELSIF p_Type = 'GroupWise' THEN

            DROP TABLE IF EXISTS "PrevFYGroupWise_Temp";
            CREATE TEMP TABLE "PrevFYGroupWise_Temp" AS
            SELECT DISTINCT "IMG"."INVMG_Id", "IMG"."INVMG_GroupName", 
                   COALESCE(SUM("INVOB_Qty"), 0) AS "INVOB_Qty"
            FROM "INV"."INV_Master_Item" "IMI"
            INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "IMI"."INVMI_Id"
            INNER JOIN "INV"."INV_Master_Group" "IMG" ON "IMG"."INVMG_Id" = "IMI"."INVMG_Id"
            WHERE "INVMG_ActiveFlg" = 1 AND "IOB"."INVOB_ActiveFlg" = 1 
                AND "IMI"."MI_Id" = p_MI_Id AND "IOB"."MI_Id" = p_MI_Id 
                AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day'
            GROUP BY "IMG"."INVMG_Id", "IMG"."INVMG_GroupName";

            DROP TABLE IF EXISTS "CurrentFYGroupWise_Temp";
            CREATE TEMP TABLE "CurrentFYGroupWise_Temp" AS
            SELECT DISTINCT "INVMG_Id", "INVMG_GroupName",
                   ("INVSTO_PurOBQty" + "INVSTO_SalesRetQty" + "INVSTO_MatIssPlusQty") - 
                   ("INVSTO_PurRetQty" + "INVSTO_ItemConQty" + "INVSTO_DisposedQty" + "INVSTO_SalesQty" + "INVSTO_MatIssMinusQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "IMG"."INVMG_Id", "IMG"."INVMG_GroupName",
                       COALESCE(SUM("INVSTO_PurOBQty"), 0) AS "INVSTO_PurOBQty",
                       COALESCE(SUM("INVSTO_AvaiableStock"), 0) AS "INVSTO_AvaiableStock",
                       COALESCE(SUM("INVSTO_SalesRetQty"), 0) AS "INVSTO_SalesRetQty",
                       COALESCE(SUM("INVSTO_MatIssPlusQty"), 0) AS "INVSTO_MatIssPlusQty",
                       COALESCE(SUM("INVSTO_PurRetQty"), 0) AS "INVSTO_PurRetQty",
                       COALESCE(SUM("INVSTO_ItemConQty"), 0) AS "INVSTO_ItemConQty",
                       COALESCE(SUM("INVSTO_DisposedQty"), 0) AS "INVSTO_DisposedQty",
                       COALESCE(SUM("INVSTO_SalesQty"), 0) AS "INVSTO_SalesQty",
                       COALESCE(SUM("INVSTO_MatIssMinusQty"), 0) AS "INVSTO_MatIssMinusQty"
                FROM "INV"."INV_Stock" "INS"
                INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "INS"."INVMI_Id"
                INNER JOIN "INV"."INV_Master_Group" "IMG" ON "IMG"."INVMG_Id" = "IMI"."INVMG_Id"
                WHERE "IMI"."MI_Id" = p_MI_Id 
                    AND CAST("INS"."INVSTO_PurchaseDate" AS date) BETWEEN p_FromDate AND p_Todate
                GROUP BY "IMG"."INVMG_Id", "IMG"."INVMG_GroupName"
            ) AS "New";

            UPDATE "CurrentFYGroupWise_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "PrevFYGroupWise_Temp" "PT"
            WHERE "CY"."INVMG_Id" = "PT"."INVMG_Id";

            RETURN QUERY SELECT * FROM "CurrentFYGroupWise_Temp";

        ELSIF p_Type = 'StoreWise' THEN

            DROP TABLE IF EXISTS "PrevFYStoreWise_Temp";
            CREATE TEMP TABLE "PrevFYStoreWise_Temp" AS
            SELECT DISTINCT "IMS"."INVMST_Id", "IMS"."INVMS_StoreName", 
                   COALESCE(SUM("INVOB_Qty"), 0) AS "INVOB_Qty"
            FROM "INV"."INV_Master_Item" "IMI"
            INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "IMI"."INVMI_Id"
            INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "IMI"."INVMG_Id"
            WHERE "INVMS_ActiveFlg" = 1 AND "IOB"."INVOB_ActiveFlg" = 1 
                AND "IMI"."MI_Id" = p_MI_Id AND "IOB"."MI_Id" = p_MI_Id 
                AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day'
            GROUP BY "IMS"."INVMST_Id", "IMS"."INVMS_StoreName";

            DROP TABLE IF EXISTS "CurrentFYStoreWise_Temp";
            CREATE TEMP TABLE "CurrentFYStoreWise_Temp" AS
            SELECT DISTINCT "INVMST_Id", "INVMS_StoreName",
                   ("INVSTO_PurOBQty" + "INVSTO_SalesRetQty" + "INVSTO_MatIssPlusQty") - 
                   ("INVSTO_PurRetQty" + "INVSTO_ItemConQty" + "INVSTO_DisposedQty" + "INVSTO_SalesQty" + "INVSTO_MatIssMinusQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "IMS"."INVMST_Id", "IMS"."INVMS_StoreName",
                       COALESCE(SUM("INVSTO_PurOBQty"), 0) AS "INVSTO_PurOBQty",
                       COALESCE(SUM("INVSTO_AvaiableStock"), 0) AS "INVSTO_AvaiableStock",
                       COALESCE(SUM("INVSTO_SalesRetQty"), 0) AS "INVSTO_SalesRetQty",
                       COALESCE(SUM("INVSTO_MatIssPlusQty"), 0) AS "INVSTO_MatIssPlusQty",
                       COALESCE(SUM("INVSTO_PurRetQty"), 0) AS "INVSTO_PurRetQty",
                       COALESCE(SUM("INVSTO_ItemConQty"), 0) AS "INVSTO_ItemConQty",
                       COALESCE(SUM("INVSTO_DisposedQty"), 0) AS "INVSTO_DisposedQty",
                       COALESCE(SUM("INVSTO_SalesQty"), 0) AS "INVSTO_SalesQty",
                       COALESCE(SUM("INVSTO_MatIssMinusQty"), 0) AS "INVSTO_MatIssMinusQty"
                FROM "INV"."INV_Stock" "INS"
                INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "INS"."INVMI_Id"
                INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "IMI"."INVMG_Id"
                WHERE "IMI"."MI_Id" = p_MI_Id 
                    AND CAST("INS"."INVSTO_PurchaseDate" AS date) BETWEEN p_FromDate AND p_Todate
                GROUP BY "IMS"."INVMST_Id", "IMS"."INVMS_StoreName"
            ) AS "New";

            UPDATE "CurrentFYStoreWise_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "PrevFYStoreWise_Temp" "PT"
            WHERE "CY"."INVMST_Id" = "PT"."INVMST_Id";

            RETURN QUERY SELECT * FROM "CurrentFYStoreWise_Temp";

        END IF;

    END IF;

    IF (v_PrevFYDateDiff <> 0) THEN

        SELECT "IMFY_FromDate" INTO v_PrevFYStartdate 
        FROM "IVRM_Master_Financialyear" 
        WHERE p_FromDate - INTERVAL '1 day' BETWEEN "IMFY_FromDate" AND "IMFY_ToDate";

        IF p_Type = 'ItemWise' THEN

            DROP TABLE IF EXISTS "DiffPrevYearItemWiseClosingQty_Temp";
            CREATE TEMP TABLE "DiffPrevYearItemWiseClosingQty_Temp" AS
            SELECT "INVMI_Id", "INVMI_ItemCode", "INVMI_ItemName",
                   ("INVTGRN_Qty" + "INVTSLRET_SalesReturnQty") - 
                   ("INVTGRNRET_ReturnQty" + "INVTSL_SalesQty" + "INVTIC_ICQty" + "INVADI_DisposedQty") AS "INVOB_Qty"
            FROM (
                SELECT DISTINCT "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName",
                       COALESCE(SUM("ITG"."INVTGRN_Qty"), 0) AS "INVTGRN_Qty",
                       COALESCE(SUM("GRET"."INVTGRNRET_ReturnQty"), 0) AS "INVTGRNRET_ReturnQty",
                       COALESCE(SUM("ITS"."INVTSL_SalesQty"), 0) AS "INVTSL_SalesQty",
                       COALESCE(SUM("ITSR"."INVTSLRET_SalesReturnQty"), 0) AS "INVTSLRET_SalesReturnQty",
                       COALESCE(SUM("ITIC"."INVTIC_ICQty"), 0) AS "INVTIC_ICQty",
                       (SELECT COALESCE(SUM("INVADI_DisposedQty"), 0) 
                        FROM "INV"."INV_Asset_Dispose" 
                        WHERE CAST("INVADI_DisposedDate" AS date) BETWEEN v_PrevFYStartdate AND p_FromDate - INTERVAL '1 day') AS "INVADI_DisposedQty"
                FROM "INV"."INV_Master_Item" "IMI"
                INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id" = "IMI"."INVMI_Id"
                INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id" = "ITG"."INVMGRN_Id" AND "IMG"."MI_Id" = "IMI"."MI_Id"
                LEFT JOIN "INV"."INV_M_GRN_Return" "GRE" ON "GRE"."INVMGRN_Id" = "IMG"."INVMGRN_Id"
                LEFT JOIN "INV"."INV_T_GRN_Return" "GRET" ON "GRET"."INVMGRNRET_Id" = "GRE"."INVMGRNRET_Id" 
                    AND "GRET"."INVMI_Id" = "ITG"."INVMI_Id" AND "GRET"."INVTGRNRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_Sales" "ITS" ON "ITS"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "INVTSL_ActiveFlg" = 1 AND "ITS"."INVTSL_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_Sales" "IMSL" ON "IMSL"."INVMSL_Id" = "ITS"."INVMSL_Id" 
                    AND "IMSL"."MI_Id" = "IMI"."MI_Id" AND "IMSL"."INVMSL_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_Sales_Return" "IMSLR" ON "IMSLR"."INVMSL_Id" = "IMSL"."INVMSL_Id" 
                    AND "IMSLR"."INVMSLRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_Sales_Return" "ITSR" ON "ITSR"."INVMSLRET_Id" = "IMSLR"."INVMSLRET_Id" 
                    AND "ITSR"."INVMI_Id" = "IMI"."INVMI_Id" AND "ITSR"."INVTSLRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_ItemConsumption" "ITIC" ON "ITIC"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "ITIC"."INVTIC_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_ItemConsumption" "IMIC" ON "IMIC"."INVMIC_Id" = "ITIC"."INVMIC_Id" 
                    AND "IMIC"."INVMIC_ActiveFlg" = 1
                WHERE "INVMI_ActiveFlg" = 1 AND "IMG"."INVMGRN_ActiveFlg" = 1 AND "ITG"."INVTGRN_ActiveFlg" = 1
                    AND "IMI"."MI_Id" = p_MI_Id AND "IMG"."MI_Id" = p_MI_Id AND "IMI"."INVMI_Id" = p_MI_Id
                    AND CAST("IMG"."INVMGRN_PurchaseDate" AS date) BETWEEN v_PrevFYStartdate AND p_FromDate - INTERVAL '1 day'
                GROUP BY "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName"
            ) AS "New";

            DROP TABLE IF EXISTS "DiffCurrentYearItemWiseClosingQty_Temp";
            CREATE TEMP TABLE "DiffCurrentYearItemWiseClosingQty_Temp" AS
            SELECT "INVMI_Id", "INVMI_ItemCode", "INVMI_ItemName",
                   ("INVTGRN_Qty" + "INVTSLRET_SalesReturnQty") - 
                   ("INVTGRNRET_ReturnQty" + "INVTSL_SalesQty" + "INVTIC_ICQty" + "INVADI_DisposedQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName",
                       COALESCE(SUM("ITG"."INVTGRN_Qty"), 0) AS "INVTGRN_Qty",
                       COALESCE(SUM("GRET"."INVTGRNRET_ReturnQty"), 0) AS "INVTGRNRET_ReturnQty",
                       COALESCE(SUM("ITS"."INVTSL_SalesQty"), 0) AS "INVTSL_SalesQty",
                       COALESCE(SUM("ITSR"."INVTSLRET_SalesReturnQty"), 0) AS "INVTSLRET_SalesReturnQty",
                       COALESCE(SUM("ITIC"."INVTIC_ICQty"), 0) AS "INVTIC_ICQty",
                       (SELECT COALESCE(SUM("INVADI_DisposedQty"), 0) 
                        FROM "INV"."INV_Asset_Dispose" 
                        WHERE CAST("INVADI_DisposedDate" AS date) BETWEEN p_FromDate AND p_ToDate) AS "INVADI_DisposedQty"
                FROM "INV"."INV_Master_Item" "IMI"
                INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id" = "IMI"."INVMI_Id"
                INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id" = "ITG"."INVMGRN_Id" AND "IMG"."MI_Id" = "IMI"."MI_Id"
                LEFT JOIN "INV"."INV_M_GRN_Return" "GRE" ON "GRE"."INVMGRN_Id" = "IMG"."INVMGRN_Id"
                LEFT JOIN "INV"."INV_T_GRN_Return" "GRET" ON "GRET"."INVMGRNRET_Id" = "GRE"."INVMGRNRET_Id" 
                    AND "GRET"."INVMI_Id" = "ITG"."INVMI_Id" AND "GRET"."INVTGRNRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_Sales" "ITS" ON "ITS"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "INVTSL_ActiveFlg" = 1 AND "ITS"."INVTSL_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_Sales" "IMSL" ON "IMSL"."INVMSL_Id" = "ITS"."INVMSL_Id" 
                    AND "IMSL"."MI_Id" = "IMI"."MI_Id" AND "IMSL"."INVMSL_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_Sales_Return" "IMSLR" ON "IMSLR"."INVMSL_Id" = "IMSL"."INVMSL_Id" 
                    AND "IMSLR"."INVMSLRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_Sales_Return" "ITSR" ON "ITSR"."INVMSLRET_Id" = "IMSLR"."INVMSLRET_Id" 
                    AND "ITSR"."INVMI_Id" = "IMI"."INVMI_Id" AND "ITSR"."INVTSLRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_ItemConsumption" "ITIC" ON "ITIC"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "ITIC"."INVTIC_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_ItemConsumption" "IMIC" ON "IMIC"."INVMIC_Id" = "ITIC"."INVMIC_Id" 
                    AND "IMIC"."INVMIC_ActiveFlg" = 1
                WHERE "INVMI_ActiveFlg" = 1 AND "IMG"."INVMGRN_ActiveFlg" = 1 AND "ITG"."INVTGRN_ActiveFlg" = 1
                    AND "IMI"."MI_Id" = p_MI_Id AND "IMG"."MI_Id" = p_MI_Id AND "IMI"."INVMI_Id" = p_MI_Id
                    AND CAST("IMG"."INVMGRN_PurchaseDate" AS date) BETWEEN p_FromDate AND p_Todate
                GROUP BY "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName"
            ) AS "New";

            UPDATE "DiffCurrentYearItemWiseClosingQty_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "DiffPrevYearItemWiseClosingQty_Temp" "PT"
            WHERE "CY"."INVMI_Id" = "PT"."INVMI_Id";

            RETURN QUERY SELECT * FROM "DiffCurrentYearItemWiseClosingQty_Temp";

        ELSIF p_Type = 'GroupWise' THEN

            DROP TABLE IF EXISTS "DiffPrevYearGroupWiseClosingQty_Temp";
            CREATE TEMP TABLE "DiffPrevYearGroupWiseClosingQty_Temp" AS
            SELECT "INVMG_Id", "INVMG_GroupName",
                   ("INVTGRN_Qty" + "INVTSLRET_SalesReturnQty") - 
                   ("INVTGRNRET_ReturnQty" + "INVTSL_SalesQty" + "INVTIC_ICQty" + "INVADI_DisposedQty") AS "INVOB_Qty"
            FROM (
                SELECT DISTINCT "IMGR"."INVMG_Id", "IMGR"."INVMG_GroupName",
                       COALESCE(SUM("ITG"."INVTGRN_Qty"), 0) AS "INVTGRN_Qty",
                       COALESCE(SUM("GRET"."INVTGRNRET_ReturnQty"), 0) AS "INVTGRNRET_ReturnQty",
                       COALESCE(SUM("ITS"."INVTSL_SalesQty"), 0) AS "INVTSL_SalesQty",
                       COALESCE(SUM("ITSR"."INVTSLRET_SalesReturnQty"), 0) AS "INVTSLRET_SalesReturnQty",
                       COALESCE(SUM("ITIC"."INVTIC_ICQty"), 0) AS "INVTIC_ICQty",
                       (SELECT COALESCE(SUM("INVADI_DisposedQty"), 0) 
                        FROM "INV"."INV_Asset_Dispose" 
                        WHERE CAST("INVADI_DisposedDate" AS date) BETWEEN v_PrevFYStartdate AND p_FromDate - INTERVAL '1 day') AS "INVADI_DisposedQty"
                FROM "INV"."INV_Master_Item" "IMI"
                INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id" = "IMI"."INVMI_Id"
                INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id" = "ITG"."INVMGRN_Id" AND "IMG"."MI_Id" = "IMI"."MI_Id"
                INNER JOIN "INV"."INV_Master_Group" "IMGR" ON "IMGR"."INVMG_Id" = "IMI"."INVMG_Id"
                LEFT JOIN "INV"."INV_M_GRN_Return" "GRE" ON "GRE"."INVMGRN_Id" = "IMG"."INVMGRN_Id"
                LEFT JOIN "INV"."INV_T_GRN_Return" "GRET" ON "GRET"."INVMGRNRET_Id" = "GRE"."INVMGRNRET_Id" 
                    AND "GRET"."INVMI_Id" = "ITG"."INVMI_Id" AND "GRET"."INVTGRNRET_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_T_Sales" "ITS" ON "ITS"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "INVTSL_ActiveFlg" = 1 AND "ITS"."INVTSL_ActiveFlg" = 1
                LEFT JOIN "INV"."INV_M_Sales" "IMSL" ON "IMSL"."