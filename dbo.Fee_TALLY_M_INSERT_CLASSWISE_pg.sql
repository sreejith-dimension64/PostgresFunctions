CREATE OR REPLACE FUNCTION "dbo"."Fee_TALLY_M_INSERT_CLASSWISE"(
    p_AMST_Id bigint,
    p_IMFY_Id bigint,
    p_ASMCL_Id bigint,
    p_AMST_REG_NO varchar(100),
    p_ASMAY_Id bigint,
    p_MI_Id bigint
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
    v_ChequeDate TIMESTAMP;
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
    v_row_count int;
    rcpt_cur_rec RECORD;
BEGIN

    SELECT "TLU_Id" INTO v_tlu_id 
    FROM "TALLY_LEDGER_UNDER" 
    WHERE "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "MI_Id" = p_MI_Id;
    
    SELECT "TMV_NAME" INTO v_VOUCHER_TYPE 
    FROM "TALLY_M_VOUCHER" 
    WHERE "TMV_TRANS_TYPE" = 'FEE';

    FOR rcpt_cur_rec IN
        SELECT DISTINCT 
            "Fee_Y_Payment"."FYP_Id",
            "FYP_Receipt_No", 
            "fyp_date",
            "FYP_DD_Cheque_No",
            "FYP_DD_Cheque_Date",
            "FYP_Tot_Amount",
            "fyp_remarks"
        FROM "Fee_T_Payment" 
        INNER JOIN "Fee_Y_Payment" 
            ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
            AND "Fee_Y_Payment"."MI_Id" = p_MI_Id 
            AND "Fee_Y_Payment"."ASMAY_ID" = p_ASMAY_Id
        INNER JOIN "Fee_Y_Payment_School_Student" 
            ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
            AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = p_ASMAY_Id
        INNER JOIN "Adm_School_M_Academic_Year" 
            ON "Fee_Y_Payment_School_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
            AND "Adm_School_M_Academic_Year"."MI_Id" = p_MI_Id 
        WHERE "Fee_Y_Payment_School_Student"."AMST_Id" = p_AMST_Id 
            AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = p_ASMAY_Id
    LOOP
        v_fyp_id := rcpt_cur_rec."FYP_Id";
        v_VOUCHER_NO := rcpt_cur_rec."FYP_Receipt_No";
        v_fyp_date := rcpt_cur_rec."fyp_date";
        v_ChequeNo := rcpt_cur_rec."FYP_DD_Cheque_No";
        v_ChequeDate := rcpt_cur_rec."FYP_DD_Cheque_Date";
        v_AMOUNT := rcpt_cur_rec."FYP_Tot_Amount";
        v_fyp_remarks := rcpt_cur_rec."fyp_remarks";

        SELECT COUNT(*) INTO v_row_count 
        FROM "TALLY_M_TRANSACTION" 
        WHERE "TMT_RefNo" = v_fyp_id 
            AND "TMT_VoucherTypeFlg" = 'RECEIPTVOUCHER';
        
        IF v_row_count = 0 THEN
            INSERT INTO "Tally_M_Transaction"(
                "TMT_Date",
                "TMT_VoucherTypeFlg",
                "TMT_VoucherNo",
                "TMT_Amount",
                "TMT_TransactionStatusFlg",
                "TMT_TransactionTypeFlg",
                "TMT_ExportToTallyFlg",
                "TMT_RefNo",
                "TMT_ChequeNo",
                "TMT_ChequeDate",
                "TMT_ActiveFlg",
                "CreatedDate",
                "UpdatedDate"
            )
            VALUES(
                TO_CHAR(v_fyp_date, 'DD/MM/YYYY'),
                v_VOUCHER_TYPE,
                v_VOUCHER_NO,
                v_AMOUNT,
                'CREATE',
                'FEE',
                0,
                v_fyp_id,
                v_ChequeNo,
                TO_CHAR(v_ChequeDate, 'DD/MM/YYYY'),
                1,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            );
            
            SELECT "TMT_Id" INTO v_TM_ID 
            FROM "TALLY_M_TRANSACTION" 
            WHERE "TMT_RefNo" = v_fyp_id 
                AND "MI_Id" = p_MI_Id 
            ORDER BY "TMT_Id" DESC 
            LIMIT 1;
            
            SELECT SUM(COALESCE("FTP_Paid_Amt", 0)) INTO v_T_Amount 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id;
            
            SELECT SUM(COALESCE("FTP_Fine_Amt", 0)) INTO v_t_Fine 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT "fyp_remarks" INTO v_NARRATION 
            FROM "Fee_Y_Payment" 
            WHERE "FYP_Id" = v_fyp_id 
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_ID" = p_ASMAY_Id;

            SELECT "FYGHM_RVRegLedgerId", "FYGHM_RVRegLedgerUnder" 
            INTO v_RVRegLedgerId, v_RVRegLedgerUnder
            FROM "Fee_Yearly_Group_Head_LedgerMapping" "LM"
            INNER JOIN "Fee_Yearly_Group_Head_Mapping" "HM" 
                ON "LM"."FYGHM_Id" = "HM"."FYGHM_Id" 
                AND "HM"."MI_Id" = p_MI_Id 
                AND "HM"."ASMAY_Id" = p_ASMAY_Id
            INNER JOIN "Fee_Master_Student_Group" "SG" 
                ON "SG"."FMG_Id" = "HM"."FMG_Id" 
                AND "FMSG_ActiveFlag" = 'Y'
            INNER JOIN "Fee_Y_Payment_School_Student" "YSS" 
                ON "YSS"."AMST_Id" = "SG"."AMST_Id" 
                AND "YSS"."ASMAY_Id" = "SG"."ASMAY_Id" 
                AND "HM"."MI_Id" = p_MI_Id
            WHERE "YSS"."FYP_Id" = v_fyp_id
            LIMIT 1;
            
            INSERT INTO "TALLY_T_TRANSACTION" (
                "TMT_Id",
                "TTT_LedgerCode",
                "TTT_LedgerUnder",
                "TTT_DRCRFlg",
                "TTT_Amount",
                "TTT_Naration",
                "TTT_ActiveFlg",
                "CreatedDate",
                "UpdatedDate"
            ) 
            VALUES(
                v_TM_ID,
                v_RVRegLedgerId,
                v_RVRegLedgerUnder,
                'Cr',
                v_T_Amount,
                v_fyp_remarks,
                1,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            );
            
            IF v_t_Fine > 0 THEN
                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id",
                    "TTT_LedgerCode",
                    "TTT_LedgerUnder",
                    "TTT_DRCRFlg",
                    "TTT_Amount",
                    "TTT_Naration",
                    "TTT_ActiveFlg",
                    "CreatedDate",
                    "UpdatedDate"
                ) 
                VALUES(
                    v_TM_ID,
                    v_RVRegLedgerId,
                    v_RVRegLedgerUnder,
                    'Cr',
                    v_t_Fine,
                    v_fyp_remarks,
                    1,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                );
            END IF;
            
            INSERT INTO "TALLY_T_TRANSACTION" (
                "TMT_Id",
                "TTT_LedgerCode",
                "TTT_LedgerUnder",
                "TTT_DRCRFlg",
                "TTT_Amount",
                "TTT_Naration",
                "TTT_ActiveFlg",
                "CreatedDate",
                "UpdatedDate"
            )
            VALUES(
                v_TM_ID,
                v_RVRegLedgerId,
                v_RVRegLedgerUnder,
                'Dr',
                v_AMOUNT,
                v_narration,
                1,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            );
        END IF;
    END LOOP;

    RETURN;
END;
$$;