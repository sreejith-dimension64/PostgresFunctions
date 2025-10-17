CREATE OR REPLACE FUNCTION "dbo"."HR_VPF_BlurCalculation_Save"(
    p_HREVPFST_Id bigint,
    p_HREVPFST_VOBAmount decimal(18,2),
    p_Contribution decimal(18,2),
    p_InterestAmt decimal(18,2),
    p_HREVPFST_TransferAmount decimal(18,2),
    p_HREVPFST_WithdrawnAmount decimal(18,2),
    p_HREVPFST_SettledAmount decimal(18,2),
    p_DepositAdjustmentAmount decimal(18,2),
    p_HREVPFST_WithsrawAdjustmentAmount decimal(18,2),
    p_ClosingBalance decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_HREVPFST_Id > 0) THEN
    
        UPDATE "dbo"."HR_Employee_VPF_Status" 
        SET     
            "HREVPFST_VOBAmount" = p_HREVPFST_VOBAmount,    
            "HREVPFST_Contribution" = p_Contribution,    
            "HREVPFST_Intersest" = p_InterestAmt,    
            "HREVPFST_WithdrawnAmount" = p_HREVPFST_WithdrawnAmount,    
            "HREVPFST_SettledAmount" = p_HREVPFST_SettledAmount,    
            "HREVPFST_TransferAmount" = p_HREVPFST_TransferAmount,    
            "HREVPFST_DepositAdjustmentAmount" = p_DepositAdjustmentAmount,    
            "HREVPFST_WithsrawAdjustmentAmount" = p_HREVPFST_WithsrawAdjustmentAmount,    
            "HREVPFST_ClosingBalance" = p_ClosingBalance    
        WHERE "HREVPFST_Id" = p_HREVPFST_Id;
    
    END IF;

END;
$$;