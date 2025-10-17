CREATE OR REPLACE FUNCTION "dbo"."deleteothersconcessioncollege"(
    p_FEC_Id bigint,
    p_asmay_id bigint,
    p_mi_id bigint,
    p_user_id bigint,
    p_FECI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_hrme_id bigint;
    v_fmgid bigint;
    v_fmhid bigint;
    v_ftiid bigint;
    v_amount bigint;
    v_count bigint;
    v_netmount bigint;
    v_paidamount bigint;
    v_concessionamt bigint;
    v_balanceamount bigint;
    v_totaltobepaid bigint;
    v_rowcount integer;
BEGIN

    SELECT "FMCOST_Id", "FMG_Id", "FMH_Id"
    INTO v_hrme_id, v_fmgid, v_fmhid
    FROM "CLG"."Fee_Others_Concession_College"
    WHERE "MI_Id" = p_mi_id 
        AND "ASMAY_ID" = p_asmay_id 
        AND "FOCC_Id" = p_FEC_Id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
    
        SELECT "FTI_Id", "FSCIC_ConcessionAmount"
        INTO v_ftiid, v_amount
        FROM "CLG"."Fee_Others_Concession_Installments_College"
        WHERE "FOCC_Id" = p_FEC_Id 
            AND "FOCIC_Id" = p_FECI_Id;
        
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
        
            DELETE FROM "CLG"."Fee_Others_Concession_Installments_College"
            WHERE "FOCC_Id" = p_FEC_Id 
                AND "FOCIC_Id" = p_FECI_Id;
            
            SELECT COUNT(p_FECI_Id)
            INTO v_count
            FROM "CLG"."Fee_Others_Concession_Installments_College"
            WHERE "FOCC_Id" = p_FEC_Id;
            
            IF v_count = 0 THEN
                DELETE FROM "CLG"."Fee_Others_Concession_College"
                WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_ID" = p_asmay_id 
                    AND "FOCC_Id" = p_FEC_Id;
            END IF;
            
            SELECT "FCSSOST_NetAmount", "FCSSOST_PaidAmount", "FCSSOST_ConcessionAmount", 
                   "FCSSOST_ToBePaid", "FCSSOST_ToBePaid"
            INTO v_netmount, v_paidamount, v_concessionamt, v_balanceamount, v_totaltobepaid
            FROM "CLG"."Fee_College_Student_Status_OthStu"
            WHERE "FMCOST_Id" = v_hrme_id 
                AND "FMG_Id" = v_fmgid 
                AND "FMH_Id" = v_fmhid
                AND "FTI_Id" = v_ftiid
                AND "ASMAY_Id" = p_asmay_id 
                AND "FCSSOST_ConcessionAmount" > 0;
            
            GET DIAGNOSTICS v_rowcount = ROW_COUNT;
            
            IF v_rowcount > 0 THEN
            
                IF v_netmount >= v_totaltobepaid + v_paidamount + v_concessionamt THEN
                
                    IF v_paidamount = 0 THEN
                    
                        UPDATE "CLG"."Fee_College_Student_Status_OthStu"
                        SET "FCSSOST_ConcessionAmount" = v_concessionamt - v_amount,
                            "FCSSOST_ToBePaid" = v_balanceamount + v_amount,
                            "FCSSOST_TotalCharges" = v_balanceamount + v_amount
                        WHERE "FMCOST_Id" = v_hrme_id 
                            AND "FMG_Id" = v_fmgid 
                            AND "FMH_Id" = v_fmhid 
                            AND "FTI_Id" = v_ftiid 
                            AND "ASMAY_Id" = p_asmay_id 
                            AND "MI_Id" = p_mi_id;
                    
                    END IF;
                
                ELSE
                
                    IF v_paidamount = 0 THEN
                    
                        UPDATE "CLG"."Fee_College_Student_Status_OthStu"
                        SET "FCSSOST_ConcessionAmount" = v_concessionamt - v_amount,
                            "FCSSOST_ToBePaid" = v_netmount,
                            "FCSSOST_TotalCharges" = v_netmount,
                            "FCSSOST_RunningExcessAmount" = 0,
                            "FCSSOST_ExcessPaidAmount" = 0
                        WHERE "FMCOST_Id" = v_hrme_id 
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