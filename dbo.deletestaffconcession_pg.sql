CREATE OR REPLACE FUNCTION "dbo"."deletestaffconcession"(
    p_FEC_Id BIGINT,
    p_asmay_id BIGINT,
    p_mi_id BIGINT,
    p_user_id BIGINT,
    p_FECI_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_hrme_id BIGINT;
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

    SELECT "hrme_id", "FMG_Id", "FMH_Id"
    INTO v_hrme_id, v_fmgid, v_fmhid
    FROM "fee_employee_concession"
    WHERE "MI_Id" = p_mi_id 
        AND "ASMAY_ID" = p_asmay_id 
        AND "FEC_Id" = p_FEC_Id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
    
        SELECT "FTI_Id", "FSCI_ConcessionAmount"
        INTO v_ftiid, v_amount
        FROM "Fee_Employee_Concession_Installments"
        WHERE "FECI_FEC_Id" = p_FEC_Id 
            AND "FECI_Id" = p_FECI_Id;
        
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
        
            DELETE FROM "Fee_Employee_Concession_Installments"
            WHERE "FECI_FEC_Id" = p_FEC_Id 
                AND "FECI_Id" = p_FECI_Id;
            
            SELECT COUNT("FECI_ID")
            INTO v_count
            FROM "Fee_Employee_Concession_Installments"
            WHERE "FECI_FEC_Id" = p_FEC_Id;
            
            IF v_count = 0 THEN
                DELETE FROM "fee_employee_concession"
                WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_ID" = p_asmay_id 
                    AND "FEC_Id" = p_FEC_Id;
            END IF;
            
            SELECT "FSSST_NetAmount", "FSSST_PaidAmount", "FSSST_ConcessionAmount", 
                   "FSSST_ToBePaid", "FSSST_ToBePaid"
            INTO v_netmount, v_paidamount, v_concessionamt, v_balanceamount, v_totaltobepaid
            FROM "Fee_Student_Status_Staff"
            WHERE "hrme_id" = v_hrme_id 
                AND "FMG_Id" = v_fmgid 
                AND "FMH_Id" = v_fmhid 
                AND "FTI_Id" = v_ftiid
                AND "ASMAY_Id" = p_asmay_id 
                AND "FSSST_ConcessionAmount" > 0;
            
            GET DIAGNOSTICS v_rowcount = ROW_COUNT;
            
            IF v_rowcount > 0 THEN
            
                IF v_netmount >= v_totaltobepaid + v_paidamount + v_concessionamt THEN
                
                    IF v_paidamount = 0 THEN
                    
                        UPDATE "Fee_Student_Status_Staff"
                        SET "FSSST_ConcessionAmount" = v_concessionamt - v_amount,
                            "FSSST_ToBePaid" = v_balanceamount + v_amount
                        WHERE "hrme_id" = v_hrme_id 
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

    RETURN;
END;
$$;