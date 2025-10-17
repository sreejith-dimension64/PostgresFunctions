CREATE OR REPLACE FUNCTION "INV"."INV_ClosingStockDetailed_Report"(
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
            DROP TABLE IF EXISTS "PrevFYItemWiseQtyDetailed_Temp";
            CREATE TEMP TABLE "PrevFYItemWiseQtyDetailed_Temp" AS
            SELECT DISTINCT "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", 
                CAST("IOB"."INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate",
                COALESCE(SUM("INVOB_Qty"), 0) AS "INVOB_Qty"
            FROM "INV"."INV_Master_Item" "IMI"
            INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "IMI"."INVMI_Id"
            WHERE "INVMI_ActiveFlg" = true AND "IOB"."INVOB_ActiveFlg" = true 
                AND "IMI"."MI_Id" = p_MI_Id AND "IOB"."MI_Id" = p_MI_Id 
                AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day'
            GROUP BY "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", CAST("IOB"."INVOB_PurchaseDate" AS date);

            DROP TABLE IF EXISTS "CurrentFYItemWiseQtyDetailed_Temp";
            CREATE TEMP TABLE "CurrentFYItemWiseQtyDetailed_Temp" AS
            SELECT DISTINCT "INVMI_Id", "INVMI_ItemCode", "INVMI_ItemName", "INVSTO_PurchaseDate",
                ("INVSTO_PurOBQty" + "INVSTO_SalesRetQty" + "INVSTO_MatIssPlusQty") - 
                ("INVSTO_PurRetQty" + "INVSTO_ItemConQty" + "INVSTO_DisposedQty" + "INVSTO_SalesQty" + "INVSTO_MatIssMinusQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "INS"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", 
                    CAST("INS"."INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
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
                GROUP BY "INS"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", CAST("INS"."INVSTO_PurchaseDate" AS date)
            ) AS "New";

            UPDATE "CurrentFYItemWiseQtyDetailed_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "PrevFYItemWiseQtyDetailed_Temp" "PT"
            WHERE "CY"."INVMI_Id" = "PT"."INVMI_Id" AND "PT"."INVOB_PurchaseDate" = "CY"."INVSTO_PurchaseDate";

            PERFORM * FROM "CurrentFYItemWiseQtyDetailed_Temp";

        ELSIF p_Type = 'GroupWise' THEN
            DROP TABLE IF EXISTS "PrevFYGroupWiseDetailed_Temp";
            CREATE TEMP TABLE "PrevFYGroupWiseDetailed_Temp" AS
            SELECT DISTINCT "IMG"."INVMG_Id", "IMG"."INVMG_GroupName", 
                CAST("IOB"."INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate",
                COALESCE(SUM("INVOB_Qty"), 0) AS "INVOB_Qty"
            FROM "INV"."INV_Master_Item" "IMI"
            INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "IMI"."INVMI_Id"
            INNER JOIN "INV"."INV_Master_Group" "IMG" ON "IMG"."INVMG_Id" = "IMI"."INVMG_Id"
            WHERE "INVMG_ActiveFlg" = true AND "IOB"."INVOB_ActiveFlg" = true 
                AND "IMI"."MI_Id" = p_MI_Id AND "IOB"."MI_Id" = p_MI_Id 
                AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day'
            GROUP BY "IMG"."INVMG_Id", "IMG"."INVMG_GroupName", CAST("IOB"."INVOB_PurchaseDate" AS date);

            DROP TABLE IF EXISTS "CurrentFYGroupWiseDetailed_Temp";
            CREATE TEMP TABLE "CurrentFYGroupWiseDetailed_Temp" AS
            SELECT DISTINCT "INVMG_Id", "INVMG_GroupName", "INVSTO_PurchaseDate",
                ("INVSTO_PurOBQty" + "INVSTO_SalesRetQty" + "INVSTO_MatIssPlusQty") - 
                ("INVSTO_PurRetQty" + "INVSTO_ItemConQty" + "INVSTO_DisposedQty" + "INVSTO_SalesQty" + "INVSTO_MatIssMinusQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "IMG"."INVMG_Id", "IMG"."INVMG_GroupName", 
                    CAST("INS"."INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
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
                GROUP BY "IMG"."INVMG_Id", "IMG"."INVMG_GroupName", CAST("INS"."INVSTO_PurchaseDate" AS date)
            ) AS "New";

            UPDATE "CurrentFYGroupWiseDetailed_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "PrevFYGroupWiseDetailed_Temp" "PT"
            WHERE "CY"."INVMG_Id" = "PT"."INVMG_Id" AND "PT"."INVOB_PurchaseDate" = "CY"."INVSTO_PurchaseDate";

            PERFORM * FROM "CurrentFYGroupWiseDetailed_Temp";

        ELSIF p_Type = 'StoreWise' THEN
            DROP TABLE IF EXISTS "PrevFYStoreWiseDetailed_Temp";
            CREATE TEMP TABLE "PrevFYStoreWiseDetailed_Temp" AS
            SELECT DISTINCT "IMS"."INVMST_Id", "IMS"."INVMS_StoreName", 
                CAST("IOB"."INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate",
                COALESCE(SUM("INVOB_Qty"), 0) AS "INVOB_Qty"
            FROM "INV"."INV_Master_Item" "IMI"
            INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "IMI"."INVMI_Id"
            INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id" = "IMI"."INVMG_Id"
            WHERE "INVMS_ActiveFlg" = true AND "IOB"."INVOB_ActiveFlg" = true 
                AND "IMI"."MI_Id" = p_MI_Id AND "IOB"."MI_Id" = p_MI_Id 
                AND CAST("INVOB_OBDate" AS date) = p_FromDate - INTERVAL '1 day'
            GROUP BY "IMS"."INVMST_Id", "IMS"."INVMS_StoreName", CAST("IOB"."INVOB_PurchaseDate" AS date);

            DROP TABLE IF EXISTS "CurrentFYStoreWiseDetailed_Temp";
            CREATE TEMP TABLE "CurrentFYStoreWiseDetailed_Temp" AS
            SELECT DISTINCT "INVMST_Id", "INVMS_StoreName", "INVSTO_PurchaseDate",
                ("INVSTO_PurOBQty" + "INVSTO_SalesRetQty" + "INVSTO_MatIssPlusQty") - 
                ("INVSTO_PurRetQty" + "INVSTO_ItemConQty" + "INVSTO_DisposedQty" + "INVSTO_SalesQty" + "INVSTO_MatIssMinusQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "IMS"."INVMST_Id", "IMS"."INVMS_StoreName", 
                    CAST("INS"."INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
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
                GROUP BY "IMS"."INVMST_Id", "IMS"."INVMS_StoreName", "INVSTO_PurchaseDate"
            ) AS "New";

            UPDATE "CurrentFYStoreWiseDetailed_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "PrevFYStoreWiseDetailed_Temp" "PT"
            WHERE "CY"."INVMST_Id" = "PT"."INVMST_Id" AND "PT"."INVOB_PurchaseDate" = "CY"."INVSTO_PurchaseDate";

            PERFORM * FROM "CurrentFYStoreWiseDetailed_Temp";
        END IF;
    END IF;

    IF (v_PrevFYDateDiff <> 0) THEN
        SELECT "IMFY_FromDate" INTO v_PrevFYStartdate 
        FROM "IVRM_Master_Financialyear" 
        WHERE (p_FromDate - INTERVAL '1 day') BETWEEN "IMFY_FromDate" AND "IMFY_ToDate";

        IF p_Type = 'ItemWise' THEN
            DROP TABLE IF EXISTS "DiffPrevYearItemWiseClosingQtyDetailed_Temp";
            CREATE TEMP TABLE "DiffPrevYearItemWiseClosingQtyDetailed_Temp" AS
            SELECT "INVMI_Id", "INVMI_ItemCode", "INVMI_ItemName", "INVMGRN_PurchaseDate", "INVMSL_SalesDate",
                ("INVTGRN_Qty" + "INVTSLRET_SalesReturnQty") - ("INVTGRNRET_ReturnQty" + "INVTSL_SalesQty" + "INVTIC_ICQty" + "INVADI_DisposedQty") AS "INVOB_Qty"
            FROM (
                SELECT DISTINCT "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", 
                    CAST("IMG"."INVMGRN_PurchaseDate" AS date) AS "INVMGRN_PurchaseDate", 
                    CAST("INVMSL_SalesDate" AS date) AS "INVMSL_SalesDate",
                    COALESCE(SUM("ITG"."INVTGRN_Qty"), 0) AS "INVTGRN_Qty",
                    COALESCE(SUM("GRET"."INVTGRNRET_ReturnQty"), 0) AS "INVTGRNRET_ReturnQty",
                    COALESCE(SUM("ITS"."INVTSL_SalesQty"), 0) AS "INVTSL_SalesQty",
                    COALESCE(SUM("ITSR"."INVTSLRET_SalesReturnQty"), 0) AS "INVTSLRET_SalesReturnQty",
                    COALESCE(SUM("ITIC"."INVTIC_ICQty"), 0) AS "INVTIC_ICQty",
                    (SELECT COALESCE(SUM("INVADI_DisposedQty"), 0) FROM "INV"."INV_Asset_Dispose" 
                     WHERE CAST("INVADI_DisposedDate" AS date) BETWEEN v_PrevFYStartdate AND p_FromDate - INTERVAL '1 day') AS "INVADI_DisposedQty"
                FROM "INV"."INV_Master_Item" "IMI"
                INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id" = "IMI"."INVMI_Id"
                INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id" = "ITG"."INVMGRN_Id" AND "IMG"."MI_Id" = "IMI"."MI_Id"
                LEFT JOIN "INV"."INV_M_GRN_Return" "GRE" ON "GRE"."INVMGRN_Id" = "IMG"."INVMGRN_Id"
                LEFT JOIN "INV"."INV_T_GRN_Return" "GRET" ON "GRET"."INVMGRNRET_Id" = "GRE"."INVMGRNRET_Id" 
                    AND "GRET"."INVMI_Id" = "ITG"."INVMI_Id" AND "GRET"."INVTGRNRET_ActiveFlg" = true
                LEFT JOIN "INV"."INV_T_Sales" "ITS" ON "ITS"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "INVTSL_ActiveFlg" = true AND "ITS"."INVTSL_ActiveFlg" = true
                LEFT JOIN "INV"."INV_M_Sales" "IMSL" ON "IMSL"."INVMSL_Id" = "ITS"."INVMSL_Id" 
                    AND "IMSL"."MI_Id" = "IMI"."MI_Id" AND "IMSL"."INVMSL_ActiveFlg" = true
                LEFT JOIN "INV"."INV_M_Sales_Return" "IMSLR" ON "IMSLR"."INVMSL_Id" = "IMSL"."INVMSL_Id" 
                    AND "IMSLR"."INVMSLRET_ActiveFlg" = true
                LEFT JOIN "INV"."INV_T_Sales_Return" "ITSR" ON "ITSR"."INVMSLRET_Id" = "IMSLR"."INVMSLRET_Id" 
                    AND "ITSR"."INVMI_Id" = "IMI"."INVMI_Id" AND "ITSR"."INVTSLRET_ActiveFlg" = true
                LEFT JOIN "INV"."INV_T_ItemConsumption" "ITIC" ON "ITIC"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "ITIC"."INVTIC_ActiveFlg" = true
                LEFT JOIN "INV"."INV_M_ItemConsumption" "IMIC" ON "IMIC"."INVMIC_Id" = "ITIC"."INVMIC_Id" 
                    AND "IMIC"."INVMIC_ActiveFlg" = true
                WHERE "INVMI_ActiveFlg" = true AND "IMG"."INVMGRN_ActiveFlg" = true 
                    AND "ITG"."INVTGRN_ActiveFlg" = true AND "IMI"."MI_Id" = p_MI_Id 
                    AND "IMG"."MI_Id" = p_MI_Id AND "IMI"."INVMI_Id" = p_MI_Id
                    AND CAST("IMG"."INVMGRN_PurchaseDate" AS date) BETWEEN v_PrevFYStartdate AND p_FromDate - INTERVAL '1 day'
                GROUP BY "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", "INVMGRN_PurchaseDate", CAST("INVMSL_SalesDate" AS date)
            ) AS "New";

            DROP TABLE IF EXISTS "DiffCurrentYearItemWiseClosingQtyDetailed_Temp";
            CREATE TEMP TABLE "DiffCurrentYearItemWiseClosingQtyDetailed_Temp" AS
            SELECT "INVMI_Id", "INVMI_ItemCode", "INVMI_ItemName", "INVMGRN_PurchaseDate", "INVMSL_SalesDate",
                ("INVTGRN_Qty" + "INVTSLRET_SalesReturnQty") - ("INVTGRNRET_ReturnQty" + "INVTSL_SalesQty" + "INVTIC_ICQty" + "INVADI_DisposedQty") AS "ClosingStock"
            FROM (
                SELECT DISTINCT "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", 
                    CAST("IMG"."INVMGRN_PurchaseDate" AS date) AS "INVMGRN_PurchaseDate", 
                    CAST("INVMSL_SalesDate" AS date) AS "INVMSL_SalesDate",
                    COALESCE(SUM("ITG"."INVTGRN_Qty"), 0) AS "INVTGRN_Qty",
                    COALESCE(SUM("GRET"."INVTGRNRET_ReturnQty"), 0) AS "INVTGRNRET_ReturnQty",
                    COALESCE(SUM("ITS"."INVTSL_SalesQty"), 0) AS "INVTSL_SalesQty",
                    COALESCE(SUM("ITSR"."INVTSLRET_SalesReturnQty"), 0) AS "INVTSLRET_SalesReturnQty",
                    COALESCE(SUM("ITIC"."INVTIC_ICQty"), 0) AS "INVTIC_ICQty",
                    (SELECT COALESCE(SUM("INVADI_DisposedQty"), 0) FROM "INV"."INV_Asset_Dispose" 
                     WHERE CAST("INVADI_DisposedDate" AS date) BETWEEN p_FromDate AND p_ToDate) AS "INVADI_DisposedQty"
                FROM "INV"."INV_Master_Item" "IMI"
                INNER JOIN "INV"."INV_T_GRN" "ITG" ON "ITG"."INVMI_Id" = "IMI"."INVMI_Id"
                INNER JOIN "INV"."INV_M_GRN" "IMG" ON "IMG"."INVMGRN_Id" = "ITG"."INVMGRN_Id" AND "IMG"."MI_Id" = "IMI"."MI_Id"
                LEFT JOIN "INV"."INV_M_GRN_Return" "GRE" ON "GRE"."INVMGRN_Id" = "IMG"."INVMGRN_Id"
                LEFT JOIN "INV"."INV_T_GRN_Return" "GRET" ON "GRET"."INVMGRNRET_Id" = "GRE"."INVMGRNRET_Id" 
                    AND "GRET"."INVMI_Id" = "ITG"."INVMI_Id" AND "GRET"."INVTGRNRET_ActiveFlg" = true
                LEFT JOIN "INV"."INV_T_Sales" "ITS" ON "ITS"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "INVTSL_ActiveFlg" = true AND "ITS"."INVTSL_ActiveFlg" = true
                LEFT JOIN "INV"."INV_M_Sales" "IMSL" ON "IMSL"."INVMSL_Id" = "ITS"."INVMSL_Id" 
                    AND "IMSL"."MI_Id" = "IMI"."MI_Id" AND "IMSL"."INVMSL_ActiveFlg" = true
                LEFT JOIN "INV"."INV_M_Sales_Return" "IMSLR" ON "IMSLR"."INVMSL_Id" = "IMSL"."INVMSL_Id" 
                    AND "IMSLR"."INVMSLRET_ActiveFlg" = true
                LEFT JOIN "INV"."INV_T_Sales_Return" "ITSR" ON "ITSR"."INVMSLRET_Id" = "IMSLR"."INVMSLRET_Id" 
                    AND "ITSR"."INVMI_Id" = "IMI"."INVMI_Id" AND "ITSR"."INVTSLRET_ActiveFlg" = true
                LEFT JOIN "INV"."INV_T_ItemConsumption" "ITIC" ON "ITIC"."INVMI_Id" = "ITG"."INVMI_Id" 
                    AND "ITIC"."INVTIC_ActiveFlg" = true
                LEFT JOIN "INV"."INV_M_ItemConsumption" "IMIC" ON "IMIC"."INVMIC_Id" = "ITIC"."INVMIC_Id" 
                    AND "IMIC"."INVMIC_ActiveFlg" = true
                WHERE "INVMI_ActiveFlg" = true AND "IMG"."INVMGRN_ActiveFlg" = true 
                    AND "ITG"."INVTGRN_ActiveFlg" = true AND "IMI"."MI_Id" = p_MI_Id 
                    AND "IMG"."MI_Id" = p_MI_Id AND "IMI"."INVMI_Id" = p_MI_Id
                    AND CAST("IMG"."INVMGRN_PurchaseDate" AS date) BETWEEN p_FromDate AND p_Todate
                GROUP BY "IMI"."INVMI_Id", "IMI"."INVMI_ItemCode", "INVMI_ItemName", CAST("IMG"."INVMGRN_PurchaseDate" AS date), CAST("INVMSL_SalesDate" AS date)
            ) AS "New";

            UPDATE "DiffCurrentYearItemWiseClosingQtyDetailed_Temp" "CY"
            SET "ClosingStock" = "CY"."ClosingStock" + "PT"."INVOB_Qty"
            FROM "DiffPrevYearItemWiseClosingQtyDetailed_Temp" "PT"
            WHERE "CY"."INVMI_Id" = "PT"."INVMI_Id" AND "PT"."INVMGRN_PurchaseDate" = "CY"."INVMGRN_PurchaseDate";

            PERFORM * FROM "DiffCurrentYearItemWiseClosingQtyDetailed_Temp";

        ELSIF p_Type = 'GroupWise' THEN
            DROP TABLE IF EXISTS "DiffPrevYearGroupWiseClosingQtyDetailed_Temp";
            CREATE TEMP TABLE "DiffPrevYearGroupWiseClosingQtyDetailed_Temp" AS
            SELECT "INVMG_Id", "INVMG_GroupName", "INVMGRN_PurchaseDate", "INVMSL_SalesDate",
                ("INVTGRN_Qty" + "INVTSLRET_SalesReturnQty") - ("INVTGRNRET_ReturnQty" + "INVTSL_SalesQty" + "INVTIC_ICQty" + "INVADI_DisposedQty") AS "INVOB_Qty"
            FROM (
                SELECT DISTINCT "IMGR"."INVMG_Id", "IMGR"."INVMG_GroupName", 
                    CAST("IMG"."INVMGRN_PurchaseDate" AS date) AS "INVMGRN_PurchaseDate", 
                    CAST("INVMSL_SalesDate" AS date) AS "INVMSL_SalesDate",
                