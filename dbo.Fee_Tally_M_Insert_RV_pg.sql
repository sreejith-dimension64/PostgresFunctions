CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_RV"(
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
    rcpt_cur RECORD;
BEGIN

    DROP TABLE IF EXISTS "StuAmtRV";

    v_Sqldynamic := '
    CREATE TEMP TABLE "StuAmtRV" AS
    SELECT DISTINCT "Fee_Y_Payment"."FYP_Id", "FYP_Receipt_No", CAST("fyp_date" AS date) AS fyp_date, 
           "FYP_DD_Cheque_No", "FYP_DD_Cheque_Date", "FYP_Tot_Amount", "fyp_remarks"
    FROM "dbo"."Fee_T_Payment"
    INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
        AND "dbo"."Fee_Y_Payment"."MI_Id" = ' || p_MI_Id || ' 
        AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || p_ASMAY_Id || '
    INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
        AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Fee_Y_Payment_School_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
        AND "dbo"."Adm_School_M_Academic_Year"."MI_Id" = ' || p_MI_Id || '
    WHERE "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND CAST("FYP_Date" AS date) BETWEEN TO_DATE(''' || p_FromDate || ''', ''DD-MM-YYYY'') 
        AND TO_DATE(''' || p_ToDate || ''', ''DD-MM-YYYY'')';

    EXECUTE v_Sqldynamic;

    FOR rcpt_cur IN SELECT * FROM "StuAmtRV"
    LOOP
        v_fyp_id := rcpt_cur."FYP_Id";
        v_VOUCHER_NO := rcpt_cur."FYP_Receipt_No";
        v_fyp_date := rcpt_cur."fyp_date";
        v_ChequeNo := rcpt_cur."FYP_DD_Cheque_No";
        v_ChequeDate := rcpt_cur."FYP_DD_Cheque_Date";
        v_AMOUNT := rcpt_cur."FYP_Tot_Amount";
        v_fyp_remarks := rcpt_cur."fyp_remarks";

        SELECT COUNT(*) INTO v_RCOUNT 
        FROM "TALLY_M_TRANSACTION" 
        WHERE "TMT_RefNo" = v_fyp_id::varchar 
            AND "TMT_VoucherTypeFlg" = 'RECEIPTVOUCHER' 
            AND "MI_Id" = p_MI_Id;

        IF (v_RCOUNT = 0) THEN

            SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

            SELECT "IMFY_Id" INTO v_IMFY_Id 
            FROM "IVRM_Master_FinancialYear" 
            WHERE "IMFY_FinancialYear" = v_ASSMAY_Year;

            INSERT INTO "Tally_M_Transaction"("MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", "TMT_Amount", 
                "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg", "TMT_RefNo", "TMT_FinancialYear", 
                "TMT_ChequeNo", "TMT_ChequeDate", "TMT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(p_MI_Id, CAST(v_fyp_date AS date), 'RECEIPTVOUCHER', v_voucher_no, v_AMOUNT, 
                'CREATE', 'FEE', 0, v_fyp_id::varchar, v_IMFY_Id, 
                v_ChequeNo, CAST(v_ChequeDate AS date), 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            SELECT "TMT_Id" INTO v_TM_ID 
            FROM "TALLY_M_TRANSACTION" 
            WHERE "TMT_RefNo" = v_fyp_id::varchar AND "MI_Id" = p_MI_Id 
            ORDER BY "TMT_Id" DESC LIMIT 1;

            SELECT SUM(COALESCE("FTP_Paid_Amt", 0)) INTO v_T_Amount 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT SUM(COALESCE("FTP_Fine_Amt", 0)) INTO v_t_Fine 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT "TMT_RefNo" INTO v_TMT_RefNo 
            FROM "Tally_M_Transaction" 
            WHERE "MI_Id" = p_MI_Id AND "TMT_Id" = v_TM_ID;

            SELECT "AMST_AdmNo" || ' ' || (COALESCE("AMST_FirstName", '') || '' || COALESCE("AMST_MiddleName", '') || '' || COALESCE("AMST_LastName", '')) 
            INTO v_RVRegLedgerIdN 
            FROM "Adm_M_Student" 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = (SELECT "AMST_Id" 
                                FROM "Fee_Y_Payment_School_Student" 
                                INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id" 
                                WHERE "Fee_Y_Payment_School_Student"."FYP_Id" = v_TMT_RefNo::bigint);

            SELECT (CASE WHEN "FYP_Bank_Or_Cash" != 'C' THEN 'Sundry Debtors' WHEN "FYP_Bank_Or_Cash" = 'C' THEN 'Cash-In-Hand' END) 
            INTO v_TTT_LedgerUnderT 
            FROM "Fee_Y_Payment" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "fyp_id" = v_fyp_id;

            INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", 
                "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_TM_ID, v_RVRegLedgerIdN, v_TTT_LedgerUnderT, 'Cr', v_T_Amount, v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            IF v_t_Fine > 0 THEN
                INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", 
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
                VALUES(v_TM_ID, 'Fine', 'Sundry Debtors', 'Cr', v_t_Fine, v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
            END IF;

            SELECT (CASE WHEN "FYP_Bank_Or_Cash" != 'C' THEN 'Bank' ELSE 'Cash' END) 
            INTO v_RVRegLedgerId 
            FROM "Fee_Y_Payment" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "fyp_id" = v_fyp_id;

            SELECT (CASE WHEN "FYP_Bank_Or_Cash" != 'C' THEN 'Sundry Debtors' WHEN "FYP_Bank_Or_Cash" = 'C' THEN 'Cash-In-Hand' END) 
            INTO v_TTT_LedgerUnder 
            FROM "Fee_Y_Payment" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "fyp_id" = v_fyp_id;

            INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", 
                "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_TM_ID, v_RVRegLedgerId, v_TTT_LedgerUnder, 'Dr', v_AMOUNT, v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        ELSE
            RAISE NOTICE 'Record already exist';
        END IF;

    END LOOP;

    PERFORM "dbo"."Tally_Excel_Report"(p_MI_Id);

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;