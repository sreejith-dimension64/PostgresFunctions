CREATE OR REPLACE FUNCTION "dbo"."ISM_GET_PAYMENT_NOTIFICATION_DETAILS"(
    p_IVRM_MI_Id TEXT, 
    p_ISMMCLT_ClientCode TEXT
)
RETURNS TABLE(
    "CLIENTID" BIGINT,
    "ISMMCLTPR_Id" BIGINT,
    "ISMCLTPRP_Year" BIGINT,
    "ISMCLTPRP_InstallmentName" VARCHAR(100),
    "ISMCLTPRP_InstallmentAmt" DECIMAL(18,2),
    "ISMCLTPRP_PaymentDate" TIMESTAMP,
    "FTI_Id" BIGINT,
    "ISMCLTPRP_PaymentStatus" VARCHAR(60),
    "ISMCLTPRP_BalanceAmt" DECIMAL(18,2),
    "ISMCLTPRP_ExcessAmt" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_CLIENTID TEXT;
    v_PROJECTID TEXT;
    v_ISMCPC_RemainderDays BIGINT;
    v_ISMCPC_FullORPartialPayment TEXT;
    v_ActAmt DECIMAL(18,2);
    v_ReceivedAmt DECIMAL(18,2);
    v_PaymentDate DATE;
    v_currentDate DATE;
BEGIN
    
    v_ActAmt := 0;
    v_ReceivedAmt := 0;
    
    SELECT DISTINCT "ISMMCLT_Id" INTO v_CLIENTID 
    FROM "ISM_Master_Client" 
    WHERE "IVRM_MI_Id" = p_IVRM_MI_Id 
    AND "ISMMCLT_ClientCode" = p_ISMMCLT_ClientCode 
    AND "ISMMCLT_ActiveFlag" = 1;
    
    SELECT "ISMCPC_RemainderDays", "ISMCPC_FullORPartialPayment" 
    INTO v_ISMCPC_RemainderDays, v_ISMCPC_FullORPartialPayment
    FROM "ISM_Client_Payment_Configuration"
    LIMIT 1;
    
    DROP TABLE IF EXISTS "TEMP_CLIENTPAYMENTDETAILS_INPROGRESS";
    DROP TABLE IF EXISTS "TEMP_CLIENTPAYMENTDETAILS_STATUS";
    
    CREATE TEMP TABLE "TEMP_CLIENTPAYMENTDETAILS_INPROGRESS"(
        "CLIENTID" BIGINT,
        "ISMMCLTPR_Id" BIGINT,
        "ISMCLTPRP_Year" BIGINT,
        "ISMCLTPRP_InstallmentName" VARCHAR(100),
        "ISMCLTPRP_InstallmentAmt" DECIMAL(18,2),
        "ISMCLTPRP_PaymentDate" TIMESTAMP,
        "FTI_Id" BIGINT,
        "ISMCLTPRP_PaymentStatus" VARCHAR(60),
        "ISMCLTPRP_BalanceAmt" DECIMAL(18,2),
        "ISMCLTPRP_ExcessAmt" DECIMAL(18,2)
    );
    
    CREATE TEMP TABLE "TEMP_CLIENTPAYMENTDETAILS_STATUS"(
        "CLIENTID" BIGINT,
        "ISMMCLTPR_Id" BIGINT,
        "ISMCLTPRP_Year" BIGINT,
        "ISMCLTPRP_InstallmentName" VARCHAR(100),
        "ISMCLTPRP_InstallmentAmt" DECIMAL(18,2),
        "ISMCLTPRP_PaymentDate" TIMESTAMP,
        "FTI_Id" BIGINT,
        "ISMCLTPRP_PaymentStatus" VARCHAR(60),
        "ISMCLTPRP_BalanceAmt" DECIMAL(18,2),
        "ISMCLTPRP_ExcessAmt" DECIMAL(18,2)
    );
    
    v_currentDate := CURRENT_DATE;
    
    SELECT CAST("ISMCLTPRP_PaymentDate" AS DATE) INTO v_PaymentDate
    FROM "ISM_Master_Client_Project" CP
    INNER JOIN "ISM_Client_Project_Payment" CPP ON CP."ISMMCLTPR_Id" = CPP."ISMMCLTPR_Id"
    WHERE "ISMMCLT_Id" = v_CLIENTID::BIGINT 
    AND "ISMCLTPRP_ActiveFlag" = 1 
    AND CPP."ISMCLTPRP_PaymentStatus" = 'In Progress'
    LIMIT 1;
    
    IF (v_currentDate <= v_PaymentDate) AND (v_PaymentDate - v_currentDate) <= v_ISMCPC_RemainderDays THEN
        
        INSERT INTO "TEMP_CLIENTPAYMENTDETAILS_INPROGRESS"(
            "CLIENTID", "ISMMCLTPR_Id", "ISMCLTPRP_Year", "ISMCLTPRP_InstallmentName",
            "ISMCLTPRP_InstallmentAmt", "ISMCLTPRP_PaymentDate", "FTI_Id", 
            "ISMCLTPRP_PaymentStatus", "ISMCLTPRP_BalanceAmt", "ISMCLTPRP_ExcessAmt"
        )
        SELECT v_CLIENTID::BIGINT, CPP."ISMMCLTPR_Id", CPP."ISMCLTPRP_Year", 
               CPP."ISMCLTPRP_InstallmentName", CPP."ISMCLTPRP_InstallmentAmt", 
               CPP."ISMCLTPRP_PaymentDate", CPP."FTI_Id", CPP."ISMCLTPRP_PaymentStatus",
               CPP."ISMCLTPRP_BalanceAmt", CPP."ISMCLTPRP_ExcessAmt"
        FROM "ISM_Master_Client_Project" CP
        INNER JOIN "ISM_Client_Project_Payment" CPP ON CP."ISMMCLTPR_Id" = CPP."ISMMCLTPR_Id"
        WHERE "ISMMCLT_Id" = v_CLIENTID::BIGINT 
        AND "ISMCLTPRP_ActiveFlag" = 1
        AND (CAST(CPP."ISMCLTPRP_PaymentDate" AS DATE) - v_currentDate) <= v_ISMCPC_RemainderDays 
        AND CPP."ISMCLTPRP_PaymentStatus" = 'In Progress';
        
    END IF;
    
    IF (v_currentDate > v_PaymentDate) AND (v_currentDate - v_PaymentDate) > 0 THEN
        
        INSERT INTO "TEMP_CLIENTPAYMENTDETAILS_INPROGRESS"(
            "CLIENTID", "ISMMCLTPR_Id", "ISMCLTPRP_Year", "ISMCLTPRP_InstallmentName",
            "ISMCLTPRP_InstallmentAmt", "ISMCLTPRP_PaymentDate", "FTI_Id", 
            "ISMCLTPRP_PaymentStatus", "ISMCLTPRP_BalanceAmt", "ISMCLTPRP_ExcessAmt"
        )
        SELECT v_CLIENTID::BIGINT, CPP."ISMMCLTPR_Id", CPP."ISMCLTPRP_Year", 
               CPP."ISMCLTPRP_InstallmentName", CPP."ISMCLTPRP_InstallmentAmt", 
               CPP."ISMCLTPRP_PaymentDate", CPP."FTI_Id", CPP."ISMCLTPRP_PaymentStatus",
               CPP."ISMCLTPRP_BalanceAmt", CPP."ISMCLTPRP_ExcessAmt"
        FROM "ISM_Master_Client_Project" CP
        INNER JOIN "ISM_Client_Project_Payment" CPP ON CP."ISMMCLTPR_Id" = CPP."ISMMCLTPR_Id"
        WHERE "ISMMCLT_Id" = v_CLIENTID::BIGINT 
        AND "ISMCLTPRP_ActiveFlag" = 1
        AND (v_currentDate - CAST(CPP."ISMCLTPRP_PaymentDate" AS DATE)) > 0 
        AND CPP."ISMCLTPRP_PaymentStatus" = 'In Progress';
        
    END IF;
    
    IF (v_ISMCPC_FullORPartialPayment = 'Full') THEN
        
        INSERT INTO "TEMP_CLIENTPAYMENTDETAILS_STATUS"(
            "CLIENTID", "ISMMCLTPR_Id", "ISMCLTPRP_Year", "ISMCLTPRP_InstallmentName",
            "ISMCLTPRP_InstallmentAmt", "ISMCLTPRP_PaymentDate", "FTI_Id", 
            "ISMCLTPRP_PaymentStatus", "ISMCLTPRP_BalanceAmt", "ISMCLTPRP_ExcessAmt"
        )
        SELECT v_CLIENTID::BIGINT, CPP."ISMMCLTPR_Id", CPP."ISMCLTPRP_Year", 
               CPP."ISMCLTPRP_InstallmentName", CPP."ISMCLTPRP_InstallmentAmt", 
               CPP."ISMCLTPRP_PaymentDate", CPP."FTI_Id", CPP."ISMCLTPRP_PaymentStatus",
               CPP."ISMCLTPRP_BalanceAmt", CPP."ISMCLTPRP_ExcessAmt"
        FROM "ISM_Master_Client_Project" CP
        INNER JOIN "ISM_Client_Project_Payment" CPP ON CP."ISMMCLTPR_Id" = CPP."ISMMCLTPR_Id"
        WHERE "ISMMCLT_Id" = v_CLIENTID::BIGINT 
        AND "ISMCLTPRP_ActiveFlag" = 1
        AND (CAST((CURRENT_DATE - v_ISMCPC_RemainderDays) AS DATE) <= CAST(CPP."ISMCLTPRP_PaymentDate" AS DATE) 
             OR CURRENT_DATE > CAST(CPP."ISMCLTPRP_PaymentDate" AS DATE))
        AND CPP."ISMCLTPRP_PaymentStatus" LIKE 'Partial Payment%';
        
    END IF;
    
    IF (v_ISMCPC_FullORPartialPayment = 'Full') THEN
        
        RETURN QUERY
        SELECT * FROM "TEMP_CLIENTPAYMENTDETAILS_INPROGRESS"
        UNION
        SELECT * FROM "TEMP_CLIENTPAYMENTDETAILS_STATUS";
        
    ELSE
        
        RETURN QUERY
        SELECT * FROM "TEMP_CLIENTPAYMENTDETAILS_INPROGRESS";
        
    END IF;
    
END;
$$;