CREATE OR REPLACE FUNCTION "dbo"."Collegeconcession"(
    p_fsc_id BIGINT,
    p_asmay_id BIGINT,
    p_mi_id BIGINT,
    p_user_id BIGINT,
    p_fsci_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_amstid BIGINT;
    v_fmgid BIGINT;
    v_fmhid BIGINT;
    v_ftiid BIGINT;
    v_amount BIGINT;
    v_count BIGINT;
    v_netmount BIGINT;
    v_paidamount BIGINT;
    v_concessionamt BIGINT;
    v_balanceamount BIGINT;
    v_totaltobepaid BIGINT;
    v_rowcount INTEGER;
BEGIN
    
    SELECT "AMCST_Id", "FMG_Id", "FMH_Id" 
    INTO v_amstid, v_fmgid, v_fmhid
    FROM "CLG"."Fee_College_Student_Concession" 
    WHERE "MI_Id" = p_mi_id 
        AND "ASMAY_ID" = p_asmay_id 
        AND "FCSC_Id" = p_fsc_id;
    
    SELECT "FTI_Id", "FSCI_ConcessionAmount" 
    INTO v_ftiid, v_amount
    FROM "CLG"."Fee_C_Student_Concession_Installments" 
    WHERE "FCSC_Id" = p_fsc_id 
        AND "FSCI_ID" = p_fsci_id;
    
    SELECT "FCSS_NetAmount", "FCSS_PaidAmount", "FCSS_ConcessionAmount", 
           "FCSS_ToBePaid", "FCSS_CurrentYrCharges"
    INTO v_netmount, v_paidamount, v_concessionamt, v_balanceamount, v_totaltobepaid
    FROM "CLG"."Fee_College_Student_Status" 
    WHERE "AMCST_Id" = v_amstid 
        AND "FMG_Id" = v_fmgid 
        AND "FMH_Id" = v_fmhid 
        AND "FTI_Id" = v_ftiid
        AND "ASMAY_Id" = p_asmay_id 
        AND "FCSS_ConcessionAmount" > 0;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        
        IF v_netmount >= v_totaltobepaid + v_paidamount + v_concessionamt THEN
            
            IF v_paidamount = 0 THEN
                
                UPDATE "CLG"."Fee_College_Student_Status" 
                SET "FCSS_ConcessionAmount" = v_concessionamt - v_amount,
                    "FCSS_TotalCharges" = v_totaltobepaid + v_amount,
                    "FCSS_ToBePaid" = v_balanceamount + v_amount 
                WHERE "AMCST_Id" = v_amstid 
                    AND "FMG_Id" = v_fmgid 
                    AND "FMH_Id" = v_fmhid 
                    AND "FTI_Id" = v_ftiid 
                    AND "ASMAY_Id" = p_asmay_id 
                    AND "MI_Id" = p_mi_id;
                
                DELETE FROM "CLG"."Fee_C_Student_Concession_Installments" 
                WHERE "FCSC_Id" = p_fsc_id 
                    AND "FSCI_ID" = p_fsci_id;
                
                v_count := 0;
                SELECT COUNT("FSCI_ID") 
                INTO v_count
                FROM "CLG"."Fee_C_Student_Concession_Installments" 
                WHERE "FCSC_Id" = p_fsc_id;
                
                IF v_count = 0 THEN
                    DELETE FROM "CLG"."Fee_College_Student_Concession" 
                    WHERE "MI_Id" = p_mi_id 
                        AND "ASMAY_ID" = p_asmay_id 
                        AND "FCSC_Id" = p_fsc_id;
                END IF;
                
            END IF;
            
        ELSE
            
            IF v_paidamount = 0 THEN
                
                UPDATE "CLG"."Fee_College_Student_Status" 
                SET "FCSS_ConcessionAmount" = v_concessionamt - v_amount,
                    "FCSS_ToBePaid" = v_netmount,
                    "FCSS_TotalCharges" = v_netmount,
                    "FCSS_RunningExcessAmount" = 0,
                    "FCSS_ExcessPaidAmount" = 0 
                WHERE "AMCST_Id" = v_amstid 
                    AND "FMG_Id" = v_fmgid 
                    AND "FMH_Id" = v_fmhid 
                    AND "FTI_Id" = v_ftiid 
                    AND "ASMAY_Id" = p_asmay_id 
                    AND "MI_Id" = p_mi_id;
                
            END IF;
            
        END IF;
        
    END IF;
    
    DELETE FROM "CLG"."Fee_C_Student_Concession_Installments" 
    WHERE "FCSC_Id" = p_fsc_id 
        AND "FSCI_ID" = p_fsci_id;
    
    v_count := 0;
    SELECT COUNT("FSCI_ID") 
    INTO v_count
    FROM "CLG"."Fee_C_Student_Concession_Installments" 
    WHERE "FCSC_Id" = p_fsc_id;
    
    IF v_count = 0 THEN
        DELETE FROM "CLG"."Fee_College_Student_Concession" 
        WHERE "MI_Id" = p_mi_id 
            AND "ASMAY_ID" = p_asmay_id 
            AND "FCSC_Id" = p_fsc_id;
    END IF;
    
    RETURN;
END;
$$;