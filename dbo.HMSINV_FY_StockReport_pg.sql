CREATE OR REPLACE FUNCTION "dbo"."HMSINV_FY_StockReport"(
    p_MI_Id bigint,
    p_IMFY_FromDate varchar(10),
    p_IMFY_ToDate varchar(10),
    p_INVMI_Ids text,
    p_INVMST_Ids text,
    p_INVMG_Id text,
    p_optionflag varchar(100),
    p_overallflag varchar(100),
    p_storeid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_dates varchar(200);
    v_Slqdymaic text;
    v_IMFY_Id bigint;
BEGIN

IF p_storeid = 0 THEN

    SELECT "IMFY_Id" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE CURRENT_DATE BETWEEN "IMFY_fromdate" AND "IMFY_Todate";

    IF p_IMFY_FromDate != '' AND p_IMFY_ToDate != '' THEN
        v_dates := ' and "INVSTO_PurchaseDate"::date >= TO_DATE(''' || p_IMFY_FromDate || ''',''DD/MM/YYYY'') and "INVSTO_PurchaseDate"::date <= TO_DATE(''' || p_IMFY_ToDate || ''',''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        IF (p_overallflag = 'Overall') THEN
        
            v_Slqdymaic := '   
            SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName", 
            (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",
            (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
            SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
            SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",
            SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
            SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",
            SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
            FROM "INV"."INV_Stock" "INS" 
            INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
            INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id" 
            WHERE "INS"."MI_Id"=' || p_MI_Id::varchar || ' ' || v_dates || ' 
            GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName"
            ORDER BY "MI"."INVMI_ItemName"';

            EXECUTE v_Slqdymaic;
        ELSE
            v_Slqdymaic := '   
            SELECT "INVMI_Id","INVMI_ItemName","INVSTO_PurchaseRate","INVSTO_PurchaseDate",
            "INVSTO_SalesRate","SalesQty","PurOBQty","INVSTO_AvaiableStock","INVSTO_CheckedOutQty","INVSTO_DisposedQty",("INVSTO_PurchaseRate")*("PurOBQty") as "obAmount",
            "INVSTO_ItemConQty","INVSTO_PhyPlusQty","INVSTO_PhyMinQty","INVSTO_MatIssPlusQty","INVSTO_MatIssMinusQty" 
            FROM 
            (SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName",("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",("INVSTO_SalesRate") "INVSTO_SalesRate","INVSTO_PurchaseDate",(SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
            SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
            SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
            FROM "INV"."INV_Stock" "INS" 
            INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
            INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id" 
            WHERE "INS"."MI_Id"=' || p_MI_Id::varchar || ' ' || v_dates || ' 
            GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName","INVSTO_PurchaseRate","INVSTO_SalesRate","INVSTO_PurchaseDate","INVSTO_PurOBQty"
            ORDER BY "MI"."INVMI_ItemName" LIMIT 100) AS "New"';
            
            EXECUTE v_Slqdymaic;
        END IF;
    END IF;

    IF (p_optionflag = 'Item') THEN
        v_Slqdymaic := '   
        SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName",
        ("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",
        ("INVSTO_SalesRate") "INVSTO_SalesRate",
        "INVSTO_PurchaseDate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",
        SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",
        SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS" 
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."MI_Id"=' || p_MI_Id::varchar || ' and "INS"."INVMI_Id" IN (' || p_INVMI_Ids || ') ' || v_dates || '
        GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName","INVSTO_PurchaseRate","INVSTO_SalesRate","INVSTO_PurchaseDate"
        ORDER BY "MI"."INVMI_ItemName"';

        EXECUTE v_Slqdymaic;
    END IF;

    IF (p_optionflag = 'Store') THEN
        v_Slqdymaic := '  
        SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName", SUM("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",SUM("INVSTO_SalesRate") "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS" 
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."MI_Id"=' || p_MI_Id::varchar || ' and "INS"."INVMST_Id" IN (' || p_INVMST_Ids || ') ' || v_dates || '
        GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName"
        ORDER BY "MI"."INVMI_ItemName"';

        EXECUTE v_Slqdymaic;
    END IF;

    IF (p_optionflag = 'Group') THEN
        v_Slqdymaic := '  
        SELECT DISTINCT "MI"."INVMG_Id", "MG"."INVMG_GroupName","INS"."INVMI_Id", "MI"."INVMI_ItemName", SUM("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",SUM("INVSTO_SalesRate") "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS" 
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Group" "MG" ON "MI"."INVMG_Id"="MG"."INVMG_Id"
        WHERE "INS"."IMFY_Id"=' || v_IMFY_Id::varchar || ' AND "INS"."MI_Id"=' || p_MI_Id::varchar || ' and "INS"."INVMI_Id" IN 
        (SELECT DISTINCT b."INVMI_Id" from "INV"."INV_Master_Group" a,
        "INV"."INV_Master_Item" b
        WHERE a."INVMG_Id"=b."INVMG_Id" and a."MI_Id"=' || p_MI_Id::varchar || ' AND a."INVMG_Id"=' || p_INVMG_Id || ') ' || v_dates || '
        GROUP BY "MI"."INVMG_Id", "MG"."INVMG_GroupName","INS"."INVMI_Id", "MI"."INVMI_ItemName"
        ORDER BY "MG"."INVMG_GroupName"';

        EXECUTE v_Slqdymaic;
    END IF;

ELSE

    SELECT "IMFY_Id" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE CURRENT_DATE BETWEEN "IMFY_fromdate" AND "IMFY_Todate";

    IF p_IMFY_FromDate != '' AND p_IMFY_ToDate != '' THEN
        v_dates := ' and "INVSTO_PurchaseDate"::date >= TO_DATE(''' || p_IMFY_FromDate || ''',''DD/MM/YYYY'') and "INVSTO_PurchaseDate"::date <= TO_DATE(''' || p_IMFY_ToDate || ''',''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'All') THEN
        IF (p_overallflag = 'Overall') THEN
        
            v_Slqdymaic := '   
            SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName", 
            (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",
            (SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
            SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
            SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",
            SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
            SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",
            SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
            FROM "INV"."INV_Stock" "INS" 
            INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
            INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id" 
            WHERE "INS"."INVMST_Id"=' || p_storeid::varchar || ' AND "INS"."MI_Id"=' || p_MI_Id::varchar || ' ' || v_dates || ' 
            GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName"
            ORDER BY "MI"."INVMI_ItemName"';

            EXECUTE v_Slqdymaic;
        ELSE
            v_Slqdymaic := '   
            SELECT "INVMI_Id","INVMI_ItemName","INVSTO_PurchaseRate","INVSTO_PurchaseDate",
            "INVSTO_SalesRate","SalesQty","PurOBQty","INVSTO_AvaiableStock","INVSTO_CheckedOutQty","INVSTO_DisposedQty",("INVSTO_PurchaseRate")*("PurOBQty") as "obAmount",
            "INVSTO_ItemConQty","INVSTO_PhyPlusQty","INVSTO_PhyMinQty","INVSTO_MatIssPlusQty","INVSTO_MatIssMinusQty" 
            FROM 
            (SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName",("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",("INVSTO_SalesRate") "INVSTO_SalesRate","INVSTO_PurchaseDate",(SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
            SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
            SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
            FROM "INV"."INV_Stock" "INS" 
            INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
            INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id" 
            WHERE "INS"."INVMST_Id"=' || p_storeid::varchar || ' AND "INS"."MI_Id"=' || p_MI_Id::varchar || ' ' || v_dates || ' 
            GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName","INVSTO_PurchaseRate","INVSTO_SalesRate","INVSTO_PurchaseDate","INVSTO_PurOBQty"
            ORDER BY "MI"."INVMI_ItemName" LIMIT 100) AS "New"';

            EXECUTE v_Slqdymaic;
        END IF;
    END IF;

    IF (p_optionflag = 'Item') THEN
        v_Slqdymaic := '   
        SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName",
        ("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",
        ("INVSTO_SalesRate") "INVSTO_SalesRate",
        "INVSTO_PurchaseDate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",
        SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",
        SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS" 
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."INVMST_Id"=' || p_storeid::varchar || ' AND "INS"."MI_Id"=' || p_MI_Id::varchar || ' and "INS"."INVMI_Id" IN (' || p_INVMI_Ids || ') ' || v_dates || '
        GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName","INVSTO_PurchaseRate","INVSTO_SalesRate","INVSTO_PurchaseDate"
        ORDER BY "MI"."INVMI_ItemName"';

        EXECUTE v_Slqdymaic;
    END IF;

    IF (p_optionflag = 'Store') THEN
        v_Slqdymaic := '  
        SELECT DISTINCT "INS"."INVMI_Id", "MI"."INVMI_ItemName", SUM("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",SUM("INVSTO_SalesRate") "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS" 
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        WHERE "INS"."INVMST_Id"=' || p_storeid::varchar || ' AND "INS"."MI_Id"=' || p_MI_Id::varchar || ' and "INS"."INVMST_Id" IN (' || p_INVMST_Ids || ') ' || v_dates || '
        GROUP BY "INS"."INVMI_Id","MI"."INVMI_ItemName"
        ORDER BY "MI"."INVMI_ItemName"';

        EXECUTE v_Slqdymaic;
    END IF;

    IF (p_optionflag = 'Group') THEN
        v_Slqdymaic := '  
        SELECT DISTINCT "MI"."INVMG_Id", "MG"."INVMG_GroupName","INS"."INVMI_Id", "MI"."INVMI_ItemName", SUM("INVSTO_PurchaseRate") "INVSTO_PurchaseRate",SUM("INVSTO_SalesRate") "INVSTO_SalesRate",
        (SUM("INVSTO_SalesQty")-SUM("INVSTO_SalesRetQty")) AS "SalesQty",(SUM("INVSTO_PurOBQty")+SUM("INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INVSTO_AvaiableStock") "INVSTO_AvaiableStock",
        SUM("INVSTO_CheckedOutQty") "INVSTO_CheckedOutQty",SUM("INVSTO_DisposedQty") "INVSTO_DisposedQty",
        (SUM("INVSTO_PurchaseRate")*SUM("INVSTO_PurOBQty")) AS "obAmount",
        SUM("INVSTO_ItemConQty") "INVSTO_ItemConQty",SUM("INVSTO_PhyPlusQty") "INVSTO_PhyPlusQty",SUM("INVSTO_PhyMinQty") "INVSTO_PhyMinQty",SUM("INVSTO_MatIssPlusQty") "INVSTO_MatIssPlusQty",
        SUM("INVSTO_MatIssMinusQty") "INVSTO_MatIssMinusQty"
        FROM "INV"."INV_Stock" "INS" 
        INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id"="INS"."IMFY_Id"
        INNER JOIN "INV"."INV_Master_Store" "IMS" ON "IMS"."INVMST_Id"="INS"."INVMST_Id" and "IMS"."MI_Id"=' || p_MI_Id::varchar || '
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="INS"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Group" "MG" ON "MI"."INVMG_Id"="MG"."INVMG_Id"
        WHERE "INS"."INVMST_Id"=' || p_storeid::varchar || ' AND "INS"."IMFY_Id"=' || v_IMFY_Id::varchar || ' AND "INS"."MI_Id"=' || p_MI_Id::varchar || ' and "INS"."INVMI_Id" IN 
        (SELECT DISTINCT b."INVMI_Id" from "INV"."INV_Master_Group" a,