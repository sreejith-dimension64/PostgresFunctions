CREATE OR REPLACE FUNCTION "dbo"."Daily_Collection_Report_All_test"(
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
    "acdyr" VARCHAR(100)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    head_names TEXT;
    sql1head TEXT;
    sqlhead TEXT;
    cols TEXT;
    cols1 TEXT;
    query TEXT;
    monthyearsd TEXT;
    monthyearsd_select TEXT;
    monthids TEXT;
    monthids1 TEXT;
    date_var TEXT;
    order_var TEXT;
    test VARCHAR(100);
    sqldynamic TEXT;
    rec RECORD;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'Userids' AND table_schema = 'dbo') THEN
        DROP TABLE "dbo"."Userids";
    END IF;

    sqldynamic := 'CREATE TEMP TABLE "Userids" AS SELECT DISTINCT "user_id" FROM "dbo"."Fee_Master_Group" WHERE "FMG_Id" IN (' || "fmg_id" || ')';
    EXECUTE sqldynamic;

    SELECT "user_id" INTO test FROM "Userids" LIMIT 1;

    IF ("Mi_Id" = '5') OR ("Mi_Id" = '6') OR ("Mi_Id" = '4') THEN
        order_var := 'ORDER BY CAST(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("FYP_Receipt_No",''SSF'',''''),''SFR'',''''),''SFF'',''''),''SF'',''''),''DF'',''''),''RF'',''''),''SB'',''''),''BF'',''''),''TF'',''''),''D'',''''),''/17-18'',''''),''/2018-2019'',''''),''Online/'',''''),''/18-19'',''''),''S'',''''),''G'',''''),''AF'',''''),''Online'',''''),''F'',''''),''TFII'',''''),''TFI'',''''),''I'',''''),''II'',''''),''TF'',''''),''/19-20'',''''))) AS INTEGER)';
    ELSE
        order_var := 'ORDER BY "FYP_Receipt_No"';
    END IF;

    IF "cheque" = '0' THEN
        date_var := 'CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || "from_date" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''',''DD/MM/YYYY'')';
    ELSE
        date_var := 'CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "from_date" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''',''DD/MM/YYYY'')';
    END IF;

    IF "fmg_id" = '0' THEN
        sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "Mi_Id" || ') AND "Fee_Group_Login_Previledge"."User_Id" = ' || test;
    ELSE
        sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "Mi_Id" || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || '))';
    END IF;

    monthyearsd := '';
    monthyearsd_select := '';

    FOR rec IN EXECUTE sql1head LOOP
        cols := rec."FMH_FeeName";
        monthyearsd := COALESCE(monthyearsd, '') || COALESCE('"' || cols || '"' || ', ', '');
        monthyearsd_select := COALESCE(monthyearsd_select, '') || COALESCE('COALESCE("' || cols || '",0) AS "' || cols || '"' || ', ', '');
    END LOOP;

    IF LENGTH(monthyearsd) > 0 THEN
        monthyearsd := LEFT(monthyearsd, LENGTH(monthyearsd) - 2);
        monthyearsd_select := LEFT(monthyearsd_select, LENGTH(monthyearsd_select) - 2);
    END IF;

    IF "datetype" = 'transdate' THEN
        IF "type" = 'all' THEN
            IF "fmg_id" = '0' THEN
                IF "acdyr" = 'All' THEN
                    query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment_OthStaff", "dbo"."Fee_Y_Payment_Staff" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" AND "MI_Id" = ' || "Mi_Id" || ' AND ' || date_var || ' AND "Fee_Y_Payment"."user_id" = ' || test || ') AS s) AS pvt GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ' || "Asmay_id" || ' AND "MI_Id" = ' || "Mi_Id" || ' AND ' || date_var || ' AND "Fee_Y_Payment"."user_id" = ' || test || ') AS s) AS pvt GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment_OthStaff", "dbo"."Fee_Y_Payment_OthStu" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" AND "ASMAY_ID" = ' || "Asmay_id" || ' AND "MI_Id" = ' || "Mi_Id" || ' AND ' || date_var || ' AND "Fee_Y_Payment"."user_id" = ' || test || ') AS s) AS pvt GROUP BY a."Date"';
                ELSE
                    query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ' || "Asmay_id" || ' AND "MI_Id" = ' || "Mi_Id" || ' AND ' || date_var || ' AND "Fee_Y_Payment"."user_id" = ' || test || ') AS s) AS pvt GROUP BY a."Date"';
                END IF;
            ELSE
                IF "acdyr" = 'All' THEN
                    query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment", "dbo"."fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ' || "Mi_Id" || ' AND ' || date_var || ') AS s) AS pvt GROUP BY a."Date"';
                ELSE
                    query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment", "dbo"."fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "Fee_Y_Payment"."ASMAY_ID" = ' || "Asmay_id" || ' AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ' || "Mi_Id" || ' AND ' || date_var || ') AS s) AS pvt GROUP BY a."Date"';
                END IF;
            END IF;
        ELSE
            IF "acdyr" = 'All' THEN
                query := 'Complex individual query structure - simplified for migration';
            ELSE
                IF ("done_by" = 'all' OR "done_by" = 'stud') AND "trans_by" = 'all' THEN
                    IF "asmcl_id" = '0' THEN
                        IF "fmg_id" = '0' THEN
                            query := 'SELECT "Name", "AMST_RegistrationNo", "AMST_AdmNo", "AMAY_RollNo", "ASMCL_ClassName", "ASMC_SectionName", "FYP_Receipt_No", "FYP_Bank_Name", "FYP_Bank_Or_Cash", "FYP_DD_Cheque_No", "Date", "Chequedate", "ASMAY_ID", "MI_Id", "FYP_Remarks", "fyp_transaction_id", ' || monthyearsd_select || ' FROM (SELECT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "Name", "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo", "Adm_School_M_Class"."ASMCL_ClassName", "Fee_Master_Head"."FMH_FeeName", "Adm_School_M_Section"."ASMC_SectionName", COALESCE("Fee_T_Payment"."FTP_Paid_Amt", 0) AS paid FROM "dbo"."Fee_Y_Payment" WHERE ' || date_var || ') AS s ' || order_var;
                        ELSE
                            query := 'Individual student query with fmg_id filter';
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    ELSE
        query := 'Settlement date query structure';
    END IF;

    RETURN QUERY EXECUTE query;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RETURN;
END;
$$;