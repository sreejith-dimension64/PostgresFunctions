CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_RV_College"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FromDate varchar,
    p_ToDate varchar
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Int_Ref_No numeric(18,0);
    v_R_Date timestamp;
    v_voucher_no varchar(500);
    v_ACTIVE int;
    v_VOUCHER_TYPE varchar(100);
    v_transaction_type varchar(500);
    v_deptdescription varchar(100);
    v_ChequeNo VARCHAR(50);
    v_ChequeDate timestamp;
    v_BankName VARCHAR(250);
    v_AMOUNT FLOAT;
    v_FLAG CHAR(2);
    v_NARRATION CHAR(100);
    v_L_Code INT;
    v_TM_ID BIGINT;
    v_AMB_CODE VARCHAR(5000);
    v_T_Amount float;
    v_t_Fine float;
    v_fyp_id bigint;
    v_fyp_date timestamp;
    v_l_code_new bigint;
    v_fyp_remarks varchar(5000);
    v_TLU_ID BIGINT;
    v_RVRegLedgerId varchar(10);
    v_RVRegLedgerUnder varchar(10);
    v_Sqldynamic text;
    v_RCOUNT int;
    v_ASSMAY_Year varchar(50);
    v_IMFY_Id bigint;
    v_TMT_RefNo varchar(50);
    v_RVRegLedgerIdN varchar(50);
    v_TTT_LedgerUnderT varchar(150);
    v_TTT_LedgerUnder varchar(150);
    rcpt_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "StuAmtRV";

    v_Sqldynamic := '
    CREATE TEMP TABLE "StuAmtRV" AS
    SELECT DISTINCT "Fee_Y_Payment"."FYP_Id", "FYP_ReceiptNo", "FYP_ReceiptDate"::date as fyp_date, 
           "FYPPM_DDChequeNo", "FYPPM_DDChequeDate", "FYP_TotalPaidAmount", "fyp_remarks"
    FROM "clg"."Fee_T_College_Payment" 
    INNER JOIN "clg"."Fee_Y_Payment"
        ON "clg"."Fee_T_College_Payment"."FYP_Id" = "clg"."Fee_Y_Payment"."FYP_Id" 
        AND "clg"."Fee_Y_Payment"."MI_Id" = ' || p_MI_Id || ' 
        AND "clg"."Fee_Y_Payment"."ASMAY_ID" = ' || p_ASMAY_Id || '
    INNER JOIN "clg"."Fee_Y_Payment_College_Student" 
        ON "Fee_Y_Payment_College_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
        AND "Fee_Y_Payment_College_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
        ON "Fee_Y_Payment_College_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
        AND "dbo"."Adm_School_M_Academic_Year"."MI_Id" = ' || p_MI_Id || ' 
    INNER JOIN "clg"."Fee_Y_Payment_PaymentMode" 
        ON "Fee_Y_Payment_PaymentMode"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
    WHERE "Fee_Y_Payment_College_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND "FYP_ReceiptDate"::date BETWEEN ''' || p_FromDate || '''::date AND ''' || p_ToDate || '''::date';

    EXECUTE v_Sqldynamic;

    FOR rcpt_rec IN SELECT * FROM "StuAmtRV"
    LOOP
        v_fyp_id := rcpt_rec."FYP_Id";
        v_VOUCHER_NO := rcpt_rec."FYP_ReceiptNo";
        v_fyp_date := rcpt_rec.fyp_date;
        v_ChequeNo := rcpt_rec."FYPPM_DDChequeNo";
        v_ChequeDate := rcpt_rec."FYPPM_DDChequeDate";
        v_AMOUNT := rcpt_rec."FYP_TotalPaidAmount";
        v_fyp_remarks := rcpt_rec.fyp_remarks;

        SELECT COUNT(*) INTO v_RCOUNT 
        FROM "TALLY_M_TRANSACTION" 
        WHERE "TMT_RefNo" = v_fyp_id 
            AND "TMT_VoucherTypeFlg" = 'RECEIPTVOUCHER' 
            AND "MI_Id" = p_MI_Id;

        IF (v_RCOUNT = 0) THEN

            SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

            SELECT "IMFY_Id" INTO v_IMFY_Id 
            FROM "IVRM_Master_FinancialYear" 
            WHERE "IMFY_FinancialYear" = v_ASSMAY_Year;

            INSERT INTO "Tally_M_Transaction"("MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", 
                "TMT_Amount", "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg", 
                "TMT_RefNo", "TMT_FinancialYear", "TMT_ChequeNo", "TMT_ChequeDate", "TMT_ActiveFlg", 
                "CreatedDate", "UpdatedDate")
            VALUES(p_MI_Id, v_fyp_date::date, 'RECEIPTVOUCHER', v_voucher_no, v_AMOUNT, 'CREATE', 'FEE', 
                0, v_fyp_id, v_IMFY_Id, v_ChequeNo, v_ChequeDate::date, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            SELECT "TMT_Id" INTO v_TM_ID 
            FROM "TALLY_M_TRANSACTION" 
            WHERE "TMT_RefNo" = v_fyp_id AND "MI_Id" = p_MI_Id 
            ORDER BY "TMT_Id" DESC 
            LIMIT 1;

            SELECT SUM(COALESCE("FTCP_PaidAmount", 0)) INTO v_T_Amount 
            FROM "clg"."Fee_T_College_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT SUM(COALESCE("FTCP_FineAmount", 0)) INTO v_t_Fine 
            FROM "clg"."Fee_T_College_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT "TMT_RefNo" INTO v_TMT_RefNo 
            FROM "Tally_M_Transaction" 
            WHERE "MI_Id" = p_MI_Id AND "TMT_Id" = v_TM_ID;

            SELECT "AMCST_AdmNo" || ' ' || (COALESCE("AMCST_FirstName", '') || '' || 
                   COALESCE("AMCST_MiddleName", '') || '' || COALESCE("AMCST_LastName", '')) 
            INTO v_RVRegLedgerIdN
            FROM "clg"."Adm_Master_College_Student" 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMCST_Id" = (SELECT "AMCST_Id" FROM "clg"."Fee_Y_Payment_College_Student" 
                                  WHERE "FYP_Id" = v_TMT_RefNo);

            SELECT CASE WHEN "FYP_TransactionTypeFlag" != 'C' THEN 'Sundry Debtors' 
                        WHEN "FYP_TransactionTypeFlag" = 'C' THEN 'Cash-In-Hand' END 
            INTO v_TTT_LedgerUnderT
            FROM "clg"."Fee_Y_Payment" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "fyp_id" = v_fyp_id;

            INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_TM_ID, v_RVRegLedgerIdN, v_TTT_LedgerUnderT, 'Cr', v_T_Amount, v_fyp_remarks, 
                1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            IF v_t_Fine > 0 THEN
                INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                    "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate") 
                VALUES(v_TM_ID, 'Fine', 'Sundry Debtors', 'Cr', v_t_Fine, v_fyp_remarks, 
                    1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
            END IF;

            SELECT CASE WHEN "FYP_TransactionTypeFlag" != 'C' THEN 'Bank' ELSE 'Cash' END 
            INTO v_RVRegLedgerId
            FROM "clg"."Fee_Y_Payment" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "fyp_id" = v_fyp_id;

            SELECT CASE WHEN "FYP_TransactionTypeFlag" != 'C' THEN 'Sundry Debtors' 
                        WHEN "FYP_TransactionTypeFlag" = 'C' THEN 'Cash-In-Hand' END 
            INTO v_TTT_LedgerUnder
            FROM "clg"."Fee_Y_Payment" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "fyp_id" = v_fyp_id;

            INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_TM_ID, v_RVRegLedgerId, v_TTT_LedgerUnder, 'Dr', v_AMOUNT, v_fyp_remarks, 
                1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        ELSE
            RAISE NOTICE 'Record already exist';
        END IF;

    END LOOP;

    PERFORM "dbo"."Tally_Excel_Report"(p_MI_Id);

END;
$$;