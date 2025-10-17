CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Mapnew"(
    p_fmg_id BIGINT,
    p_amst_id BIGINT,
    p_MI_ID BIGINT,
    p_fti_id_new BIGINT,
    p_FMH_ID_new BIGINT,
    p_userid BIGINT,
    p_asmay_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyghm_id BIGINT;
    v_fmcc_id BIGINT;
    v_amcl_id BIGINT;
    v_fma_id BIGINT;
    v_fti_name VARCHAR(100);
    v_fma_amount NUMERIC;
    v_fmh_name VARCHAR(100);
    v_fmg_id_new BIGINT;
    v_fmsgid BIGINT;
    v_ftp_concession_amt BIGINT;
    v_fmh_id BIGINT;
    v_fti_id BIGINT;
    v_previousacademicyear BIGINT;
    v_rowcount INTEGER;
    yearly_fee_rec RECORD;
    fee_det_rec RECORD;
BEGIN
    v_amcl_id := 0;
    v_fmcc_id := 0;
    v_fma_id := 0;
    v_fti_name := '';
    v_fma_amount := 0;
    v_fmh_name := '';
    v_ftp_concession_amt := 0;

    SELECT * FROM "Fee_Master_Student_Group" 
    WHERE "ASMAY_Id" = p_asmay_id 
    AND "FMG_Id" = p_fmg_id 
    AND "MI_Id" = p_MI_ID 
    AND "AMST_Id" = p_amst_id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount = 0 THEN
        RAISE NOTICE 'a';
        INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
        VALUES (p_mi_id, p_amst_id, p_asmay_id, p_fmg_id, 'Y');
    END IF;

    BEGIN
        SELECT "FMSG_Id" INTO v_fmsgid 
        FROM "Fee_Master_Student_Group" 
        WHERE "ASMAY_Id" = p_asmay_id 
        AND "FMG_Id" = p_fmg_id 
        AND "MI_Id" = p_MI_ID 
        AND "AMST_Id" = p_amst_id;
        
        RAISE NOTICE '%', v_fmsgid;
        RAISE NOTICE 'e';
        RAISE NOTICE '%, %, %', v_fmsgid, p_FMH_ID_new, p_fti_id_new;
        
        INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
        VALUES (v_fmsgid, p_FMH_ID_new, p_fti_id_new);
        
        SELECT "FMSGI_Id" INTO v_fmsgid 
        FROM "Fee_Master_Student_Group_Installment" 
        WHERE "FMSG_Id" = v_fmsgid;
        
        RAISE NOTICE '%', v_fmsgid;
        RAISE NOTICE 'd';
        
        FOR yearly_fee_rec IN
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = p_fmg_id 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = p_asmay_id 
            AND "FMH_Id" = p_FMH_ID_new 
            AND "FMI_Id" IN (
                SELECT "FMI_Id" 
                FROM "Fee_T_Installment" 
                WHERE "FTI_Id" = p_fti_id_new
            )
        LOOP
            v_fyghm_id := yearly_fee_rec."FYGHM_Id";
            v_fmg_id_new := yearly_fee_rec."FMG_Id";
            v_fmh_id := yearly_fee_rec."FMH_Id";
            
            RAISE NOTICE 'b';
            RAISE NOTICE 'c';
            
            SELECT "ASMCL_Id" INTO v_amcl_id 
            FROM "Adm_School_Y_Student" 
            WHERE "amst_id" = p_amst_id 
            AND "ASMAY_Id" = p_asmay_id;
            
            RAISE NOTICE '%', v_amcl_id;
            
            IF v_amcl_id > 0 THEN
                SELECT "FMCC_Id" INTO v_fmcc_id 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "ASMAY_Id" = p_ASMAY_ID 
                AND "MI_Id" = p_mi_id 
                AND "FYCC_Id" IN (
                    SELECT "FYCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" = v_amcl_id
                );
                
                RAISE NOTICE '%', v_fmcc_id;
                
                IF v_fmcc_id > 0 THEN
                    FOR fee_det_rec IN
                        SELECT "Fee_Master_Amount"."fma_id", "Fee_Master_Amount"."fti_id", "fee_t_installment"."fti_name", "Fee_Master_Amount"."fma_amount" 
                        FROM "Fee_Master_Amount" 
                        INNER JOIN "fee_t_installment" ON "Fee_Master_Amount"."fti_id" = "fee_t_installment"."fti_id" 
                        WHERE "FMCC_Id" = v_fmcc_id 
                        AND "FMG_Id" = v_fmg_id_new 
                        AND "FMH_Id" = p_FMH_ID_new 
                        AND "Fee_Master_Amount"."FTI_Id" = p_fti_id_new 
                        AND "ASMAY_Id" = p_asmay_id
                    LOOP
                        v_fma_id := fee_det_rec."fma_id";
                        v_fti_id := fee_det_rec."fti_id";
                        v_fti_name := fee_det_rec."fti_name";
                        v_fma_amount := fee_det_rec."fma_amount";
                        
                        SELECT "FMH_FeeName" INTO v_fmh_name 
                        FROM "Fee_Master_Head" 
                        WHERE "fmh_id" = p_FMH_ID_new;
                        
                        SELECT * FROM "Fee_Student_Status" 
                        WHERE "Amst_Id" = p_amst_id 
                        AND "fmg_id" = v_fmg_id_new 
                        AND "fmh_id" = p_FMH_ID_new 
                        AND "fma_id" = v_fma_id;
                        
                        SELECT "FSCI_ConcessionAmount" INTO v_ftp_concession_amt 
                        FROM "Fee_Student_Concession" 
                        INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" 
                        WHERE "AMST_Id" = p_amst_id 
                        AND "FMH_Id" = p_FMH_ID_new 
                        AND "FTI_Id" = p_fti_id_new 
                        AND "FMG_Id" = p_fmg_id 
                        AND "MI_Id" = p_MI_ID;
                        
                        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
                        
                        RAISE NOTICE '%', v_ftp_concession_amt;
                        
                        IF v_rowcount = 0 THEN
                            RAISE NOTICE 'b';
                            
                            SELECT * FROM "Fee_Student_Status" 
                            WHERE "Amst_Id" = p_amst_id 
                            AND "fmg_id" = v_fmg_id_new 
                            AND "fmh_id" = p_FMH_ID_new 
                            AND "fma_id" = v_fma_id;
                            
                            INSERT INTO "Fee_Student_Status"(
                                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", 
                                "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", 
                                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
                                "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
                            ) VALUES (
                                p_MI_ID, p_asmay_id, p_amst_id, p_fmg_id, p_FMH_ID_new, p_fti_id_new, v_fma_id, 
                                0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                v_fma_amount, 0, 0, 0, 1, p_userid, 0
                            );
                            
                            PERFORM "UpdateStudPaidAmt"(p_amst_id, v_fma_id, p_MI_ID);
                        ELSE
                            PERFORM "UpdateStudPaidAmt"(p_amst_id, v_fma_id, p_MI_ID);
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'ErrorNumber: %', SQLSTATE;
            RAISE NOTICE 'ErrorMessage: %', SQLERRM;
            RAISE;
    END;

    RETURN;
END;
$$;