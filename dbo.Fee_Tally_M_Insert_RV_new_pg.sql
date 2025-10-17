CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_RV_new"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FromDate text,
    p_ToDate text
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
    v_FY_ASMAY_Id bigint;
    v_AMST_IdC bigint;
    v_FYGHM_Id bigint;
    v_NET_TAMOUNT decimal(18,2);
    v_FMH_Id bigint;
    v_FMA_Id bigint;
    v_radcount int;
    v_rrecount int;
    v_rarcount int;
    v_FYP_Bank_Or_Cash varchar(100);
    rcpt_cur RECORD;
BEGIN

    DROP TABLE IF EXISTS "StuAmtRV";

    v_Sqldynamic := '
    CREATE TEMP TABLE "StuAmtRV" AS
    SELECT DISTINCT "Fee_Y_Payment"."FYP_Id", "FYP_Receipt_No", 
           CAST("fyp_date" AS date) AS fyp_date, 
           "FYP_DD_Cheque_No", "FYP_DD_Cheque_Date", "FYP_Tot_Amount", "fyp_remarks",
           (CASE WHEN "FYP_Bank_Or_Cash" = COALESCE(''B'', ''0'') THEN ''Bank''
                 WHEN "FYP_Bank_Or_Cash" = COALESCE(''C'', ''0'') THEN ''Cash'' 
                 WHEN "FYP_Bank_Or_Cash" = COALESCE(''O'', ''0'') THEN ''Online''
                 WHEN "FYP_Bank_Or_Cash" = COALESCE(''S'', ''0'') THEN ''Card'' 
                 WHEN "FYP_Bank_Or_Cash" = COALESCE(''E'', ''0'') THEN ''ECS'' 
                 WHEN "FYP_Bank_Or_Cash" = COALESCE(''R'', ''0'') THEN ''RTGS'' END) AS "FYP_Bank_Or_Cash"
    FROM "dbo"."Fee_T_Payment" 
    INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
           AND "dbo"."Fee_Y_Payment"."MI_Id" = ' || p_MI_Id || ' 
           AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || p_ASMAY_Id || '
    INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
           AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Fee_Y_Payment_School_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
           AND "dbo"."Adm_School_M_Academic_Year"."MI_Id" = ' || p_MI_Id || '
    WHERE "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
          AND CAST("FYP_Date" AS date) BETWEEN CAST(''' || p_FromDate || ''' AS date) AND CAST(''' || p_ToDate || ''' AS date)';

    EXECUTE v_Sqldynamic;

    FOR rcpt_cur IN SELECT * FROM "StuAmtRV" LOOP
        v_fyp_id := rcpt_cur."FYP_Id";
        v_voucher_no := rcpt_cur."FYP_Receipt_No";
        v_fyp_date := rcpt_cur.fyp_date;
        v_ChequeNo := rcpt_cur."FYP_DD_Cheque_No";
        v_ChequeDate := rcpt_cur."FYP_DD_Cheque_Date";
        v_AMOUNT := rcpt_cur."FYP_Tot_Amount";
        v_fyp_remarks := rcpt_cur.fyp_remarks;
        v_FYP_Bank_Or_Cash := rcpt_cur."FYP_Bank_Or_Cash";

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

            INSERT INTO "Tally_M_Transaction"(
                "MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", "TMT_Amount",
                "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg",
                "TMT_RefNo", "TMT_FinancialYear", "TMT_ChequeNo", "TMT_ChequeDate",
                "TMT_ActiveFlg", "CreatedDate", "UpdatedDate", "FMT_Id", "TMT_TallyMasterId"
            )
            VALUES(
                p_MI_Id, CAST(v_fyp_date AS date), 'RECEIPTVOUCHER', v_voucher_no, v_AMOUNT,
                'CREATE', v_FYP_Bank_Or_Cash, 0, v_fyp_id, v_IMFY_Id, v_ChequeNo, 
                CAST(v_ChequeDate AS date), 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, '0'
            );

            SELECT "TMT_Id" INTO v_TM_ID 
            FROM "TALLY_M_TRANSACTION" 
            WHERE "TMT_RefNo" = v_fyp_id AND "MI_Id" = p_MI_Id 
            ORDER BY "TMT_Id" DESC 
            LIMIT 1;

            SELECT SUM(COALESCE("FTP_Paid_Amt", 0)) INTO v_T_Amount 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT SUM(COALESCE("FTP_Fine_Amt", 0)) INTO v_t_Fine 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id;

            SELECT "FMA_Id" INTO v_FMA_Id 
            FROM "Fee_t_Payment" 
            WHERE "FYP_Id" = v_fyp_id 
            LIMIT 1;

            SELECT "ASMAY_Id", "FMH_Id" INTO v_FY_ASMAY_Id, v_FMH_Id 
            FROM "Fee_Master_Amount" 
            WHERE "FMA_Id" = v_FMA_Id AND "MI_Id" = p_MI_Id;

            -- AdvanceFeeDate start
            SELECT COUNT(*) INTO v_radcount 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = p_MI_Id 
                  AND "ASMAY_Id" = v_FY_ASMAY_Id 
                  AND CAST(v_fyp_date AS date) <= CAST("ASMAY_AdvanceFeeDate" AS date);

            IF (v_radcount <> 0) THEN

                SELECT "FYGHM_Id" INTO v_FYGHM_Id 
                FROM "Fee_Yearly_Group_Head_Mapping" 
                WHERE "MI_Id" = p_MI_Id 
                      AND "ASMAY_Id" = v_FY_ASMAY_Id 
                      AND "FMH_Id" = v_FMH_Id 
                      AND "FYGHM_FineApplicableFlag" IS NULL;

                SELECT "FYGHM_RVAdvanceLegderId", "FYGHM_RVAdvanceLegderUnder" 
                INTO v_RVRegLedgerIdN, v_TTT_LedgerUnderT 
                FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                WHERE "FYGHM_Id" = v_FYGHM_Id;

                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    v_TM_ID, v_RVRegLedgerIdN, v_TTT_LedgerUnderT, 'Cr', v_T_Amount,
                    v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

                IF v_t_Fine > 0 THEN
                    INSERT INTO "TALLY_T_TRANSACTION" (
                        "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                        "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                    )
                    VALUES(
                        v_TM_ID, 'Fine', 'Sundry Debtors', 'Cr', v_t_Fine,
                        v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );
                END IF;

                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    v_TM_ID, v_RVRegLedgerId, v_TTT_LedgerUnder, 'Dr', v_AMOUNT,
                    v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

            END IF;
            -- AdvanceFeeDate end

            -- RegularFeeDate start
            SELECT COUNT(*) INTO v_rrecount 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = p_MI_Id 
                  AND "ASMAY_Id" = v_FY_ASMAY_Id 
                  AND (CAST(v_fyp_date AS date) BETWEEN CAST("ASMAY_RegularFeeFDate" AS date) 
                       AND CAST("ASMAY_RegularFeeTDate" AS date));

            IF (v_rrecount <> 0) THEN

                SELECT "FYGHM_Id" INTO v_FYGHM_Id 
                FROM "Fee_Yearly_Group_Head_Mapping" 
                WHERE "MI_Id" = p_MI_Id 
                      AND "ASMAY_Id" = v_FY_ASMAY_Id 
                      AND "FMH_Id" = v_FMH_Id;

                SELECT "FYGHM_RVRegLedgerId", "FYGHM_RVRegLedgerUnder" 
                INTO v_RVRegLedgerIdN, v_TTT_LedgerUnderT 
                FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                WHERE "FYGHM_Id" = v_FYGHM_Id;

                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    v_TM_ID, v_RVRegLedgerIdN, v_TTT_LedgerUnderT, 'Cr', v_T_Amount,
                    v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

                IF v_t_Fine > 0 THEN
                    INSERT INTO "TALLY_T_TRANSACTION" (
                        "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                        "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                    )
                    VALUES(
                        v_TM_ID, 'Fine', 'Sundry Debtors', 'Cr', v_t_Fine,
                        v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );
                END IF;

                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    v_TM_ID, v_RVRegLedgerId, v_TTT_LedgerUnder, 'Dr', v_AMOUNT,
                    v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

            END IF;
            -- RegularFeeDate end

            -- ArrearFeeDate start
            SELECT COUNT(*) INTO v_rarcount 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = p_MI_Id 
                  AND "ASMAY_Id" = v_FY_ASMAY_Id 
                  AND (CAST(v_fyp_date AS date) > CAST("ASMAY_ArrearFeeDate" AS date));

            IF (v_rarcount <> 0) THEN

                SELECT "FYGHM_Id" INTO v_FYGHM_Id 
                FROM "Fee_Yearly_Group_Head_Mapping" 
                WHERE "MI_Id" = p_MI_Id 
                      AND "ASMAY_Id" = v_FY_ASMAY_Id 
                      AND "FMH_Id" = v_FMH_Id;

                SELECT "FYGHM_RVArrearLedgerId", "FYGHM_RVArrearLedgerUnder" 
                INTO v_RVRegLedgerIdN, v_TTT_LedgerUnderT 
                FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                WHERE "FYGHM_Id" = v_FYGHM_Id;

                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    v_TM_ID, v_RVRegLedgerIdN, v_TTT_LedgerUnderT, 'Cr', v_T_Amount,
                    v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

                IF v_t_Fine > 0 THEN
                    INSERT INTO "TALLY_T_TRANSACTION" (
                        "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                        "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                    )
                    VALUES(
                        v_TM_ID, 'Fine', 'Sundry Debtors', 'Cr', v_t_Fine,
                        v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );
                END IF;

                INSERT INTO "TALLY_T_TRANSACTION" (
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount",
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    v_TM_ID, v_RVRegLedgerId, v_TTT_LedgerUnder, 'Dr', v_AMOUNT,
                    v_fyp_remarks, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

            END IF;
            -- ArrearFeeDate end

        ELSE
            RAISE NOTICE 'Record already exist';
        END IF;

    END LOOP;

    PERFORM "dbo"."Tally_Excel_Report"(p_MI_Id);

END;
$$;