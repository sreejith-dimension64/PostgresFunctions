CREATE OR REPLACE FUNCTION "dbo"."HR_VPF_TRANSACTION_INSERT"(
    p_MI_Id BIGINT,
    p_Monthname VARCHAR(500),
    p_YearId BIGINT,
    p_HRME_ID1 BIGINT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "IMFY_Id" BIGINT,
    "Month_Id" BIGINT,
    "HREVPFST_VOBAmount" DECIMAL(18,2),
    "HREVPFST_Contribution" DECIMAL(18,2),
    "HREVPFST_Intersest" DECIMAL(18,2),
    "HREVPFST_WithdrawnAmount" DECIMAL(18,2),
    "HREVPFST_SettledAmount" DECIMAL(18,2),
    "HREVPFST_ClosingBalance" DECIMAL(18,2),
    "HREVPFST_ActiveFlg" BOOLEAN,
    "HREVPFST_CreatedBy" BIGINT,
    "HREVPFST_UpdatedBy" BIGINT,
    "HREVPFST_CreatedDate" TIMESTAMP,
    "HREVPFST_UpdatedDate" TIMESTAMP,
    "HREVPFST_TransferAmount" DECIMAL(18,2),
    "HREVPFST_DepositAdjustmentAmount" DECIMAL(18,2),
    "HREVPFST_WithsrawAdjustmentAmount" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_COUNT BIGINT;
    v_HRME_Id BIGINT;
    v_HREVPFST_OpeningBalance DECIMAL(18,2);
    v_Contribution DECIMAL(18,2);
    v_ClosingBalance DECIMAL(18,2);
    v_Interest DECIMAL(18,2);
    v_IMFY_Id BIGINT;
    v_COUNT1 BIGINT;
    v_HRMPFVPFINT_VPFInterestRate DECIMAL(18,2);
    v_MonthId BIGINT;
    v_DATE DATE;
BEGIN
    SELECT "IVRM_Month_Id" INTO v_MonthId FROM "IVRM_Month" WHERE "IVRM_Month_Name" = p_Monthname;
    
    v_DATE := TO_DATE(CONCAT(p_YearId, '-', v_MonthId, '-', '01'), 'YYYY-MM-DD');
    
    SELECT "IMFY_ID" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE v_DATE BETWEEN "IMFY_FromDate" AND "IMFY_ToDate";
    
    SELECT "HRMPFVPFINT_VPFInterestRate" INTO v_HRMPFVPFINT_VPFInterestRate 
    FROM "HR_Master_PFVPF_Interest" 
    WHERE "MI_Id" = p_MI_Id 
    AND "IMFY_Id" = v_IMFY_Id 
    AND "HRMPFVPFINT_ActiveFlg" = TRUE;
    
    SELECT DISTINCT A."HRME_ID" INTO v_HRME_Id 
    FROM "HR_Master_Employee" A
    INNER JOIN "HR_Employee_Salary" B ON B."HRME_ID" = A."HRME_ID"
    WHERE A."MI_Id" = p_MI_Id 
    AND B."HRES_Year" = p_YearId 
    AND B."HRES_Month" = p_Monthname 
    AND A."HRME_PFApplicableFlag" = TRUE 
    AND A."HRME_Id" = p_HRME_ID1 
    AND A."HRME_Id" NOT IN (
        SELECT "HRME_Id" 
        FROM "HR_Employee_VPF_Status" 
        WHERE "MI_Id" = p_MI_Id 
        AND "IMFY_Id" = v_IMFY_Id 
        AND "Month_Id" = v_MonthId 
        AND "HRME_Id" = p_HRME_ID1
    );
    
    SELECT COUNT(*) INTO v_COUNT 
    FROM "HR_Employee_VPF_Status" 
    WHERE "HRME_Id" = v_HRME_Id;
    
    IF (v_COUNT > 0) THEN
        SELECT "HREVPFST_ClosingBalance" INTO v_HREVPFST_OpeningBalance 
        FROM "HR_Employee_VPF_Status" 
        WHERE "HRME_Id" = v_HRME_Id 
        ORDER BY "HREVPFST_CreatedDate" DESC 
        LIMIT 1;
        
        SELECT B."HRESD_Amount" INTO v_Contribution 
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_ID" = B."HRES_ID"
        INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_ID" = C."HRMED_ID"
        WHERE A."MI_ID" = p_MI_Id 
        AND A."HRME_ID" = v_HRME_Id 
        AND A."HRES_year" = p_YearId 
        AND A."HRES_Month" = p_Monthname 
        AND C."HRMED_EDTypeFlag" = 'VPF' 
        AND C."HRMED_ActiveFlag" = TRUE;
        
        v_Interest := ROUND((COALESCE(v_HREVPFST_OpeningBalance, 0)) * COALESCE(v_HRMPFVPFINT_VPFInterestRate, 0) / (12 * 100), 0);
        
        v_ClosingBalance := COALESCE(v_HREVPFST_OpeningBalance, 0) + COALESCE(v_Contribution, 0);
        
        SELECT COUNT(*) INTO v_COUNT1 
        FROM "HR_Employee_VPF_Status" 
        WHERE "MI_Id" = p_MI_Id 
        AND "IMFY_Id" = v_IMFY_Id 
        AND "Month_Id" = v_MonthId 
        AND "HRME_Id" = p_HRME_ID1;
        
        IF (v_COUNT1 = 0) THEN
            INSERT INTO "HR_Employee_VPF_Status" (
                "MI_Id", "HRME_Id", "IMFY_Id", "Month_Id", "HREVPFST_VOBAmount", 
                "HREVPFST_Contribution", "HREVPFST_Intersest", "HREVPFST_WithdrawnAmount", 
                "HREVPFST_SettledAmount", "HREVPFST_ClosingBalance", "HREVPFST_ActiveFlg",
                "HREVPFST_CreatedBy", "HREVPFST_UpdatedBy", "HREVPFST_CreatedDate", 
                "HREVPFST_UpdatedDate", "HREVPFST_TransferAmount", 
                "HREVPFST_DepositAdjustmentAmount", "HREVPFST_WithsrawAdjustmentAmount"
            )
            VALUES (
                p_MI_Id, v_HRME_Id, v_IMFY_Id, v_MonthId, v_HREVPFST_OpeningBalance,
                v_Contribution, v_Interest, 0, 0, v_ClosingBalance, TRUE,
                0, 0, v_DATE, v_DATE, 0, 0, 0
            );
        END IF;
    END IF;
    
    RETURN QUERY 
    SELECT 
        s."MI_Id", s."HRME_Id", s."IMFY_Id", s."Month_Id", s."HREVPFST_VOBAmount",
        s."HREVPFST_Contribution", s."HREVPFST_Intersest", s."HREVPFST_WithdrawnAmount",
        s."HREVPFST_SettledAmount", s."HREVPFST_ClosingBalance", s."HREVPFST_ActiveFlg",
        s."HREVPFST_CreatedBy", s."HREVPFST_UpdatedBy", s."HREVPFST_CreatedDate",
        s."HREVPFST_UpdatedDate", s."HREVPFST_TransferAmount",
        s."HREVPFST_DepositAdjustmentAmount", s."HREVPFST_WithsrawAdjustmentAmount"
    FROM "HR_Employee_VPF_Status" s
    WHERE s."MI_Id" = p_MI_Id 
    AND s."IMFY_Id" = v_IMFY_Id 
    AND s."Month_Id" = v_MonthId 
    AND s."HRME_Id" = p_HRME_ID1;
END;
$$;