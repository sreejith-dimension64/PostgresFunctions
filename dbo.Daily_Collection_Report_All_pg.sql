CREATE OR REPLACE FUNCTION "dbo"."Daily_Collection_Report_All"(
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
RETURNS TABLE(result_data JSON)
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
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'dbo' AND tablename = 'Userids') THEN
        DROP TABLE "dbo"."Userids";
    END IF;

    v_sqldynamic := 'CREATE TEMP TABLE "Userids" AS SELECT DISTINCT "user_id" FROM "dbo"."Fee_Master_Group" WHERE "FMG_Id" IN (' || "fmg_id" || ')';
    EXECUTE v_sqldynamic;

    SELECT "user_id" INTO v_test FROM "Userids" LIMIT 1;

    IF ("Mi_Id" = '5') OR ("Mi_Id" = '6') OR ("Mi_Id" = '4') THEN
        v_order := 'ORDER BY CAST(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("FYP_Receipt_No",''SSF'',''''),''SFR'',''''),''SFF'',''''),''SF'',''''),''DF'',''''),''RF'',''''),''SB'',''''),''BF'',''''),''TF'',''''),''D'',''''),''/17-18'',''''),''/2018-2019'',''''),''Online/'',''''),''/18-19'',''''),''S'',''''),''G'',''''),''AF'',''''),''Online'',''''),''F'',''''),''TFII'',''''),''TFI'',''''),''I'',''''),''II'',''''),''TF'',''''),''/19-20'',''''))) AS INTEGER)';
    ELSE
        v_order := 'ORDER BY "FYP_Receipt_No"';
    END IF;

    IF "cheque" = '0' THEN
        v_date := 'CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || "from_date" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''',''DD/MM/YYYY'')';
    ELSE
        v_date := 'CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "from_date" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''',''DD/MM/YYYY'')';
    END IF;

    IF "fmg_id" = '0' THEN
        v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "dbo"."Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "Mi_Id" || ') AND "Fee_Group_Login_Previledge"."User_Id" = ' || v_test;
    ELSE
        v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "Mi_Id" || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || '))';
    END IF;

    v_monthyearsd := '';
    v_monthyearsd_select := '';

    FOR rec IN EXECUTE v_sql1head LOOP
        v_cols := rec."FMH_FeeName";
        v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols || '"' || ', ', '');
        v_monthyearsd_select := COALESCE(v_monthyearsd_select, '') || COALESCE('COALESCE("' || v_cols || '",0) AS "' || v_cols || '"' || ', ', '');
    END LOOP;

    v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
    v_monthyearsd_select := LEFT(v_monthyearsd_select, LENGTH(v_monthyearsd_select) - 2);

    IF "datetype" = 'transdate' THEN
        IF "type" = 'all' THEN
            IF "fmg_id" = '0' THEN
                IF "acdyr" = 'All' THEN
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B",0) AS "ByBank", COALESCE("C",0) AS "ByCash", COALESCE("O",0) AS "ByOnline", COALESCE("S",0) AS "ByCard", COALESCE("E",0) AS "ByECS", COALESCE("R",0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment_OthStaff", "dbo"."Fee_Y_Payment_Staff" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" AND "MI_Id" = ' || "Mi_Id" || ' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B",0) AS "ByBank", COALESCE("C",0) AS "ByCash", COALESCE("O",0) AS "ByOnline", COALESCE("S",0) AS "ByCard", COALESCE("E",0) AS "ByECS", COALESCE("R",0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ' || "Asmay_id" || ' AND "MI_Id" = ' || "Mi_Id" || ' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date" UNION SELECT a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B",0) AS "ByBank", COALESCE("C",0) AS "ByCash", COALESCE("O",0) AS "ByOnline", COALESCE("S",0) AS "ByCard", COALESCE("E",0) AS "ByECS", COALESCE("R",0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment_OthStaff", "dbo"."Fee_Y_Payment_OthStu" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" AND "ASMAY_ID" = ' || "Asmay_id" || ' AND "MI_Id" = ' || "Mi_Id" || ' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date"';
                ELSE
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B",0) AS "ByBank", COALESCE("C",0) AS "ByCash", COALESCE("O",0) AS "ByOnline", COALESCE("S",0) AS "ByCard", COALESCE("E",0) AS "ByECS", COALESCE("R",0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "ASMAY_ID" = ' || "Asmay_id" || ' AND "MI_Id" = ' || "Mi_Id" || ' AND ' || v_date || ' AND "Fee_Y_Payment"."user_id" = ' || v_test || ') AS s) AS pvt GROUP BY a."Date"';
                END IF;
            ELSE
                IF "acdyr" = 'All' THEN
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B",0) AS "ByBank", COALESCE("C",0) AS "ByCash", COALESCE("O",0) AS "ByOnline", COALESCE("S",0) AS "ByCard", COALESCE("E",0) AS "ByECS", COALESCE("R",0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment", "dbo"."fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ' || "Mi_Id" || ' AND ' || v_date || ') AS s) AS pvt GROUP BY a."Date"';
                ELSE
                    v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (SELECT "date", "FYP_Receipt_No", COALESCE("B",0) AS "ByBank", COALESCE("C",0) AS "ByCash", COALESCE("O",0) AS "ByOnline", COALESCE("S",0) AS "ByCard", COALESCE("E",0) AS "ByECS", COALESCE("R",0) AS "ByRTGS" FROM (SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "date" FROM "dbo"."Fee_Y_Payment", "dbo"."Fee_T_Payment", "dbo"."fee_master_amount" WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "fee_master_amount"."fma_id" = "Fee_T_Payment"."fma_id" AND "Fee_Y_Payment"."ASMAY_ID" = ' || "Asmay_id" || ' AND "fmg_id" IN (' || "fmg_id" || ') AND "Fee_Y_Payment"."MI_Id" = ' || "Mi_Id" || ' AND ' || v_date || ') AS s) AS pvt GROUP BY a."Date"';
                END IF;
            END IF;
        ELSE
            IF "acdyr" = 'All' THEN
                v_query := 'SELECT "Name", "AMST_RegistrationNo", "AMST_AdmNo", "AMAY_RollNo", "ASMCL_ClassName", "ASMC_SectionName", "FYP_Receipt_No", "FYP_Bank_Name", "FYP_Bank_Or_Cash", "FYP_DD_Cheque_No", "Date", "Chequedate", "ASMAY_ID", "MI_Id", "FYP_Remarks", "fyp_transaction_id", "FYP_PaymentReference_Id", ' || v_monthyearsd_select || ' FROM (SELECT COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') AS "Name", "dbo"."Adm_M_Student"."AMST_RegistrationNo", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Fee_Master_Head"."FMH_FeeName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", COALESCE("dbo"."Fee_T_Payment"."FTP_Paid_Amt",0) AS paid, "dbo"."Fee_Y_Payment"."FYP_Receipt_No", "dbo"."Fee_Y_Payment"."FYP_Bank_Name", CASE "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash'' WHEN ''O'' THEN ''Online'' WHEN ''S'' THEN ''Card'' WHEN ''R'' THEN ''RTGS'' ELSE ''ECS'' END AS "FYP_Bank_Or_Cash", "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_No", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''DD/MM/YYYY'') AS "Date", TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "Chequedate", "dbo"."Fee_Y_Payment"."ASMAY_ID", "dbo"."Fee_Y_Payment"."MI_Id", "FYP_Remarks", "fyp_transaction_id", "FYP_PaymentReference_Id" FROM "dbo"."Fee_Y_Payment_School_Student" INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" INNER JOIN "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" AND "dbo"."Fee_Y_Payment_School_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_T_Payment"."FYP_Id" INNER JOIN "dbo"."Fee_Master_Amount" ON "dbo"."Fee_T_Payment"."FMA_Id" = "dbo"."Fee_Master_Amount"."FMA_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" WHERE ("dbo"."Adm_M_Student"."MI_Id" = ' || "Mi_Id" || ') AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "Asmay_id" || ') AND "Fee_Master_Amount"."fmg_id" IN (' || "fmg_id" || ') AND ' || v_date || ') AS s ' || v_order;
            ELSE
                IF ("done_by" = 'all' OR "done_by" = 'stud') AND "trans_by" = 'all' THEN
                    IF "asmcl_id" = '0' THEN
                        IF "fmg_id" = '0' THEN
                            v_query := 'SELECT "Name", "AMST_RegistrationNo", "AMST_AdmNo", "AMAY_RollNo", "ASMCL_ClassName", "ASMC_SectionName", "FYP_Receipt_No", "FYP_Bank_Name", "FYP_Bank_Or_Cash", "FYP_DD_Cheque_No", "Date", "Chequedate", "ASMAY_ID", "MI_Id", "FYP_Remarks", "fyp_transaction_id", "FYP_PaymentReference_Id", ' || v_monthyearsd_select || ' FROM (SELECT COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') AS "Name", "dbo"."Adm_M_Student"."AMST_RegistrationNo", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Fee_Master_Head"."FMH_FeeName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", COALESCE("dbo"."Fee_T_Payment"."FTP_Paid_Amt",0) AS paid, "dbo"."Fee_Y_Payment"."FYP_Receipt_No", "dbo"."Fee_Y_Payment"."FYP_Bank_Name", CASE "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash'' WHEN ''O'' THEN ''Online'' WHEN ''S'' THEN ''Card'' WHEN ''R'' THEN ''RTGS'' ELSE ''ECS'' END AS "FYP_Bank_Or_Cash", "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_No", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''DD/MM/YYYY'') AS "Date", TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "Chequedate", "dbo"."Fee_Y_Payment"."ASMAY_ID", "dbo"."Fee_Y_Payment"."MI_Id", "FYP_Remarks", "fyp_transaction_id", "FYP_PaymentReference_Id" FROM "dbo"."Fee_Y_Payment_School_Student" INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" INNER JOIN "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" AND "dbo"."Fee_Y_Payment_School_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_T_Payment"."FYP_Id" INNER JOIN "dbo"."Fee_Master_Amount" ON "dbo"."Fee_T_Payment"."FMA_Id" = "dbo"."Fee_Master_Amount"."FMA_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" WHERE ("dbo"."Adm_M_Student"."MI_Id" = ' || "Mi_Id" || ') AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "Asmay_id" || ') AND "Fee_Y_Payment"."user_id" = ' || v_test || ' AND ' || v_date || ') AS s ' || v_order;
                        ELSE
                            v_query := 'SELECT * FROM (SELECT "Name", "AMST_RegistrationNo", "AMST_AdmNo", "AMAY_RollNo", "ASMCL_ClassName", "ASMC_SectionName", "FYP_Receipt_No", "FYP_Bank_Name", "FYP_Bank_Or_Cash", "FYP_DD_Cheque_No", "Date", "Chequedate", "ASMAY_ID", "MI_Id", "FYP_Remarks", "fyp_transaction_id", "FYP_PaymentReference_Id", ' || v_monthyearsd_select || ' FROM (SELECT COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') AS "Name", "dbo"."Adm_M_Student"."AMST_RegistrationNo", "dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_Y_Student"."AMAY_RollNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Fee_Master_Head"."FMH_FeeName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", COALESCE("dbo"."Fee_T_Payment"."FTP_Paid_Amt",0) AS paid, "dbo"."Fee_Y_Payment"."FYP_Receipt_No", "dbo"."Fee_Y_Payment"."FYP_Bank_Name", CASE "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash''