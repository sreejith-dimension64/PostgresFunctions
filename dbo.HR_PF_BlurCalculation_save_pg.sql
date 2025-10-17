CREATE OR REPLACE FUNCTION "dbo"."HR_PF_BlurCalculation_save"(
    "HREPFST_Id" bigint,
    "HREPFST_OBOwnAmount" decimal(18,2),
    "HHREPFST_OBInstituteAmount" decimal(18,2),
    "Contribution" decimal(18,2),
    "InstituteContribution" decimal(18,2),
    "InterestAmt" decimal(18,2),
    "INST_Interest" decimal(18,2),
    "HREPFST_OwnTransferAmount" decimal(18,2),
    "HREPFST_InstituteTransferAmount" decimal(18,2),
    "HREPFST_OwnWithdrwanAmount" decimal(18,2),
    "HREPFST_InstituteWithdrawnAmount" decimal(18,2),
    "HREPFST_OwnSettlementAmount" decimal(18,2),
    "HREPFST_InstituteLSettlementAmount" decimal(18,2),
    "HREPFST_OwnDepositAdjustmentAmount" decimal(18,2),
    "HREPFST_InstituteDepositAdjustmentAmount" decimal(18,2),
    "HREPFST_OwnWithdrawAdjustmentAmount" decimal(18,2),
    "HREPFST_InstituteWithdrawAdjustmentAmount" decimal(18,2),
    "ClosingBalance" decimal(18,2),
    "InstitutionClosingBalance" decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    IF "HREPFST_Id" > 0 THEN
    
        UPDATE "dbo"."HR_Employee_PF_Status" 
        SET   
            "HREPFST_OBOwnAmount" = "HREPFST_OBOwnAmount",  
            "HREPFST_OBInstituteAmount" = "HHREPFST_OBInstituteAmount",
            "HREPFST_OwnContribution" = "Contribution",  
            "HREPFST_IntstituteContribution" = "InstituteContribution",  
            "HREPFST_OwnInterest" = "InterestAmt",  
            "HREPFST_InstituteInterest" = "INST_Interest",  
            "HREPFST_OwnWithdrwanAmount" = "HREPFST_OwnWithdrwanAmount",  
            "HREPFST_InstituteWithdrawnAmount" = "HREPFST_InstituteWithdrawnAmount",
            "HREPFST_OwnSettlementAmount" = "HREPFST_OwnSettlementAmount", 
            "HREPFST_InstituteLSettlementAmount" = "HREPFST_InstituteLSettlementAmount",  
            "HREPFST_OwnTransferAmount" = "HREPFST_OwnTransferAmount",  
            "HREPFST_InstituteTransferAmount" = "HREPFST_InstituteTransferAmount",
            "HREPFST_OwnDepositAdjustmentAmount" = "HREPFST_OwnDepositAdjustmentAmount",  
            "HREPFST_InstituteDepositAdjustmentAmount" = "HREPFST_InstituteDepositAdjustmentAmount", 
            "HREPFST_OwnWithdrawAdjustmentAmount" = "HREPFST_OwnWithdrawAdjustmentAmount",  
            "HREPFST_InstituteWithdrawAdjustmentAmount" = "HREPFST_InstituteWithdrawAdjustmentAmount",  
            "HREPFST_OwnClosingBalance" = "ClosingBalance", 
            "HREPFST_InstituteClosingBalance" = "InstitutionClosingBalance"  
        WHERE "HREPFST_Id" = "HREPFST_Id";
    
    END IF;

END;
$$;