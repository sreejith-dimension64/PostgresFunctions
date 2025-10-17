CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingEdit"(
    p_mi_id BIGINT,
    p_amst_id BIGINT,
    p_asmay_id BIGINT,
    p_fmg_id BIGINT,
    p_fmh_id BIGINT,
    p_fti_id BIGINT,
    p_type VARCHAR(5),
    OUT p_errormessage VARCHAR(50)
)
RETURNS VARCHAR(50)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMG_GroupName VARCHAR(100);
    v_FMH_FeeName VARCHAR(100);
    v_FTI_Name VARCHAR(100);
    v_FMSG_Id BIGINT;
    v_rowcount INTEGER;
BEGIN
    IF p_type = 'G' THEN
        SELECT COUNT(*) INTO v_rowcount 
        FROM "Fee_Student_Status" 
        WHERE "FMG_Id" = p_fmg_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "AMST_Id" = p_amst_id 
            AND "FSS_PaidAmount" = 0;
        
        IF v_rowcount > 0 THEN
            SELECT "FMSG_Id" INTO v_FMSG_Id 
            FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id;
            
            DELETE FROM "Fee_Master_Student_Group" WHERE "FMSG_Id" = v_FMSG_Id;
            
            INSERT INTO "Fee_Master_Student_Group_Installment_Log"("FMSGI_Id","FMSG_Id","FMH_ID","FTI_ID","ActionName")
            SELECT "FMSGI_Id","FMSG_Id","FMH_ID","FTI_ID",'Delete' 
            FROM "Fee_Master_Student_Group_Installment" 
            WHERE "FMSG_Id" = v_FMSG_Id;
            
            DELETE FROM "Fee_Master_Student_Group_Installment" WHERE "FMSG_Id" = v_FMSG_Id;
            
            INSERT INTO "Fee_Student_Status_Log"("FSS_Id","MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","ActionName")
            SELECT "FSS_Id","MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id",'Delete' 
            FROM "Fee_Student_Status"
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id;
            
            DELETE FROM "Fee_Student_Status" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id;
            
            SELECT "FMG_GroupName" INTO v_FMG_GroupName 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = p_fmg_id;
            
            p_errormessage := 'deleted Group ' || v_FMG_GroupName;
        ELSE
            SELECT "FMG_GroupName" INTO v_FMG_GroupName 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = p_fmg_id;
            
            p_errormessage := 'Cant delete Group ' || v_FMG_GroupName || ' Amount has been already Paid';
        END IF;
        
    ELSIF p_type = 'H' THEN
        SELECT COUNT(*) INTO v_rowcount 
        FROM "Fee_Student_Status" 
        WHERE "FMG_Id" = p_fmg_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "AMST_Id" = p_amst_id 
            AND "FMH_ID" = p_fmh_id 
            AND "FSS_PaidAmount" = 0;
        
        IF v_rowcount > 0 THEN
            INSERT INTO "Fee_Master_Student_Group_Installment_Log"("FMSGI_Id","FMSG_Id","FMH_ID","FTI_ID","ActionName")
            SELECT "FMSGI_Id",a."FMSG_Id","FMH_ID","FTI_ID",'Delete' 
            FROM "Fee_Master_Student_Group_Installment" a 
            INNER JOIN "Fee_Master_Student_Group" b ON a."FMSG_Id" = b."FMSG_Id" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id;
            
            DELETE FROM "Fee_Master_Student_Group_Installment" a 
            USING "Fee_Master_Student_Group" b 
            WHERE a."FMSG_Id" = b."FMSG_Id" 
                AND "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id;
            
            INSERT INTO "Fee_Student_Status_Log"("FSS_Id","MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","ActionName")
            SELECT "FSS_Id","MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id",'Delete' 
            FROM "Fee_Student_Status"
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id;
            
            DELETE FROM "Fee_Student_Status" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id;
            
            SELECT "FMG_GroupName" INTO v_FMG_GroupName 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = p_fmg_id;
            
            SELECT "FMH_FeeName" INTO v_FMH_FeeName 
            FROM "Fee_Master_Head" 
            WHERE "FMH_ID" = p_fmh_id;
            
            p_errormessage := 'deleted Head ' || v_FMH_FeeName || ' from Group' || v_FMG_GroupName;
        ELSE
            SELECT "FMG_GroupName" INTO v_FMG_GroupName 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = p_fmg_id;
            
            SELECT "FMH_FeeName" INTO v_FMH_FeeName 
            FROM "Fee_Master_Head" 
            WHERE "FMH_ID" = p_fmh_id;
            
            p_errormessage := 'Cant delete Head ' || v_FMH_FeeName || ' from Group ' || v_FMG_GroupName || ' Amount has been already Paid';
        END IF;
        
    ELSIF p_type = 'I' THEN
        SELECT COUNT(*) INTO v_rowcount 
        FROM "Fee_Student_Status" 
        WHERE "FMG_Id" = p_fmg_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "AMST_Id" = p_amst_id 
            AND "FMH_ID" = p_fmh_id 
            AND "FSS_PaidAmount" = 0;
        
        IF v_rowcount > 0 THEN
            INSERT INTO "Fee_Master_Student_Group_Installment_Log"("FMSGI_Id","FMSG_Id","FMH_ID","FTI_ID","ActionName")
            SELECT "FMSGI_Id",a."FMSG_Id","FMH_ID","FTI_ID",'Delete' 
            FROM "Fee_Master_Student_Group_Installment" a 
            INNER JOIN "Fee_Master_Student_Group" b ON a."FMSG_Id" = b."FMSG_Id" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id 
                AND "FTI_ID" = p_fti_id;
            
            DELETE FROM "Fee_Master_Student_Group_Installment" b 
            USING "Fee_Master_Student_Group" a 
            WHERE a."FMSG_Id" = b."FMSG_Id" 
                AND "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id 
                AND "FTI_ID" = p_fti_id;
            
            INSERT INTO "Fee_Student_Status_Log"("FSS_Id","MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","ActionName")
            SELECT "FSS_Id","MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id",'Delete' 
            FROM "Fee_Student_Status"
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id 
                AND "FTI_ID" = p_fti_id;
            
            DELETE FROM "Fee_Student_Status" 
            WHERE "FMG_Id" = p_fmg_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "MI_Id" = p_mi_id 
                AND "AMST_Id" = p_amst_id 
                AND "FMH_ID" = p_fmh_id 
                AND "FTI_ID" = p_fti_id;
            
            SELECT "FMG_GroupName" INTO v_FMG_GroupName 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = p_fmg_id;
            
            SELECT "FMH_FeeName" INTO v_FMH_FeeName 
            FROM "Fee_Master_Head" 
            WHERE "FMH_ID" = p_fmh_id;
            
            SELECT "FTI_Name" INTO v_FTI_Name 
            FROM "Fee_T_Installment" 
            WHERE "FTI_Name" = p_fti_id;
            
            p_errormessage := 'Deleted Installment' || v_FTI_Name || ' in Head ' || v_FMH_FeeName || ' from Group' || v_FMG_GroupName;
        ELSE
            SELECT "FMG_GroupName" INTO v_FMG_GroupName 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = p_fmg_id;
            
            SELECT "FMH_FeeName" INTO v_FMH_FeeName 
            FROM "Fee_Master_Head" 
            WHERE "FMH_ID" = p_fmh_id;
            
            SELECT "FTI_Name" INTO v_FTI_Name 
            FROM "Fee_T_Installment" 
            WHERE "FTI_Name" = p_fti_id;
            
            p_errormessage := 'Cant delete Installment' || v_FTI_Name || ' in Head ' || v_FMH_FeeName || ' from Group ' || v_FMG_GroupName || ' Amount has been already Paid';
        END IF;
    END IF;
    
    RETURN;
END;
$$;