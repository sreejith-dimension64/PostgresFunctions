CREATE OR REPLACE FUNCTION "dbo"."calculatefine_OnlinePayment"(
    p_MI_Id bigint,
    p_Asmay_Id bigint,
    p_Amst_Id bigint,
    p_fmt_id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyg_id bigint;
    v_fma_id bigint;
    v_fmg_id bigint;
    v_fti_id bigint;
    v_Fmh_id bigint;
    v_amay_id bigint;
    v_fmh_name varchar(100);
    v_fti_name varchar(100);
    v_ftp_tobepaid_amt numeric;
    v_paidamount numeric;
    v_ftp_concession_amt numeric;
    v_Net_amount numeric;
    v_ftp_fine_amt numeric;
    v_refundamt numeric;
    v_fmi_name varchar(100);
    v_On_Date timestamp;
    v_FineAmount numeric;
    v_ecsflag numeric;
    v_FlagArrear int;
    v_fypwaived bigint;
    v_row_count int;
    yearly_fee_rec RECORD;
BEGIN
    v_On_Date := CURRENT_TIMESTAMP;
    v_fmi_name := '';
    v_FineAmount := 0;
    
    DELETE FROM "v_studentpending";
    
    FOR yearly_fee_rec IN
        SELECT 
            "FMA_Id",
            "FSS_ToBePaid",
            "FSS_FineAmount",
            "FSS_ConcessionAmount",
            "FSS_WaivedAmount",
            "FMG_Id",
            "Fee_Student_Status"."FTI_Id",
            "FSS_PaidAmount",
            "FSS_NetAmount",
            "FSS_RefundAmount",
            "FMH_FeeName",
            "FTI_Name",
            "Fee_Student_Status"."FMH_Id"
        FROM "Fee_Student_Status"
        INNER JOIN "Fee_Master_Terms_FeeHeads" 
            ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
        INNER JOIN "Fee_Master_Head" 
            ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_T_Installment" 
            ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
        WHERE "Fee_Student_Status"."MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_Asmay_Id 
            AND "AMST_Id" = p_Amst_Id 
            AND "FMT_Id" = p_fmt_id
    LOOP
        v_fma_id := yearly_fee_rec."FMA_Id";
        v_ftp_tobepaid_amt := yearly_fee_rec."FSS_ToBePaid";
        v_ftp_fine_amt := yearly_fee_rec."FSS_FineAmount";
        v_ftp_concession_amt := yearly_fee_rec."FSS_ConcessionAmount";
        v_fypwaived := yearly_fee_rec."FSS_WaivedAmount";
        v_fmg_id := yearly_fee_rec."FMG_Id";
        v_fti_id := yearly_fee_rec."FTI_Id";
        v_paidamount := yearly_fee_rec."FSS_PaidAmount";
        v_Net_amount := yearly_fee_rec."FSS_NetAmount";
        v_refundamt := yearly_fee_rec."FSS_RefundAmount";
        v_fmh_name := yearly_fee_rec."FMH_FeeName";
        v_fti_name := yearly_fee_rec."FTI_Name";
        v_Fmh_id := yearly_fee_rec."FMH_Id";
        
        SELECT COUNT(*) INTO v_row_count
        FROM "fee_t_due_date"
        WHERE "fma_id" = v_fma_id;
        
        IF v_row_count > 0 THEN
            SELECT * FROM "dbo"."Sp_Calculate_Fine"(
                v_On_Date,
                v_fma_id,
                v_amay_id
            ) INTO v_FineAmount, v_FlagArrear;
            
            INSERT INTO "v_studentpending"(
                "fmg_id",
                "fma_id",
                "fti_id",
                "Fmh_id",
                "asmay_id",
                "FSS_ToBePaid",
                "FSS_PaidAmount",
                "FSS_ConcessionAmount",
                "FSS_NetAmount",
                "FSS_FineAmount",
                "FSS_RefundAmount",
                "fmh_feeName",
                "fti_name",
                "mi_id",
                "CreatedDate",
                "UpdatedDate"
            ) VALUES(
                v_fmg_id,
                v_fma_id,
                v_fti_id,
                v_Fmh_id,
                p_asmay_id,
                v_ftp_tobepaid_amt,
                v_paidamount,
                v_ftp_concession_amt,
                v_Net_amount,
                v_FineAmount,
                v_refundamt,
                v_fmh_name,
                v_fti_name,
                p_MI_Id,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            );
        END IF;
    END LOOP;
    
    RETURN;
END;
$$;