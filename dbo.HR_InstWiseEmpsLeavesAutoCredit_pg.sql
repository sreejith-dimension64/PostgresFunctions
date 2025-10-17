CREATE OR REPLACE FUNCTION "dbo"."HR_InstWiseEmpsLeavesAutoCredit"(p_MI_Id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id BIGINT;
    v_LeaveYearRCount INT;
    v_LeaveYearOrder INT;
    v_FromDate TIMESTAMP;
    v_ToDate TIMESTAMP;
    v_HRMLY_Id BIGINT;
    v_PrevHRMLY_Id BIGINT;
    v_EmpLeaveECount INT;
    v_CHRME_Id BIGINT;
    v_CHRMLY_Id BIGINT;
    v_CHRML_Id BIGINT;
    v_CHRML_LeaveCode VARCHAR(100);
    v_CHRELS_OBLeaves DECIMAL(18,2);
    v_CHRELS_CreditedLeaves DECIMAL(18,2);
    v_CHRELS_TotalLeaves DECIMAL(18,2);
    v_CHRELS_TransLeaves DECIMAL(18,2);
    v_CHRELS_CBLeaves DECIMAL(18,2);
    v_ELSRcount INT;
    v_HRME_DOJ DATE;
    emp_record RECORD;
    leave_record RECORD;
BEGIN

    v_HRME_Id := 0;
    v_LeaveYearRCount := 0;

    v_FromDate := TO_TIMESTAMP(CONCAT('01', '-', '01', '-', EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::TEXT), 'DD-MM-YYYY');
    v_ToDate := TO_TIMESTAMP(CONCAT('31', '-', '12', '-', EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::TEXT), 'DD-MM-YYYY');

    FOR emp_record IN
        SELECT "HRME_Id", "HRME_DOJ" 
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = p_MI_Id AND "HRME_ActiveFlag" = TRUE AND "HRME_LeftFlag" = FALSE
    LOOP
        v_HRME_Id := emp_record."HRME_Id";
        v_HRME_DOJ := emp_record."HRME_DOJ";

        v_LeaveYearOrder := 0;
        SELECT COALESCE("HRMLY_LeaveYearOrder", 0) + 1 
        INTO v_LeaveYearOrder
        FROM "HR_Master_LeaveYear" 
        WHERE "MI_Id" = p_MI_Id AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT - 1;

        v_LeaveYearRCount := 0;
        SELECT COUNT(*) 
        INTO v_LeaveYearRCount
        FROM "HR_Master_LeaveYear" 
        WHERE "MI_Id" = p_MI_Id AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;

        IF (v_LeaveYearRCount = 0) THEN
            INSERT INTO "HR_Master_LeaveYear"("MI_Id", "HRMLY_LeaveYear", "HRMLY_FromDate", "HRMLY_ToDate", "HRMLY_ActiveFlag", "CreatedDate", "UpdatedDate", "HRMLY_LeaveYearOrder")
            VALUES(p_MI_Id, EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT, v_FromDate, v_ToDate, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_LeaveYearOrder);
        END IF;

        SELECT "HRMLY_Id" 
        INTO v_HRMLY_Id
        FROM "HR_Master_LeaveYear" 
        WHERE "MI_Id" = p_MI_Id AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;

        SELECT "HRMLY_Id" 
        INTO v_PrevHRMLY_Id
        FROM "HR_Master_LeaveYear" 
        WHERE "MI_Id" = p_MI_Id AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT - 1;

        v_EmpLeaveECount := 0;
        SELECT COUNT(*) 
        INTO v_EmpLeaveECount
        FROM "HR_Emp_Leave_Status" 
        WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = v_HRME_Id AND "HRMLY_Id" = v_PrevHRMLY_Id;

        IF (v_EmpLeaveECount > 0) THEN

            FOR leave_record IN
                SELECT "HRME_Id", "HRMLY_Id", "HML"."HRML_Id", "HRML_LeaveCode", "HRELS_OBLeaves", "HRELS_CreditedLeaves", "HRELS_TotalLeaves", "HRELS_TransLeaves", "HRELS_CBLeaves"
                FROM "HR_Emp_Leave_Status" "HELS"
                INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HELS"."HRML_Id"
                WHERE "HML"."MI_Id" = p_MI_Id AND "HELS"."MI_Id" = p_MI_Id AND "HELS"."HRME_Id" = v_HRME_Id AND "HELS"."HRMLY_Id" = v_PrevHRMLY_Id
                ORDER BY "HRML_LateDeductOrder"
            LOOP
                v_CHRME_Id := leave_record."HRME_Id";
                v_CHRMLY_Id := leave_record."HRMLY_Id";
                v_CHRML_Id := leave_record."HRML_Id";
                v_CHRML_LeaveCode := leave_record."HRML_LeaveCode";
                v_CHRELS_OBLeaves := leave_record."HRELS_OBLeaves";
                v_CHRELS_CreditedLeaves := leave_record."HRELS_CreditedLeaves";
                v_CHRELS_TotalLeaves := leave_record."HRELS_TotalLeaves";
                v_CHRELS_TransLeaves := leave_record."HRELS_TransLeaves";
                v_CHRELS_CBLeaves := leave_record."HRELS_CBLeaves";

                IF v_CHRML_LeaveCode = 'CL' AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) >= 6 THEN
                    v_CHRELS_OBLeaves := v_CHRELS_CBLeaves;
                    v_CHRELS_CreditedLeaves := 10;
                    v_CHRELS_TotalLeaves := v_CHRELS_OBLeaves + v_CHRELS_CreditedLeaves;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := v_CHRELS_OBLeaves + v_CHRELS_CreditedLeaves;
                ELSIF v_CHRML_LeaveCode = 'SL' THEN
                    v_CHRELS_CreditedLeaves := 3;
                    v_CHRELS_TotalLeaves := 3;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := 3;
                ELSIF v_CHRML_LeaveCode = 'EL' THEN
                    v_CHRELS_CreditedLeaves := 2;
                    v_CHRELS_TotalLeaves := 2;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := 2;
                ELSIF v_CHRML_LeaveCode = 'PL' AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) >= 12 THEN
                    v_CHRELS_OBLeaves := v_CHRELS_CBLeaves;
                    v_CHRELS_CreditedLeaves := 15;
                    v_CHRELS_TotalLeaves := v_CHRELS_OBLeaves + v_CHRELS_CreditedLeaves;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := v_CHRELS_OBLeaves + v_CHRELS_CreditedLeaves;
                END IF;

                v_ELSRcount := 0;
                SELECT COUNT(*) 
                INTO v_ELSRcount
                FROM "HR_Emp_Leave_Status" 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = v_CHRME_Id AND "HRML_Id" = v_CHRML_Id AND "HRMLY_Id" = v_HRMLY_Id;

                IF (v_ELSRcount = 0) THEN
                    INSERT INTO "HR_Emp_Leave_Status"("MI_Id", "HRME_Id", "HRML_Id", "HRMLY_Id", "HRELS_OBLeaves", "HRELS_CreditedLeaves", "HRELS_TotalLeaves", "HRELS_TransLeaves", "HRELS_EncashedLeaves", "HRELS_CBLeaves", "CreatedDate", "UpdatedDate")
                    VALUES(p_MI_Id, v_CHRME_Id, v_CHRML_Id, v_HRMLY_Id, v_CHRELS_OBLeaves, v_CHRELS_CreditedLeaves, v_CHRELS_TotalLeaves, v_CHRELS_TransLeaves, 0, v_CHRELS_CBLeaves, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;

            END LOOP;

        ELSE

            FOR leave_record IN
                SELECT v_HRME_Id AS "HRME_Id", 0 AS "HRMLY_Id", "HML"."HRML_Id", "HRML_LeaveCode", 0 AS "HRELS_OBLeaves", 0 AS "HRELS_CreditedLeaves", 0 AS "HRELS_TotalLeaves", 0 AS "HRELS_TransLeaves", 0 AS "HRELS_CBLeaves"
                FROM "HR_Master_Leave" "HML"
                WHERE "HML"."MI_Id" = p_MI_Id
                ORDER BY "HRML_LateDeductOrder"
            LOOP
                v_CHRME_Id := leave_record."HRME_Id";
                v_CHRMLY_Id := leave_record."HRMLY_Id";
                v_CHRML_Id := leave_record."HRML_Id";
                v_CHRML_LeaveCode := leave_record."HRML_LeaveCode";
                v_CHRELS_OBLeaves := leave_record."HRELS_OBLeaves";
                v_CHRELS_CreditedLeaves := leave_record."HRELS_CreditedLeaves";
                v_CHRELS_TotalLeaves := leave_record."HRELS_TotalLeaves";
                v_CHRELS_TransLeaves := leave_record."HRELS_TransLeaves";
                v_CHRELS_CBLeaves := leave_record."HRELS_CBLeaves";

                IF v_CHRML_LeaveCode = 'CL' AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) >= 6 THEN
                    v_CHRELS_CreditedLeaves := 10;
                    v_CHRELS_TotalLeaves := 10;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := 10;
                ELSIF v_CHRML_LeaveCode = 'SL' THEN
                    v_CHRELS_CreditedLeaves := 3;
                    v_CHRELS_TotalLeaves := 3;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := 3;
                ELSIF v_CHRML_LeaveCode = 'EL' THEN
                    v_CHRELS_CreditedLeaves := 2;
                    v_CHRELS_TotalLeaves := 2;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := 2;
                ELSIF v_CHRML_LeaveCode = 'PL' AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) >= 12 THEN
                    v_CHRELS_CreditedLeaves := 15;
                    v_CHRELS_TotalLeaves := 15;
                    v_CHRELS_TransLeaves := 0;
                    v_CHRELS_CBLeaves := 15;
                END IF;

                v_ELSRcount := 0;
                SELECT COUNT(*) 
                INTO v_ELSRcount
                FROM "HR_Emp_Leave_Status" 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = v_CHRME_Id AND "HRML_Id" = v_CHRML_Id AND "HRMLY_Id" = v_HRMLY_Id;

                IF (v_ELSRcount = 0) THEN
                    INSERT INTO "HR_Emp_Leave_Status"("MI_Id", "HRME_Id", "HRML_Id", "HRMLY_Id", "HRELS_OBLeaves", "HRELS_CreditedLeaves", "HRELS_TotalLeaves", "HRELS_TransLeaves", "HRELS_EncashedLeaves", "HRELS_CBLeaves", "CreatedDate", "UpdatedDate")
                    VALUES(p_MI_Id, v_CHRME_Id, v_CHRML_Id, v_HRMLY_Id, v_CHRELS_OBLeaves, v_CHRELS_CreditedLeaves, v_CHRELS_TotalLeaves, v_CHRELS_TransLeaves, 0, v_CHRELS_CBLeaves, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;

            END LOOP;

        END IF;

    END LOOP;

    RETURN;

END;
$$;