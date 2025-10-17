CREATE OR REPLACE FUNCTION "dbo"."Daily_Collection_Report_All_dd_date"(
    "p_Asmay_id" VARCHAR(100),
    "p_Mi_Id" VARCHAR(100),
    "p_from_date" TEXT,
    "p_to_date" TEXT,
    "p_asmcl_id" TEXT,
    "p_fmg_id" TEXT,
    "p_type" TEXT,
    "p_done_by" TEXT,
    "p_trans_by" TEXT,
    "p_cheque" TEXT,
    "p_userid" VARCHAR(100),
    "p_datetype" VARCHAR(100),
    "p_acdyr" VARCHAR(100)
)
RETURNS TABLE(
    result_data TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_head_names TEXT;
    v_sql1head TEXT;
    v_sqlhead TEXT;
    v_cols TEXT;
    v_cols1 TEXT;
    v_query TEXT;
    v_monthyearsd TEXT;
    v_monthyearsd_select TEXT;
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_date TEXT;
    v_order TEXT;
    v_test VARCHAR(100);
    v_sqldynamic TEXT;
    rec RECORD;
BEGIN
    DROP TABLE IF EXISTS "Userids";
    
    v_sqldynamic := 'CREATE TEMP TABLE "Userids" AS SELECT DISTINCT "user_id" FROM "Fee_Master_Group" WHERE "FMG_Id" IN (' || "p_fmg_id" || ')';
    EXECUTE v_sqldynamic;
    
    SELECT "user_id" INTO v_test FROM "Userids" LIMIT 1;
    
    IF ("p_Mi_Id" = '5') OR ("p_Mi_Id" = '6') OR ("p_Mi_Id" = '4') THEN
        v_order := 'ORDER BY CAST(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("FYP_Receipt_No",''SSF'',''''),''SFR'',''''),''SFF'',''''),''SF'',''''),''DF'',''''),''RF'',''''),''SB'',''''),''BF'',''''),''TF'',''''),''D'',''''),''/17-18'',''''),''/2018-2019'',''''),''Online/'',''''),''/18-19'',''''),''S'',''''),''G'',''''),''AF'',''''),''Online'',''''),''F'',''''),''TFII'',''''),''TFI'','''' ),''I'','''' ),''II'',''''),''TF'',''''),''/19-20'',''''))) AS INTEGER)';
    ELSE
        v_order := 'ORDER BY "FYP_Receipt_No"';
    END IF;
    
    IF "p_cheque" = '0' THEN
        v_date := 'TO_DATE("dbo"."Fee_Y_Payment"."fyp_date"::TEXT, ''DD/MM/YYYY'') BETWEEN TO_DATE(''' || "p_from_date" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_to_date" || ''', ''DD/MM/YYYY'')';
    ELSE
        v_date := 'TO_DATE("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date"::TEXT, ''DD/MM/YYYY'') BETWEEN TO_DATE(''' || "p_from_date" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_to_date" || ''', ''DD/MM/YYYY'')';
    END IF;
    
    IF "p_fmg_id" = '0' THEN
        v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE "Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_Mi_Id" || ' AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "p_Asmay_id" || ' AND "Fee_Group_Login_Previledge"."User_Id" = ' || v_test;
    ELSE
        v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE "Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_Mi_Id" || ' AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "p_Asmay_id" || ' AND "Fee_Master_Group"."FMG_Id" IN (' || "p_fmg_id" || ')';
    END IF;
    
    v_monthyearsd := '';
    v_monthyearsd_select := '';
    
    FOR rec IN EXECUTE v_sql1head LOOP
        v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || rec."FMH_FeeName" || '"' || ', ', '');
        v_monthyearsd_select := COALESCE(v_monthyearsd_select, '') || COALESCE('COALESCE("' || rec."FMH_FeeName" || '", 0) AS "' || rec."FMH_FeeName" || '"' || ', ', '');
    END LOOP;
    
    v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
    v_monthyearsd_select := LEFT(v_monthyearsd_select, LENGTH(v_monthyearsd_select) - 2);
    
    IF "p_datetype" = 'transdate' THEN
        IF "p_type" = 'all' THEN
            IF "p_fmg_id" = '0' THEN
                IF "p_acdyr" = 'All' THEN
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" AND "ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "MI_Id" = ''' || "p_Mi_Id" || ''' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "MI_Id" = ''' || "p_Mi_Id" || ''' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" AND "ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "MI_Id" = ''' || "p_Mi_Id" || ''' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date"';
                ELSE
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "MI_Id" = ''' || "p_Mi_Id" || ''' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date"';
                END IF;
            ELSE
                IF "p_acdyr" = 'All' THEN
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment", "fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "Fee_Y_Payment"."ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "fmg_id" IN (' || "p_fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ''' || "p_Mi_Id" || ''' AND ' || v_date || ') AS s) AS pvt GROUP BY a."Date"';
                ELSE
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment", "fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "Fee_Y_Payment"."ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "fmg_id" IN (' || "p_fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ''' || "p_Mi_Id" || ''' AND ' || v_date || ') AS s) AS pvt GROUP BY a."Date"';
                END IF;
            END IF;
        END IF;
    END IF;
    
    RETURN QUERY EXECUTE v_query;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RETURN;
END;
$$;