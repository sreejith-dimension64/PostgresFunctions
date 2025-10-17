CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Mapnew_staff_College"(
    p_FMG_Id bigint,
    p_HRME_Id bigint,
    p_MI_Id bigint,
    p_FTI_Id_new bigint,
    p_FMH_Id_new bigint,
    p_userid bigint,
    p_ASMAY_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyghm_id bigint;
    v_fmcc_id bigint;
    v_FMCAOST_Id bigint;
    v_FTI_Name varchar(100);
    v_FCMAS_Amount numeric;
    v_FMH_Name varchar(100);
    v_FMG_Id_new bigint;
    v_FMSGId bigint;
    v_ftp_concession_amt bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_previousacademicyear bigint;
    v_FCMAS_Id bigint;
    v_SGRcount bigint;
    v_SSRcount bigint;
    
    yearly_fee_rec RECORD;
    fee_det_rec RECORD;
BEGIN
    v_FMCC_Id := 0;
    v_FMCAOST_Id := 0;
    v_FTI_Name := '';
    v_FCMAS_Amount := 0;
    v_FMH_Name := '';
    v_ftp_concession_amt := 0;
    
    SELECT "ASMAY_Id" INTO v_previousacademicyear 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id 
    AND "ASMAY_Order" = (
        SELECT "ASMAY_Order" - 1 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id
    );
    
    RAISE NOTICE '%', v_previousacademicyear;
    
    v_SGRcount := 0;
    
    SELECT COUNT(*) INTO v_SGRcount 
    FROM "Fee_Master_Staff_GroupHead" 
    WHERE "ASMAY_Id" = p_asmay_id 
    AND "FMG_Id" = p_FMG_Id 
    AND "MI_Id" = p_MI_Id 
    AND "HRME_Id" = p_HRME_Id;
    
    IF v_SGRcount = 0 THEN
        INSERT INTO "Fee_Master_Staff_GroupHead" (
            "MI_Id", "HRME_Id", "ASMAY_Id", "FMG_Id", "FMSTGH_ActiveFlag", 
            "FMSTGH_CreatedBy", "FMSTGH_UpdatedBy"
        ) VALUES (
            p_mi_id, p_HRME_Id, p_asmay_id, p_fmg_id, 'Y', p_userid, p_userid
        );
    END IF;
    
    BEGIN
        SELECT "FMSTGH_Id" INTO v_FMSGId 
        FROM "Fee_Master_Staff_GroupHead" 
        WHERE "ASMAY_Id" = p_asmay_id 
        AND "FMG_Id" = p_fmg_id 
        AND "MI_Id" = p_MI_ID 
        AND "HRME_Id" = p_HRME_Id;
        
        INSERT INTO "Fee_Master_Staff_GroupHead_Installments" (
            "FMSTGH_Id", "FMH_ID", "FTI_ID", "FMSTGHI_CreatedBy", "FMSTGHI_UpdatedBy"
        ) VALUES (
            v_FMSGId, p_FMH_Id_new, p_FTI_Id_new, p_userid, p_userid
        );
        
        SELECT "FMSTGHI_Id" INTO v_FMSGId 
        FROM "Fee_Master_Staff_GroupHead_Installments" 
        WHERE "FMSTGH_Id" = v_fmsgid;
        
        FOR yearly_fee_rec IN
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = p_FMG_Id 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FMH_Id" = p_FMH_Id_new 
            AND "FMI_Id" IN (
                SELECT "FMI_Id" 
                FROM "Fee_T_Installment" 
                WHERE "FTI_Id" = p_fti_id_new 
                AND "MI_Id" = p_MI_Id
            )
        LOOP
            v_FYGHM_Id := yearly_fee_rec."FYGHM_Id";
            v_FMG_Id_new := yearly_fee_rec."FMG_Id";
            v_FMH_Id := yearly_fee_rec."FMH_Id";
            
            FOR fee_det_rec IN
                SELECT 
                    CLG."Fee_Master_College_Amount_OthStaffs"."FMCAOST_Id",
                    CLG."Fee_Master_College_Amount_OthStaffs"."FTI_Id",
                    "fee_t_installment"."fti_name",
                    CLG."Fee_Master_College_Amount_OthStaffs"."FMCAOST_Amount",
                    CLG."Fee_Master_College_Amount_OthStaffs"."FCMAS_Id"
                FROM clg."Fee_Master_College_Amount_OthStaffs"
                INNER JOIN "fee_t_installment" 
                    ON clg."Fee_Master_College_Amount_OthStaffs"."fti_id" = "fee_t_installment"."fti_id"
                WHERE "FMG_Id" = v_fmg_id_new 
                AND "FMH_Id" = p_FMH_ID_new 
                AND clg."Fee_Master_College_Amount_OthStaffs"."FTI_Id" = p_fti_id_new
                AND "ASMAY_Id" = p_asmay_id 
                AND "FMCAOST_OthStaffFlag" = 'S'
            LOOP
                v_FMCAOST_Id := fee_det_rec."FMCAOST_Id";
                v_FTI_Id := fee_det_rec."FTI_Id";
                v_FTI_Name := fee_det_rec."fti_name";
                v_FCMAS_Amount := fee_det_rec."FMCAOST_Amount";
                v_FCMAS_Id := fee_det_rec."FCMAS_Id";
                
                SELECT "FMH_FeeName" INTO v_fmh_name 
                FROM "Fee_Master_Head" 
                WHERE "FMH_Id" = p_FMH_ID_new 
                AND "MI_Id" = p_MI_Id;
                
                v_SSRcount := 0;
                
                SELECT COUNT(*) INTO v_SSRcount 
                FROM clg."Fee_College_Student_Status_Staff" 
                WHERE "HRME_Id" = p_HRME_Id 
                AND "FMG_Id" = v_fmg_id_new 
                AND "FMH_Id" = p_FMH_ID_new 
                AND "FMCAOST_Id" = v_FMCAOST_Id;
                
                SELECT "FECIC_ConcessionAmount" INTO v_ftp_concession_amt 
                FROM clg."Fee_Employee_Concession_College"
                INNER JOIN clg."Fee_Employee_Concession_Installments_College" 
                    ON clg."Fee_Employee_Concession_College"."FECC_Id" = CLG."Fee_Employee_Concession_Installments_College"."FECC_Id"
                WHERE "HRME_Id" = p_HRME_Id 
                AND "FMH_Id" = p_FMH_ID_new 
                AND "FTI_Id" = p_FTI_Id_new 
                AND "FMG_Id" = p_FMG_Id 
                AND "MI_Id" = p_MI_Id;
                
                RAISE NOTICE '%', v_ftp_concession_amt;
                
                IF v_SSRcount = 0 THEN
                    RAISE NOTICE 'b';
                    
                    INSERT INTO clg."Fee_College_Student_Status_Staff"(
                        "MI_Id", "ASMAY_Id", "HRME_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMCAOST_Id",
                        "FCSSST_OBArrearAmount", "FCSSST_OBExcessAmount", "FCSSST_CurrentYrCharges",
                        "FCSSST_TotalCharges", "FCSSST_ConcessionAmount", "FCSSST_WaivedAmount",
                        "FCSSST_ToBePaid", "FCSSST_PaidAmount", "FCSSST_ExcessPaidAmount",
                        "FCSSST_ExcessAdjustedAmount", "FCSSST_RunningExcessAmount", "FCSSST_AdjustedAmount",
                        "FCSSST_RebateAmount", "FCSSST_FineAmount", "FCSSST_RefundAmount",
                        "FCSSST_RefundAmountAdjusted", "FCSSST_NetAmount", "FCSSST_ChequeBounceAmount",
                        "FCSSST_ArrearFlag", "FCSSST_RefundOverFlag", "FCSSST_ActiveFlag",
                        "FCSSST_CreatedDate", "FCSSST_UpdatedDate", "FCSSST_CreatedBy",
                        "FCSSST_UpdatedBy", "FCMAS_Id"
                    ) VALUES(
                        p_MI_Id, p_ASMAY_Id, p_HRME_Id, p_FMG_Id, p_FMH_Id_new, p_FTI_Id_new, v_FMCAOST_Id,
                        0, 0, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, v_FCMAS_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        v_FCMAS_Amount, 0, 0, 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid, p_userid, v_FCMAS_Id
                    );
                    
                    PERFORM "UpdateStudPaidAmt_College"(p_HRME_Id, v_FCMAS_Id, p_MI_Id);
                ELSE
                    PERFORM "UpdateStudPaidAmt_College"(p_HRME_Id, v_FCMAS_Id, p_MI_Id);
                END IF;
            END LOOP;
        END LOOP;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error Number: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE;
    END;
    
    RETURN;
END;
$$;