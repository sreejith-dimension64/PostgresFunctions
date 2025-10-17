CREATE OR REPLACE FUNCTION "dbo"."HR_PFTransactionSave"(
    p_IMFY_Id bigint,
    p_Month_Id bigint,
    p_MI_Id bigint,
    p_HRME_Id bigint,
    p_userid bigint,
    p_OwnAmount decimal(18,2),
    p_InstAmount decimal(18,2),
    p_HeadType varchar(50),
    p_DepositWithdrow varchar(50),
    p_Remarks varchar(50),
    p_Headdate date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_count bigint;
    v_HREVPFST_ClosingBalance decimal(18,2);
    v_HREPFST_InstituteClosingBalance decimal(18,2);
    v_IMFY_FromDate DATE;
    v_IMFY_ToDate DATE;
    v_YearId bigint;
    v_InterestAmt decimal(18,2);
    v_OwnContribution decimal(18,2);
    v_HRME_DOB DATE;
    v_SUMAMOUNT decimal(18,2);
    v_HRMPFVPFINT_PFInterestRate decimal(18,2);
    v_ClosingBalance decimal(18,2);
    v_HRME_FPFNotApplicableFlg BOOLEAN;
    v_INST_PF decimal(18,2);
    v_Inst_Contribution decimal(18,2);
    v_INST_Interest decimal(18,2);
    v_INST_ClosingBalance decimal(18,2);
    v_MonthName VARCHAR(500);
    v_MinDate DATE;
    v_MaxDate DATE;
BEGIN

    SELECT "HRMPFVPFINT_PFInterestRate" INTO v_HRMPFVPFINT_PFInterestRate 
    FROM "HR_Master_PFVPF_Interest" 
    WHERE "MI_Id" = p_MI_Id AND "IMFY_Id" = p_IMFY_Id AND "HRMPFVPFINT_ActiveFlg" = true
    LIMIT 1;

    SELECT "IVRM_Month_Name" INTO v_MonthName 
    FROM "IVRM_Month" 
    WHERE "IVRM_Month_Id" = p_Month_Id AND "Is_Active" = 1
    LIMIT 1;

    SELECT "IMFY_FromDate", "IMFY_ToDate" INTO v_IMFY_FromDate, v_IMFY_ToDate 
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_Id" = p_IMFY_Id;

    v_MinDate := v_IMFY_FromDate;
    v_MaxDate := v_IMFY_ToDate;

    CREATE TEMP TABLE IF NOT EXISTS "#date" ("Date" DATE);
    TRUNCATE TABLE "#date";

    INSERT INTO "#date" ("Date")
    SELECT generate_series(v_MinDate, v_MaxDate, '1 day'::interval)::DATE;

    SELECT EXTRACT(YEAR FROM "Date") INTO v_YearId 
    FROM "#date" 
    WHERE EXTRACT(MONTH FROM "Date") = p_Month_Id 
    LIMIT 1;

    SELECT "HREPFST_OwnClosingBalance", "HREPFST_InstituteClosingBalance" 
    INTO v_HREVPFST_ClosingBalance, v_HREPFST_InstituteClosingBalance
    FROM "HR_Employee_PF_Status" 
    WHERE "HRME_Id" = p_HRME_Id 
    ORDER BY "HREPFST_CreatedDate" DESC 
    LIMIT 1;

    SELECT "B"."HRESD_Amount" INTO v_OwnContribution
    FROM "HR_Employee_Salary" "A"
    INNER JOIN "HR_Employee_Salary_Details" "B" ON "A"."HRES_ID" = "B"."HRES_ID"
    INNER JOIN "HR_Master_EarningsDeductions" "C" ON "B"."HRMED_ID" = "C"."HRMED_ID"
    WHERE "A"."MI_ID" = p_MI_Id AND "A"."HRME_ID" = p_HRME_Id AND "A"."HRES_year" = v_YearId 
        AND "A"."HRES_Month" = v_MonthName AND "C"."HRMED_EDTypeFlag" = 'PF' 
        AND "C"."HRMED_ActiveFlag" = 1
    LIMIT 1;

    SELECT SUM("B"."HRESD_Amount") INTO v_SUMAMOUNT
    FROM "HR_Employee_Salary" "A"
    INNER JOIN "HR_Employee_Salary_Details" "B" ON "A"."HRES_Id" = "B"."HRES_Id"
    INNER JOIN "HR_Master_EarningsDeductions" "C" ON "B"."HRMED_Id" = "C"."HRMED_Id"
    WHERE "A"."MI_Id" = p_MI_Id AND "A"."HRES_Year" = v_YearId AND "A"."HRES_Month" = v_MonthName 
        AND "C"."HRMED_EarnDedFlag" = 'Earning' AND "A"."HRME_Id" = p_HRME_ID;

    SELECT "HRME_FPFNotApplicableFlg" INTO v_HRME_FPFNotApplicableFlg
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = p_HRME_ID;

    IF (v_SUMAMOUNT < 15000 AND v_HRME_FPFNotApplicableFlg = true) THEN
        v_INST_PF := ROUND(v_SUMAMOUNT * v_HRMPFVPFINT_PFInterestRate / 100, 0);
    ELSIF (v_HRME_FPFNotApplicableFlg = true) THEN
        v_INST_PF := 1250;
    ELSE
        v_INST_PF := 0;
    END IF;

    IF (v_HRME_FPFNotApplicableFlg = false) THEN
        v_Inst_Contribution := v_OwnContribution;
    ELSE
        v_Inst_Contribution := v_OwnContribution - v_INST_PF;
    END IF;

    IF (v_OwnContribution > 0) THEN
        v_OwnContribution := v_OwnContribution;
    ELSE
        v_OwnContribution := 0;
    END IF;

    IF (v_Inst_Contribution > 0) THEN
        v_Inst_Contribution := v_Inst_Contribution;
    ELSE
        v_Inst_Contribution := 0;
    END IF;

    IF (p_DepositWithdrow = 'Deposit') THEN

        IF (p_HeadType = 'Opening Balance') THEN

            v_InterestAmt := ROUND((p_OwnAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_ClosingBalance := p_OwnAmount + v_OwnContribution;
            v_INST_Interest := ROUND((p_InstAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_INST_ClosingBalance := p_InstAmount + v_Inst_Contribution;

            INSERT INTO "HR_Employee_PF_Status"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFST_OBOwnAmount","HREPFST_OBInstituteAmount","HREPFST_OwnContribution","HREPFST_IntstituteContribution",
            "HREPFST_OwnInterest","HREPFST_InstituteInterest","HREPFST_OwnWithdrwanAmount","HREPFST_InstituteWithdrawnAmount","HREPFST_OwnSettlementAmount","HREPFST_InstituteLSettlementAmount","HREPFST_OwnClosingBalance",
            "HREPFST_InstituteClosingBalance","HREPFST_ActiveFlg","HREPFST_CreatedBy","HREPFST_UpdatedBy","HREPFST_CreatedDate","HREPFST_UpdatedDate","HREPFST_OwnTransferAmount","HREPFST_InstituteTransferAmount","HREPFST_OwnDepositAdjustmentAmount",
            "HREPFST_OwnWithdrawAdjustmentAmount","HREPFST_InstituteDepositAdjustmentAmount","HREPFST_InstituteWithdrawAdjustmentAmount")
            VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,p_OwnAmount,p_InstAmount,v_OwnContribution,v_Inst_Contribution,v_InterestAmt,v_INST_Interest,0,0,0,0,v_ClosingBalance,
            v_INST_ClosingBalance,1,p_userid,p_userid,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,0,0,0,0,0,0);

        ELSIF (p_HeadType = 'PF Transefer') THEN

            IF (EXTRACT(DAY FROM p_Headdate) <= 25) THEN
                v_InterestAmt := ROUND((v_HREVPFST_ClosingBalance - p_OwnAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                v_INST_Interest := ROUND((v_HREPFST_InstituteClosingBalance - p_InstAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            ELSIF (EXTRACT(DAY FROM p_Headdate) > 25) THEN
                v_InterestAmt := ROUND((v_HREVPFST_ClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                v_INST_Interest := ROUND((v_HREPFST_InstituteClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            END IF;

            v_ClosingBalance := (v_HREVPFST_ClosingBalance + v_OwnContribution) + p_OwnAmount;
            v_INST_ClosingBalance := (v_HREPFST_InstituteClosingBalance + v_Inst_Contribution) + p_InstAmount;

            SELECT COUNT(*) INTO v_count 
            FROM "HR_Employee_PF_Status" 
            WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;

            IF (v_count > 0) THEN
                UPDATE "HR_Employee_PF_Status" 
                SET "HREPFST_OwnTransferAmount" = p_OwnAmount, "HREPFST_InstituteTransferAmount" = p_InstAmount,
                    "HREPFST_OwnClosingBalance" = v_ClosingBalance, "HREPFST_InstituteClosingBalance" = v_INST_ClosingBalance 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;
            ELSE
                INSERT INTO "HR_Employee_PF_Status"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFST_OBOwnAmount","HREPFST_OBInstituteAmount","HREPFST_OwnContribution","HREPFST_IntstituteContribution",
                "HREPFST_OwnInterest","HREPFST_InstituteInterest","HREPFST_OwnWithdrwanAmount","HREPFST_InstituteWithdrawnAmount","HREPFST_OwnSettlementAmount","HREPFST_InstituteLSettlementAmount","HREPFST_OwnClosingBalance",
                "HREPFST_InstituteClosingBalance","HREPFST_ActiveFlg","HREPFST_CreatedBy","HREPFST_UpdatedBy","HREPFST_CreatedDate","HREPFST_UpdatedDate","HREPFST_OwnTransferAmount","HREPFST_InstituteTransferAmount","HREPFST_OwnDepositAdjustmentAmount",
                "HREPFST_OwnWithdrawAdjustmentAmount","HREPFST_InstituteDepositAdjustmentAmount","HREPFST_InstituteWithdrawAdjustmentAmount")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,v_HREVPFST_ClosingBalance,v_HREPFST_InstituteClosingBalance,v_OwnContribution,v_Inst_Contribution,v_InterestAmt,v_INST_Interest,0,0,0,0,v_ClosingBalance,
                v_INST_ClosingBalance,1,p_userid,p_userid,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,p_OwnAmount,p_InstAmount,0,0,0,0);
            END IF;

        ELSIF (p_HeadType = 'FPF To PF') THEN

            v_InterestAmt := ROUND((p_OwnAmount + v_HREVPFST_ClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_ClosingBalance := p_OwnAmount + v_HREVPFST_ClosingBalance;
            v_INST_Interest := ROUND((p_InstAmount + v_HREPFST_InstituteClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_INST_ClosingBalance := p_InstAmount + v_HREPFST_InstituteClosingBalance;

            INSERT INTO "HR_Employee_PF_Status"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFST_OBOwnAmount","HREPFST_OBInstituteAmount","HREPFST_OwnContribution","HREPFST_IntstituteContribution",
            "HREPFST_OwnInterest","HREPFST_InstituteInterest","HREPFST_OwnWithdrwanAmount","HREPFST_InstituteWithdrawnAmount","HREPFST_OwnSettlementAmount","HREPFST_InstituteLSettlementAmount","HREPFST_OwnClosingBalance",
            "HREPFST_InstituteClosingBalance","HREPFST_ActiveFlg","HREPFST_CreatedBy","HREPFST_UpdatedBy","HREPFST_CreatedDate","HREPFST_UpdatedDate","HREPFST_OwnTransferAmount","HREPFST_InstituteTransferAmount","HREPFST_OwnDepositAdjustmentAmount",
            "HREPFST_OwnWithdrawAdjustmentAmount","HREPFST_InstituteDepositAdjustmentAmount","HREPFST_InstituteWithdrawAdjustmentAmount")
            VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,v_HREVPFST_ClosingBalance,v_HREPFST_InstituteClosingBalance,v_OwnContribution,v_Inst_Contribution,v_InterestAmt,v_INST_Interest,0,0,0,0,v_ClosingBalance,
            v_INST_ClosingBalance,1,p_userid,p_userid,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,0,0,0,0,0,0);

        ELSIF (p_HeadType = 'Interest Adjestment') THEN

            v_InterestAmt := ROUND((p_OwnAmount + v_HREVPFST_ClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_ClosingBalance := p_OwnAmount + v_HREVPFST_ClosingBalance;
            v_INST_Interest := ROUND((p_InstAmount + v_HREPFST_InstituteClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_INST_ClosingBalance := p_InstAmount + v_HREPFST_InstituteClosingBalance;

            SELECT COUNT(*) INTO v_count 
            FROM "HR_Employee_PF_Status" 
            WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;

            IF (v_count > 0) THEN
                UPDATE "HR_Employee_PF_Status" 
                SET "HREPFST_OwnDepositAdjustmentAmount" = p_OwnAmount, "HREPFST_InstituteDepositAdjustmentAmount" = p_InstAmount,
                    "HREPFST_OwnClosingBalance" = v_ClosingBalance, "HREPFST_InstituteClosingBalance" = v_INST_ClosingBalance 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;
            ELSE
                INSERT INTO "HR_Employee_PF_Status"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFST_OBOwnAmount","HREPFST_OBInstituteAmount","HREPFST_OwnContribution","HREPFST_IntstituteContribution",
                "HREPFST_OwnInterest","HREPFST_InstituteInterest","HREPFST_OwnWithdrwanAmount","HREPFST_InstituteWithdrawnAmount","HREPFST_OwnSettlementAmount","HREPFST_InstituteLSettlementAmount","HREPFST_OwnClosingBalance",
                "HREPFST_InstituteClosingBalance","HREPFST_ActiveFlg","HREPFST_CreatedBy","HREPFST_UpdatedBy","HREPFST_CreatedDate","HREPFST_UpdatedDate","HREPFST_OwnTransferAmount","HREPFST_InstituteTransferAmount","HREPFST_OwnDepositAdjustmentAmount",
                "HREPFST_OwnWithdrawAdjustmentAmount","HREPFST_InstituteDepositAdjustmentAmount","HREPFST_InstituteWithdrawAdjustmentAmount")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,v_HREVPFST_ClosingBalance,v_HREPFST_InstituteClosingBalance,v_OwnContribution,v_Inst_Contribution,v_InterestAmt,v_INST_Interest,0,0,0,0,v_ClosingBalance+p_OwnAmount,
                v_INST_ClosingBalance+p_InstAmount,1,p_userid,p_userid,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,0,0,p_OwnAmount,0,p_InstAmount,0);
            END IF;

        END IF;

    ELSIF (p_DepositWithdrow = 'Withdraw') THEN

        IF (p_HeadType = 'Settlement Of PF') THEN

            IF (EXTRACT(DAY FROM p_Headdate) <= 25) THEN
                v_InterestAmt := ROUND((v_HREVPFST_ClosingBalance - p_OwnAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                v_INST_Interest := ROUND((v_HREPFST_InstituteClosingBalance - p_InstAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            ELSIF (EXTRACT(DAY FROM p_Headdate) > 25) THEN
                v_InterestAmt := ROUND((v_HREVPFST_ClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                v_INST_Interest := ROUND((v_HREPFST_InstituteClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            END IF;

            v_ClosingBalance := (v_HREVPFST_ClosingBalance + v_OwnContribution) - p_OwnAmount;
            v_INST_ClosingBalance := (v_HREPFST_InstituteClosingBalance + v_Inst_Contribution) - p_InstAmount;

            SELECT COUNT(*) INTO v_count 
            FROM "HR_Employee_PF_Status" 
            WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;

            IF (v_count > 0) THEN
                UPDATE "HR_Employee_PF_Status" 
                SET "HREPFST_OwnSettlementAmount" = p_OwnAmount, "HREPFST_InstituteLSettlementAmount" = p_InstAmount,
                    "HREPFST_OwnClosingBalance" = v_ClosingBalance, "HREPFST_InstituteClosingBalance" = v_INST_ClosingBalance 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;

                INSERT INTO "HR_Employee_PF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFW_OwnAmount","HREPFW_InstituteAmount","HREPFW_Date","HREPFW_Flag","HREPFW_Remarks","HREPFW_ActiveFlg",
                "HREPFW_CreatedDate","HREPFW_UpdatedDate","HREPFW_CreatedBy","HREPFW_UpdatedBy")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,p_OwnAmount,p_InstAmount,p_Headdate,p_HeadType,p_Remarks,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,p_userid,p_userid);
            ELSE
                INSERT INTO "HR_Employee_PF_Status"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFST_OBOwnAmount","HREPFST_OBInstituteAmount","HREPFST_OwnContribution","HREPFST_IntstituteContribution",
                "HREPFST_OwnInterest","HREPFST_InstituteInterest","HREPFST_OwnWithdrwanAmount","HREPFST_InstituteWithdrawnAmount","HREPFST_OwnSettlementAmount","HREPFST_InstituteLSettlementAmount","HREPFST_OwnClosingBalance",
                "HREPFST_InstituteClosingBalance","HREPFST_ActiveFlg","HREPFST_CreatedBy","HREPFST_UpdatedBy","HREPFST_CreatedDate","HREPFST_UpdatedDate","HREPFST_OwnTransferAmount","HREPFST_InstituteTransferAmount","HREPFST_OwnDepositAdjustmentAmount",
                "HREPFST_OwnWithdrawAdjustmentAmount","HREPFST_InstituteDepositAdjustmentAmount","HREPFST_InstituteWithdrawAdjustmentAmount")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,v_HREVPFST_ClosingBalance,v_HREPFST_InstituteClosingBalance,v_OwnContribution,v_Inst_Contribution,v_InterestAmt,v_INST_Interest,0,0,p_OwnAmount,p_InstAmount,v_ClosingBalance,
                v_INST_ClosingBalance,1,p_userid,p_userid,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,(v_YearId || '-' || p_Month_Id || '-' || '12')::TIMESTAMP,0,0,0,0,0,0);

                INSERT INTO "HR_Employee_PF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFW_OwnAmount","HREPFW_InstituteAmount","HREPFW_Date","HREPFW_Flag","HREPFW_Remarks","HREPFW_ActiveFlg",
                "HREPFW_CreatedDate","HREPFW_UpdatedDate","HREPFW_CreatedBy","HREPFW_UpdatedBy")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,p_OwnAmount,p_InstAmount,p_Headdate,p_HeadType,p_Remarks,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,p_userid,p_userid);
            END IF;

        ELSIF (p_HeadType = 'Interest Adjestment') THEN

            v_InterestAmt := ROUND(p_OwnAmount + v_HREVPFST_ClosingBalance * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_ClosingBalance := v_HREVPFST_ClosingBalance - p_OwnAmount;
            v_INST_Interest := ROUND((p_InstAmount + v_HREPFST_InstituteClosingBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_INST_ClosingBalance := v_HREPFST_InstituteClosingBalance - p_InstAmount;

            SELECT COUNT(*) INTO v_count 
            FROM "HR_Employee_PF_Status" 
            WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;

            IF (v_count > 0) THEN
                UPDATE "HR_Employee_PF_Status" 
                SET "HREPFST_OwnWithdrawAdjustmentAmount" = p_OwnAmount, "HREPFST_InstituteWithdrawAdjustmentAmount" = p_InstAmount,
                    "HREPFST_OwnClosingBalance" = v_ClosingBalance, "HREPFST_InstituteClosingBalance" = v_INST_ClosingBalance 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id AND "IMFY_Id" = p_IMFY_Id AND "Month_Id" = p_Month_Id;

                INSERT INTO "HR_Employee_PF_Withdraw"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFW_OwnAmount","HREPFW_InstituteAmount","HREPFW_Date","HREPFW_Flag","HREPFW_Remarks","HREPFW_ActiveFlg",
                "HREPFW_CreatedDate","HREPFW_UpdatedDate","HREPFW_CreatedBy","HREPFW_UpdatedBy")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,p_OwnAmount,p_InstAmount,CURRENT_TIMESTAMP,p_HeadType,p_Remarks,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,p_userid,p_userid);
            ELSE
                INSERT INTO "HR_Employee_PF_Status"("MI_Id","HRME_Id","IMFY_Id","Month_Id","HREPFST_OBOwnAmount","HREPFST_OBInstituteAmount","HREPFST_OwnContribution","HREPFST_IntstituteContribution",
                "HREPFST_OwnInterest","HREPFST_InstituteInterest","HREPFST_OwnWithdrwanAmount","HREPFST_InstituteWithdrawnAmount","HREPFST_OwnSettlementAmount","HREPFST_InstituteLSettlementAmount","HREPFST_OwnClosingBalance",
                "HREPFST_InstituteClosingBalance","HREPFST_ActiveFlg","HREPFST_CreatedBy","HREPFST_UpdatedBy","HREPFST_CreatedDate","HREPFST_UpdatedDate","HREPFST_OwnTransferAmount","HREPFST_InstituteTransferAmount","HREPFST_OwnDepositAdjustmentAmount",
                "HREPFST_OwnWithdrawAdjustmentAmount","HREPFST_InstituteDepositAdjustmentAmount","HREPFST_InstituteWithdrawAdjustmentAmount")
                VALUES(p_MI_Id,p_HRME_Id,p_IMFY_Id,p_Month_Id,v_HREVPFST_ClosingBalance,v_HREPFST_InstituteClosingBalance,v_OwnContribution,v_Inst_Contribution,v_InterestAmt,v_INST_Interest,0,0,0,0,v_ClosingBalance-p