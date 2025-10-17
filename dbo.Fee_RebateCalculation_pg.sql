CREATE OR REPLACE FUNCTION "dbo"."Fee_RebateCalculation"(
    p_MI_Id bigint,
    p_asmay_id varchar,
    p_amst_adm_no varchar,
    p_paidamount decimal(18,2),
    p_paiddate varchar
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_admno varchar(250);
    v_studreceiptno varchar(250);
    v_studpaidamount decimal;
    v_studpaiddate timestamp;
    v_ayclid bigint;
    v_acmid bigint;
    v_aystid bigint;
    v_amstid bigint;
    v_fmaid bigint;
    v_statamount bigint;
    v_tobepaid bigint;
    v_netamount bigint;
    v_ftcuid bigint;
    v_fyghid bigint;
    v_ftiid bigint;
    v_intrefno bigint;
    v_yearid bigint;
    v_fypid bigint;
    v_lcode bigint;
    v_amt bigint;
    v_amtststusupdate bigint;
    v_ftpconcessionamt bigint;
    v_tno bigint;
    v_paidamt bigint;
    v_feeheadname varchar(250);
    v_remarks varchar(250);
    v_convertteddate timestamp;
    v_recno varchar(200);
    v_recnomax bigint;
    v_FYGID bigint;
    v_fmgid varchar;
    v_fineamount bigint;
    v_arrflag bigint;
    v_totfine bigint;
    v_totconcessionamt bigint;
    v_curyear bigint;
    v_newlcode bigint;
    v_newlfmaidd bigint;
    v_previousfine bigint;
    v_Prefixname varchar(50);
    v_Suffixname varchar(50);
    v_Prefixnamelen bigint;
    v_suffixnamelen bigint;
    v_sql1head text;
    v_sqlhead text;
    v_Rowcount bigint;
    v_Receiptno varchar;
    v_fmttrm bigint;
    v_fmt_id bigint;
    v_Rcount int;
    v_SRcount int;
    v_tobepaidT bigint;
    v_tobepaidf bigint;
    v_tobepaidf1 bigint;
    v_FMA_IdF bigint;
    v_FMH_Order int;
    v_RebatePercentage decimal(18,2);
    v_CurrentYrCharges decimal(18,2);
    v_WaivedOffAmount decimal(18,2);
    v_FTI_Id bigint;
    v_FromDate date;
    v_ToDate date;
    v_paidamount decimal(18,2);
    v_paiddate varchar;
    rec_fee_grp RECORD;
    rec_fee_installment RECORD;
    rec_famids1 RECORD;
    rec_fmaids RECORD;
BEGIN
    v_fineamount := 0;
    v_previousfine := 0;
    v_tobepaid := 0;
    v_fmgid := '0';
    v_intrefno := 0;
    v_tno := 0;
    v_paiddate := TO_CHAR(TO_DATE(p_paiddate, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    v_paidamount := p_paidamount;

    -- fetch current year
    v_curyear := p_asmay_id::bigint;

    -- fetch student id
    SELECT "AMST_Id" INTO v_amstid 
    FROM "Adm_M_Student" 
    WHERE "AMST_AdmNo" = p_amst_adm_no AND "MI_Id" = p_MI_Id;

    -- fetch fmgids
    FOR rec_fee_grp IN
        SELECT DISTINCT "Fee_Master_Group"."FMG_Id"
        FROM "Fee_Master_Terms_FeeHeads"
        INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
        INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "fee_student_status"."FMG_Id"
        WHERE "AMST_Id" = v_amstid AND "ASMAY_Id" = v_curyear 
            AND "fee_student_status"."MI_Id" = p_MI_Id 
            AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id 
            AND "FMG_CompulsoryFlag" != 'R'
    LOOP
        v_fmgid := v_fmgid || ',' || rec_fee_grp."FMG_Id"::varchar;
    END LOOP;

    -- receiptnogeneration
    PERFORM "receiptnogeneration"(p_MI_Id, v_curyear, v_fmgid);
    SELECT "Receiptno" INTO v_Receiptno FROM "receiptnogeneration"(p_MI_Id, v_curyear, v_fmgid) AS "Receiptno";

    v_remarks := 'After Rebate Cal Receiptno generation';
    v_ftcuid := 1;

    INSERT INTO "Fee_Y_Payment" ("ASMAY_ID", "FTCU_Id", "FYP_Receipt_No", "FYP_Bank_Name", "FYP_Bank_Or_Cash", 
        "FYP_DD_Cheque_No", "FYP_DD_Cheque_Date", "FYP_Date", "FYP_Tot_Amount", "FYP_Tot_Waived_Amt", 
        "FYP_Tot_Fine_Amt", "FYP_Tot_Concession_Amt", "FYP_Remarks", "IVRMSTAUL_ID", "FYP_Chq_Bounce", 
        "MI_Id", "DOE", "CreatedDate", "UpdatedDate", "user_id", "fyp_transaction_id", 
        "FYP_OnlineChallanStatusFlag", "FYP_PaymentReference_Id", "FYP_ChallanNo", "FYP_DeviseFlg", 
        "FYP_PayModeType", "FYP_PayGatewayType")
    VALUES (v_curyear, v_ftcuid, v_Receiptno, '', 'C', '', 
        TO_TIMESTAMP(v_paiddate, 'DD/MM/YYYY'), TO_TIMESTAMP(v_paiddate, 'DD/MM/YYYY'), 
        v_paidamount, 0, 0, 0, v_remarks, '', 'CL', p_MI_Id, CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 66234, '', 'Sucessfull', '', '', '', '', 'RebateProcess');

    SELECT MAX("FYP_Id") INTO v_fypid 
    FROM "Fee_Y_Payment" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_curyear;

    INSERT INTO "Fee_Y_Payment_PaymentMode" ("FYP_Id", "FYP_TransactionTypeFlag", "FYPPM_TotalPaidAmount", 
        "FYPPM_LedgerId", "FYPPM_BankName", "FYPPM_DDChequeNo", "FYPPM_DDChequeDate", "FYPPM_TransactionId", 
        "FYPPM_PaymentReferenceId", "FYPPM_ClearanceStatusFlag", "FYPPM_ClearanceDate", "FYPPM_SettlementAmount")
    VALUES (v_fypid, 'C', v_paidamount, 0, '', '', TO_TIMESTAMP(v_paiddate, 'DD/MM/YYYY'), '', '', 0, 
        TO_TIMESTAMP(v_paiddate, 'DD/MM/YYYY'), 0);

    INSERT INTO "Fee_Y_Payment_School_Student" ("FYP_Id", "AMST_Id", "ASMAY_Id", "FTP_TotalPaidAmount", 
        "FTP_TotalWaivedAmount", "FTP_TotalConcessionAmount", "FTP_TotalFineAmount")
    VALUES (v_fypid, v_amstid, v_curyear, v_paidamount, 0, 0, 0);

    RAISE NOTICE '@fmgid valies: %', v_fmgid;

    -- fetch terms orderwise
    FOR rec_fee_installment IN
        SELECT DISTINCT "fee_student_status"."FTI_Id", 
            CAST("FTIDD_FromDate" AS date) AS "FTIDD_FromDate", 
            CAST("FTIDD_ToDate" AS date) AS "FTIDD_ToDate"
        FROM "Fee_Master_Terms_FeeHeads"
        INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"
        INNER JOIN "Fee_T_Installment_DueDate" D ON D."FTI_Id" = "Fee_T_Installment"."FTI_Id" 
            AND D."MI_Id" = p_MI_Id AND D."ASMAY_Id" = v_curyear
        WHERE "fee_student_status"."MI_Id" = p_MI_Id 
            AND "fee_student_status"."ASMAY_Id" = v_curyear 
            AND "AMST_Id" = v_amstid
            AND TO_TIMESTAMP(v_paiddate, 'DD/MM/YYYY') BETWEEN CAST("FTIDD_FromDate" AS date) 
                AND CAST("FTIDD_ToDate" AS date)
    LOOP
        v_FTI_Id := rec_fee_installment."FTI_Id";
        v_FromDate := rec_fee_installment."FTIDD_FromDate";
        v_ToDate := rec_fee_installment."FTIDD_ToDate";

        IF (v_paidamount > 0) THEN
            
            -- check term wise pending amount
            SELECT COUNT(*) INTO v_Rcount 
            FROM "Fee_Master_Terms_FeeHeads"
            INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
            WHERE "AMST_Id" = v_amstid 
                AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                AND "FSS_ToBePaid" > 0 
                AND "FSS_CurrentYrCharges" > 0 
                AND "fee_student_status"."MI_Id" = p_MI_Id 
                AND "fee_student_status"."ASMAY_Id" = v_curyear;

            IF (v_Rcount > 0) THEN
                -- fetch balance term wise
                SELECT COALESCE("FMC_RebatePercentage", 0) INTO v_RebatePercentage 
                FROM "Fee_Master_Configuration" 
                WHERE "MI_Id" = p_MI_Id AND "FMC_RebateFlag" = 1;

                SELECT SUM("FSS_CurrentYrCharges") INTO v_CurrentYrCharges
                FROM "Fee_Master_Terms_FeeHeads"
                INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                    AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                WHERE "AMST_Id" = v_amstid 
                    AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                    AND "FSS_ToBePaid" > 0 
                    AND "FSS_CurrentYrCharges" > 0 
                    AND "fee_student_status"."MI_Id" = p_MI_Id 
                    AND "fee_student_status"."ASMAY_Id" = v_curyear;

                v_WaivedOffAmount := (v_CurrentYrCharges * (v_RebatePercentage / 100));
                v_tobepaid := 0;

                SELECT SUM("FSS_ToBePaid") INTO v_tobepaid 
                FROM "Fee_Master_Terms_FeeHeads"
                INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                    AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                WHERE "AMST_Id" = v_amstid 
                    AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                    AND "FSS_ToBePaid" > 0 
                    AND "FSS_CurrentYrCharges" > 0 
                    AND "fee_student_status"."MI_Id" = p_MI_Id 
                    AND "fee_student_status"."ASMAY_Id" = v_curyear;

                v_tobepaid := v_tobepaid - v_WaivedOffAmount;

                IF (v_tobepaid > 0) AND (v_paidamount <= v_tobepaid) THEN
                    
                    FOR rec_famids1 IN
                        SELECT "FMA_Id", "FMH_Order" 
                        FROM "Fee_Master_Terms_FeeHeads"
                        INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                        INNER JOIN "Fee_Master_Head" FMH ON FMH."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
                            AND FMH."MI_Id" = p_MI_Id
                        WHERE "AMST_Id" = v_amstid 
                            AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                            AND "FSS_ToBePaid" > 0 
                            AND "FMA_Id" <> 0 
                            AND "fee_student_status"."ASMAY_Id" = v_curyear 
                            AND "fee_student_status"."MI_Id" = p_MI_Id 
                        ORDER BY "FMH_Order"
                    LOOP
                        v_fmaid := rec_famids1."FMA_Id";
                        v_FMH_Order := rec_famids1."FMH_Order";

                        SELECT SUM("FSS_ToBePaid") INTO v_tobepaidf1
                        FROM "Fee_Master_Terms_FeeHeads"
                        INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                        WHERE "AMST_Id" = v_amstid 
                            AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                            AND "FSS_ToBePaid" > 0 
                            AND "FSS_CurrentYrCharges" > 0 
                            AND "fee_student_status"."MI_Id" = p_MI_Id 
                            AND "FMA_Id" = v_fmaid 
                            AND "fee_student_status"."ASMAY_Id" = v_curyear;

                        IF (v_paidamount >= v_tobepaidf1) THEN
                            
                            INSERT INTO "Fee_T_Payment" ("FYP_Id", "FMA_Id", "FTP_Paid_Amt", "FTP_Fine_Amt", 
                                "FTP_Concession_Amt", "FTP_Waived_Amt", "ftp_remarks", "FTP_RebateAmount")
                            VALUES (v_fypid, v_fmaid, v_tobepaidf1, 0, 0, v_WaivedOffAmount, 'INST PAYMENT', 0);

                            UPDATE "Fee_Student_Status" 
                            SET "FSS_ToBePaid" = 0, 
                                "FSS_PaidAmount" = v_tobepaidf1, 
                                "FSS_RebateAmount" = v_WaivedOffAmount 
                            WHERE "ASMAY_Id" = v_curyear 
                                AND "AMST_Id" = v_amstid 
                                AND "FMA_Id" = v_fmaid 
                                AND "MI_Id" = p_MI_Id;

                            v_paidamount := v_paidamount - v_tobepaidf1;
                            RAISE NOTICE 'paid amount002 : %', v_paidamount;
                            v_tobepaidf1 := 0;

                        ELSIF (v_paidamount <= v_tobepaidf1) AND (v_paidamount <> 0 AND v_tobepaidf1 <> 0) THEN
                            
                            INSERT INTO "Fee_T_Payment" ("FYP_Id", "FMA_Id", "FTP_Paid_Amt", "FTP_Fine_Amt", 
                                "FTP_Concession_Amt", "FTP_Waived_Amt", "ftp_remarks", "FTP_RebateAmount")
                            VALUES (v_fypid, v_fmaid, v_paidamount, 0, 0, v_WaivedOffAmount, 'INST PAYMENT', 0);

                            UPDATE "Fee_Student_Status" 
                            SET "FSS_ToBePaid" = "FSS_ToBePaid" - v_paidamount, 
                                "FSS_PaidAmount" = v_paidamount, 
                                "FSS_RebateAmount" = v_WaivedOffAmount 
                            WHERE "ASMAY_Id" = v_curyear 
                                AND "AMST_Id" = v_amstid 
                                AND "fma_id" = v_fmaid 
                                AND "MI_Id" = p_MI_Id;

                            RAISE NOTICE 'paid amount003 : %', v_paidamount;
                            v_paidamount := 0;
                            v_tobepaidf1 := 0;

                        END IF;
                    END LOOP;

                    RAISE NOTICE 'paid amount004 last : %', v_paidamount;

                ELSIF (v_tobepaid > 0) AND (v_paidamount >= v_tobepaid) THEN
                    
                    FOR rec_fmaids IN
                        SELECT "FMA_Id", "FMH_Order" 
                        FROM "Fee_Master_Terms_FeeHeads"
                        INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                        INNER JOIN "Fee_Master_Head" FMH ON FMH."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
                            AND FMH."MI_Id" = p_MI_Id
                        WHERE "AMST_Id" = v_amstid 
                            AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                            AND "FSS_ToBePaid" > 0 
                            AND "FMA_Id" <> 0 
                            AND "fee_student_status"."ASMAY_Id" = v_curyear 
                            AND "fee_student_status"."MI_Id" = p_MI_Id 
                        ORDER BY "FMH_Order"
                    LOOP
                        v_fmaid := rec_fmaids."FMA_Id";
                        v_FMH_Order := rec_fmaids."FMH_Order";
                        v_tobepaidf := 0;

                        SELECT SUM("FSS_ToBePaid") INTO v_tobepaidf 
                        FROM "Fee_Master_Terms_FeeHeads"
                        INNER JOIN "fee_student_status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                        WHERE "AMST_Id" = v_amstid 
                            AND "fee_student_status"."FTI_Id" = v_FTI_Id 
                            AND "FSS_ToBePaid" > 0 
                            AND "FSS_CurrentYrCharges" > 0 
                            AND "fee_student_status"."MI_Id" = p_MI_Id 
                            AND "FMA_Id" = v_fmaid 
                            AND "fee_student_status"."ASMAY_Id" = v_curyear;

                        IF (v_paidamount >= v_tobepaidf) THEN
                            
                            INSERT INTO "Fee_T_Payment" ("FYP_Id", "FMA_Id", "FTP_Paid_Amt", "FTP_Fine_Amt", 
                                "FTP_Concession_Amt", "FTP_Waived_Amt", "ftp_remarks", "FTP_RebateAmount")
                            VALUES (v_fypid, v_fmaid, v_tobepaidf, 0, 0, v_WaivedOffAmount, 'INST PAYMENT', 0);

                            UPDATE "Fee_Student_Status" 
                            SET "FSS_ToBePaid" = 0, 
                                "FSS_PaidAmount" = v_tobepaidf, 
                                "FSS_RebateAmount" = v_WaivedOffAmount 
                            WHERE "ASMAY_Id" = v_curyear 
                                AND "AMST_Id" = v_amstid 
                                AND "fma_id" = v_fmaid 
                                AND "MI_Id" = p_MI_Id;

                            v_paidamount := v_paidamount - v_tobepaidf;
                            RAISE NOTICE 'paid amount001 : %', v_paidamount;

                        END IF;
                    END LOOP;

                END IF;

            END IF;

        END IF;

    END LOOP;

    INSERT INTO "Fee_Student_Waived_Off" ("MI_Id", "AMST_Id", "FMA_Id", "ASMAY_Id", "FSWO_Date", "FMH_Id", 
        "FMG_Id", "FTI_Id", "FSWO_WaivedOffAmount", "FSWO_ActiveFlag", "CreatedDate", "UpdatedDate", 
        "User_id", "FSWO_FineFlg", "FSWO_WaivedOffRemarks", "FSWO_FullFineWaiveOffFlg", 
        "FSWO_WaivedOfffilepath", "FSWO_WaivedOfffilename")
    SELECT "MI_Id", "AMST_Id", "FMA_Id", "ASMAY_Id", CURRENT_TIMESTAMP, "FMH_Id", "FMG_Id", "FTI_Id", 
        "FSS_RebateAmount", true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, "User_Id", 0, '', 0, '', ''
    FROM "Fee_Student_Status" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = v_curyear 
        AND "AMST_Id" = v_amstid;

    RETURN;
END;
$$;