CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_JV_Concession"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_AMST_Id TEXT,
    p_FMT_Id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Rcount INT;
    v_AMST_IdC BIGINT;
    v_ASSMAY_Year VARCHAR(50);
    v_IMFY_Id BIGINT;
    v_NetAmt DECIMAL(18,2);
    v_Sqldynamic TEXT;
    v_FYGHM_Id BIGINT;
    v_NET_TAMOUNT DECIMAL(18,2);
    v_TMT_Id BIGINT;
    v_VOUCHER_NO VARCHAR(300);
    v_JVRegLedgerId VARCHAR(50);
    v_JVRegLedgerUnder VARCHAR(50);
    v_TMT_RefNo VARCHAR(100);
    v_FMT_IdC BIGINT;
    rec_student RECORD;
    rec_trans RECORD;
BEGIN
    v_Rcount := 0;

    DROP TABLE IF EXISTS "StudentNetAmt";
    DROP TABLE IF EXISTS "StudentNetAmtT";

    IF(p_FMT_Id = '') THEN

        v_Sqldynamic := 'CREATE TEMP TABLE "StudentNetAmt" AS
        SELECT "AMST_Id", SUM("ConAmt") AS "ConAmt" FROM (
            SELECT DISTINCT "Fee_Student_Status"."AMST_Id", "Fee_Master_Terms"."FMT_Id", 
            "fee_student_status"."FSS_ConcessionAmount" AS "ConAmt"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                AND "Fee_Master_Group"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                AND "Fee_Master_Head"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                AND "Adm_M_Student"."MI_Id" = ' || p_MI_Id || ' 
                AND "AMST_ActiveFlag" = 1 AND "amst_sol" = ''S''
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "AMAY_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
                AND "Adm_School_M_Class"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" 
                AND "Adm_School_M_Section"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
                AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || p_MI_Id || ' 
                AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                AND "Fee_Master_Terms"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                AND "fee_t_installment"."MI_ID" = ' || p_MI_Id || '
            INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND "Adm_School_Y_Student"."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND "fee_student_status"."MI_Id" = ' || p_MI_Id || ' 
                AND "fee_student_status"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND "Adm_School_Y_Student"."AMST_Id" IN (' || p_AMST_Id || ') 
                AND "fee_student_status"."FSS_ConcessionAmount" > 0
        ) AS "NEW" GROUP BY "AMST_Id"';

        EXECUTE v_Sqldynamic;

        FOR rec_student IN SELECT * FROM "StudentNetAmt" LOOP
            v_AMST_IdC := rec_student."AMST_Id";
            v_NetAmt := rec_student."ConAmt";

            SELECT COUNT(*) INTO v_Rcount 
            FROM "Tally_M_Transaction" 
            WHERE "TMT_RefNo" = v_AMST_IdC::VARCHAR 
                AND "MI_Id" = p_MI_Id 
                AND "TMT_VoucherTypeFlg" = 'JOURNALVOUCHER' 
                AND "TMT_TransactionTypeFlg" = 'Concession';

            IF(v_Rcount = 0) THEN

                SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
                FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

                SELECT "IMFY_Id" INTO v_IMFY_Id 
                FROM "IVRM_Master_FinancialYear" 
                WHERE "IMFY_FinancialYear" = v_ASSMAY_Year;

                INSERT INTO "Tally_M_Transaction"("MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", 
                    "TMT_Amount", "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg", 
                    "TMT_RefNo", "TMT_FinancialYear", "TMT_ActiveFlg", "CreatedDate", "UpdatedDate", 
                    "TMT_ChequeNo", "TMT_ChequeDate", "FMT_Id")
                VALUES(p_MI_Id, CURRENT_TIMESTAMP, 'JOURNALVOUCHER', '', v_NetAmt, 'CREATE', 'Concession', 
                    0, v_AMST_IdC::VARCHAR, v_IMFY_Id, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                    '', '1900-01-01', 0);

                SELECT MAX("TMT_Id") INTO v_TMT_ID 
                FROM "Tally_M_Transaction" 
                WHERE "MI_Id" = p_MI_Id AND "TMT_RefNo" = v_AMST_IdC::VARCHAR;

                FOR rec_trans IN 
                    SELECT "FYGHM_Id", SUM("Con_amount") AS "Con_amount" FROM (
                        SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", 
                            "Fee_Master_Terms"."FMT_Id", 
                            "FSS_ConcessionAmount" AS "Con_amount"
                        FROM "Fee_Student_Status"
                        INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                            ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                            AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                            AND "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                            AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id
                        INNER JOIN "Fee_Master_Terms_FeeHeads" 
                            ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id 
                            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                        INNER JOIN "Fee_Master_Terms" 
                            ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                            AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
                        INNER JOIN "fee_t_installment" 
                            ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                            AND "fee_t_installment"."MI_ID" = p_MI_Id
                        WHERE "Fee_Student_Status"."AMST_Id" = v_AMST_IdC 
                            AND "Fee_Student_Status"."MI_Id" = p_MI_Id 
                            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
                            AND "fee_student_status"."FSS_ConcessionAmount" > 0
                    ) AS "NEW" GROUP BY "FYGHM_Id"
                LOOP
                    v_FYGHM_Id := rec_trans."FYGHM_Id";
                    v_NET_TAMOUNT := rec_trans."Con_amount";

                    SELECT "FYGHM_JVRegLedgerId", "FYGHM_JVRegLedgerUnder" 
                    INTO v_JVRegLedgerId, v_JVRegLedgerUnder
                    FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                    WHERE "FYGHM_Id" = v_FYGHM_Id;

                    INSERT INTO "TALLY_T_TRANSACTION"("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                        "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
                    VALUES(v_TMT_ID, v_JVRegLedgerId, v_JVRegLedgerUnder, 'Dr', v_NET_TAMOUNT, 
                        'Concession', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END LOOP;

                SELECT SUM("Con_amount") INTO v_NET_TAMOUNT FROM (
                    SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", 
                        "Fee_Master_Terms"."FMT_Id", 
                        "FSS_ConcessionAmount" AS "Con_amount"
                    FROM "Fee_Student_Status"
                    INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                        ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                        AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                        AND "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                        AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id
                    INNER JOIN "Fee_Master_Terms_FeeHeads" 
                        ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
                        AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id 
                        AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                    INNER JOIN "Fee_Master_Terms" 
                        ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                        AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
                    INNER JOIN "fee_t_installment" 
                        ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                        AND "fee_t_installment"."MI_ID" = p_MI_Id
                    WHERE "Fee_Student_Status"."AMST_Id" = v_AMST_IdC 
                        AND "Fee_Student_Status"."MI_Id" = p_MI_Id 
                        AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
                        AND "fee_student_status"."FSS_ConcessionAmount" > 0
                ) AS "NEW";

                SELECT "TMT_RefNo" INTO v_TMT_RefNo 
                FROM "Tally_M_Transaction" 
                WHERE "MI_Id" = p_MI_Id AND "TMT_Id" = v_TMT_ID;

                SELECT "AMST_AdmNo" || COALESCE("AMST_FirstName", '') || '' || COALESCE("AMST_MiddleName", '') || '' || COALESCE("AMST_LastName", '') 
                INTO v_JVRegLedgerId
                FROM "Adm_M_Student" 
                WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = v_TMT_RefNo::BIGINT;

                INSERT INTO "TALLY_T_TRANSACTION"("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                    "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
                VALUES(v_TMT_Id, v_JVRegLedgerId, 'Sundry Debtors', 'Cr', v_NET_TAMOUNT, 
                    'Concession', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
            ELSE
                RAISE NOTICE 'Record already exist';
            END IF;
        END LOOP;

    ELSE

        v_Sqldynamic := 'CREATE TEMP TABLE "StudentNetAmtT" AS
        SELECT "AMST_Id", "FMT_Id", SUM("ConAmt") AS "ConAmt" FROM (
            SELECT DISTINCT "Fee_Student_Status"."AMST_Id", "Fee_Master_Terms"."FMT_Id", 
            "fee_student_status"."FSS_ConcessionAmount" AS "ConAmt"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                AND "Fee_Master_Group"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                AND "Fee_Master_Head"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                AND "Adm_M_Student"."MI_Id" = ' || p_MI_Id || ' 
                AND "AMST_ActiveFlag" = 1 AND "amst_sol" = ''S''
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "AMAY_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
                AND "Adm_School_M_Class"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" 
                AND "Adm_School_M_Section"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
                AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || p_MI_Id || ' 
                AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                AND "Fee_Master_Terms"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                AND "fee_t_installment"."MI_ID" = ' || p_MI_Id || '
            INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND "Adm_School_Y_Student"."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND "fee_student_status"."MI_Id" = ' || p_MI_Id || ' 
                AND "fee_student_status"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND "Adm_School_Y_Student"."AMST_Id" IN (' || p_AMST_Id || ') 
                AND "fee_student_status"."FSS_ConcessionAmount" > 0
                AND "Fee_Master_Terms"."FMT_Id" IN (' || p_FMT_Id || ')
        ) AS "New" GROUP BY "AMST_Id", "FMT_Id"';

        EXECUTE v_Sqldynamic;

        FOR rec_student IN SELECT * FROM "StudentNetAmtT" LOOP
            v_AMST_IdC := rec_student."AMST_Id";
            v_FMT_IdC := rec_student."FMT_Id";
            v_NetAmt := rec_student."ConAmt";

            SELECT COUNT(*) INTO v_Rcount 
            FROM "Tally_M_Transaction" 
            WHERE "TMT_RefNo" = v_AMST_IdC::VARCHAR 
                AND "MI_Id" = p_MI_Id 
                AND "TMT_VoucherTypeFlg" = 'JOURNALVOUCHER' 
                AND "FMT_Id" = v_FMT_IdC 
                AND "TMT_TransactionTypeFlg" = 'Concession';

            IF(v_Rcount = 0) THEN

                SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
                FROM "Adm_School_M_Academic_Year" 
                WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

                SELECT "IMFY_Id" INTO v_IMFY_Id 
                FROM "IVRM_Master_FinancialYear" 
                WHERE "IMFY_FinancialYear" = v_ASSMAY_Year;

                INSERT INTO "Tally_M_Transaction"("MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", 
                    "TMT_Amount", "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg", 
                    "TMT_RefNo", "TMT_FinancialYear", "TMT_ActiveFlg", "CreatedDate", "UpdatedDate", 
                    "FMT_Id", "TMT_ChequeNo", "TMT_ChequeDate")
                VALUES(p_MI_Id, CURRENT_TIMESTAMP, 'JOURNALVOUCHER', '', v_NetAmt, 'CREATE', 'Concession', 
                    0, v_AMST_IdC::VARCHAR, v_IMFY_Id, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                    v_FMT_IdC, '', '1900-01-01');

                SELECT MAX("TMT_Id") INTO v_TMT_ID 
                FROM "Tally_M_Transaction" 
                WHERE "MI_Id" = p_MI_Id AND "TMT_RefNo" = v_AMST_IdC::VARCHAR AND "FMT_Id" = v_FMT_IdC;

                FOR rec_trans IN 
                    SELECT "FYGHM_Id", SUM("Con_amount") AS "Con_amount" FROM (
                        SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", 
                            "Fee_Master_Terms_FeeHeads"."FMT_Id", 
                            "FSS_ConcessionAmount" AS "Con_amount"
                        FROM "Fee_Student_Status"
                        INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                            ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                            AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                            AND "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                            AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id
                        INNER JOIN "Fee_Master_Terms_FeeHeads" 
                            ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id 
                            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                        INNER JOIN "Fee_Master_Terms" 
                            ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                            AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
                        INNER JOIN "fee_t_installment" 
                            ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                            AND "fee_t_installment"."MI_ID" = p_MI_Id
                        WHERE "Fee_Student_Status"."AMST_Id" = v_AMST_IdC 
                            AND "Fee_Student_Status"."MI_Id" = p_MI_Id 
                            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
                            AND "Fee_Master_Terms"."FMT_Id" = v_FMT_IdC 
                            AND "fee_student_status"."FSS_ConcessionAmount" > 0
                    ) AS "new" GROUP BY "FYGHM_Id"
                LOOP
                    v_FYGHM_Id := rec_trans."FYGHM_Id";
                    v_NET_TAMOUNT := rec_trans."Con_amount";

                    SELECT "FYGHM_JVRegLedgerId", "FYGHM_JVRegLedgerUnder" 
                    INTO v_JVRegLedgerId, v_JVRegLedgerUnder
                    FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                    WHERE "FYGHM_Id" = v_FYGHM_Id;

                    INSERT INTO "TALLY_T_TRANSACTION"("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                        "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
                    VALUES(v_TMT_ID, v_JVRegLedgerId, v_JVRegLedgerUnder, 'Dr', v_NET_TAMOUNT, 
                        'Concession', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END LOOP;

                SELECT SUM("Con_amount") INTO v_NET_TAMOUNT FROM (
                    SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", 
                        "Fee_Master_Terms_FeeHeads"."FMT_Id", 
                        "FSS_ConcessionAmount" AS "Con_amount"
                    FROM "Fee_Student_Status"
                    INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                        ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                        AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                        AND "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                        AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id
                    INNER JOIN "Fee_Master_Terms_FeeHeads" 
                        ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
                        AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id 
                        AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                    INNER JOIN "Fee_Master_Terms" 
                        ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                        AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
                    INNER JOIN "fee_t_installment" 
                        ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                        AND "fee_t_installment"."MI_ID" = p_MI_Id
                    WHERE "Fee_Student_Status"."AMST_Id" = v_AMST_IdC 
                        AND "Fee_Student_Status"."MI_Id" = p_MI_Id 
                        AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id 
                        AND "Fee_Master_Terms"."FMT_Id" = v_FMT_IdC 
                        AND "fee_student_status"."FSS_ConcessionAmount" > 0
                ) AS "New";

                SELECT "TMT_RefNo" INTO v_TMT_RefNo 
                FROM "Tally_M_Transaction" 
                WHERE "MI_Id" = p_MI_Id AND "TMT_Id" = v_TMT_ID;

                SELECT "AMST_AdmNo" || COALESCE("AMST_FirstName", '') || '' || COALESCE("AMST_MiddleName", '') || '' || COALESCE("AMST_LastName", '') 
                INTO v_JVRegLedgerId
                FROM "Adm_M_Student" 
                WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = v_TMT_RefNo::BIGINT;

                INSERT INTO "TALLY_T_TRANSACTION"("TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", 
                    "TTT_DRCRFlg", "TTT_Amount", "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate")
                VALUES(v_TMT_Id, v_JVRegLedgerId, 'Sundry Debtors', 'Cr', v_NET_TAMOUNT, 
                    'Concession', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
            ELSE
                RAISE NOTICE 'Record already exist';
            END IF;
        END LOOP;

    END IF;

    RETURN;
END;
$$;