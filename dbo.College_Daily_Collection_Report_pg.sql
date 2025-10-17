
CREATE OR REPLACE FUNCTION "College_Daily_Collection_Report"(
    "p_Asmay_id" VARCHAR,
    "p_Mi_Id" VARCHAR,
    "p_from_date" TEXT,
    "p_to_date" TEXT,
    "p_amco_ids" TEXT,
    "p_amb_ids" TEXT,
    "p_amse_ids" TEXT,
    "p_fmg_id" TEXT,
    "p_type" TEXT,
    "p_done_by" TEXT,
    "p_trans_by" TEXT,
    "p_cheque" TEXT,
    "p_userid" VARCHAR,
    "p_Settlement" TEXT,
    "p_transdate" TEXT
)
RETURNS REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    "v_head_names" TEXT;
    "v_sql1head" TEXT;
    "v_sqlhead" TEXT;
    "v_cols" TEXT;
    "v_cols1" TEXT;
    "v_query" TEXT;
    "v_monthyearsd" TEXT;
    "v_monthids" TEXT;
    "v_monthids1" TEXT;
    "v_date" TEXT;
    "v_monthyearsd_select" TEXT;
    "v_FeeUser" TEXT;
    "v_FeeGroupLUser" TEXT;
    "v_AMCO_Id" VARCHAR(50);
    "v_AMB_Id" VARCHAR(50);
    "v_AMSE_Id" VARCHAR(20);
    "v_AMSE_Id_N" VARCHAR(20);
    "v_FTCP_PaidAmount" VARCHAR(100);
    "v_Rcount" INT;
    "v_cursor" REFCURSOR := 'result_cursor';
    "rec_cols" RECORD;
BEGIN

    IF "p_transdate" = 'transaction' THEN
        "v_date" := 'CAST("clg"."Fee_Y_Payment"."FYP_ReceiptDate" AS DATE) BETWEEN CAST(''' || "p_from_date" || ''' AS DATE) AND CAST(''' || "p_to_date" || ''' AS DATE)';
    ELSIF "p_transdate" = 'Chequedate' THEN
        "v_date" := 'CAST("clg"."Fee_Y_Payment_PaymentMode"."FYPPM_DDChequeDate" AS DATE) BETWEEN CAST(''' || "p_from_date" || ''' AS DATE) AND CAST(''' || "p_to_date" || ''' AS DATE)';
    ELSIF "p_transdate" = 'Clearance' THEN
        "v_date" := 'CAST("clg"."Fee_Y_Payment_PaymentMode"."FYPPM_ClearanceDate" AS DATE) BETWEEN CAST(''' || "p_from_date" || ''' AS DATE) AND CAST(''' || "p_to_date" || ''' AS DATE)';
    ELSIF "p_transdate" = 'Settlement' THEN
        "v_date" := 'CAST("clg"."Fee_Y_Payment"."FYP_ReceiptDate" AS DATE) BETWEEN CAST(''' || "p_from_date" || ''' AS DATE) AND CAST(''' || "p_to_date" || ''' AS DATE)';
    END IF;

    IF "p_userid" != '' AND "p_userid" != '0' THEN
        "v_FeeUser" := ' AND "clg"."Fee_Y_Payment"."User_Id" = ' || "p_userid" || ' ';
    ELSE
        "v_FeeUser" := '';
    END IF;

    IF "p_userid" != '' AND "p_userid" != '0' THEN
        "v_FeeGroupLUser" := ' AND "Fee_Group_Login_Previledge"."User_Id" = ' || "p_userid" || ' ';
    ELSE
        "v_FeeGroupLUser" := '';
    END IF;

    IF "p_fmg_id" = '0' THEN
        IF "p_Asmay_id" = '0' THEN
            "v_sql1head" := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN ' ||
                '"Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Fee_Group_Login_Previledge" ON ' ||
                '"Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_Mi_Id" || ') ' || "v_FeeGroupLUser";
        ELSE
            "v_sql1head" := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN ' ||
                '"Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Fee_Group_Login_Previledge" ON ' ||
                '"Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_Mi_Id" || ') AND ("Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "p_Asmay_id" || ') ' || "v_FeeGroupLUser";
        END IF;
    ELSE
        IF "p_Asmay_id" = '0' THEN
            "v_sql1head" := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN ' ||
                '"Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_Mi_Id" || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || "p_fmg_id" || '))';
        ELSE
            "v_sql1head" := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN ' ||
                '"Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_Mi_Id" || ') AND ("Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "p_Asmay_id" || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || "p_fmg_id" || '))';
        END IF;
    END IF;

    "v_monthyearsd" := '';
    "v_monthyearsd_select" := '';

    FOR "rec_cols" IN EXECUTE "v_sql1head"
    LOOP
        "v_monthyearsd" := COALESCE("v_monthyearsd", '') || COALESCE('"' || "rec_cols"."FMH_FeeName" || '"' || ', ', '');
        "v_monthyearsd_select" := COALESCE("v_monthyearsd_select", '') || COALESCE('COALESCE("' || "rec_cols"."FMH_FeeName" || '", 0) AS "' || "rec_cols"."FMH_FeeName" || '" ' || ', ', '');
    END LOOP;

    "v_monthyearsd" := LEFT("v_monthyearsd", LENGTH("v_monthyearsd") - 2);
    "v_monthyearsd_select" := LEFT("v_monthyearsd_select", LENGTH("v_monthyearsd_select") - 2);

    IF "p_type" = 'all' THEN
        "v_query" := 'SELECT "AMSE_SEMName", a."Date", COUNT("FYP_ReceiptNo") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", ' ||
            'SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total", SUM("PendingCount") AS "PendingCount", SUM("ApprovedCount") AS "ApprovedCount" ' ||
            'FROM (SELECT DISTINCT "AMSE_SEMName", "date", "FYP_ReceiptNo", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS", ' ||
            'COALESCE("PendingCount", 0) AS "PendingCount", COALESCE("ApprovedCount", 0) AS "ApprovedCount" FROM (SELECT DISTINCT S."AMSE_SEMName", "FYP_ReceiptNo", "FTCP_PaidAmount", "clg"."Fee_Y_Payment_PaymentMode"."FYPPM_TransactionTypeFlag", ' ||
            'TO_CHAR(CAST("FYP_ReceiptDate" AS TIMESTAMP), ''DD/MM/YYYY'') AS "date", (CASE WHEN "FYP_ApprovedFlg" = FALSE THEN 1 END) AS "PendingCount", (CASE WHEN "FYP_ApprovedFlg" = TRUE THEN 1 END) AS "ApprovedCount" ' ||
            'FROM "clg"."Fee_Y_Payment" INNER JOIN "clg"."Fee_Y_Payment_PaymentMode" ON "clg"."Fee_Y_Payment_PaymentMode"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
            'INNER JOIN "clg"."Fee_Y_Payment_College_Student" ON "clg"."Fee_Y_Payment_College_Student"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
            'INNER JOIN "clg"."Adm_College_Yearly_Student" ACYS ON ACYS."AMCST_Id" = "clg"."Fee_Y_Payment_College_Student"."AMCST_Id" AND ACYS."ASMAY_Id" = "clg"."Fee_Y_Payment_College_Student"."ASMAY_Id" ' ||
            'INNER JOIN "clg"."Fee_T_College_Payment" ON "clg"."Fee_T_College_Payment"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
            'INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" ON "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id" = "clg"."Fee_T_College_Payment"."FCMAS_Id" ' ||
            'INNER JOIN "clg"."Fee_College_Master_Amount" ON "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id" ' ||
            'INNER JOIN "clg"."Adm_Master_Semester" S ON S."AMSE_Id" = ACYS."AMSE_Id" AND S."MI_Id" = ''' || "p_Mi_Id" || ''' ' ||
            'WHERE "clg"."Fee_College_Master_Amount"."fmg_id" IN (' || "p_fmg_id" || ') AND "FTCP_PaidAmount" > 0 AND ' || "v_date" || ' AND "clg"."Fee_Y_Payment"."ASMAY_ID" = ''' || "p_Asmay_id" || ''' AND "clg"."Fee_Y_Payment"."MI_Id" = ''' || "p_Mi_Id" || ''' ' || "v_FeeUser" ||
            ') AS s) AS pvt) AS a GROUP BY "AMSE_SEMName", a."Date"';
    ELSE
        IF ("p_done_by" = 'all' OR "p_done_by" = 'stud') AND "p_trans_by" = 'all' THEN
            "v_query" := 'SELECT * FROM (SELECT COALESCE("AMCST_FirstName", '''') || '' '' || COALESCE("AMCST_MiddleName", '''') || '' '' || COALESCE("AMCST_LastName", '''') AS "Name", "AMCST_RegistrationNo", "AMCST_AdmNo", ' ||
                '(SELECT DISTINCT "ACYST_RollNo" FROM "clg"."Adm_College_Yearly_Student" WHERE "amcst_id" = "clg"."Adm_Master_College_Student"."amcst_id" AND "ASMAY_Id" = ''' || "p_Asmay_id" || ''' AND "ACYST_ActiveFlag" = TRUE) AS "ACYST_RollNo", ' ||
                '"AMCO_CourseName", "Fee_Master_Head"."FMH_FeeName", "AMB_BranchName", "AMSE_SEMName", "FTCP_PaidAmount" AS "paid", "FYP_ReceiptNo", "FYPPM_BankName", ' ||
                'CASE "FYPPM_TransactionTypeFlag" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash'' WHEN ''O'' THEN ''Online'' WHEN ''S'' THEN ''Card'' WHEN ''R'' THEN ''RTGS'' ELSE ''ECS'' END AS "FYP_TransactionTypeFlag", ' ||
                '"FYPPM_DDChequeNo", TO_CHAR("FYP_ReceiptDate", ''DD/MM/YYYY'') AS "Date", TO_CHAR("clg"."Fee_Y_Payment"."FYP_ReceiptDate", ''DD/MM/YYYY'') AS "Chequedate", "CLG"."Fee_Y_Payment"."ASMAY_ID", "clg"."Fee_Y_Payment"."MI_Id", ' ||
                'CASE WHEN "FYP_ApprovedFlg" = FALSE THEN ''Pending'' WHEN "FYP_ApprovedFlg" = TRUE THEN ''Approved'' END AS "ApprovedFlg", "AMCST_FatherName", "AMCST_MobileNo", "AMCST_emailId", "AU"."UserName" ' ||
                'FROM "clg"."Fee_Y_Payment" INNER JOIN "clg"."Fee_Y_Payment_PaymentMode" ON "clg"."Fee_Y_Payment_PaymentMode"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
                'INNER JOIN "clg"."Fee_Y_Payment_College_Student" ON "clg"."Fee_Y_Payment_College_Student"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
                'INNER JOIN "clg"."Fee_T_College_Payment" ON "clg"."Fee_T_College_Payment"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
                'INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" ON "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id" = "clg"."Fee_T_College_Payment"."FCMAS_Id" ' ||
                'INNER JOIN "clg"."Fee_College_Master_Amount" ON "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id" ' ||
                'INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."amcst_id" = "clg"."Fee_Y_Payment_College_Student"."amcst_id" ' ||
                'INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "clg"."Adm_College_Yearly_Student"."AMCST_Id" ' ||
                'INNER JOIN "clg"."Adm_Master_Branch" ON "clg"."Adm_Master_Branch"."AMB_Id" = "clg"."Adm_College_Yearly_Student"."AMB_Id" ' ||
                'INNER JOIN "clg"."Adm_Master_Course" ON "clg"."Adm_Master_Course"."AMCO_Id" = "clg"."Adm_College_Yearly_Student"."AMCO_Id" ' ||
                'INNER JOIN "clg"."Adm_Master_Semester" ON "clg"."Adm_Master_Semester"."AMSE_Id" = "clg"."Adm_College_Yearly_Student"."AMSE_Id" ' ||
                'INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_College_Master_Amount"."FMH_Id" ' ||
                'INNER JOIN "ApplicationUser" AU ON AU."id" = "clg"."Fee_Y_Payment"."User_Id" ' ||
                'WHERE ("clg"."Fee_Y_Payment"."MI_Id" = ''' || "p_Mi_Id" || ''') AND ("clg"."Fee_Y_Payment"."ASMAY_Id" = ''' || "p_Asmay_id" || ''') AND "AMCST_ActiveFlag" = TRUE AND "Fee_College_Master_Amount"."fmg_id" IN (' || "p_fmg_id" || ') ' ||
                'AND ' || "v_date" || ' AND "ACYST_ActiveFlag" = TRUE AND "clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "p_amco_ids" || ') AND "clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "p_amb_ids" || ') ' ||
                'AND "clg"."Adm_College_Yearly_Student"."AMSE_Id" IN (' || "p_amse_ids" || ') ' || "v_FeeUser" || ') AS s ORDER BY "FYP_ReceiptNo"';

        ELSIF ("p_done_by" = 'all' OR "p_done_by" = 'stud') THEN
            IF "p_trans_by" = '' THEN
                IF "p_Asmay_id" = '0' THEN
                    "v_query" := 'SELECT * FROM (SELECT COALESCE("AMCST_FirstName", '''') || '' '' || COALESCE("AMCST_MiddleName", '''') || '' '' || COALESCE("AMCST_LastName", '''') AS "Name", "AMCST_RegistrationNo", "AMCST_AdmNo", ' ||
                        '"AMCO_CourseName", "Fee_Master_Head"."FMH_FeeName", "AMB_BranchName", "AMSE_SEMName", "FTCP_PaidAmount" AS "paid", "FYP_ReceiptNo", "FYPPM_BankName", ' ||
                        'CASE "FYPPM_TransactionTypeFlag" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash'' WHEN ''O'' THEN ''Online'' WHEN ''S'' THEN ''Card'' WHEN ''R'' THEN ''RTGS'' ELSE ''ECS'' END AS "FYP_TransactionTypeFlag", ' ||
                        '"FYPPM_DDChequeNo", TO_CHAR("FYP_ReceiptDate", ''DD/MM/YYYY'') AS "Date", TO_CHAR("FYPPM_DDChequeDate", ''DD/MM/YYYY'') AS "Chequedate", "CLG"."Fee_Y_Payment"."ASMAY_ID", "clg"."Fee_Y_Payment"."MI_Id", ' ||
                        'CASE WHEN "FYP_ApprovedFlg" = FALSE THEN ''Pending'' WHEN "FYP_ApprovedFlg" = TRUE THEN ''Approved'' END AS "ApprovedFlg", "AMCST_FatherName", "AMCST_MobileNo", "AMCST_emailId", "AU"."UserName" ' ||
                        'FROM "clg"."Fee_Y_Payment" INNER JOIN "clg"."Fee_Y_Payment_PaymentMode" ON "clg"."Fee_Y_Payment_PaymentMode"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
                        'INNER JOIN "clg"."Fee_Y_Payment_College_Student" ON "clg"."Fee_Y_Payment_College_Student"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
                        'INNER JOIN "clg"."Fee_T_College_Payment" ON "clg"."Fee_T_College_Payment"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" ' ||
                        'INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" ON "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id" = "clg"."Fee_T_College_Payment"."FCMAS_Id" ' ||
                        'INNER JOIN "clg"."Fee_College_Master_Amount" ON "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id" ' ||
                        'INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."amcst_id" = "clg"."Fee_Y_Payment_College_Student"."amcst_id" ' ||
                        'INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "clg"."Adm_College_Yearly_Student"."AMCST_Id" ' ||
                        'INNER JOIN "clg"."Adm_Master_Branch" ON "clg"."Adm_Master_Branch"."AMB_Id" = "clg"."Adm_College_Yearly_Student"."AMB_Id" ' ||
                        'INNER JOIN "clg"."Adm_Master_Course" ON "clg"."Adm_Master_Course"."AMCO_Id" = "clg"."Adm_College_Yearly_Student"."AMCO_Id" ' ||
                        'INNER JOIN "clg"."Adm_Master_Semester" ON "clg"."Adm_Master_Semester"."AMSE_Id" = "clg"."Adm_College_Yearly_Student"."AMSE_Id" ' ||
                        'INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Master_Amount"."FMH_Id" ' ||
                        'INNER JOIN "ApplicationUser" AU ON AU."id" = "clg"."Fee_Y_Payment"."User_Id" ' ||
                        'WHERE ("clg"."Fee_Y_Payment"."MI_Id" = ''' || "p_Mi_Id" || ''') AND "AMCST_ActiveFlag" = TRUE AND ' || "v_date" || ' AND "ACYST_ActiveFlag" = TRUE ' ||
                        'AND "clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "p_amco_ids" || ') AND "clg"."Adm_College_Yearly_Student"."AMSE_Id" IN (' || "p_amse_ids" || ')) AS s ' ||
                        'UNION SELECT "Name", '''' AS "AMCST_RegistrationNo", '''' AS "AMCST_AdmNo", '''' AS "AMCO_CourseName", '''' AS "AMB_BranchName", '''' AS "AMSE_SEMName", "FYP_ReceiptNo", "FYPPM_BankName", "FYP_TransactionTypeFlag", ' ||
                        '"FYPPM_DDChequeNo", "Date", "Chequedate", "ASMAY_ID", "MI_Id", '''' AS "AMCST_MobileNo", '''' AS "AMCST_emailId", '''' AS "UserName", '''' AS "AMCST_FatherName", '''' AS "ApprovedFlg", ' || "v_monthyearsd_select" || ' ' ||
                        'FROM (SELECT "FYPTP_Name" AS "Name", "Fee_Master_Head"."FMH_FeeName", COALESCE("Fee_Y_Payment_ThirdParty"."FTP_TotalPaidAmount", 0) AS "paid", "Fee_Y_Payment"."FYP_Receipt_No" AS "FYP_ReceiptNo", "Fee_Y_Payment"."FYP_Bank_Name" AS "FYPPM_BankName", ' ||
                        'CASE "Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash'' WHEN ''O'' THEN ''Online'' WHEN ''S'' THEN ''Card'' WHEN ''R'' THEN ''RTGS'' ELSE ''ECS'' END AS "FYP_TransactionTypeFlag", ' ||
                        '"Fee_Y_Payment"."FYP_DD_Cheque_No" AS "FYPPM_DDChequeNo", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''DD/MM/YYYY'') AS "Date", TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "Chequedate", ' ||
                        '"Fee_Y_Payment"."MI_Id", "Fee_Y_Payment"."ASMAY_Id", "FYP_Remarks", "fyp_transaction_id", "FYP_PaymentReference_Id" ' ||
                        'FROM "Fee_Y_Payment" INNER JOIN "Fee_Y_Payment_ThirdParty" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_ThirdParty"."FYP_Id" ' ||
                        'INNER JOIN "Fee_Master_Head" ON "Fee_Y_Payment_ThirdParty"."FMH_Id" = "Fee_Master_Head"."FMH_Id" ' ||
                        'WHERE CAST("Fee_Y_Payment"."FYP_Date" AS DATE) BETWEEN CAST(''' || "p_from_date" || ''' AS DATE) AND CAST(''' || "p_to_date" || ''' AS DATE) AND ("Fee_Y_Payment"."MI_Id" = ''' || "p_Mi_Id" || ''')) AS s';
                ELSE
                    "v_query" := 'SELECT * FROM (SELECT COALESCE("AMCST_FirstName", '''') || '' '' || COALESCE("AMCST_MiddleName", '''') || '' '' || COALESCE("AMCST_LastName", '''') AS "Name", "AMCST_RegistrationNo", "AMCST_AdmNo", ' ||
                        '(SELECT DISTINCT "ACYST_RollNo" FROM "clg"."Adm_College_Yearly_Student" WHERE "amcst_id" = "clg"."Adm_Master_College_Student"."amcst_id" AND "ASMAY_Id" = ''' || "p_Asmay_id" || ''' AND "ACYST_ActiveFlag" = TRUE) AS "ACYST_RollNo", ' ||
                        '"AMCO_CourseName", "Fee_Master_Head"."FMH_FeeName", "AMB_BranchName", "AMSE_SEMName", "FTCP_PaidAmount" AS "paid", "FYP_ReceiptNo", "FYPPM_BankName", ' ||
                        'CASE "FYPPM_TransactionTypeFlag" WHEN ''B'' THEN ''Bank'' WHEN ''C'' THEN ''Cash'' WHEN ''O'' THEN ''Online'' WHEN ''S'' THEN ''Card'' WHEN ''R'' THEN ''RTGS'' ELSE ''ECS'' END AS "FYP_TransactionTypeFlag", ' ||
                        '"FYPPM_DDChequeNo", TO_CHAR("FYP_ReceiptDate", ''DD/MM/YYYY'') AS "Date", TO_CHAR("FYPPM_DDChequeDate", ''DD/MM/YYYY'') AS "Chequedate", "CLG"."Fee_Y_Payment"."ASMAY_ID", "clg"."Fee_Y_Payment"."MI_Id", ' ||
                        'CASE WHEN "FYP_ApprovedFlg" = FALSE THEN ''Pending'' WHEN "FYP_ApprovedFlg" = TRUE THEN ''Approved'' END AS "ApprovedFlg", "AMCST_FatherName", "AMCST_MobileNo", "AMCST_emailId", "AU"."UserName" ' ||
                        'FROM "clg"."Fee_Y_Payment" INNER JOIN "