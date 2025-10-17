CREATE OR REPLACE FUNCTION "dbo"."HR_PF_BlurCalculation"(
    p_HREPFST_Id bigint,
    p_HREPFST_OBOwnAmount decimal(18,2),
    p_HHREPFST_OBInstituteAmount decimal(18,2),
    p_HREPFST_OwnWithdrwanAmount decimal(18,2),
    p_HREPFST_InstituteWithdrawnAmount decimal(18,2),
    p_HREPFST_OwnSettlementAmount decimal(18,2),
    p_HREPFST_InstituteLSettlementAmount decimal(18,2),
    p_HREPFST_OwnTransferAmount decimal(18,2),
    p_HREPFST_InstituteTransferAmount decimal(18,2),
    p_HREPFST_OwnDepositAdjustmentAmount decimal(18,2),
    p_HREPFST_InstituteDepositAdjustmentAmount decimal(18,2),
    p_HREPFST_OwnWithdrawAdjustmentAmount decimal(18,2),
    p_HREPFST_InstituteWithdrawAdjustmentAmount decimal(18,2),
    p_Headdate date
)
RETURNS TABLE(
    "HREPFST_Id" bigint,
    "HRME_Id" bigint,
    "IMFY_Id" bigint,
    "IVRM_Month_Name" text,
    "HREPFST_OBOwnAmount" decimal(18,2),
    "HREPFST_OBInstituteAmount" decimal(18,2),
    "HREPFST_OwnContribution" decimal(18,2),
    "HREPFST_IntstituteContribution" decimal(18,2),
    "HREPFST_OwnWithdrwanAmount" decimal(18,2),
    "HREPFST_InstituteWithdrawnAmount" decimal(18,2),
    "HREPFST_OwnSettlementAmount" decimal(18,2),
    "HREPFST_InstituteLSettlementAmount" decimal(18,2),
    "HREPFST_OwnTransferAmount" decimal(18,2),
    "HREPFST_InstituteTransferAmount" decimal(18,2),
    "HREPFST_OwnDepositAdjustmentAmount" decimal(18,2),
    "HREPFST_InstituteDepositAdjustmentAmount" decimal(18,2),
    "HREPFST_OwnWithdrawAdjustmentAmount" decimal(18,2),
    "HREPFST_InstituteWithdrawAdjustmentAmount" decimal(18,2),
    "HREPFST_OwnClosingBalance" decimal(18,2),
    "HREPFST_InstituteClosingBalance" decimal(18,2),
    "HREPFST_OwnInterest" decimal(18,2),
    "HREPFST_InstituteInterest" decimal(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HREPFST_OBInstituteAmount decimal(18,2);
    v_MI_Id bigint;
    v_IMFY_Id bigint;
    v_HRME_Id bigint;
    v_TranctionID bigint;
    v_Month_Id bigint;
    v_HRMPFVPFINT_PFInterestRate decimal(18,2);
    v_HREPFST_IntstituteContribution decimal(18,2);
    v_NextOpeningbalance decimal(18,2);
    v_NextInstitutionOpeningbalance decimal(18,2);
    v_MonthId bigint;
    v_YearId bigint;
    v_HREPFST_OwnClosingBalance decimal(18,2);
    v_HREPFST_InstituteClosingBalance decimal(18,2);
    v_HREPFST_OwnContribution decimal(18,2);
    v_INST_Interest decimal(18,2);
    v_IVRM_Month_Name text;
    v_SUMAMOUNT decimal(18,2);
    v_HRME_FPFNotApplicableFlg boolean;
    v_INST_PF decimal(18,2);
    v_Inst_Contribution decimal(18,2);
    v_HREPFST_InstituteOpeningBalance decimal(18,2);
    v_Openingbalance decimal(18,2);
    v_InstituteOpeningbalance decimal(18,2);
    v_Contribution decimal(18,2);
    v_InstituteContribution decimal(18,2);
    v_WithdrawnAmount decimal(18,2);
    v_InstituteWithdrawnAmount decimal(18,2);
    v_SettledAmount decimal(18,2);
    v_InstituteSettledAmount decimal(18,2);
    v_TransferAmount decimal(18,2);
    v_InstituteTransferAmount decimal(18,2);
    v_InstituteDepositAdjustmentAmount decimal(18,2);
    v_WithsrawAdjustmentAmount decimal(18,2);
    v_InstituteWithsrawAdjustmentAmount decimal(18,2);
    v_Instituteclosingbalance decimal(18,2);
    v_InterestAmt decimal(18,2);
    v_DepositAdjustmentAmount decimal(18,2);
    v_ClosingBalance decimal(18,2);
    v_InstitutionClosingBalance decimal(18,2);
    rec RECORD;
BEGIN

    SELECT a."IMFY_Id", a."HRME_Id", b."HRME_FPFNotApplicableFlg"
    INTO v_IMFY_Id, v_HRME_Id, v_HRME_FPFNotApplicableFlg
    FROM "HR_Employee_PF_Status_Edit" a
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    WHERE "HREPFST_Id" = p_HREPFST_Id;

    v_NextOpeningbalance := 0;
    v_NextInstitutionOpeningbalance := 0;
    v_Openingbalance := 0;
    v_InstituteOpeningbalance := 0;
    v_HREPFST_OwnClosingBalance := 0;
    v_HREPFST_InstituteClosingBalance := 0;
    v_HREPFST_OwnContribution := 0;
    v_HREPFST_IntstituteContribution := 0;
    v_HRMPFVPFINT_PFInterestRate := 0;

    FOR rec IN
        SELECT "HREPFST_Id", "IVRM_Month_Name", "IMFY_Id", "HREPFST_OBOwnAmount", "HREPFST_OBInstituteAmount",
               "HREPFST_OwnContribution", "HREPFST_IntstituteContribution", "HREPFST_OwnWithdrwanAmount",
               "HREPFST_InstituteWithdrawnAmount", "HREPFST_OwnSettlementAmount", "HREPFST_InstituteLSettlementAmount",
               "HREPFST_OwnTransferAmount", "HREPFST_InstituteTransferAmount", "HREPFST_OwnDepositAdjustmentAmount",
               "HREPFST_InstituteDepositAdjustmentAmount", "HREPFST_OwnWithdrawAdjustmentAmount",
               "HREPFST_InstituteWithdrawAdjustmentAmount", "HREPFST_OwnClosingBalance", "HREPFST_InstituteClosingBalance"
        FROM "HR_Employee_PF_Status_Edit"
        WHERE "HRME_Id" = v_HRME_Id AND "IMFY_Id" = v_IMFY_Id AND "HREPFST_Id" >= p_HREPFST_Id
        ORDER BY "HREPFST_Id"
    LOOP
        v_TranctionID := rec."HREPFST_Id";
        v_IVRM_Month_Name := rec."IVRM_Month_Name";
        v_IMFY_Id := rec."IMFY_Id";
        v_Openingbalance := rec."HREPFST_OBOwnAmount";
        v_InstituteOpeningbalance := rec."HREPFST_OBInstituteAmount";
        v_Contribution := rec."HREPFST_OwnContribution";
        v_InstituteContribution := rec."HREPFST_IntstituteContribution";
        v_WithdrawnAmount := rec."HREPFST_OwnWithdrwanAmount";
        v_InstituteWithdrawnAmount := rec."HREPFST_InstituteWithdrawnAmount";
        v_SettledAmount := rec."HREPFST_OwnSettlementAmount";
        v_InstituteSettledAmount := rec."HREPFST_InstituteLSettlementAmount";
        v_TransferAmount := rec."HREPFST_OwnTransferAmount";
        v_InstituteTransferAmount := rec."HREPFST_InstituteTransferAmount";
        v_DepositAdjustmentAmount := rec."HREPFST_OwnDepositAdjustmentAmount";
        v_InstituteDepositAdjustmentAmount := rec."HREPFST_InstituteDepositAdjustmentAmount";
        v_WithsrawAdjustmentAmount := rec."HREPFST_OwnWithdrawAdjustmentAmount";
        v_InstituteWithsrawAdjustmentAmount := rec."HREPFST_InstituteWithdrawAdjustmentAmount";
        v_ClosingBalance := rec."HREPFST_OwnClosingBalance";
        v_Instituteclosingbalance := rec."HREPFST_InstituteClosingBalance";

        SELECT "HRMPFVPFINT_VPFInterestRate"
        INTO v_HRMPFVPFINT_PFInterestRate
        FROM "HR_Master_PFVPF_Interest"
        WHERE "IMFY_Id" = v_IMFY_Id AND "HRMPFVPFINT_ActiveFlg" = true;

        SELECT "IVRM_Month_Id"
        INTO v_MonthId
        FROM "IVRM_Month"
        WHERE "IVRM_Month_Name" = v_IVRM_Month_Name;

        IF (v_MonthId >= 4) THEN
            SELECT EXTRACT(YEAR FROM "IMFY_FromDate")
            INTO v_YearId
            FROM "IVRM_Master_FinancialYear"
            WHERE "IMFY_Id" = v_IMFY_Id;
        ELSE
            SELECT EXTRACT(YEAR FROM "IMFY_ToDate")
            INTO v_YearId
            FROM "IVRM_Master_FinancialYear"
            WHERE "IMFY_Id" = v_IMFY_Id;
        END IF;

        SELECT B."HRESD_Amount"
        INTO v_Contribution
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_ID" = B."HRES_ID"
        INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_ID" = C."HRMED_ID"
        WHERE A."MI_ID" = v_MI_Id AND A."HRME_ID" = v_HRME_Id AND A."HRES_year" = v_YearId
          AND A."HRES_Month" = v_IVRM_Month_Name AND C."HRMED_EDTypeFlag" = 'PF'
          AND C."HRMED_ActiveFlag" = true;

        SELECT DISTINCT SUM(B."HRESD_Amount")
        INTO v_SUMAMOUNT
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
        INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_Id" = C."HRMED_Id"
        WHERE A."MI_Id" = v_MI_Id AND A."HRES_Year" = v_YearId AND A."HRES_Month" = v_IVRM_Month_Name
          AND C."HRMED_EarnDedFlag" = 'Earning' AND A."HRME_Id" = v_HRME_Id;

        IF (COALESCE(v_SUMAMOUNT, 0) < 15000 AND v_HRME_FPFNotApplicableFlg = true) THEN
            v_INST_PF := ROUND(v_SUMAMOUNT * v_HRMPFVPFINT_PFInterestRate / 100, 0);
        ELSIF (v_HRME_FPFNotApplicableFlg = true) THEN
            v_INST_PF := 1250;
        ELSE
            v_INST_PF := 0;
        END IF;

        IF (v_HRME_FPFNotApplicableFlg = false) THEN
            v_Inst_Contribution := v_Contribution;
        ELSE
            v_Inst_Contribution := v_Contribution - v_INST_PF;
        END IF;

        IF (v_TranctionID = p_HREPFST_Id) THEN
            
            IF (p_HREPFST_OwnSettlementAmount > 0 OR p_HREPFST_InstituteLSettlementAmount > 0 OR
                p_HREPFST_OwnWithdrwanAmount > 0 OR p_HREPFST_InstituteWithdrawnAmount > 0) THEN

                IF (EXTRACT(DAY FROM p_Headdate) >= 25) THEN

                    IF (p_HREPFST_OwnSettlementAmount > 0 OR p_HREPFST_InstituteLSettlementAmount > 0) THEN
                        v_InterestAmt := ROUND((p_HREPFST_OBOwnAmount - p_HREPFST_OwnSettlementAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                        v_INST_Interest := ROUND((v_HREPFST_InstituteOpeningBalance - p_HREPFST_InstituteLSettlementAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                    ELSIF (p_HREPFST_OwnWithdrwanAmount > 0 OR p_HREPFST_InstituteWithdrawnAmount > 0) THEN
                        v_InterestAmt := ROUND((p_HREPFST_OBOwnAmount - p_HREPFST_OwnWithdrwanAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                        v_INST_Interest := ROUND((v_HREPFST_InstituteOpeningBalance - p_HREPFST_InstituteWithdrawnAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                    END IF;

                END IF;

            ELSE

                IF (EXTRACT(DAY FROM p_Headdate) < 25) THEN
                    v_InterestAmt := ROUND((p_HREPFST_OBOwnAmount) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                    v_INST_Interest := ROUND((v_HREPFST_InstituteOpeningBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
                END IF;

            END IF;

            v_ClosingBalance := (p_HREPFST_OBOwnAmount + v_Contribution + p_HREPFST_OwnTransferAmount + p_HREPFST_OwnDepositAdjustmentAmount) -
                               (p_HREPFST_OwnWithdrwanAmount + p_HREPFST_OwnSettlementAmount + p_HREPFST_OwnWithdrawAdjustmentAmount);
            v_InstitutionClosingBalance := (p_HHREPFST_OBInstituteAmount + v_Inst_Contribution + p_HREPFST_InstituteTransferAmount + p_HREPFST_InstituteDepositAdjustmentAmount) -
                                          (p_HREPFST_InstituteWithdrawnAmount + p_HREPFST_InstituteLSettlementAmount + p_HREPFST_InstituteWithdrawAdjustmentAmount);

            UPDATE "HR_Employee_PF_Status_Edit"
            SET "HREPFST_OBOwnAmount" = p_HREPFST_OBOwnAmount,
                "HREPFST_OBInstituteAmount" = p_HHREPFST_OBInstituteAmount,
                "HREPFST_OwnContribution" = v_Contribution,
                "HREPFST_IntstituteContribution" = v_InstituteContribution,
                "HREPFST_OwnInterest" = v_InterestAmt,
                "HREPFST_InstituteInterest" = v_INST_Interest,
                "HREPFST_OwnWithdrwanAmount" = p_HREPFST_OwnWithdrwanAmount,
                "HREPFST_InstituteWithdrawnAmount" = p_HREPFST_InstituteWithdrawnAmount,
                "HREPFST_OwnSettlementAmount" = p_HREPFST_OwnSettlementAmount,
                "HREPFST_InstituteLSettlementAmount" = p_HREPFST_InstituteLSettlementAmount,
                "HREPFST_OwnTransferAmount" = p_HREPFST_OwnTransferAmount,
                "HREPFST_InstituteTransferAmount" = p_HREPFST_InstituteTransferAmount,
                "HREPFST_OwnDepositAdjustmentAmount" = p_HREPFST_OwnDepositAdjustmentAmount,
                "HREPFST_InstituteDepositAdjustmentAmount" = p_HREPFST_InstituteDepositAdjustmentAmount,
                "HREPFST_OwnWithdrawAdjustmentAmount" = p_HREPFST_OwnWithdrawAdjustmentAmount,
                "HREPFST_InstituteWithdrawAdjustmentAmount" = p_HREPFST_InstituteWithdrawAdjustmentAmount,
                "HREPFST_OwnClosingBalance" = v_ClosingBalance,
                "HREPFST_InstituteClosingBalance" = v_InstitutionClosingBalance
            WHERE "HREPFST_Id" = p_HREPFST_Id;

            v_NextOpeningbalance := v_ClosingBalance;
            v_NextInstitutionOpeningbalance := v_InstitutionClosingBalance;

        ELSE

            v_InterestAmt := ROUND((v_NextOpeningbalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);
            v_INST_Interest := ROUND((v_NextInstitutionOpeningbalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);

            v_ClosingBalance := (v_NextOpeningbalance + v_Contribution + v_TransferAmount + v_DepositAdjustmentAmount) -
                               (v_WithdrawnAmount + v_SettledAmount + v_WithsrawAdjustmentAmount);
            v_InstitutionClosingBalance := (v_NextInstitutionOpeningbalance + v_Inst_Contribution + v_InstituteTransferAmount + v_InstituteDepositAdjustmentAmount) -
                                          (v_InstituteWithdrawnAmount + v_InstituteSettledAmount + v_InstituteWithsrawAdjustmentAmount);

            UPDATE "HR_Employee_PF_Status_Edit"
            SET "HREPFST_OBOwnAmount" = v_NextOpeningbalance,
                "HREPFST_OBInstituteAmount" = v_NextInstitutionOpeningbalance,
                "HREPFST_OwnContribution" = v_Contribution,
                "HREPFST_IntstituteContribution" = v_Inst_Contribution,
                "HREPFST_OwnInterest" = v_InterestAmt,
                "HREPFST_InstituteInterest" = v_INST_Interest,
                "HREPFST_OwnClosingBalance" = v_ClosingBalance,
                "HREPFST_InstituteClosingBalance" = v_InstitutionClosingBalance
            WHERE "HREPFST_Id" = v_TranctionID;

            v_NextOpeningbalance := v_ClosingBalance;
            v_NextInstitutionOpeningbalance := v_InstitutionClosingBalance;

        END IF;

    END LOOP;

    RETURN QUERY
    SELECT 
        a."HREPFST_Id",
        a."HRME_Id",
        a."IMFY_Id",
        a."IVRM_Month_Name",
        a."HREPFST_OBOwnAmount",
        a."HREPFST_OBInstituteAmount",
        a."HREPFST_OwnContribution",
        a."HREPFST_IntstituteContribution",
        a."HREPFST_OwnWithdrwanAmount",
        a."HREPFST_InstituteWithdrawnAmount",
        a."HREPFST_OwnSettlementAmount",
        a."HREPFST_InstituteLSettlementAmount",
        a."HREPFST_OwnTransferAmount",
        a."HREPFST_InstituteTransferAmount",
        a."HREPFST_OwnDepositAdjustmentAmount",
        a."HREPFST_InstituteDepositAdjustmentAmount",
        a."HREPFST_OwnWithdrawAdjustmentAmount",
        a."HREPFST_InstituteWithdrawAdjustmentAmount",
        a."HREPFST_OwnClosingBalance",
        a."HREPFST_InstituteClosingBalance",
        a."HREPFST_OwnInterest",
        a."HREPFST_InstituteInterest"
    FROM "HR_Employee_PF_Status_Edit" a;

END;
$$;