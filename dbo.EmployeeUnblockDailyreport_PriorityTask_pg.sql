CREATE OR REPLACE FUNCTION "dbo"."EmployeeUnblockDailyreport_PriorityTask"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ISMBE_Id bigint;
    v_CurrentDate date;
    v_Rcount int;
    v_MI_Id bigint;
    emp_cursor CURSOR FOR
        SELECT DISTINCT a."ISMBE_Id" 
        FROM "ISM_Block_Employee" a 
        INNER JOIN "ISM_Block_Employee_Priority" b ON a."ISMBE_Id" = b."ISMBE_Id"
        WHERE a."ISMBE_BlockFlg" = true 
        AND a."ISEBE_UnblockDate" IS NULL;
BEGIN
    FOR v_ISMBE_Id IN 
        SELECT DISTINCT a."ISMBE_Id" 
        FROM "ISM_Block_Employee" a 
        INNER JOIN "ISM_Block_Employee_Priority" b ON a."ISMBE_Id" = b."ISMBE_Id"
        WHERE a."ISMBE_BlockFlg" = true 
        AND a."ISEBE_UnblockDate" IS NULL
    LOOP
        v_CurrentDate := CURRENT_DATE;
        
        v_Rcount := 0;
        
        SELECT COUNT(DISTINCT TC."ISMTCR_Title") INTO v_Rcount
        FROM "ISM_Block_Employee_Priority" TP
        INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id" = TP."ISMTCR_Id"
        INNER JOIN "ISM_TaskCreation_AssignedTo" TA ON TC."ISMTCR_Id" = TC."ISMTCR_Id" 
            AND TA."ISMTCR_Id" = TP."ISMTCR_Id"
        WHERE TC."ISMTCR_Status" IN ('Inprogress','Open','ReOpen','Pending','In progress') 
        AND TP."ISMBE_Id" = v_ISMBE_Id;
        
        IF v_Rcount = 0 THEN
            UPDATE "ISM_Block_Employee" 
            SET "ISMBE_BlockFlg" = false,
                "ISEBE_UnblockDate" = CURRENT_TIMESTAMP,
                "UpdatedDate" = CURRENT_TIMESTAMP 
            WHERE "ISMBE_Id" = v_ISMBE_Id;
        END IF;
        
    END LOOP;
    
    RETURN;
END;
$$;