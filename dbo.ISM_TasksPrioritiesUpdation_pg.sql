CREATE OR REPLACE FUNCTION "dbo"."ISM_TasksPrioritiesUpdation"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Instid bigint;
    v_HRME_Id bigint;
    v_CYear bigint;
    v_HRMLY_Id bigint;
    v_ISMTCR_Id bigint;
    v_AssignedDate date;
    v_AssignedTime varchar(50);
    v_MajorId bigint;
    v_MajorId_old bigint;
    v_TaskDaysCount int;
    v_CurrentTime varchar(50);
    v_Rcount bigint;
    v_blockid bigint;
    v_duplicate bigint;
    v_HRMPR_Id bigint;
    v_transcount bigint;
    v_CurrentDate date;
    v_blockcheck bigint;
    rec_inst RECORD;
    rec_emp RECORD;
    rec_task_minor RECORD;
    rec_task_major RECORD;
    rec_task_critical RECORD;
BEGIN

    v_CurrentTime := '00:00:00';

    FOR rec_inst IN 
        SELECT DISTINCT "MI_Id" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1
    LOOP
        v_Instid := rec_inst."MI_Id";

        FOR rec_emp IN 
            SELECT DISTINCT "HRME_Id" 
            FROM "HR_Master_Employee" 
            WHERE "MI_Id" = v_Instid 
                AND "HRME_ActiveFlag" = 1 
                AND "HRME_LeftFlag" = 0 
                AND "HRME_ExcDR" = 0
        LOOP
            v_HRME_Id := rec_emp."HRME_Id";

            -------- Minor is converted into Major after 30 days start ---------------------------
            FOR rec_task_minor IN
                SELECT TA."ISMTCR_Id",
                       CAST(TA."ISMTCRASTO_AssignedDate" AS date) AS AssignedDate,
                       CAST(TA."ISMTCRASTO_AssignedDate" AS time(0)) AS AssignedTime,
                       tc."HRMPR_Id"
                FROM "ISM_TaskCreation" TC
                INNER JOIN "ISM_TaskCreation_AssignedTo" TA ON TC."ISMTCR_Id" = TA."ISMTCR_Id"
                INNER JOIN "HR_Master_Priority" MP ON MP."HRMPR_Id" = TC."HRMPR_Id"
                WHERE TA."HRME_Id" = v_HRME_Id 
                    AND TC."ISMTCR_Status" IN ('Inprogress','Open','ReOpen','Pending','In progress') 
                    AND TRIM(MP."HRMP_Name") = TRIM('Minor')
            LOOP
                v_ISMTCR_Id := rec_task_minor."ISMTCR_Id";
                v_AssignedDate := rec_task_minor.AssignedDate;
                v_AssignedTime := rec_task_minor.AssignedTime;
                v_HRMPR_Id := rec_task_minor."HRMPR_Id";

                SELECT COUNT(*) INTO v_transcount 
                FROM "ISM_TaskPriorityStatusChanges_Details" 
                WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "HRMPR_Id_New" = v_HRMPR_Id;
                
                IF v_transcount > 0 THEN
                    SELECT "ISMTPSCD_AssignedToDate" INTO v_AssignedDate 
                    FROM "ISM_TaskPriorityStatusChanges_Details" 
                    WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "HRMPR_Id_New" = v_HRMPR_Id;
                END IF;

                SELECT EXTRACT(YEAR FROM CURRENT_TIMESTAMP) INTO v_CYear;

                SELECT "HRMLY_Id" INTO v_HRMLY_Id 
                FROM "HR_Master_LeaveYear" 
                WHERE "MI_Id" = v_Instid AND "HRMLY_LeaveYear" = v_CYear;
                
                v_TaskDaysCount := 0;

                SELECT COUNT(CAST("FOMHWDD_FromDate" AS date)) INTO v_TaskDaysCount
                FROM "FO"."FO_HolidayWorkingDay_Type" FHT
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" FMHD ON FHT."FOHWDT_Id" = FMHD."FOHWDT_Id"
                WHERE "FOHWDT_ActiveFlg" = 1 
                    AND "FOHTWD_HolidayFlag" = 0 
                    AND FHT."MI_Id" = v_Instid 
                    AND FMHD."MI_Id" = v_Instid 
                    AND "HRMLY_Id" = v_HRMLY_Id
                    AND CAST("FOMHWDD_FromDate" AS date) BETWEEN v_AssignedDate AND CAST(CURRENT_TIMESTAMP AS date);

                IF (v_TaskDaysCount > 30) THEN

                    SELECT MP."HRMPR_Id", TC."HRMPR_Id" INTO v_MajorId, v_MajorId_old 
                    FROM "HR_Master_Priority" MP 
                    INNER JOIN "ISM_TaskCreation" TC ON TC."MI_Id" = MP."MI_Id"
                    WHERE TC."ISMTCR_Id" = v_ISMTCR_Id 
                        AND TRIM(MP."HRMP_Name") = 'Major' 
                        AND MP."HRMP_ActiveFlag" = 1;

                    SELECT COUNT(*) INTO v_duplicate 
                    FROM "ISM_TaskPriorityStatusChanges_Details" 
                    WHERE "ISMTCR_Id" = v_ISMTCR_Id 
                        AND "HRME_Id" = v_HRME_Id 
                        AND "HRMPR_Id_Old" = v_MajorId_old 
                        AND "HRMPR_Id_New" = v_MajorId 
                        AND "ISMTPSCD_CurrentPrStatus" = 'Major';
                    
                    IF v_duplicate = 0 THEN

                        UPDATE "ISM_TaskCreation" SET "HRMPR_Id" = v_MajorId WHERE "ISMTCR_Id" = v_ISMTCR_Id;

                        INSERT INTO "ISM_TaskPriorityStatusChanges_Details"
                            ("MI_Id","ISMTCR_Id","HRME_Id","HRMPR_Id_Old","HRMPR_Id_New","ISMTPSCD_AssignedToDate",
                             "ISMTPSCD_CurrentDate","ISMTPSCD_CurrentPrStatus","CreatedDate","UpdatedDate")
                        VALUES(v_Instid, v_ISMTCR_Id, v_HRME_Id, v_MajorId_old, v_MajorId, v_AssignedDate, 
                               CURRENT_TIMESTAMP, 'Major', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    END IF;

                ELSE

                    v_CurrentTime := CAST(CURRENT_TIMESTAMP AS time(0))::varchar;

                    IF (v_TaskDaysCount = 30) AND (v_AssignedTime = v_CurrentTime) THEN

                        SELECT MP."HRMPR_Id", TC."HRMPR_Id" INTO v_MajorId, v_MajorId_old 
                        FROM "HR_Master_Priority" MP 
                        INNER JOIN "ISM_TaskCreation" TC ON TC."MI_Id" = MP."MI_Id"
                        WHERE TC."ISMTCR_Id" = v_ISMTCR_Id 
                            AND TRIM(MP."HRMP_Name") = 'Major' 
                            AND MP."HRMP_ActiveFlag" = 1;

                        SELECT COUNT(*) INTO v_duplicate 
                        FROM "ISM_TaskPriorityStatusChanges_Details" 
                        WHERE "ISMTCR_Id" = v_ISMTCR_Id 
                            AND "HRME_Id" = v_HRME_Id 
                            AND "HRMPR_Id_Old" = v_MajorId_old 
                            AND "HRMPR_Id_New" = v_MajorId 
                            AND "ISMTPSCD_CurrentPrStatus" = 'Major';
                        
                        IF v_duplicate = 0 THEN

                            UPDATE "ISM_TaskCreation" SET "HRMPR_Id" = v_MajorId WHERE "ISMTCR_Id" = v_ISMTCR_Id;

                            INSERT INTO "ISM_TaskPriorityStatusChanges_Details"
                                ("MI_Id","ISMTCR_Id","HRME_Id","HRMPR_Id_Old","HRMPR_Id_New","ISMTPSCD_AssignedToDate",
                                 "ISMTPSCD_CurrentDate","ISMTPSCD_CurrentPrStatus","CreatedDate","UpdatedDate")
                            VALUES(v_Instid, v_ISMTCR_Id, v_HRME_Id, v_MajorId_old, v_MajorId, v_AssignedDate, 
                                   CURRENT_TIMESTAMP, 'Major', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        END IF;

                    END IF;
                END IF;

            END LOOP;

            -------- Minor is converted into Major after 30 days over ---------------------------

            ----------- Major is convert into critical start ---------------------
            FOR rec_task_major IN
                SELECT TA."ISMTCR_Id",
                       CAST(TA."ISMTCRASTO_AssignedDate" AS date) AS AssignedDate,
                       CAST(TA."ISMTCRASTO_AssignedDate" AS time(0)) AS AssignedTime,
                       tc."HRMPR_Id"
                FROM "ISM_TaskCreation" TC
                INNER JOIN "ISM_TaskCreation_AssignedTo" TA ON TC."ISMTCR_Id" = TA."ISMTCR_Id"
                INNER JOIN "HR_Master_Priority" MP ON MP."HRMPR_Id" = TC."HRMPR_Id"
                WHERE TA."HRME_Id" = v_HRME_Id 
                    AND TC."ISMTCR_Status" IN ('Inprogress','Open','ReOpen','Pending','In progress') 
                    AND TRIM(MP."HRMP_Name") = TRIM('Major')
            LOOP
                v_ISMTCR_Id := rec_task_major."ISMTCR_Id";
                v_AssignedDate := rec_task_major.AssignedDate;
                v_AssignedTime := rec_task_major.AssignedTime;
                v_HRMPR_Id := rec_task_major."HRMPR_Id";

                SELECT COUNT(*) INTO v_transcount 
                FROM "ISM_TaskPriorityStatusChanges_Details" 
                WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "HRMPR_Id_New" = v_HRMPR_Id;
                
                IF v_transcount > 0 THEN
                    SELECT "ISMTPSCD_CurrentDate" INTO v_AssignedDate 
                    FROM "ISM_TaskPriorityStatusChanges_Details" 
                    WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "HRMPR_Id_New" = v_HRMPR_Id;
                END IF;

                SELECT EXTRACT(YEAR FROM CURRENT_TIMESTAMP) INTO v_CYear;

                SELECT "HRMLY_Id" INTO v_HRMLY_Id 
                FROM "HR_Master_LeaveYear" 
                WHERE "MI_Id" = v_Instid AND "HRMLY_LeaveYear" = v_CYear;

                v_TaskDaysCount := 0;

                SELECT COUNT(CAST("FOMHWDD_FromDate" AS date)) INTO v_TaskDaysCount
                FROM "FO"."FO_HolidayWorkingDay_Type" FHT
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" FMHD ON FHT."FOHWDT_Id" = FMHD."FOHWDT_Id"
                WHERE "FOHWDT_ActiveFlg" = 1 
                    AND "FOHTWD_HolidayFlag" = 0 
                    AND FHT."MI_Id" = v_Instid 
                    AND FMHD."MI_Id" = v_Instid 
                    AND "HRMLY_Id" = v_HRMLY_Id
                    AND CAST("FOMHWDD_FromDate" AS date) BETWEEN v_AssignedDate AND CAST(CURRENT_TIMESTAMP AS date);

                IF (v_TaskDaysCount > 15) THEN

                    SELECT MP."HRMPR_Id", TC."HRMPR_Id" INTO v_MajorId, v_MajorId_old 
                    FROM "HR_Master_Priority" MP 
                    INNER JOIN "ISM_TaskCreation" TC ON TC."MI_Id" = MP."MI_Id"
                    WHERE TC."ISMTCR_Id" = v_ISMTCR_Id 
                        AND TRIM(MP."HRMP_Name") = 'critical' 
                        AND MP."HRMP_ActiveFlag" = 1;

                    SELECT COUNT(*) INTO v_duplicate 
                    FROM "ISM_TaskPriorityStatusChanges_Details" 
                    WHERE "ISMTCR_Id" = v_ISMTCR_Id 
                        AND "HRME_Id" = v_HRME_Id 
                        AND "HRMPR_Id_Old" = v_MajorId_old 
                        AND "HRMPR_Id_New" = v_MajorId 
                        AND "ISMTPSCD_CurrentPrStatus" = 'critical';
                    
                    IF v_duplicate = 0 THEN

                        UPDATE "ISM_TaskCreation" SET "HRMPR_Id" = v_MajorId WHERE "ISMTCR_Id" = v_ISMTCR_Id;

                        INSERT INTO "ISM_TaskPriorityStatusChanges_Details"
                            ("MI_Id","ISMTCR_Id","HRME_Id","HRMPR_Id_Old","HRMPR_Id_New","ISMTPSCD_AssignedToDate",
                             "ISMTPSCD_CurrentDate","ISMTPSCD_CurrentPrStatus","CreatedDate","UpdatedDate")
                        VALUES(v_Instid, v_ISMTCR_Id, v_HRME_Id, v_MajorId_old, v_MajorId, v_AssignedDate, 
                               CURRENT_TIMESTAMP, 'critical', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    END IF;

                ELSE

                    v_CurrentTime := CAST(CURRENT_TIMESTAMP AS time(0))::varchar;

                    IF (v_TaskDaysCount = 15) AND (v_AssignedTime = v_CurrentTime) THEN

                        SELECT MP."HRMPR_Id", TC."HRMPR_Id" INTO v_MajorId, v_MajorId_old 
                        FROM "HR_Master_Priority" MP 
                        INNER JOIN "ISM_TaskCreation" TC ON TC."MI_Id" = MP."MI_Id"
                        WHERE TC."ISMTCR_Id" = v_ISMTCR_Id 
                            AND TRIM(MP."HRMP_Name") = 'critical' 
                            AND MP."HRMP_ActiveFlag" = 1;

                        SELECT COUNT(*) INTO v_duplicate 
                        FROM "ISM_TaskPriorityStatusChanges_Details" 
                        WHERE "ISMTCR_Id" = v_ISMTCR_Id 
                            AND "HRME_Id" = v_HRME_Id 
                            AND "HRMPR_Id_Old" = v_MajorId_old 
                            AND "HRMPR_Id_New" = v_MajorId 
                            AND "ISMTPSCD_CurrentPrStatus" = 'critical';
                        
                        IF v_duplicate = 0 THEN

                            UPDATE "ISM_TaskCreation" SET "HRMPR_Id" = v_MajorId WHERE "ISMTCR_Id" = v_ISMTCR_Id;

                            INSERT INTO "ISM_TaskPriorityStatusChanges_Details"
                                ("MI_Id","ISMTCR_Id","HRME_Id","HRMPR_Id_Old","HRMPR_Id_New","ISMTPSCD_AssignedToDate",
                                 "ISMTPSCD_CurrentDate","ISMTPSCD_CurrentPrStatus","CreatedDate","UpdatedDate")
                            VALUES(v_Instid, v_ISMTCR_Id, v_HRME_Id, v_MajorId_old, v_MajorId, v_AssignedDate, 
                                   CURRENT_TIMESTAMP, 'critical', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        END IF;

                    END IF;
                END IF;

            END LOOP;

            -------------------- Major is convert into critical after 15 days ------------------

            ----------- critical is convert into nextlevel start ---------------------
            FOR rec_task_critical IN
                SELECT TA."ISMTCR_Id",
                       CAST(TA."ISMTCRASTO_AssignedDate" AS date) AS AssignedDate,
                       CAST(TA."ISMTCRASTO_AssignedDate" AS time(0)) AS AssignedTime,
                       tc."HRMPR_Id"
                FROM "ISM_TaskCreation" TC
                INNER JOIN "ISM_TaskCreation_AssignedTo" TA ON TC."ISMTCR_Id" = TA."ISMTCR_Id"
                INNER JOIN "HR_Master_Priority" MP ON MP."HRMPR_Id" = TC."HRMPR_Id"
                WHERE TA."HRME_Id" = v_HRME_Id 
                    AND TC."ISMTCR_Status" IN ('Inprogress','Open','ReOpen','Pending','In progress') 
                    AND TRIM(MP."HRMP_Name") = TRIM('Critical')
            LOOP
                v_ISMTCR_Id := rec_task_critical."ISMTCR_Id";
                v_AssignedDate := rec_task_critical.AssignedDate;
                v_AssignedTime := rec_task_critical.AssignedTime;
                v_HRMPR_Id := rec_task_critical."HRMPR_Id";

                SELECT COUNT(*) INTO v_transcount 
                FROM "ISM_TaskPriorityStatusChanges_Details" 
                WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "HRMPR_Id_New" = v_HRMPR_Id;
                
                IF v_transcount > 0 THEN
                    SELECT "ISMTPSCD_CurrentDate" INTO v_AssignedDate 
                    FROM "ISM_TaskPriorityStatusChanges_Details" 
                    WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "HRMPR_Id_New" = v_HRMPR_Id;
                END IF;

                SELECT EXTRACT(YEAR FROM CURRENT_TIMESTAMP) INTO v_CYear;

                SELECT "HRMLY_Id" INTO v_HRMLY_Id 
                FROM "HR_Master_LeaveYear" 
                WHERE "MI_Id" = v_Instid AND "HRMLY_LeaveYear" = v_CYear;

                v_TaskDaysCount := 0;

                SELECT COUNT(CAST("FOMHWDD_FromDate" AS date)) INTO v_TaskDaysCount
                FROM "FO"."FO_HolidayWorkingDay_Type" FHT
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" FMHD ON FHT."FOHWDT_Id" = FMHD."FOHWDT_Id"
                WHERE "FOHWDT_ActiveFlg" = 1 
                    AND "FOHTWD_HolidayFlag" = 0 
                    AND FHT."MI_Id" = v_Instid 
                    AND FMHD."MI_Id" = v_Instid 
                    AND "HRMLY_Id" = v_HRMLY_Id
                    AND CAST("FOMHWDD_FromDate" AS date) BETWEEN v_AssignedDate AND CAST(CURRENT_TIMESTAMP AS date);

                IF (v_TaskDaysCount > 7) THEN

                    SELECT COUNT(*) INTO v_blockcheck 
                    FROM "ISM_Block_Employee_Priority" a 
                    INNER JOIN "ISM_Block_Employee" b ON a."ISMBE_Id" = b."ISMBE_Id"
                    WHERE "ISMTCR_Id" = v_ISMTCR_Id 
                        AND "ISMBE_BlockFlg" = 1 
                        AND "ISEBE_UnblockDate" IS NULL;
                    
                    IF v_blockcheck = 0 THEN

                        v_Rcount := 0;

                        SELECT COUNT(*) INTO v_Rcount 
                        FROM "ISM_Block_Employee" 
                        WHERE "HRME_Id" = v_HRME_Id 
                            AND CAST("ISMBE_BlockDate" AS date) = CAST(CURRENT_TIMESTAMP AS date)
                            AND "ISMBE_Reason" = 'Critical tasks over due - AutoBlock';

                        IF (v_Rcount = 0) THEN

                            v_CurrentDate := CAST(CURRENT_TIMESTAMP AS date);

                            INSERT INTO "ISM_Block_Employee"
                                ("MI_Id","HRME_Id","ISMBE_BlockDate","ISMBE_Reason","ISMBE_BlockFlg","ISMBE_ActiveFlg",
                                 "CreatedDate","UpdatedDate","ISMBE_CreatedBy","ISMBE_UpdatedBy","ISMEMN_ID")
                            VALUES(v_Instid, v_HRME_Id, v_CurrentDate, 'Critical tasks over due - AutoBlock', 1, 1,
                                   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, 0, NULL);

                            SELECT "ISMBE_Id" INTO v_blockid 
                            FROM "ISM_Block_Employee" 
                            WHERE "HRME_Id" = v_HRME_Id 
                                AND CAST("ISMBE_BlockDate" AS date) = CAST(CURRENT_TIMESTAMP AS date)
                                AND "ISMBE_Reason" = 'Critical tasks over due - AutoBlock';

                            SELECT COUNT(*) INTO v_transcount 
                            FROM "ISM_Block_Employee_Priority" 
                            WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "ISMBE_Id" = v_blockid;
                            
                            IF v_transcount = 0 THEN

                                INSERT INTO "ISM_Block_Employee_Priority"
                                    ("ISMBE_Id","ISMTCR_Id","CreatedDate","UpdatedDate")
                                VALUES(v_blockid, v_ISMTCR_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                            END IF;

                        ELSE
                            SELECT "ISMBE_Id" INTO v_blockid 
                            FROM "ISM_Block_Employee" 
                            WHERE "HRME_Id" = v_HRME_Id 
                                AND CAST("ISMBE_BlockDate" AS date) = CAST(CURRENT_TIMESTAMP AS date)
                                AND "ISMBE_Reason" = 'Critical tasks over due - AutoBlock';

                            SELECT COUNT(*) INTO v_transcount 
                            FROM "ISM_Block_Employee_Priority" 
                            WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "ISMBE_Id" = v_blockid;
                            
                            IF v_transcount = 0 THEN

                                INSERT INTO "ISM_Block_Employee_Priority"
                                    ("ISMBE_Id","ISMTCR_Id","CreatedDate","UpdatedDate")
                                VALUES(v_blockid, v_ISMTCR_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                            END IF;
                        END IF;

                    END IF;

                ELSE

                    v_CurrentTime := CAST(CURRENT_TIMESTAMP AS time(0))::varchar;

                    IF (v_TaskDaysCount = 7) AND (v_AssignedTime = v_CurrentTime) THEN

                        SELECT COUNT(*) INTO v_blockcheck 
                        FROM "ISM_Block_Employee_Priority" a 
                        INNER JOIN "ISM_Block_Employee" b ON a."ISMBE_Id" = b."ISMBE_Id"
                        WHERE "ISMTCR_Id" = v_ISMTCR_Id 
                            AND "ISMBE_BlockFlg" = 1 
                            AND "ISEBE_UnblockDate" IS NULL;
                        
                        IF v_blockcheck = 0 THEN

                            v_Rcount := 0;
                            SELECT COUNT(*) INTO v_Rcount 
                            FROM "ISM_Block_Employee" 
                            WHERE "HRME_Id" = v_HRME_Id 
                                AND CAST("ISMBE_BlockDate" AS date) = CAST(CURRENT_TIMESTAMP AS date)
                                AND "ISMBE_Reason" = 'Critical tasks over due - AutoBlock';

                            IF (v_Rcount = 0) THEN
                                v_CurrentDate := CAST(CURRENT_TIMESTAMP AS date);

                                INSERT INTO "ISM_Block_Employee"
                                    ("MI_Id","HRME_Id","ISMBE_BlockDate","ISMBE_Reason","ISMBE_BlockFlg","ISMBE_ActiveFlg",
                                     "CreatedDate","UpdatedDate","ISMBE_CreatedBy","ISMBE_UpdatedBy","ISMEMN_ID")
                                VALUES(v_Instid, v_HRME_Id, v_CurrentDate, 'Critical tasks over due - AutoBlock', 1, 1,
                                       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, 0, NULL);

                                SELECT "ISMBE_Id" INTO v_blockid 
                                FROM "ISM_Block_Employee" 
                                WHERE "HRME_Id" = v_HRME_Id 
                                    AND CAST("ISMBE_BlockDate" AS date) = CAST(CURRENT_TIMESTAMP AS date)
                                    AND "ISMBE_Reason" = 'Critical tasks over due - AutoBlock';

                                SELECT COUNT(*) INTO v_transcount 
                                FROM "ISM_Block_Employee_Priority" 
                                WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "ISMBE_Id" = v_blockid;
                                
                                IF v_transcount = 0 THEN

                                    INSERT INTO "ISM_Block_Employee_Priority"
                                        ("ISMBE_Id","ISMTCR_Id","CreatedDate","UpdatedDate")
                                    VALUES(v_blockid, v_ISMTCR_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                                END IF;

                            ELSE
                                SELECT "ISMBE_Id" INTO v_blockid 
                                FROM "ISM_Block_Employee" 
                                WHERE "HRME_Id" = v_HRME_Id 
                                    AND CAST("ISMBE_BlockDate" AS date) = CAST(CURRENT_TIMESTAMP AS date)
                                    AND "ISMBE_Reason" = 'Critical tasks over due - AutoBlock';

                                SELECT COUNT(*) INTO v_transcount 
                                FROM "ISM_Block_Employee_Priority" 
                                WHERE "ISMTCR_Id" = v_ISMTCR_Id AND "ISMBE_Id" = v_blockid;
                                
                                IF v_transcount = 0 THEN

                                    INSERT INTO "ISM_Block_Employee_Priority"
                                        ("ISMBE_Id","ISMTCR_Id","CreatedDate","UpdatedDate")
                                    VALUES(v_blockid, v_ISMTCR_Id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                                END IF;

                            END IF;

                        END IF;

                    END IF;

                END IF;

            END LOOP;

        END LOOP;

    END LOOP;

    PERFORM "dbo"."EmployeeUnblockDailyreport_PriorityTask"();

END;
$$;