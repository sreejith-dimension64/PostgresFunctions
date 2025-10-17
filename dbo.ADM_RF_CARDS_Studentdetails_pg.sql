CREATE OR REPLACE FUNCTION dbo."ADM_RF_CARDS_Studentdetails"(
    p_AMCTST_IP VARCHAR
)
RETURNS TABLE (
    "AMCTST_Id" BIGINT,
    "AMST_Id" BIGINT,
    "AMCTST_IP" VARCHAR,
    "AMCTST_STATUS" VARCHAR,
    "MI_Id" BIGINT,
    "PDA_amount" NUMERIC,
    "SchoolCollegeFlag" VARCHAR,
    "PDAEH_ID" BIGINT,
    "ASMAY_Id" BIGINT,
    "walletamount" NUMERIC,
    "flag" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_MI_id BIGINT;
    v_flag VARCHAR(10);
BEGIN
    SELECT "MI_Id", "StaffStudFlag" 
    INTO v_MI_id, v_flag 
    FROM dbo."ADM_RF_CARDS" 
    WHERE "AMCTST_IP" = p_AMCTST_IP AND "AMCTST_STATUS" = 'A';

    IF (v_flag = 'S') THEN
        RETURN QUERY
        SELECT 
            a."AMCTST_Id",
            a."AMST_Id",
            a."AMCTST_IP",
            a."AMCTST_STATUS",
            a."MI_Id",
            a."PDA_amount",
            a."SchoolCollegeFlag",
            a."PDAEH_ID",
            a."ASMAY_Id",
            c."CMSTWLT_BalanceAmount" AS walletamount,
            v_flag AS flag
        FROM dbo."ADM_RF_CARDS" a
        INNER JOIN dbo."Adm_M_Student" b ON b."AMST_Id" = a."AMST_Id"
        LEFT JOIN dbo."CM_Student_Wallet" c ON c."ACMST_Id" = a."AMST_Id"
        WHERE a."MI_Id" = v_MI_id 
            AND a."AMCTST_IP" = p_AMCTST_IP 
            AND a."AMCTST_STATUS" = 'A';
            
    ELSIF (v_flag = 'E') THEN
        RETURN QUERY
        SELECT 
            a."AMCTST_Id",
            a."AMST_Id",
            a."AMCTST_IP",
            a."AMCTST_STATUS",
            b."MI_Id",
            a."PDA_amount",
            a."SchoolCollegeFlag",
            a."PDAEH_ID",
            a."ASMAY_Id",
            c."CMSTFWLT_BalanceAmount" AS walletamount,
            v_flag AS flag
        FROM dbo."ADM_RF_CARDS" a
        INNER JOIN dbo."HR_Master_Employee" b ON b."HRME_Id" = a."AMST_Id"
        LEFT JOIN dbo."CM_Staff_Wallet" c ON c."HRME_Id" = a."AMST_Id"
        WHERE a."MI_Id" = v_MI_id 
            AND a."AMCTST_IP" = p_AMCTST_IP 
            AND a."AMCTST_STATUS" = 'A';
    END IF;
    
    RETURN;
END;
$$;