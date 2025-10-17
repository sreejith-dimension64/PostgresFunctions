CREATE OR REPLACE FUNCTION "dbo"."Daily_Collection_Report_All_1_Old"(
    "Asmay_id" VARCHAR(100),
    "Mi_Id" VARCHAR(100),
    "from_date" TEXT,
    "to_date" TEXT,
    "asmcl_id" TEXT,
    "fmg_id" TEXT,
    "type" TEXT,
    "done_by" TEXT,
    "trans_by" TEXT,
    "cheque" TEXT,
    "userid" VARCHAR(100),
    "datetype" VARCHAR(100),
    "acdyr" VARCHAR(100),
    "yrflag" VARCHAR(100)
)
RETURNS TABLE(
    "Date" TEXT,
    "Receipts_Count" BIGINT,
    "ByBank" NUMERIC,
    "ByCash" NUMERIC,
    "ByOnline" NUMERIC,
    "ByCard" NUMERIC,
    "ByECS" NUMERIC,
    "ByRTGS" NUMERIC,
    "Total" NUMERIC,
    "Name" TEXT,
    "FYP_Receipt_No" TEXT,
    "FYP_Bank_Name" TEXT,
    "FYP_Bank_Or_Cash" TEXT,
    "FYP_DD_Cheque_No" TEXT,
    "Chequedate" TEXT,
    "ASMAY_ID" TEXT,
    "MI_Id" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "FYP_Remarks" TEXT,
    "fyp_transaction_id" TEXT,
    "FYP_PaymentReference_Id" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "head_names" TEXT;
    "sql1head" TEXT;
    "sqlhead" TEXT;
    "cols" TEXT;
    "cols1" TEXT;
    "query" TEXT;
    "monthyearsd" TEXT;
    "monthyearsd_select" TEXT;
    "monthids" TEXT;
    "monthids1" TEXT;
    "date" TEXT;
    "order" TEXT;
    "test" VARCHAR(100);
    "sqldynamic" TEXT;
    "rec" RECORD;
BEGIN

    DROP TABLE IF EXISTS "Userids";

    "sqldynamic" := 'CREATE TEMP TABLE "Userids" AS SELECT DISTINCT "user_id" FROM "Fee_Master_Group" WHERE "FMG_Id" IN (' || "fmg_id" || ')';
    EXECUTE "sqldynamic";

    SELECT "user_id" INTO "test" FROM "Userids" LIMIT 1;

    IF ("Mi_Id" = '5') OR ("Mi_Id" = '6') OR ("Mi_Id" = '4') THEN
        "order" := 'ORDER BY CAST(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("FYP_Receipt_No",''SSF'',''''),''SFR'',''''),''SFF'',''''),''SF'',''''),''DF'',''''),''RF'',''''),''SB'',''''),''BF'',''''),''TF'',''''),''D'',''''),''/17-18'',''''),''/2018-2019'',''''),''Online/'',''''),''/18-19'',''''),''S'',''''),''G'',''''),''AF'',''''),''Online'',''''),''F'',''''),''TFII'',''''),''TFI'','''' ),''I'','''' ),''II'',''''),''TF'',''''),''/19-20'',''''))) AS INTEGER)';
    ELSE
        "order" := 'ORDER BY "FYP_Receipt_No"';
    END IF;

    IF "cheque" = '0' THEN
        "date" := 'CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || "from_date" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''',''DD/MM/YYYY'')';
    ELSE
        "date" := 'CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "from_date" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''',''DD/MM/YYYY'')';
    END IF;

    IF "fmg_id" = '0' THEN
        "sql1head" := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "Mi_Id" || ') AND "Fee_Group_Login_Previledge"."User_Id" = ' || "test";
    ELSE
        "sql1head" := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "Mi_Id" || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || '))';
    END IF;

    "monthyearsd" := '';
    "monthyearsd_select" := '';

    FOR "rec" IN EXECUTE "sql1head" LOOP
        "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "rec"."FMH_FeeName" || '"' || ', ', '');
        "monthyearsd_select" := COALESCE("monthyearsd_select", '') || COALESCE('COALESCE("' || "rec"."FMH_FeeName" || '",0) AS "' || "rec"."FMH_FeeName" || '"' || ', ', '');
    END LOOP;

    "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 1);
    "monthyearsd_select" := LEFT("monthyearsd_select", LENGTH("monthyearsd_select") - 1);

    IF "datetype" = 'transdate' THEN
        IF "type" = 'all' THEN
            IF "fmg_id" = '0' THEN
                IF "acdyr" = 'All' THEN
                    "query" := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" AND "MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "Fee_Y_Payment"."user_id" = ' || "test" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ''' || "Asmay_id" || ''' AND "MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "Fee_Y_Payment"."user_id" = ' || "test" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" AND "ASMAY_ID" = ''' || "Asmay_id" || ''' AND "MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "Fee_Y_Payment"."user_id" = ' || "test" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date"';
                ELSE
                    "query" := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ''' || "Asmay_id" || ''' AND "MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "Fee_Y_Payment"."user_id" = ' || "test" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date"';
                END IF;
            ELSE
                IF "acdyr" = 'All' THEN
                    "query" := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment", "fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff", "Fee_Master_Amount_OthStaffs" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" AND "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id" AND "Fee_Y_Payment"."ASMAY_ID" = ''' || "Asmay_id" || ''' AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu", "Fee_Master_Amount_OthStaffs" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" AND "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id" AND "Fee_Y_Payment"."ASMAY_ID" = ''' || "Asmay_id" || ''' AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date"';
                ELSE
                    "query" := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "Fee_Y_Payment", "Fee_T_Payment", "fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "Fee_Y_Payment"."ASMAY_ID" = ''' || "Asmay_id" || ''' AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ''' || "Mi_Id" || ''' AND ' || "date" || ' AND "FYP_Chq_Bounce" <> ''CB'' AND "FYP_Chq_Bounce" = ''CL'') AS s) AS a GROUP BY a."Date"';
                END IF;
            END IF;
        ELSE
            "query" := 'SELECT NULL::TEXT AS "Date", NULL::BIGINT AS "Receipts_Count", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS", NULL::NUMERIC AS "Total", NULL::TEXT AS "Name", NULL::TEXT AS "FYP_Receipt_No", NULL::TEXT AS "FYP_Bank_Name", NULL::TEXT AS "FYP_Bank_Or_Cash", NULL::TEXT AS "FYP_DD_Cheque_No", NULL::TEXT AS "Chequedate", NULL::TEXT AS "ASMAY_ID", NULL::TEXT AS "MI_Id", NULL::TEXT AS "AMST_RegistrationNo", NULL::TEXT AS "AMST_AdmNo", NULL::TEXT AS "AMAY_RollNo", NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "ASMC_SectionName", NULL::TEXT AS "FYP_Remarks", NULL::TEXT AS "fyp_transaction_id", NULL::TEXT AS "FYP_PaymentReference_Id" LIMIT 0';
        END IF;
    ELSE
        "query" := 'SELECT NULL::TEXT AS "Date", NULL::BIGINT AS "Receipts_Count", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS", NULL::NUMERIC AS "Total", NULL::TEXT AS "Name", NULL::TEXT AS "FYP_Receipt_No", NULL::TEXT AS "FYP_Bank_Name", NULL::TEXT AS "FYP_Bank_Or_Cash", NULL::TEXT AS "FYP_DD_Cheque_No", NULL::TEXT AS "Chequedate", NULL::TEXT AS "ASMAY_ID", NULL::TEXT AS "MI_Id", NULL::TEXT AS "AMST_RegistrationNo", NULL::TEXT AS "AMST_AdmNo", NULL::TEXT AS "AMAY_RollNo", NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "ASMC_SectionName", NULL::TEXT AS "FYP_Remarks", NULL::TEXT AS "fyp_transaction_id", NULL::TEXT AS "FYP_PaymentReference_Id" LIMIT 0';
    END IF;

    RETURN QUERY EXECUTE "query";

END;
$$;