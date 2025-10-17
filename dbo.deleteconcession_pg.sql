CREATE OR REPLACE FUNCTION "dbo"."deleteconcession"(
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
    SELECT "AMST_Id", "FMG_Id", "FMH_Id" 
    INTO v_amstid, v_fmgid, v_fmhid
    FROM "dbo"."Fee_Student_Concession" 
    WHERE "MI_Id" = p_mi_id 
        AND "ASMAY_ID" = p_asmay_id 
        AND "FSC_Id" = p_fsc_id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        
        SELECT "FTI_Id", "FSCI_ConcessionAmount" 
        INTO v_ftiid, v_amount
        FROM "dbo"."Fee_Student_Concession_Installments" 
        WHERE "FSCI_FSC_Id" = p_fsc_id 
            AND "FSCI_ID" = p_fsci_id;
        
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
            
            DELETE FROM "dbo"."Fee_Student_Concession_Installments" 
            WHERE "FSCI_FSC_Id" = p_fsc_id 
                AND "FSCI_ID" = p_fsci_id;
            
            SELECT COUNT("FSCI_ID") 
            INTO v_count
            FROM "dbo"."Fee_Student_Concession_Installments" 
            WHERE "FSCI_FSC_Id" = p_fsc_id;
            
            IF v_count = 0 THEN
                DELETE FROM "dbo"."Fee_Student_Concession" 
                WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_ID" = p_asmay_id 
                    AND "FSC_Id" = p_fsc_id;
            END IF;
            
            SELECT "FSS_NetAmount", "FSS_PaidAmount", "FSS_ConcessionAmount", 
                   "FSS_ToBePaid", "FSS_TotalToBePaid"
            INTO v_netmount, v_paidamount, v_concessionamt, 
                 v_balanceamount, v_totaltobepaid
            FROM "dbo"."Fee_Student_Status" 
            WHERE "AMST_Id" = v_amstid 
                AND "FMG_Id" = v_fmgid 
                AND "FMH_Id" = v_fmhid 
                AND "FTI_Id" = v_ftiid 
                AND "ASMAY_Id" = p_asmay_id 
                AND "FSS_ConcessionAmount" > 0;
            
            GET DIAGNOSTICS v_rowcount = ROW_COUNT;
            
            IF v_rowcount > 0 THEN
                
                IF v_netmount >= v_totaltobepaid + v_paidamount + v_concessionamt THEN
                    
                    IF v_paidamount = 0 THEN
                        
                        UPDATE "dbo"."Fee_Student_Status" 
                        SET "FSS_ConcessionAmount" = v_concessionamt - v_amount,
                            "FSS_TotalToBePaid" = v_totaltobepaid + v_amount,
                            "FSS_ToBePaid" = v_balanceamount + v_amount 
                        WHERE "AMST_Id" = v_amstid 
                            AND "FMG_Id" = v_fmgid 
                            AND "FMH_Id" = v_fmhid 
                            AND "FTI_Id" = v_ftiid 
                            AND "ASMAY_Id" = p_asmay_id 
                            AND "MI_Id" = p_mi_id;
                    
                    END IF;
                
                END IF;
            
            END IF;
        
        END IF;
    
    END IF;

END;
$$;