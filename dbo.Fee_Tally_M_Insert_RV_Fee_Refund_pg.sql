CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_RV_Fee_Refund"(
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
    v_fr_id bigint;
    v_fr_date timestamp;
    v_l_code_new bigint;
    v_fr_remarks varchar(5000);
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
    rcpt_record RECORD;
BEGIN

    DROP TABLE IF EXISTS "StuAmtRVR";

    v_Sqldynamic := '
    CREATE TEMP TABLE "StuAmtRVR" AS
    SELECT DISTINCT "FR"."FR_ID", "FR_RefundNo", "FR_Date"::date AS "FR_date", "FR_CheqNo", "FR_CheqDate", "FR_RefundAmount", ''Refund'' AS "FR_remarks"
    FROM "dbo"."Fee_Refund" "FR"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "FR"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
        AND "dbo"."Adm_School_M_Academic_Year"."MI_Id" = ' || p_MI_Id::varchar || '
    WHERE "FR_RefundFlag" = ''true'' 
        AND "FR_RefundAmount" > 0 
        AND "FR"."ASMAY_Id" = ' || p_ASMAY_Id::varchar || '
        AND "FR_Date"::date BETWEEN TO_DATE(''' || p_FromDate || ''', ''DD-MM-YYYY'') 
        AND TO_DATE(''' || p_ToDate || ''', ''DD-MM-YYYY'')';

    EXECUTE v_Sqldynamic;

    FOR rcpt_record IN 
        SELECT * FROM "StuAmtRVR"
    LOOP
        v_fr_id := rcpt_record."FR_ID";
        v_VOUCHER_NO := rcpt_record."FR_RefundNo";
        v_fr_date := rcpt_record."FR_date";
        v_ChequeNo := rcpt_record."FR_CheqNo";
        v_ChequeDate := rcpt_record."FR_CheqDate";
        v_AMOUNT := rcpt_record."FR_RefundAmount";
        v_fr_remarks := rcpt_record."FR_remarks";

        SELECT COUNT(*) INTO v_RCOUNT 
        FROM "TALLY_M_TRANSACTION" 
        WHERE "TMT_RefNo" = v_fr_id::varchar 
            AND "TMT_VoucherTypeFlg" = 'PAYMENTVOUCHER' 
            AND "MI_Id" = p_MI_Id 
            AND "TMT_TransactionTypeFlg" = 'Refund';

        IF (v_RCOUNT = 0) THEN

            SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

            SELECT "IMFY_Id" INTO v_IMFY_Id 
            FROM "IVRM_Master_FinancialYear" 
            WHERE "IMFY_FinancialYear" = v_ASSMAY_Year;

            INSERT INTO "Tally_M_Transaction"("MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", "TMT_Amount", "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg", "TMT_RefNo", "TMT_FinancialYear", "TMT_ChequeNo", "TMT_ChequeDate", "TMT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(p_MI_Id, v_fr_date::date, 'PAYMENTVOUCHER', v_voucher_no, v_AMOUNT, 'CREATE', v_fr_remarks, 0, v_fr_id::varchar, v_IMFY_Id, v_ChequeNo, v_ChequeDate::date, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            SELECT "TMT_Id" INTO v_TM_ID 
            FROM "TALLY_M_TRANSACTION" 
            WHERE "TMT_RefNo" = v_fr_id::varchar AND "MI_Id" = p_MI_Id 
            ORDER BY "TMT_Id" DESC 
            LIMIT 1;

            SELECT "TMT_RefNo" INTO v_TMT_RefNo 
            FROM "Tally_M_Transaction" 
            WHERE "MI_Id" = p_MI_Id AND "TMT_Id" = v_TM_ID;

            SELECT "AMST_AdmNo" || '+' || COALESCE("AMST_FirstName", '') || '+' || COALESCE("AMST_MiddleName", '') || '+' || COALESCE("AMST_LastName", '') 
            INTO v_RVRegLedgerIdN
            FROM "Adm_M_Student" 
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = (SELECT "AMST_Id" FROM "Fee_Refund" WHERE "FR_Id" = v_TMT_RefNo::bigint);

            SELECT (CASE WHEN "FR_BANK_CASH" != 'C' THEN 'Sundry Debtors' WHEN "FR_BANK_CASH" = 'C' THEN 'Cash-In-Hand' END) 
            INTO v_TTT_LedgerUnderT
            FROM "Fee_Refund" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "FR_Id" = v_fr_id;

            INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_TM_ID, v_RVRegLedgerIdN, v_TTT_LedgerUnderT, 'Dr', v_AMOUNT, v_fr_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            SELECT (CASE WHEN "FR_BANK_CASH" != 'C' THEN 'Bank' ELSE 'Cash' END) 
            INTO v_RVRegLedgerId
            FROM "Fee_Refund" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "FR_Id" = v_fr_id;

            SELECT (CASE WHEN "FR_BANK_CASH" != 'C' THEN 'Sundry Debtors' WHEN "FR_BANK_CASH" = 'C' THEN 'Cash-In-Hand' END) 
            INTO v_TTT_LedgerUnder
            FROM "Fee_Refund" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_ID" = p_ASMAY_Id AND "FR_Id" = v_fr_id;

            INSERT INTO "TALLY_T_TRANSACTION" ("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_TM_ID, v_RVRegLedgerId, v_TTT_LedgerUnder, 'Cr', v_AMOUNT, v_fr_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        ELSE
            RAISE NOTICE 'Record already exist';
        END IF;

    END LOOP;

    PERFORM "Tally_Excel_Report"(p_MI_Id);

    RETURN;

END;
$$;