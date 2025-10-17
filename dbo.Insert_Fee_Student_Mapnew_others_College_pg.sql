CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Mapnew_others_College"(
    p_FMG_Id bigint,
    p_FMCOST_Id bigint,
    p_MI_Id bigint,
    p_FTI_Id_new bigint,
    p_FMH_Id_new bigint,
    p_Userid bigint,
    p_ASMAY_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyghm_id bigint;
    v_fmcc_id bigint;
    v_amcl_id bigint;
    v_FCMAS_Id bigint;
    v_FTI_Name varchar(100);
    v_FMA_Amount numeric;
    v_FMH_Name varchar(100);
    v_FMG_Id_new bigint;
    v_fmsgid bigint;
    v_ftp_concession_amt bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_previousacademicyear bigint;
    v_FMCORcount bigint;
    v_FMCAOST_Id bigint;
    
    rec_yearly_fee RECORD;
    rec_fee_det RECORD;
BEGIN
    v_fti_name := '';
    v_fma_amount := 0;
    v_fmh_name := '';
    v_ftp_concession_amt := 0;
    
    SELECT COUNT(*) INTO v_FMCORcount 
    FROM "CLG"."Fee_Master_College_OthStudents_GH" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
        AND "FMG_Id" = p_FMG_Id 
        AND "MI_Id" = p_MI_Id 
        AND "FMCOST_Id" = p_FMCOST_Id;
    
    IF v_FMCORcount = 0 THEN
        INSERT INTO "CLG"."Fee_Master_College_OthStudents_GH" (
            "MI_Id", "FMCOST_Id", "ASMAY_Id", "FMG_Id", "FMCOSTGH_ActiveFlag", 
            "FMCOSTGH_CreatedBy", "FMCOSTGH_UpdatedBy"
        ) 
        VALUES (
            p_mi_id, p_FMCOST_Id, p_asmay_id, p_fmg_id, 'Y', p_Userid, p_Userid
        );
    END IF;
    
    BEGIN
        SELECT "FMCOSTGH_Id" INTO v_fmsgid 
        FROM "CLG"."Fee_Master_College_OthStudents_GH" 
        WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "FMG_Id" = p_FMG_Id 
            AND "MI_Id" = p_MI_Id 
            AND "FMCOST_Id" = p_FMCOST_Id;
        
        RAISE NOTICE 'fmsgid: %, FMH_ID_new: %, fti_id_new: %', v_fmsgid, p_FMH_ID_new, p_fti_id_new;
        
        INSERT INTO "CLG"."Fee_Master_College_OthStudents_GH_Instl" (
            "FMCOSTGH_Id", "FMH_Id", "FTI_Id", "FMCOSTGHI_CreatedBy", "FMCOSTGHI_UpdatedBy"
        ) 
        VALUES (
            v_fmsgid, p_FMH_ID_new, p_fti_id_new, p_Userid, p_Userid
        );
        
        SELECT "FMCOSTGHI_Id" INTO v_fmsgid 
        FROM "CLG"."Fee_Master_College_OthStudents_GH_Instl" 
        WHERE "FMCOSTGH_Id" = v_fmsgid;
        
        RAISE NOTICE 'fmsgid: %', v_fmsgid;
        
        FOR rec_yearly_fee IN
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = p_FMG_Id 
                AND "FYGHM_ActiveFlag" = 1 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "FMH_Id" = p_FMH_Id_new 
                AND "FMI_Id" IN (
                    SELECT "FMI_Id" 
                    FROM "Fee_T_Installment" 
                    WHERE "FTI_Id" = p_FTI_Id_new 
                        AND "MI_Id" = p_MI_Id
                )
        LOOP
            v_FYGHM_Id := rec_yearly_fee."FYGHM_Id";
            v_FMG_Id_new := rec_yearly_fee."FMG_Id";
            v_FMH_Id := rec_yearly_fee."FMH_Id";
            
            FOR rec_fee_det IN
                SELECT 
                    "FMCAOST_Id",
                    "clg"."Fee_Master_College_Amount_OthStaffs"."FTI_Id",
                    "Fee_T_Installment"."FTI_Name",
                    "clg"."Fee_Master_College_Amount_OthStaffs"."FMCAOST_Amount",
                    "clg"."Fee_Master_College_Amount_OthStaffs"."FCMAS_Id"
                FROM "CLG"."Fee_Master_College_Amount_OthStaffs"
                INNER JOIN "Fee_T_Installment" 
                    ON "CLG"."Fee_Master_College_Amount_OthStaffs"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
                WHERE "FMG_Id" = v_FMG_Id_new 
                    AND "FMH_Id" = p_FMH_Id_new 
                    AND "clg"."Fee_Master_College_Amount_OthStaffs"."FTI_Id" = p_FTI_Id_new 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "FMCAOST_OthStaffFlag" = 'S'
            LOOP
                v_FMCAOST_Id := rec_fee_det."FMCAOST_Id";
                v_fti_id := rec_fee_det."FTI_Id";
                v_fti_name := rec_fee_det."FTI_Name";
                v_fma_amount := rec_fee_det."FMCAOST_Amount";
                v_FCMAS_Id := rec_fee_det."FCMAS_Id";
                
                SELECT "FMH_FeeName" INTO v_fmh_name 
                FROM "Fee_Master_Head" 
                WHERE "FMH_Id" = p_FMH_Id_new 
                    AND "MI_Id" = p_MI_Id;
                
                PERFORM * 
                FROM "clg"."Fee_College_Student_Status_OthStu" 
                WHERE "FMCOST_Id" = p_FMCOST_Id 
                    AND "FMG_Id" = v_FMG_Id_new 
                    AND "FMH_Id" = p_FMH_Id_new 
                    AND "FCMAS_Id" = v_FCMAS_Id;
                
                INSERT INTO "clg"."Fee_College_Student_Status_OthStu"(
                    "MI_Id", "ASMAY_Id", "FMCOST_Id", "FMG_Id", "FCSSOST_OBArrearAmount", 
                    "FCSSOST_OBExcessAmount", "FCSSOST_CurrentYrCharges", "FCSSOST_TotalCharges", 
                    "FCSSOST_ConcessionAmount", "FCSSOST_WaivedAmount", "FCSSOST_ToBePaid", 
                    "FCSSOST_PaidAmount", "FCSSOST_ExcessPaidAmount", "FCSSOST_ExcessAdjustedAmount", 
                    "FCSSOST_RunningExcessAmount", "FCSSOST_AdjustedAmount", "FCSSOST_RebateAmount", 
                    "FCSSOST_FineAmount", "FCSSOST_RefundAmount", "FCSSOST_RefundAmountAdjusted", 
                    "FCSSOST_NetAmount", "FCSSOST_ChequeBounceAmount", "FCSSOST_ArrearFlag", 
                    "FCSSOST_RefundOverFlag", "FCSSOST_ActiveFlag", "FCSSOST_CreatedDate", 
                    "FCSSOST_UpdatedDate", "FMH_Id", "FTI_Id", "FCMAS_Id"
                ) 
                VALUES(
                    p_MI_ID, p_asmay_id, p_FMCOST_Id, p_fmg_id, 0, 0, v_fma_amount, v_fma_amount, 
                    0, 0, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_fma_amount, 0, 0, 0, 1, 
                    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_FMH_ID_new, p_fti_id_new, v_FCMAS_Id
                );
                
                PERFORM "UpdateStudPaidAmt_College"(p_FMCOST_Id, v_FCMAS_Id, p_MI_Id);
                
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