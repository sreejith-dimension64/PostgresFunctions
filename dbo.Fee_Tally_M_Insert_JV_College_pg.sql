CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_JV_College"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_id bigint,
    p_AMB_id bigint,
    p_AMCST_Id text
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Rcount int;
    v_AMST_IdC bigint;
    v_ASSMAY_Year varchar(50);
    v_IMFY_Id bigint;
    v_NetAmt decimal(18,2);
    v_Sqldynamic text;
    v_FYGHM_Id bigint;
    v_NET_TAMOUNT decimal(18,2);
    v_TMT_Id bigint;
    v_VOUCHER_NO varchar(300);
    v_JVRegLedgerId varchar(50);
    v_JVRegLedgerUnder varchar(50);
    v_TMT_RefNo varchar(100);
    v_FMT_IdC bigint;
    v_FMC_InstallmentwiseJVFlg boolean;
    v_VoucherNo int;
    v_j int;
    v_JNvochername varchar(200);
    v_JNvochername_New varchar(200);
    v_StudentcountN int;
    v_K int;
    v_l int;
    v_rec_student RECORD;
    v_rec_trans RECORD;
BEGIN
    v_FMC_InstallmentwiseJVFlg := false;
    v_Rcount := 0;

    DROP TABLE IF EXISTS "StudentNetAmt";
    DROP TABLE IF EXISTS "StudentNetAmtT";

    v_Sqldynamic := ' CREATE TEMP TABLE "StudentNetAmt" AS 
    SELECT "AMST_Id", SUM("NetAmt") AS "NetAmt" FROM (
        SELECT DISTINCT "clg"."Fee_College_Student_Status"."AMCST_Id" as "AMST_Id",
            "clg"."Fee_College_Student_Status"."FMG_Id",
            "clg"."Fee_College_Student_Status"."FMH_Id",
            ("clg"."Fee_College_Student_Status"."FCSS_NetAmount") AS "NetAmt"    
        FROM "Fee_Master_Group" 
        INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id"="clg"."Fee_College_Student_Status"."FMG_Id" 
            AND "Fee_Master_Group"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" 
            AND "Fee_Master_Head"."MI_Id"=' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_College_Student" ON "Adm_Master_College_Student"."AMCST_Id"="clg"."Fee_College_Student_Status"."AMCST_Id" 
        INNER JOIN "clg"."Adm_College_Yearly_Student" ON "Adm_College_Yearly_Student"."AMCST_Id"="Adm_Master_College_Student"."AMCST_Id" 
            AND "Adm_College_Yearly_Student"."ASMAY_Id"=' || p_ASMAY_Id || '
        INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id"="clg"."Adm_College_Yearly_Student"."AMCO_Id" 
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id"="clg"."Adm_College_Yearly_Student"."AMB_Id" 
        INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id"="clg"."Adm_College_Yearly_Student"."AMSE_Id" 
        INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id"="clg"."Adm_College_Yearly_Student"."ACMS_Id"
        INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="clg"."Fee_College_Student_Status"."FTI_Id" 
            AND "fee_t_installment"."MI_ID"=' || p_MI_Id || '
        INNER JOIN "clg"."Fee_College_T_Due_Date" ON "Fee_College_T_Due_Date"."FCMAS_Id"="clg"."Fee_College_Student_Status"."FCMAS_Id"
        WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
            AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" = ' || p_AMB_id || ') 
            AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || p_MI_Id || ') 
            AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
            AND "clg"."Adm_College_Yearly_Student"."AMCST_Id" IN (' || p_AMCST_Id || ')
    ) AS "NEW" GROUP BY "AMST_Id"';

    EXECUTE v_Sqldynamic;

    v_JNvochername := 'ADM';
    v_VoucherNo := 0;
    v_j := 1;

    SELECT COUNT(DISTINCT "Amst_id") INTO v_StudentcountN FROM "StudentNetAmt";

    RAISE NOTICE '@StudentcountN%', v_StudentcountN;

    SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

    SELECT "IMFY_Id" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_FinancialYear" = v_ASSMAY_Year;

    SELECT MAX(CAST(REPLACE(REPLACE(REPLACE("TMT_VoucherNo", v_JNvochername, ''), v_ASSMAY_Year, ''), '/', '') AS INTEGER)) 
    INTO v_VoucherNo
    FROM "Tally_M_Transaction" 
    WHERE "MI_Id" = p_MI_Id AND "TMT_VoucherTypeFlg" = 'JOURNALVOUCHER';

    v_VoucherNo := COALESCE(v_VoucherNo, 0);

    RAISE NOTICE 'vocherno%', v_VoucherNo;

    v_K := v_VoucherNo + 1;

    FOR v_rec_student IN SELECT * FROM "StudentNetAmt"
    LOOP
        v_AMST_IdC := v_rec_student."AMST_Id";
        v_NetAmt := v_rec_student."NetAmt";

        SELECT COUNT(*) INTO v_Rcount 
        FROM "Tally_M_Transaction" 
        WHERE "TMT_RefNo" = v_AMST_IdC::varchar 
            AND "MI_Id" = p_MI_Id 
            AND "TMT_VoucherTypeFlg" = 'JOURNALVOUCHER';

        IF v_Rcount = 0 THEN
            WHILE v_j <= v_StudentcountN LOOP
                v_JNvochername_New := v_JNvochername || '/' || v_ASSMAY_Year || '/' || v_K::varchar;

                INSERT INTO "Tally_M_Transaction"(
                    "MI_Id", "TMT_Date", "TMT_VoucherTypeFlg", "TMT_VoucherNo", "TMT_Amount", 
                    "TMT_TransactionStatusFlg", "TMT_TransactionTypeFlg", "TMT_ExportToTallyFlg", 
                    "TMT_RefNo", "TMT_FinancialYear", "TMT_ActiveFlg", "CreatedDate", "UpdatedDate", 
                    "TMT_ChequeNo", "TMT_ChequeDate", "FMT_Id"
                ) 
                VALUES(
                    p_MI_Id, CURRENT_TIMESTAMP, 'JOURNALVOUCHER', v_JNvochername_New, v_NetAmt, 
                    'CREATE', 'ADM', 0, v_AMST_IdC::varchar, v_IMFY_Id, 1, CURRENT_TIMESTAMP, 
                    CURRENT_TIMESTAMP, '', '1900-01-01'::timestamp, 0
                );

                SELECT MAX("TMT_Id") INTO v_TMT_ID 
                FROM "Tally_M_Transaction" 
                WHERE "MI_Id" = p_MI_Id AND "TMT_RefNo" = v_AMST_IdC::varchar;

                FOR v_rec_trans IN
                    SELECT "FYGHM_Id", SUM("Net_amount") AS "Net_amount" FROM (
                        SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", 
                            ("FCSS_NetAmount") AS "Net_amount" 
                        FROM "clg"."Fee_College_Student_Status"
                        INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                            ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "clg"."Fee_College_Student_Status"."FMG_Id" 
                            AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "clg"."Fee_College_Student_Status"."FMH_Id" 
                            AND "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                            AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id
                        INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" 
                            ON "clg"."Fee_College_Student_Status"."FCMAS_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
                        INNER JOIN "clg"."Fee_College_Master_Amount" 
                            ON "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id"
                        INNER JOIN "fee_t_installment" 
                            ON "fee_t_installment"."FTI_Id" = "Fee_College_Master_Amount"."FTI_Id" 
                            AND "fee_t_installment"."MI_ID" = p_MI_Id
                        INNER JOIN "clg"."Fee_T_College_Payment" 
                            ON "clg"."Fee_T_College_Payment"."FCMAS_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
                        WHERE "clg"."Fee_College_Student_Status"."AMCST_Id" = v_AMST_IdC 
                            AND "clg"."Fee_College_Student_Status"."MI_Id" = p_MI_Id 
                            AND "clg"."Fee_College_Student_Status"."ASMAY_Id" = p_ASMAY_Id
                    ) AS "NEW" 
                    GROUP BY "FYGHM_Id" 
                    HAVING SUM("Net_amount") > 0
                LOOP
                    v_FYGHM_Id := v_rec_trans."FYGHM_Id";
                    v_NET_TAMOUNT := v_rec_trans."Net_amount";

                    SELECT "FYGHM_JVRegLedgerId", "FYGHM_JVRegLedgerUnder" 
                    INTO v_JVRegLedgerId, v_JVRegLedgerUnder 
                    FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                    WHERE "FYGHM_Id" = v_FYGHM_Id;

                    INSERT INTO "TALLY_T_TRANSACTION"(
                        "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", 
                        "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                    )
                    VALUES(
                        v_TMT_ID, v_JVRegLedgerId, v_JVRegLedgerUnder, 'Cr', v_NET_TAMOUNT, 
                        '', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );
                END LOOP;

                SELECT SUM("Net_amount") INTO v_NET_TAMOUNT FROM (
                    SELECT "FYGHM_Id", SUM("Net_amount") AS "Net_amount" FROM (
                        SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", 
                            ("FCSS_NetAmount") AS "Net_amount" 
                        FROM "clg"."Fee_College_Student_Status"
                        INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                            ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "clg"."Fee_College_Student_Status"."FMG_Id" 
                            AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "clg"."Fee_College_Student_Status"."FMH_Id" 
                            AND "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                            AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id
                        INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" 
                            ON "clg"."Fee_College_Student_Status"."FCMAS_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
                        INNER JOIN "clg"."Fee_College_Master_Amount" 
                            ON "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id"
                        INNER JOIN "fee_t_installment" 
                            ON "fee_t_installment"."FTI_Id" = "Fee_College_Master_Amount"."FTI_Id" 
                            AND "fee_t_installment"."MI_ID" = p_MI_Id
                        INNER JOIN "clg"."Fee_T_College_Payment" 
                            ON "clg"."Fee_T_College_Payment"."FCMAS_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
                        WHERE "clg"."Fee_College_Student_Status"."AMCST_Id" = v_AMST_IdC 
                            AND "clg"."Fee_College_Student_Status"."MI_Id" = p_MI_Id 
                            AND "clg"."Fee_College_Student_Status"."ASMAY_Id" = p_ASMAY_Id
                    ) AS "NEW" 
                    GROUP BY "FYGHM_Id" 
                    HAVING SUM("Net_amount") > 0
                ) AS "NEW";

                SELECT "TMT_RefNo" INTO v_TMT_RefNo 
                FROM "Tally_M_Transaction" 
                WHERE "MI_Id" = p_MI_Id AND "TMT_Id" = v_TMT_ID;

                SELECT "AMCST_AdmNo" || ' ' || (COALESCE("AMCST_FirstName", '') || '' || 
                       COALESCE("AMCST_MiddleName", '') || '' || COALESCE("AMCST_LastName", '')) 
                INTO v_JVRegLedgerId 
                FROM "clg"."Adm_Master_College_Student" 
                WHERE "MI_Id" = p_MI_Id AND "AMCST_Id" = v_TMT_RefNo::bigint;

                INSERT INTO "TALLY_T_TRANSACTION"(
                    "TMT_Id", "TTT_LedgerCode", "TTT_LedgerUnder", "TTT_DRCRFlg", "TTT_Amount", 
                    "TTT_Naration", "TTT_ActiveFlg", "CreatedDate", "UpdatedDate"
                ) 
                VALUES(
                    v_TMT_Id, v_JVRegLedgerId, 'Sundry Debtors', 'Dr', v_NET_TAMOUNT, 
                    '', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );

                v_j := v_j + 1;
                v_K := v_K + 1;

                IF v_j > v_StudentcountN THEN
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            RAISE NOTICE 'Record already exist';
        END IF;
    END LOOP;

    RETURN;
END;
$$;