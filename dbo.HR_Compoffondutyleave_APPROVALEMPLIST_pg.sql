CREATE OR REPLACE FUNCTION "dbo"."HR_Compoffondutyleave_APPROVALEMPLIST"(p_User_Id bigint)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRELAP_Id" BIGINT,
    "HRELAP_ApplicationID" VARCHAR(100),
    "HRME_EmployeeFirstName" TEXT,
    "HRELAP_ApplicationDate" DATE,
    "HRELAP_ApplicationStatus" TEXT,
    "HRML_LeaveName" TEXT,
    "HRELAPD_InTime" VARCHAR(50),
    "HRELAPD_OutTime" VARCHAR(50),
    "HRELAP_FromDate" DATE,
    "HRELAP_ToDate" DATE,
    "HRELAP_SupportingDocument" TEXT,
    "HRELAP_LeaveReason" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SanctionLevelNo bigint;
    v_Rcount bigint;
    v_Rcount1 bigint;
    v_MaxSanctionLevelNo bigint;
    v_MaxSanctionLevelNo_New bigint;
    v_ApprCount bigint;
    v_HRELAP_Id bigint;
    v_Preuserid bigint;
    v_staffhrmeid bigint;
    v_HRME_IdRApply bigint;
    v_HRELAP_Id2 bigint;
    v_HRME_IdRApply2 TEXT;
    v_AppEmpRcount bigint;
    v_HRMGT_Id bigint;
    v_HRMD_Id bigint;
    v_HRMDES_Id bigint;
    v_HRMG_Id bigint;
    v_Nextlevel TEXT;
    v_Nextcode TEXT;
    v_Nexthrmeid TEXT;
    v_Nexthrname TEXT;
    rec_empids RECORD;
    rec_empids1 RECORD;
    rec_dept RECORD;
BEGIN

    SELECT "Emp_Code" INTO v_staffhrmeid FROM "IVRM_Staff_User_Login" WHERE "Id" = p_User_Id;

    DROP TABLE IF EXISTS "HR_Leavecompoff_onduty_Temp";

    CREATE TEMP TABLE "HR_Leavecompoff_onduty_Temp"(
        "HRME_Id" BIGINT,
        "HRELAP_Id" BIGINT,
        "HRELAP_ApplicationID" VARCHAR(100),
        "HRME_EmployeeFirstName" TEXT,
        "HRME_EmployeeMiddleName" TEXT,
        "HRME_EmployeeLastName" TEXT,
        "HRELAP_ApplicationDate" DATE,
        "HRELAP_ApplicationStatus" TEXT,
        "HRML_LeaveName" TEXT,
        "HRELAPD_InTime" VARCHAR(50),
        "HRELAPD_OutTime" VARCHAR(50),
        "HRELAP_FromDate" DATE,
        "HRELAP_ToDate" DATE,
        "HRELAP_SupportingDocument" TEXT,
        "HRELAP_LeaveReason" TEXT
    );

    v_Rcount1 := 0;

    SELECT COUNT(*) INTO v_Rcount1 
    FROM "HR_Process_Authorisation" PA
    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
    WHERE "HRPA_TypeFlag" = 'compoffODApproval' AND "IVRMUL_Id" = p_User_Id;

    v_SanctionLevelNo := 0;
    v_MaxSanctionLevelNo := 0;
    v_Preuserid := 0;

    SELECT MAX("HRPAON_SanctionLevelNo") INTO v_MaxSanctionLevelNo
    FROM "HR_Process_Authorisation" PA
    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
    WHERE "HRPA_TypeFlag" = 'compoffODApproval';

    FOR rec_dept IN 
        SELECT "HRMGT_Id", "HRMD_Id", "HRMDES_Id", "HRMG_Id", "HRPAON_SanctionLevelNo"
        FROM "HR_Process_Authorisation" PA
        INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
        WHERE "HRPA_TypeFlag" = 'compoffODApproval' AND "IVRMUL_Id" = p_User_Id
    LOOP
        v_HRMGT_Id := rec_dept."HRMGT_Id";
        v_HRMD_Id := rec_dept."HRMD_Id";
        v_HRMDES_Id := rec_dept."HRMDES_Id";
        v_HRMG_Id := rec_dept."HRMG_Id";
        v_SanctionLevelNo := rec_dept."HRPAON_SanctionLevelNo";

        FOR rec_empids IN
            SELECT DISTINCT A."HRME_Id", A."HRELAP_Id" 
            FROM "HR_Emp_Leave_Application" A 
            INNER JOIN "HR_Emp_Leave_Appl_Details" O ON A."HRELAP_Id" = O."HRELAP_Id" 
            INNER JOIN "HR_master_Leave" L ON L."HRML_Id" = O."HRML_Id" 
            WHERE L."HRML_LeaveCode" IN ('COMPOFF', 'OD') 
            AND A."HRELAP_ActiveFlag" = 1 
            AND O."HRELAPD_ActiveFlag" = 1
            AND (A."HRELAP_ApplicationStatus" = 'Requested' OR "HRELAP_ApplicationStatus" = 'Partial Approved')
        LOOP
            v_HRME_IdRApply := rec_empids."HRME_Id";
            v_HRELAP_Id := rec_empids."HRELAP_Id";

            IF (v_SanctionLevelNo = 1) THEN
                v_Rcount := 0;

                SELECT COUNT(*) INTO v_Rcount 
                FROM "HR_Emp_Leave_Appl_Authorisation" 
                WHERE "HRELAP_Id" = v_HRELAP_Id AND "HRME_Id" = v_staffhrmeid;

                IF (v_Rcount = 0) THEN
                    INSERT INTO "HR_Leavecompoff_onduty_Temp"(
                        "HRME_Id", "HRELAP_Id", "HRELAP_ApplicationID", "HRME_EmployeeFirstName", 
                        "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", "HRELAP_ApplicationDate", 
                        "HRELAP_ApplicationStatus", "HRML_LeaveName", "HRELAPD_InTime", "HRELAPD_OutTime", 
                        "HRELAP_FromDate", "HRELAP_ToDate", "HRELAP_SupportingDocument", "HRELAP_LeaveReason"
                    )
                    SELECT DISTINCT A."HRME_Id", A."HRELAP_Id", A."HRELAP_ApplicationID", 
                        D."HRME_EmployeeFirstName", D."HRME_EmployeeMiddleName", D."HRME_EmployeeLastName", 
                        A."HRELAP_ApplicationDate", A."HRELAP_ApplicationStatus", C."HRML_LeaveName", 
                        B."HRELAPD_InTime", B."HRELAPD_OutTime", A."HRELAP_FromDate", A."HRELAP_ToDate", 
                        A."HRELAP_SupportingDocument", A."HRELAP_LeaveReason"
                    FROM "HR_Emp_Leave_Application" A
                    INNER JOIN "HR_Emp_Leave_Appl_Details" B ON A."HRELAP_Id" = B."HRELAP_Id"
                    INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id" 
                        AND D."HRMD_Id" = v_HRMD_Id 
                        AND D."HRMDES_Id" = v_HRMDES_Id 
                        AND D."HRMG_Id" = v_HRMG_Id 
                        AND D."HRMGT_Id" = v_HRMGT_Id
                    INNER JOIN "HR_master_Leave" C ON C."HRML_Id" = B."HRML_Id"
                    WHERE A."HRELAP_Id" = v_HRELAP_Id 
                    AND C."HRML_LeaveCode" IN ('COMPOFF', 'OD') 
                    AND A."HRELAP_ActiveFlag" = 1 
                    AND B."HRELAPD_ActiveFlag" = 1 
                    AND A."HRELAP_ApplicationStatus" = 'Requested'
                    AND A."HRELAP_Id" NOT IN (
                        SELECT DISTINCT COALESCE("HRELAP_Id", 0) "HRELAP_Id" 
                        FROM "HR_Emp_Leave_Appl_Authorisation" 
                        WHERE "HRME_ID" = v_staffhrmeid AND "HRELAP_ActiveFlag" = 1
                    );
                END IF;
            END IF;
        END LOOP;

        IF (v_SanctionLevelNo > 1) THEN
            FOR rec_empids1 IN
                SELECT DISTINCT A."HRELAP_Id" 
                FROM "HR_Emp_Leave_Application" A
                INNER JOIN "HR_Emp_Leave_Appl_Details" B ON A."HRELAP_Id" = B."HRELAP_Id"
                INNER JOIN "HR_Emp_Leave_Appl_Authorisation" C ON C."HRELAP_Id" = A."HRELAP_Id"
                WHERE C."HRELAPA_LeaveStatus" = 'Approved' 
                AND A."HRELAP_ApplicationStatus" NOT IN ('Approved', 'Rejected') 
                AND A."HRELAP_ActiveFlag" = 1 
                AND B."HRELAPD_ActiveFlag" = 1
            LOOP
                v_HRELAP_Id2 := rec_empids1."HRELAP_Id";

                v_Rcount := 0;
                v_AppEmpRcount := 0;

                SELECT COUNT(*) INTO v_Rcount 
                FROM "HR_Emp_Leave_Appl_Authorisation" 
                WHERE "HRELAP_Id" = v_HRELAP_Id2;

                SELECT COUNT(*) INTO v_AppEmpRcount 
                FROM "HR_Emp_Leave_Appl_Authorisation" 
                WHERE "HRELAP_Id" = v_HRELAP_Id2 AND "HRME_Id" = v_staffhrmeid;

                IF (v_Rcount > 0) AND (v_MaxSanctionLevelNo >= v_SanctionLevelNo) AND v_AppEmpRcount = 0 THEN
                    SELECT DISTINCT "IVRMUL_Id" INTO v_Preuserid
                    FROM "HR_Process_Authorisation" PA
                    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id"
                    WHERE "HRPA_TypeFlag" = 'compoffODApproval' 
                    AND "HRPAON_SanctionLevelNo" = v_SanctionLevelNo - 1
                    AND "HRMD_Id" = v_HRMD_Id 
                    AND "HRMDES_Id" = v_HRMDES_Id 
                    AND "HRMG_Id" = v_HRMG_Id 
                    AND "HRMGT_Id" = v_HRMGT_Id;

                    INSERT INTO "HR_Leavecompoff_onduty_Temp"(
                        "HRME_Id", "HRELAP_Id", "HRELAP_ApplicationID", "HRME_EmployeeFirstName", 
                        "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", "HRELAP_ApplicationDate", 
                        "HRELAP_ApplicationStatus", "HRML_LeaveName", "HRELAPD_InTime", "HRELAPD_OutTime", 
                        "HRELAP_FromDate", "HRELAP_ToDate", "HRELAP_SupportingDocument", "HRELAP_LeaveReason"
                    )
                    SELECT DISTINCT A."HRME_Id", A."HRELAP_Id", A."HRELAP_ApplicationID", 
                        D."HRME_EmployeeFirstName", D."HRME_EmployeeMiddleName", D."HRME_EmployeeLastName", 
                        A."HRELAP_ApplicationDate", A."HRELAP_ApplicationStatus", C."HRML_LeaveName", 
                        B."HRELAPD_InTime", B."HRELAPD_OutTime", A."HRELAP_FromDate", A."HRELAP_ToDate", 
                        A."HRELAP_SupportingDocument", A."HRELAP_LeaveReason"
                    FROM "HR_Emp_Leave_Application" A
                    INNER JOIN "HR_Emp_Leave_Appl_Details" B ON A."HRELAP_Id" = B."HRELAP_Id"
                    INNER JOIN "HR_Master_Employee" D ON D."HRME_Id" = A."HRME_Id" 
                        AND D."HRMD_Id" = v_HRMD_Id 
                        AND D."HRMDES_Id" = v_HRMDES_Id 
                        AND D."HRMG_Id" = v_HRMG_Id 
                        AND D."HRMGT_Id" = v_HRMGT_Id
                    INNER JOIN "HR_master_Leave" C ON C."HRML_Id" = B."HRML_Id"
                    INNER JOIN "HR_Emp_Leave_Appl_Authorisation" E ON E."HRELAP_Id" = A."HRELAP_Id"
                    WHERE A."HRELAP_Id" = v_HRELAP_Id2 
                    AND C."HRML_LeaveCode" IN ('COMPOFF', 'OD') 
                    AND A."HRELAP_ActiveFlag" = 1 
                    AND B."HRELAPD_ActiveFlag" = 1 
                    AND D."HRME_ActiveFlag" = 1 
                    AND E."HRELAPA_LeaveStatus" = 'Approved'
                    AND A."HRELAP_ApplicationStatus" != 'Approved' 
                    AND E."IVRMUL_Id" = v_Preuserid 
                    AND E."IVRMUL_Id" != p_User_Id;
                END IF;

                v_ApprCount := 0;
                SELECT COUNT(*) INTO v_ApprCount 
                FROM "HR_Emp_Leave_Appl_Authorisation" 
                WHERE "HRELAP_Id" = v_HRELAP_Id;

                v_MaxSanctionLevelNo_New := v_MaxSanctionLevelNo - 1;
            END LOOP;
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT DISTINCT 
        t."HRME_Id",
        t."HRELAP_Id",
        t."HRELAP_ApplicationID",
        CONCAT(COALESCE(t."HRME_EmployeeFirstName", ''), ' ', COALESCE(t."HRME_EmployeeMiddleName", ''), ' ', COALESCE(t."HRME_EmployeeLastName", ''))::TEXT,
        t."HRELAP_ApplicationDate",
        t."HRELAP_ApplicationStatus",
        t."HRML_LeaveName",
        t."HRELAPD_InTime",
        t."HRELAPD_OutTime",
        t."HRELAP_FromDate",
        t."HRELAP_ToDate",
        t."HRELAP_SupportingDocument",
        t."HRELAP_LeaveReason"
    FROM "HR_Leavecompoff_onduty_Temp" t;

END;
$$;