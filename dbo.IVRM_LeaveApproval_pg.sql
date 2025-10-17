CREATE OR REPLACE FUNCTION "dbo"."IVRM_LeaveApproval"(
    p_MI_Id bigint,
    p_userid bigint
)
RETURNS TABLE(
    "HRME_EmployeeFirstName" text,
    "HRELAP_Id" bigint,
    "HRML_LeaveName" text,
    "HRELAP_FromDate" timestamp,
    "HRELAP_ToDate" timestamp,
    "HRELAP_TotalDays" decimal(18,2),
    "HRELAP_ReportingDate" timestamp,
    "HRELAP_LeaveReason" text,
    "HRME_Id" bigint,
    "HRML_Id" bigint,
    "HRELAP_ApplicationID" text,
    "HRELAP_SupportingDocument" text,
    "HRELAPA_Remarks" text,
    "HRELAP_ApplicationDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_IdApp1 bigint;
    v_HRME_IdLApply bigint;
    v_Rcount bigint;
    v_MaxLevel bigint;
    v_level bigint;
    v_Remarklevel bigint;
    v_HRELAP_Id bigint;
    v_AppliedName text;
    v_MI_Id bigint;
    v_HRMGT_Id bigint;
    v_HRMD_Id bigint;
    v_HRMDES_Id bigint;
    v_HRMG_Id bigint;
    v_HRML_ID bigint;
    rec_leave RECORD;
    rec_emp RECORD;
    rec_app RECORD;
BEGIN

    v_level := 1;
    v_Remarklevel := 0;

    DROP TABLE IF EXISTS "EmployeeLeaveApprovalLevel_temp";

    CREATE TEMP TABLE "EmployeeLeaveApprovalLevel_temp"(
        "HRME_EmployeeFirstName" text,
        "HRELAP_Id" bigint,
        "HRML_LeaveName" text,
        "HRELAP_FromDate" timestamp,
        "HRELAP_ToDate" timestamp,
        "HRELAP_TotalDays" decimal(18,2),
        "HRELAP_ReportingDate" timestamp,
        "HRELAP_LeaveReason" text,
        "HRME_Id" bigint,
        "HRML_Id" bigint,
        "HRELAP_ApplicationID" text,
        "HRELAP_SupportingDocument" text,
        "HRELAPA_Remarks" text,
        "HRELAP_ApplicationDate" timestamp
    );

    SELECT "Emp_Code" INTO v_HRME_IdApp1 FROM "IVRM_Staff_User_Login" WHERE "Id" = p_userid;

    SELECT MAX("HRLAON_SanctionLevelNo") INTO v_MaxLevel 
    FROM "HR_Leave_Auth_OrderNo" 
    WHERE "IVRMUL_Id" = p_userid;

    FOR rec_leave IN 
        SELECT A."MI_Id", A."HRMGT_Id", A."HRMD_Id", A."HRMDES_Id", A."HRMG_Id", A."HRML_Id" 
        FROM "HR_Leave_Authorisation" A
        INNER JOIN "HR_Leave_Auth_OrderNo" B ON A."HRLA_Id" = B."HRLA_Id" 
        WHERE B."IVRMUL_Id" = p_userid
    LOOP
        v_MI_Id := rec_leave."MI_Id";
        v_HRMGT_Id := rec_leave."HRMGT_Id";
        v_HRMD_Id := rec_leave."HRMD_Id";
        v_HRMDES_Id := rec_leave."HRMDES_Id";
        v_HRMG_Id := rec_leave."HRMG_Id";
        v_HRML_ID := rec_leave."HRML_Id";

        FOR rec_emp IN 
            SELECT DISTINCT A."HRME_Id" 
            FROM "HR_Master_Employee" A
            INNER JOIN "HR_Emp_Leave_Application" B ON A."HRME_Id" = B."HRME_Id"
            INNER JOIN "HR_Emp_Leave_Appl_Details" C ON C."HRML_Id" = v_HRML_ID
            WHERE A."MI_Id" = v_MI_Id 
                AND A."HRMGT_Id" = v_HRMGT_Id 
                AND A."HRMD_Id" = v_HRMD_Id 
                AND A."HRMDES_Id" = v_HRMDES_Id 
                AND A."HRMG_Id" = v_HRMG_Id  
                AND A."HRME_ActiveFlag" = true 
                AND A."HRME_LeftFlag" = false
        LOOP
            v_HRME_IdLApply := rec_emp."HRME_Id";

            RAISE NOTICE 'EmpId:%', v_HRME_IdLApply;

            v_Rcount := 0;

            SELECT COUNT(*) INTO v_Rcount 
            FROM "HR_Emp_Leave_Application" 
            WHERE "HRME_Id" = v_HRME_IdLApply 
                AND ("HRELAP_ApplicationStatus" != 'Approved' AND "HRELAP_ApplicationStatus" != 'Rejected');

            IF v_Rcount <> 0 THEN

                FOR rec_app IN
                    SELECT DISTINCT A."HRELAP_Id" 
                    FROM "HR_Emp_Leave_Application" A
                    INNER JOIN "HR_Emp_Leave_Appl_Details" B ON B."HRELAP_Id" = A."HRELAP_Id"
                    WHERE B."HRML_Id" = v_HRML_ID 
                        AND A."HRELAP_ActiveFlag" = true 
                        AND A."HRME_Id" = v_HRME_IdLApply 
                        AND (A."HRELAP_ApplicationStatus" != 'Approved' AND A."HRELAP_ApplicationStatus" != 'Rejected')
                    ORDER BY A."HRELAP_Id" DESC
                LOOP
                    v_HRELAP_Id := rec_app."HRELAP_Id";

                    WHILE v_MaxLevel >= v_level LOOP

                        IF v_level = 1 THEN

                            RAISE NOTICE '@@HRME_IdLApply: %', v_HRME_IdLApply;
                            RAISE NOTICE '@HRELAP_Id: %', v_HRELAP_Id;
                            RAISE NOTICE '@MaxLevel: %', v_MaxLevel;
                            RAISE NOTICE '@level: %', v_level;

                            v_AppliedName := '';

                            SELECT "HML"."HRML_LeaveName" INTO v_AppliedName
                            FROM "HR_Emp_Leave_Application" "ELA"
                            INNER JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
                            INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "ELAD"."HRML_Id"
                            WHERE "ELA"."HRME_Id" = v_HRME_IdLApply AND "ELA"."HRELAP_Id" = v_HRELAP_Id;

                            RAISE NOTICE 'A';
                            RAISE NOTICE '-------------------';
                            RAISE NOTICE 'HRME_IdLApply: %', v_HRME_IdLApply;
                            RAISE NOTICE 'HRME_IdApplicationId: %', v_HRELAP_Id;
                            RAISE NOTICE 'EmpLeaveAppliedType: %', v_AppliedName;
                            RAISE NOTICE 'HRME_IdApproved EmployeeName: %', p_userid;
                            RAISE NOTICE 'HRLAON_SanctionLevelNo: %', v_level;
                            RAISE NOTICE '@@level; %', v_level;
                            RAISE NOTICE 'HRELAPA_SanctioningLevel: %', v_Remarklevel;
                            RAISE NOTICE '-------------------';

                            INSERT INTO "EmployeeLeaveApprovalLevel_temp"(
                                "HRME_EmployeeFirstName", "HRELAP_Id", "HRML_LeaveName", "HRELAP_FromDate", 
                                "HRELAP_ToDate", "HRELAP_TotalDays", "HRELAP_ReportingDate", "HRELAP_LeaveReason", 
                                "HRME_Id", "HRML_Id", "HRELAP_ApplicationID", "HRELAP_SupportingDocument", 
                                "HRELAP_ApplicationDate"
                            )
                            SELECT DISTINCT 
                                (COALESCE("HRME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeLastName", '')) AS "HRME_EmployeeFirstName",
                                "ELA"."HRELAP_Id", "ML"."HRML_LeaveName", "ELA"."HRELAP_FromDate", 
                                "ELA"."HRELAP_ToDate", "ELA"."HRELAP_TotalDays", "ELA"."HRELAP_ReportingDate", 
                                "ELA"."HRELAP_LeaveReason", "ELA"."HRME_Id", "ML"."HRML_Id",
                                "ELA"."HRELAP_ApplicationID", "ELA"."HRELAP_SupportingDocument", 
                                "ELA"."HRELAP_ApplicationDate"
                            FROM "HR_Emp_Leave_Application" "ELA"
                            INNER JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
                            INNER JOIN "HR_Master_Employee" "HRME" ON "ELA"."HRME_Id" = "HRME"."HRME_Id" AND "HRME"."HRME_Id" = v_HRME_IdLApply
                            INNER JOIN "HR_Emp_Leave_Trans" "LT" ON "LT"."HRME_Id" = "HRME"."HRME_Id" 
                                AND "LT"."HRELT_FromDate" = "ELA"."HRELAP_FromDate" 
                                AND "LT"."HRELT_ToDate" = "ELA"."HRELAP_ToDate" 
                                AND "LT"."HRELT_TotDays" = "ELA"."HRELAP_TotalDays" 
                                AND "LT"."HRELT_Status" = 'Applied' 
                                AND "LT"."HRELT_LeaveId" = "ELAD"."HRML_Id"
                            INNER JOIN "HR_Master_Leave" "ML" ON "ML"."HRML_Id" = "LT"."HRELT_LeaveId" 
                                AND "LT"."HRELT_LeaveId" = "ELAD"."HRML_Id"
                            INNER JOIN "HR_Leave_Auth_OrderNo" "LAO" ON "LAO"."IVRMUL_Id" = p_userid 
                                AND "LAO"."HRLAON_SanctionLevelNo" = v_level
                            INNER JOIN "HR_Leave_Authorisation" "HLA" ON "HLA"."HRLA_Id" = "LAO"."HRLA_Id" 
                                AND "HLA"."HRMGT_Id" = "HRME"."HRMGT_Id" 
                                AND "HLA"."HRMD_Id" = "HRME"."HRMD_Id" 
                                AND "HLA"."HRMDES_Id" = "HRME"."HRMDES_Id" 
                                AND "HLA"."HRMG_Id" = "HRME"."HRMG_Id" 
                                AND "HLA"."HRML_Id" = "ML"."HRML_Id"
                            WHERE "ELA"."HRELAP_ActiveFlag" = true 
                                AND "LT"."HRELT_ActiveFlag" = true 
                                AND "ELA"."HRELAP_Id" = v_HRELAP_Id 
                                AND "ELA"."HRELAP_ApplicationStatus" != 'Approved';

                            v_level := v_level + 1;

                        ELSE

                            v_Remarklevel := v_level - 1;

                            v_AppliedName := '';

                            SELECT "HML"."HRML_LeaveName" INTO v_AppliedName
                            FROM "HR_Emp_Leave_Application" "ELA"
                            INNER JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
                            INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "ELAD"."HRML_Id"
                            WHERE "ELA"."HRME_Id" = v_HRME_IdLApply AND "ELA"."HRELAP_Id" = v_HRELAP_Id;

                            RAISE NOTICE '-------------------';
                            RAISE NOTICE 'HRME_IdLApply: %', v_HRME_IdLApply;
                            RAISE NOTICE 'HRME_IdApplicationId: %', v_HRELAP_Id;
                            RAISE NOTICE 'EmpLeaveAppliedType: %', v_AppliedName;
                            RAISE NOTICE 'HRME_IdApproved EmployeeName: %', p_userid;
                            RAISE NOTICE 'HRLAON_SanctionLevelNo: %', v_level;
                            RAISE NOTICE '@@level; %', v_level;
                            RAISE NOTICE 'HRELAPA_SanctioningLevel: %', v_Remarklevel;
                            RAISE NOTICE '-------------------';

                            INSERT INTO "EmployeeLeaveApprovalLevel_temp"(
                                "HRME_EmployeeFirstName", "HRELAP_Id", "HRML_LeaveName", "HRELAP_FromDate", 
                                "HRELAP_ToDate", "HRELAP_TotalDays", "HRELAP_ReportingDate", "HRELAP_LeaveReason", 
                                "HRME_Id", "HRML_Id", "HRELAP_ApplicationID", "HRELAP_SupportingDocument", 
                                "HRELAPA_Remarks", "HRELAP_ApplicationDate"
                            )
                            SELECT DISTINCT 
                                (COALESCE("HRME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeLastName", '')) AS "HRME_EmployeeFirstName",
                                "ELA"."HRELAP_Id", "ML"."HRML_LeaveName", "ELA"."HRELAP_FromDate", 
                                "ELA"."HRELAP_ToDate", "ELA"."HRELAP_TotalDays", "ELA"."HRELAP_ReportingDate", 
                                "ELA"."HRELAP_LeaveReason", "ELA"."HRME_Id", "ML"."HRML_Id",
                                "ELA"."HRELAP_ApplicationID", "ELA"."HRELAP_SupportingDocument", 
                                "AA"."HRELAPA_Remarks", "ELA"."HRELAP_ApplicationDate"
                            FROM "HR_Emp_Leave_Application" "ELA"
                            INNER JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
                            INNER JOIN "HR_Master_Employee" "HRME" ON "ELA"."HRME_Id" = "HRME"."HRME_Id" AND "HRME"."HRME_Id" = v_HRME_IdLApply
                            INNER JOIN "HR_Emp_Leave_Trans" "LT" ON "LT"."HRME_Id" = "HRME"."HRME_Id" 
                                AND "LT"."HRELT_FromDate" = "ELA"."HRELAP_FromDate" 
                                AND "LT"."HRELT_ToDate" = "ELA"."HRELAP_ToDate" 
                                AND "LT"."HRELT_TotDays" = "ELA"."HRELAP_TotalDays" 
                                AND ("LT"."HRELT_Status" != 'Approved' AND "LT"."HRELT_Status" != 'Rejected') 
                                AND "LT"."HRELT_LeaveId" = "ELAD"."HRML_Id"
                            INNER JOIN "HR_Master_Leave" "ML" ON "ML"."HRML_Id" = "LT"."HRELT_LeaveId"
                            INNER JOIN "HR_Leave_Auth_OrderNo" "LAO" ON "LAO"."IVRMUL_Id" = p_userid 
                                AND "LAO"."HRLAON_SanctionLevelNo" = v_level
                            INNER JOIN "HR_Emp_Leave_Appl_Authorisation" "AA" ON "AA"."HRELAP_Id" = "ELA"."HRELAP_Id" 
                                AND "AA"."HRELAPA_SanctioningLevel" = v_Remarklevel
                            INNER JOIN "HR_Leave_Authorisation" "HLA" ON "HLA"."HRLA_Id" = "LAO"."HRLA_Id" 
                                AND "HLA"."HRMGT_Id" = "HRME"."HRMGT_Id" 
                                AND "HLA"."HRMD_Id" = "HRME"."HRMD_Id" 
                                AND "HLA"."HRMDES_Id" = "HRME"."HRMDES_Id" 
                                AND "HLA"."HRMG_Id" = "HRME"."HRMG_Id" 
                                AND "HLA"."HRML_Id" = "ML"."HRML_Id"
                            WHERE ("AA"."HRME_Id" NOT IN (
                                    SELECT DISTINCT "HRME_Id" 
                                    FROM "HR_Emp_Leave_Appl_Authorisation" 
                                    WHERE "HRME_Id" = p_userid AND "HRELAP_Id" = v_HRELAP_Id
                                )
                                AND "ELA"."HRELAP_Id" NOT IN (
                                    SELECT DISTINCT "HRELAP_Id" 
                                    FROM "HR_Emp_Leave_Appl_Authorisation" 
                                    WHERE "HRME_Id" = p_userid AND "HRELAP_Id" = v_HRELAP_Id
                                )
                                AND "ELA"."HRELAP_ActiveFlag" = true 
                                AND "LT"."HRELT_ActiveFlag" = true 
                                AND "ELA"."HRELAP_Id" = v_HRELAP_Id 
                                AND "ELA"."HRELAP_ApplicationStatus" != 'Approved'
                            );

                            v_level := v_level + 1;

                        END IF;

                    END LOOP;

                    v_level := 1;
                    v_Remarklevel := 0;

                END LOOP;

            END IF;

        END LOOP;

    END LOOP;

    RETURN QUERY 
    SELECT * FROM "EmployeeLeaveApprovalLevel_temp" 
    ORDER BY "HRELAP_ApplicationDate";

END;
$$;