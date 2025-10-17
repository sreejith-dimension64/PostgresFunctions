CREATE OR REPLACE FUNCTION "dbo"."Fee_Tally_M_Insert_JV_Old"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_AMST_Id text
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
    student_rec RECORD;
    trans_rec RECORD;
BEGIN
    v_Rcount := 0;

    DROP TABLE IF EXISTS "StudentNetAmt";

    v_Sqldynamic := '
    CREATE TEMP TABLE "StudentNetAmt" AS
    SELECT DISTINCT "Fee_Student_Status"."AMST_Id",
    SUM("fee_student_status"."FSS_NetAmount") AS "NetAmt"
    FROM "Fee_Master_Group" 
    INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id"=' || p_MI_Id || ' 
    INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id"=' || p_MI_Id || '
    INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id"=' || p_MI_Id || ' AND "AMST_ActiveFlag"=1 AND "amst_sol"=''S''
    INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id"=' || p_ASMAY_Id || ' AND "AMAY_ActiveFlag"=1
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id"=' || p_MI_Id || '
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id"=' || p_MI_Id || '
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=' || p_MI_Id || '
    INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=' || p_MI_Id || '
    INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=' || p_MI_Id || '
    INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
    WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ') AND ("Adm_School_Y_Student"."ASMCL_Id" =' || p_ASMCL_Id || ') AND ("fee_student_status"."MI_Id" = ' || p_MI_Id || ') AND ("fee_student_status"."ASMAY_Id" = ' || p_ASMAY_Id || ') AND "Adm_School_Y_Student"."AMST_Id" IN (' || p_AMST_Id || ') 
    GROUP BY "Fee_Student_Status"."AMST_Id"';

    EXECUTE v_Sqldynamic;

    FOR student_rec IN SELECT * FROM "StudentNetAmt"
    LOOP
        v_AMST_IdC := student_rec."AMST_Id";
        v_NetAmt := student_rec."NetAmt";
        
        SELECT COUNT(*) INTO v_Rcount 
        FROM "Tally_M_Transaction" 
        WHERE "TMT_RefNo"=v_AMST_IdC::varchar AND "MI_Id"=p_MI_Id AND "TMT_VoucherTypeFlg"='JOURNALVOUCHER';

        IF (v_Rcount=0) THEN
            SELECT "ASMAY_Year" INTO v_ASSMAY_Year 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id;
            
            SELECT "IMFY_Id" INTO v_IMFY_Id 
            FROM "IVRM_Master_FinancialYear" 
            WHERE "IMFY_FinancialYear"=v_ASSMAY_Year;

            INSERT INTO "Tally_M_Transaction"("MI_Id","TMT_Date","TMT_VoucherTypeFlg","TMT_VoucherNo","TMT_Amount","TMT_TransactionStatusFlg","TMT_TransactionTypeFlg","TMT_ExportToTallyFlg","TMT_RefNo","TMT_FinancialYear","TMT_ActiveFlg","CreatedDate","UpdatedDate") 
            VALUES(p_MI_Id,CURRENT_TIMESTAMP,'JOURNALVOUCHER','',v_NetAmt,'CREATE','ADM',0,v_AMST_IdC::varchar,v_IMFY_Id,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);

            SELECT MAX("TMT_Id") INTO v_TMT_ID 
            FROM "Tally_M_Transaction" 
            WHERE "MI_Id"=p_MI_Id AND "TMT_RefNo"=v_AMST_IdC::varchar;

            FOR trans_rec IN
                SELECT DISTINCT "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id", SUM("FSS_NetAmount") AS "Net_amount"
                FROM "Fee_Student_Status"
                INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                    ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id"="Fee_Student_Status"."FMG_Id" 
                    AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id"="Fee_Student_Status"."FMH_Id" 
                    AND "Fee_Yearly_Group_Head_Mapping"."MI_Id"=p_MI_Id 
                    AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id"=p_ASMAY_Id
                INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=p_MI_Id
                INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=p_MI_Id
                INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=p_MI_Id
                WHERE "Fee_Student_Status"."AMST_Id"=v_AMST_IdC AND "Fee_Student_Status"."MI_Id"=p_MI_Id AND "Fee_Student_Status"."ASMAY_Id"=p_ASMAY_Id 
                GROUP BY "Fee_Yearly_Group_Head_Mapping"."FYGHM_Id"
            LOOP
                v_FYGHM_Id := trans_rec."FYGHM_Id";
                v_NET_TAMOUNT := trans_rec."Net_amount";

                SELECT "FYGHM_JVRegLedgerId", "FYGHM_JVRegLedgerUnder" INTO v_JVRegLedgerId, v_JVRegLedgerUnder
                FROM "Fee_Yearly_Group_Head_LedgerMapping" 
                WHERE "FYGHM_Id"=v_FYGHM_Id;

                INSERT INTO "TALLY_T_TRANSACTION"("TMT_Id","TTT_LedgerCode","TTT_LedgerUnder","TTT_DRCRFlg","TTT_Amount","TTT_Naration","TTT_ActiveFlg","CreatedDate","UpdatedDate")
                VALUES(v_TMT_ID,v_JVRegLedgerId,v_JVRegLedgerUnder,'Cr',v_NET_TAMOUNT,'',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
            END LOOP;

            SELECT SUM("FSS_NetAmount") INTO v_NET_TAMOUNT
            FROM "Fee_Student_Status"
            INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id"="Fee_Student_Status"."FMG_Id" 
                AND "Fee_Yearly_Group_Head_Mapping"."FMH_Id"="Fee_Student_Status"."FMH_Id" 
                AND "Fee_Yearly_Group_Head_Mapping"."MI_Id"=p_MI_Id 
                AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id"=p_ASMAY_Id
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=p_MI_Id
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=p_MI_Id
            INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=p_MI_Id
            WHERE "Fee_Student_Status"."AMST_Id"=v_AMST_IdC AND "Fee_Student_Status"."MI_Id"=p_MI_Id AND "Fee_Student_Status"."ASMAY_Id"=p_ASMAY_Id;

            SELECT "TMT_RefNo" INTO v_TMT_RefNo 
            FROM "Tally_M_Transaction" 
            WHERE "MI_Id"=p_MI_Id AND "TMT_Id"=v_TMT_ID;

            SELECT "AMST_AdmNo" || (COALESCE("AMST_FirstName",'') || '' || COALESCE("AMST_MiddleName",'') || '' || COALESCE("AMST_LastName",'')) INTO v_JVRegLedgerId
            FROM "Adm_M_Student" 
            WHERE "MI_Id"=p_MI_Id AND "AMST_Id"=v_TMT_RefNo::bigint;

            INSERT INTO "TALLY_T_TRANSACTION"("TMT_Id","TTT_LedgerCode","TTT_LedgerUnder","TTT_DRCRFlg","TTT_Amount","TTT_Naration","TTT_ActiveFlg","CreatedDate","UpdatedDate") 
            VALUES(v_TMT_Id,v_JVRegLedgerId,'Sundry Debtors','Dr',v_NET_TAMOUNT,'',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
        ELSE
            RAISE NOTICE 'Record already exist';
        END IF;
    END LOOP;

    RETURN;
END;
$$;