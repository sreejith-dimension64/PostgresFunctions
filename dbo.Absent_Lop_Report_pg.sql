CREATE OR REPLACE FUNCTION "dbo"."Absent_Lop_Report"(@MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    @HRME_Id bigint;
    @HRMLY_Id bigint;
    @Rowcount bigint;
    @HRELT_Id bigint;
    @HRML_Id bigint;
    empids_cursor CURSOR FOR 
        SELECT "HRME_Id" 
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = @MI_Id 
            AND "HRME_ActiveFlag" = 1 
            AND "HRME_LeftFlag" = 0 
            AND "HRME_Id" NOT IN (
                SELECT DISTINCT "HRME_Id" 
                FROM "fo"."FO_Emp_Punch" 
                WHERE "MI_Id" = @MI_Id  
                    AND CAST("FOEP_PunchDate" AS DATE) = CURRENT_DATE
            );
BEGIN

    OPEN empids_cursor;
    
    LOOP
        FETCH NEXT FROM empids_cursor INTO @HRME_Id;
        EXIT WHEN NOT FOUND;
        
        SELECT "HRMLY_Id" INTO @HRMLY_Id
        FROM "HR_Master_LeaveYear" 
        WHERE "MI_Id" = @MI_Id 
            AND CURRENT_TIMESTAMP BETWEEN CAST("HRMLY_FromDate" AS DATE) AND CAST("HRMLY_ToDate" AS DATE)
        LIMIT 1;

        SELECT COUNT(*) INTO @Rowcount
        FROM "HR_Emp_Leave_Trans" 
        WHERE "MI_Id" = @MI_Id 
            AND "HRME_Id" = @HRME_Id 
            AND CAST("HRELT_FromDate" AS DATE) = CURRENT_DATE
            AND CAST("HRELT_ToDate" AS DATE) = CURRENT_DATE
            AND "HRELT_Status" = 'Approved'
            AND "HRMLY_Id" = (
                SELECT "HRMLY_Id" 
                FROM "HR_Master_LeaveYear" 
                WHERE "MI_Id" = @MI_Id 
                    AND CURRENT_TIMESTAMP BETWEEN CAST("HRMLY_FromDate" AS DATE) AND CAST("HRMLY_ToDate" AS DATE)
                LIMIT 1
            );

        IF (COALESCE(@Rowcount, 0) = 0) THEN
        
            INSERT INTO "HR_Emp_Leave_Trans"(
                "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", 
                "HRELT_TotDays", "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", 
                "CreatedDate", "UpdatedDate", "HRELT_ActiveFlag", "HRELT_EntryDate"
            )
            VALUES(
                @MI_Id, @HRME_Id, @HRMLY_Id, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                1, CURRENT_TIMESTAMP + INTERVAL '1 day', 'LWP', 'absent', 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
            );

            SELECT "HRML_Id" INTO @HRML_Id
            FROM "HR_Master_Leave" 
            WHERE "MI_Id" = @MI_Id 
                AND "HRML_LeaveType" = 'LWP'
            LIMIT 1;

            SELECT "HRELT_Id" INTO @HRELT_Id
            FROM "HR_Emp_Leave_Trans" 
            WHERE "MI_Id" = @MI_Id 
                AND "HRME_Id" = @HRME_Id 
                AND CURRENT_DATE BETWEEN CAST("HRELT_FromDate" AS DATE) AND CAST("HRELT_ToDate" AS DATE)
            LIMIT 1;

            INSERT INTO "dbo"."HR_Emp_Leave_Trans_Details"(
                "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", 
                "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
            ) 
            VALUES(
                @HRELT_Id, @HRML_Id, @HRME_Id, @MI_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                1.00, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );

        ELSE
        
            RAISE NOTICE 'Employee leave is approved';

        END IF;

    END LOOP;
    
    CLOSE empids_cursor;

END;
$$;