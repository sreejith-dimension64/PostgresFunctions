CREATE OR REPLACE FUNCTION "dbo"."HR_EMPLEAVE_CARRYFORWARD_DETAILS"(
    p_mi_id bigint,
    p_hrme_id bigint
)
RETURNS TABLE(
    "HRELS_Id" bigint,
    "MI_Id" bigint,
    "HRME_Id" bigint,
    "HRML_Id" bigint,
    "HRMLY_Id" bigint,
    "HRELS_OBLeaves" decimal,
    "HRELS_CreditedLeaves" decimal,
    "HRELS_TotalLeaves" decimal,
    "HRELS_TransLeaves" decimal,
    "HRELS_EncashedLeaves" decimal,
    "HRELS_CBLeaves" decimal,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp,
    "HRELS_CreatedBy" bigint,
    "HRELS_UpdatedBy" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_preHRMLY_Id bigint;
    v_currentleavecount bigint;
    v_HRML_ID bigint;
    v_HRELS_CBLeaves decimal;
    v_HRMLY_Id bigint;
    rec RECORD;
BEGIN

    SELECT "HRMLY_Id" INTO v_HRMLY_Id 
    FROM "HR_Master_LeaveYear" 
    WHERE "MI_Id" = p_mi_id 
    AND "HRMLY_ActiveFlag" = 1 
    AND CURRENT_TIMESTAMP BETWEEN "HRMLY_FromDate" AND "HRMLY_ToDate";

    SELECT COUNT(*) INTO v_currentleavecount 
    FROM "HR_Emp_Leave_Status" 
    WHERE "HRME_Id" = p_hrme_id 
    AND "HRMLY_Id" = v_HRMLY_Id;

    IF v_currentleavecount = 0 THEN
    
        SELECT "HRMLY_Id" INTO v_preHRMLY_Id 
        FROM "HR_Emp_Leave_Status" 
        WHERE "HRME_Id" = p_hrme_id 
        ORDER BY "HRMLY_Id" DESC 
        LIMIT 1;

        FOR rec IN 
            SELECT "HRML_Id", "HRELS_CBLeaves" 
            FROM "HR_Emp_Leave_Status" 
            WHERE "HRMLY_Id" = v_preHRMLY_Id 
            AND "HRME_Id" = p_hrme_id
        LOOP
            v_HRML_ID := rec."HRML_Id";
            v_HRELS_CBLeaves := rec."HRELS_CBLeaves";

            INSERT INTO "HR_Emp_Leave_Status"(
                "MI_Id",
                "HRME_Id",
                "HRML_Id",
                "HRMLY_Id",
                "HRELS_OBLeaves",
                "HRELS_CreditedLeaves",
                "HRELS_TotalLeaves",
                "HRELS_TransLeaves",
                "HRELS_EncashedLeaves",
                "HRELS_CBLeaves",
                "CreatedDate",
                "UpdatedDate",
                "HRELS_CreatedBy",
                "HRELS_UpdatedBy"
            ) VALUES (
                p_mi_id,
                p_hrme_id,
                v_HRML_ID,
                v_HRMLY_Id,
                v_HRELS_CBLeaves,
                v_HRELS_CBLeaves,
                v_HRELS_CBLeaves,
                0,
                0,
                v_HRELS_CBLeaves,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                0,
                0
            );

        END LOOP;

    END IF;

    RETURN QUERY
    SELECT 
        "HRELS_Id",
        "MI_Id",
        "HRME_Id",
        "HRML_Id",
        "HRMLY_Id",
        "HRELS_OBLeaves",
        "HRELS_CreditedLeaves",
        "HRELS_TotalLeaves",
        "HRELS_TransLeaves",
        "HRELS_EncashedLeaves",
        "HRELS_CBLeaves",
        "CreatedDate",
        "UpdatedDate",
        "HRELS_CreatedBy",
        "HRELS_UpdatedBy"
    FROM "HR_Emp_Leave_Status" 
    WHERE "HRME_Id" = p_hrme_id 
    AND "HRMLY_Id" = v_HRMLY_Id;

END;
$$;