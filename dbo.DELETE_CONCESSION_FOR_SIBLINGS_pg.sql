CREATE OR REPLACE FUNCTION "dbo"."DELETE_CONCESSION_FOR_SIBLINGS"(
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_AMST_ID BIGINT,
    p_HRME_Id BIGINT,
    p_FLAG TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMSTS_Siblings_AMST_ID BIGINT;
    v_AMSTS_SiblingsOrder BIGINT;
    v_SIBLINGAMOUNT BIGINT;
    v_AMST_Concession_Type BIGINT;
    v_FMCCD_PerOrAmtFlag TEXT;
    v_FSCI_ID BIGINT;
    v_FMG_ID BIGINT;
    v_FMH_ID BIGINT;
    v_FTI_ID BIGINT;
    v_FSS_CurrentYrCharges BIGINT;
    v_CONCESSIONAMOUNT BIGINT;
    v_FSS_ConcessionAmount BIGINT;
    v_rec_outer RECORD;
    v_rec_inner RECORD;
BEGIN

    IF p_FLAG = 'stud' THEN
    
        v_CONCESSIONAMOUNT := 0;
        
        FOR v_rec_outer IN 
            SELECT "AMSTS_Siblings_AMST_ID", "AMSTS_SiblingsOrder", "AMST_Concession_Type" 
            FROM "Adm_Master_Student_SiblingsDetails"
            INNER JOIN "Adm_M_Student" ON "Adm_Master_Student_SiblingsDetails"."amst_id" = "Adm_M_Student"."amst_id"
            WHERE "Adm_M_Student"."AMST_Id" = p_AMST_ID AND "Adm_M_Student"."MI_Id" = p_MI_ID
        LOOP
            v_AMSTS_Siblings_AMST_ID := v_rec_outer."AMSTS_Siblings_AMST_ID";
            v_AMSTS_SiblingsOrder := v_rec_outer."AMSTS_SiblingsOrder";
            v_AMST_Concession_Type := v_rec_outer."AMST_Concession_Type";
            
            SELECT "FMCCD_PerOrAmt", "FMCCD_PerOrAmtFlag" 
            INTO v_SIBLINGAMOUNT, v_FMCCD_PerOrAmtFlag 
            FROM "Fee_Master_Concession_Details" 
            WHERE "FMCCD_ToNoSibblings" = v_AMSTS_SiblingsOrder AND "FMCC_ID" = v_AMST_Concession_Type;
            
            IF (COALESCE(v_SIBLINGAMOUNT, 0) > 0) THEN
            
                FOR v_rec_inner IN 
                    SELECT DISTINCT "Fee_Student_Status"."FMG_ID", "Fee_Student_Status"."FMH_ID", 
                           "Fee_Student_Status"."FTI_ID", "FSS_CurrentYrCharges", "FSS_ConcessionAmount" 
                    FROM "Fee_Master_AutoConcession_Group"
                    INNER JOIN "Fee_Student_Status" ON "Fee_Master_AutoConcession_Group"."FMG_Id" = "Fee_Student_Status"."FMG_ID"
                        AND "Fee_Master_AutoConcession_Group"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                    WHERE "MI_ID" = p_MI_ID AND "ASMAY_ID" = p_ASMAY_ID 
                        AND "FMCC_ID" = v_AMST_Concession_Type 
                        AND "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                        AND "Fee_Student_Status"."FSS_PAIDAMOUNT" = 0 
                        AND "FSS_CurrentYrCharges" > 0
                LOOP
                    v_FMG_ID := v_rec_inner."FMG_ID";
                    v_FMH_ID := v_rec_inner."FMH_ID";
                    v_FTI_ID := v_rec_inner."FTI_ID";
                    v_FSS_CurrentYrCharges := v_rec_inner."FSS_CurrentYrCharges";
                    v_FSS_ConcessionAmount := v_rec_inner."FSS_ConcessionAmount";
                    
                    DELETE FROM "Fee_Student_Concession_Installments" 
                    WHERE "FTI_Id" = v_FTI_ID 
                        AND "FSCI_FSC_Id" IN (
                            SELECT "FSC_ID" FROM "Fee_Student_Concession" 
                            WHERE "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                                AND "MI_Id" = p_MI_ID 
                                AND "ASMAY_ID" = p_ASMAY_ID 
                                AND "FMG_Id" = v_FMG_ID 
                                AND "FMH_Id" = v_FMH_ID
                        );
                    
                    DELETE FROM "FEE_STUDENT_CONCESSION" 
                    WHERE "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                        AND "MI_Id" = p_MI_ID 
                        AND "ASMAY_ID" = p_ASMAY_ID 
                        AND "FMG_Id" = v_FMG_ID 
                        AND "FMH_Id" = v_FMH_ID;
                    
                    IF (v_FMCCD_PerOrAmtFlag = 'P') THEN
                        v_CONCESSIONAMOUNT := v_FSS_CurrentYrCharges * v_SIBLINGAMOUNT / 100;
                    END IF;
                    
                    IF v_CONCESSIONAMOUNT > 0 AND v_FSS_ConcessionAmount > 0 THEN
                        UPDATE "FEE_STUDENT_STATUS" 
                        SET "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_CONCESSIONAMOUNT,
                            "FSS_ToBePaid" = "FSS_ToBePaid" + v_CONCESSIONAMOUNT,
                            "FSS_ConcessionAmount" = "FSS_ConcessionAmount" - v_CONCESSIONAMOUNT 
                        WHERE "MI_ID" = p_MI_ID 
                            AND "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                            AND "FMG_ID" = v_FMG_ID 
                            AND "FMH_ID" = v_FMH_ID 
                            AND "FTI_ID" = v_FTI_ID 
                            AND "ASMAY_Id" = p_ASMAY_ID;
                    END IF;
                    
                END LOOP;
                
            END IF;
            
        END LOOP;
        
        DELETE FROM "Adm_Master_Student_SiblingsDetails" 
        WHERE "AMST_Id" = p_AMST_ID AND "MI_Id" = p_MI_ID;
        
    ELSIF p_FLAG = 'stfoth' THEN
    
        v_CONCESSIONAMOUNT := 0;
        
        FOR v_rec_outer IN 
            SELECT "Adm_M_Student"."AMST_Id", "AMSTE_SiblingsOrder", "AMST_Concession_Type" 
            FROM "Adm_M_Student_EmployeeDetails"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student_EmployeeDetails"."amst_id" = "Adm_M_Student"."amst_id"
            WHERE "Adm_M_Student_EmployeeDetails"."HRME_Id" = p_HRME_Id AND "Adm_M_Student"."MI_Id" = p_MI_ID
        LOOP
            v_AMSTS_Siblings_AMST_ID := v_rec_outer."AMST_Id";
            v_AMSTS_SiblingsOrder := v_rec_outer."AMSTE_SiblingsOrder";
            v_AMST_Concession_Type := v_rec_outer."AMST_Concession_Type";
            
            SELECT "FMCCD_PerOrAmt", "FMCCD_PerOrAmtFlag" 
            INTO v_SIBLINGAMOUNT, v_FMCCD_PerOrAmtFlag 
            FROM "Fee_Master_Concession_Details" 
            WHERE "FMCCD_ToNoSibblings" = v_AMSTS_SiblingsOrder AND "FMCC_ID" = v_AMST_Concession_Type;
            
            IF (COALESCE(v_SIBLINGAMOUNT, 0) > 0) THEN
            
                FOR v_rec_inner IN 
                    SELECT DISTINCT "Fee_Student_Status"."FMG_ID", "Fee_Student_Status"."FMH_ID", 
                           "Fee_Student_Status"."FTI_ID", "FSS_CurrentYrCharges", "FSS_ConcessionAmount" 
                    FROM "Fee_Master_AutoConcession_Group"
                    INNER JOIN "Fee_Student_Status" ON "Fee_Master_AutoConcession_Group"."FMG_Id" = "Fee_Student_Status"."FMG_ID"
                        AND "Fee_Master_AutoConcession_Group"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                    WHERE "MI_ID" = p_MI_ID AND "ASMAY_ID" = p_ASMAY_ID 
                        AND "FMCC_ID" = v_AMST_Concession_Type 
                        AND "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                        AND "Fee_Student_Status"."FSS_PAIDAMOUNT" = 0 
                        AND "FSS_CurrentYrCharges" > 0
                LOOP
                    v_FMG_ID := v_rec_inner."FMG_ID";
                    v_FMH_ID := v_rec_inner."FMH_ID";
                    v_FTI_ID := v_rec_inner."FTI_ID";
                    v_FSS_CurrentYrCharges := v_rec_inner."FSS_CurrentYrCharges";
                    v_FSS_ConcessionAmount := v_rec_inner."FSS_ConcessionAmount";
                    
                    DELETE FROM "Fee_Student_Concession_Installments" 
                    WHERE "FTI_Id" = v_FTI_ID 
                        AND "FSCI_FSC_Id" IN (
                            SELECT "FSC_ID" FROM "Fee_Student_Concession" 
                            WHERE "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                                AND "MI_Id" = p_MI_ID 
                                AND "ASMAY_ID" = p_ASMAY_ID 
                                AND "FMG_Id" = v_FMG_ID 
                                AND "FMH_Id" = v_FMH_ID
                        );
                    
                    DELETE FROM "FEE_STUDENT_CONCESSION" 
                    WHERE "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                        AND "MI_Id" = p_MI_ID 
                        AND "ASMAY_ID" = p_ASMAY_ID 
                        AND "FMG_Id" = v_FMG_ID 
                        AND "FMH_Id" = v_FMH_ID;
                    
                    IF (v_FMCCD_PerOrAmtFlag = 'P') THEN
                        v_CONCESSIONAMOUNT := v_FSS_CurrentYrCharges * v_SIBLINGAMOUNT / 100;
                    END IF;
                    
                    IF v_CONCESSIONAMOUNT > 0 AND v_FSS_ConcessionAmount > 0 THEN
                        UPDATE "FEE_STUDENT_STATUS" 
                        SET "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_CONCESSIONAMOUNT,
                            "FSS_ToBePaid" = "FSS_ToBePaid" + v_CONCESSIONAMOUNT,
                            "FSS_ConcessionAmount" = "FSS_ConcessionAmount" - v_CONCESSIONAMOUNT 
                        WHERE "MI_ID" = p_MI_ID 
                            AND "AMST_ID" = v_AMSTS_Siblings_AMST_ID 
                            AND "FMG_ID" = v_FMG_ID 
                            AND "FMH_ID" = v_FMH_ID 
                            AND "FTI_ID" = v_FTI_ID 
                            AND "ASMAY_Id" = p_ASMAY_ID;
                    END IF;
                    
                END LOOP;
                
            END IF;
            
        END LOOP;
        
        DELETE FROM "Adm_M_Student_EmployeeDetails" 
        WHERE "HRME_Id" = p_HRME_Id;
        
    END IF;

END;
$$;