CREATE OR REPLACE FUNCTION "dbo"."CompoffLeaveApproval"(
    p_HRELAP_Id BIGINT,
    p_HRME_Id BIGINT,
    p_HRELAPA_Remarks TEXT,
    p_HRELAPA_InTime VARCHAR(10),
    p_HRELAPA_OutTime VARCHAR(10),
    p_Status VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FinalFlag BOOLEAN;
    v_HRML_Id BIGINT;
    v_LeaveCode VARCHAR(50);
    v_EMPHRMEID BIGINT;
    v_MIID BIGINT;
    v_HRMLY_Id BIGINT;
    v_HRELAP_FromDate TIMESTAMP;
    v_IVRMUL_ID BIGINT;
    v_HRPAON_SanctionLevelNo INT;
    v_HRELS_CreditedLeaves DECIMAL(18,2);
    v_HRELS_TotalLeaves DECIMAL(18,2);
    v_HRELS_CBLeaves DECIMAL(18,2);
    v_FOHTWD_HolidayWDTypeFlag TEXT;
    v_FOHWDT_Id BIGINT;
    v_TimeDifference VARCHAR(50);
    v_punchcout BIGINT;
    v_FOEP_Id BIGINT;
    v_FOEPD_InOutFlg VARCHAR(50);
    v_HOlidayCount BIGINT;
BEGIN

    SELECT "Id" INTO v_IVRMUL_ID 
    FROM "IVRM_Staff_User_Login" 
    WHERE "Emp_Code" = p_HRME_Id;

    SELECT DISTINCT "HRPAON_FinalFlg", "HRPAON_SanctionLevelNo" 
    INTO v_FinalFlag, v_HRPAON_SanctionLevelNo
    FROM "HR_Process_Authorisation" a
    INNER JOIN "HR_Process_Auth_OrderNo" b ON a."HRPA_Id" = b."HRPA_Id"
    INNER JOIN "IVRM_Staff_User_Login" c ON b."IVRMUL_Id" = c."Id"
    WHERE "Emp_Code" = p_HRME_Id AND "HRPA_TypeFlag" = 'compoffODApproval';

    SELECT "HRME_Id" INTO v_EMPHRMEID 
    FROM "HR_Emp_Leave_Application" 
    WHERE "HRELAP_Id" = p_HRELAP_Id;

    SELECT "MI_Id", "HRELAP_FromDate" INTO v_MIID, v_HRELAP_FromDate 
    FROM "HR_Emp_Leave_Application" 
    WHERE "HRELAP_Id" = p_HRELAP_Id;

    SELECT "HRMLY_Id" INTO v_HRMLY_Id 
    FROM "HR_Master_LeaveYear" 
    WHERE "MI_Id" = v_MIID 
        AND CAST("HRMLY_FromDate" AS DATE) <= CURRENT_DATE 
        AND CAST("HRMLY_ToDate" AS DATE) >= CURRENT_DATE;

    IF (p_Status = 'Rejected') THEN
        
        UPDATE "HR_Emp_Leave_Appl_Details" 
        SET "HRELAPD_LeaveStatus" = p_Status 
        WHERE "HRELAP_Id" = p_HRELAP_Id;

        UPDATE "HR_Emp_Leave_Application" 
        SET "HRELAP_ApplicationStatus" = p_Status, 
            "HRELAP_SanctioningLevel" = v_HRPAON_SanctionLevelNo 
        WHERE "HRELAP_Id" = p_HRELAP_Id;

        INSERT INTO "HR_Emp_Leave_Appl_Authorisation"(
            "HRELAP_Id", "HRME_Id", "HRELAPA_SanctioningLevel", "HRELAPA_Remarks", 
            "HRELAPA_FinalFlag", "CreatedDate", "UpdatedDate", "HRELAPA_InTime", 
            "HRELAPA_OutTime", "HRELAPA_LeaveStatus", "IVRMUL_Id")
        VALUES(p_HRELAP_Id, p_HRME_Id, '1', p_HRELAPA_Remarks, '1', 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_HRELAPA_InTime, 
            p_HRELAPA_OutTime, p_Status, v_IVRMUL_ID);

    ELSIF (p_Status = 'Approved') THEN

        IF (v_FinalFlag = TRUE) THEN

            UPDATE "HR_Emp_Leave_Application" 
            SET "HRELAP_ApplicationStatus" = p_Status, 
                "HRELAP_FinalFlag" = 1, 
                "HRELAP_SanctioningLevel" = v_HRPAON_SanctionLevelNo, 
                "UpdatedDate" = CURRENT_TIMESTAMP 
            WHERE "HRELAP_Id" = p_HRELAP_Id;

            UPDATE "HR_Emp_Leave_Appl_Details" 
            SET "HRELAPD_LeaveStatus" = p_Status, 
                "UpdatedDate" = CURRENT_TIMESTAMP 
            WHERE "HRELAP_Id" = p_HRELAP_Id;

            INSERT INTO "HR_Emp_Leave_Appl_Authorisation"(
                "HRELAP_Id", "HRME_Id", "HRELAPA_SanctioningLevel", "HRELAPA_Remarks", 
                "HRELAPA_FinalFlag", "CreatedDate", "UpdatedDate", "HRELAPA_InTime", 
                "HRELAPA_OutTime", "HRELAPA_LeaveStatus", "IVRMUL_Id")
            VALUES(p_HRELAP_Id, p_HRME_Id, '1', p_HRELAPA_Remarks, '1', 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_HRELAPA_InTime, 
                p_HRELAPA_OutTime, p_Status, v_IVRMUL_ID);

            SELECT "HRML_Id" INTO v_HRML_Id 
            FROM "HR_Emp_Leave_Appl_Details" 
            WHERE "HRELAP_Id" = p_HRELAP_Id;

            SELECT "HRML_LeaveCode" INTO v_LeaveCode 
            FROM "HR_Master_Leave" 
            WHERE "HRML_Id" = v_HRML_Id AND "MI_Id" = v_MIID;

            SELECT A."FOHWDT_Id", "FOHTWD_HolidayWDTypeFlag" 
            INTO v_FOHWDT_Id, v_FOHTWD_HolidayWDTypeFlag
            FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
            INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
            WHERE a."MI_Id" = v_MIID 
                AND CAST("FOMHWDD_FromDate" AS DATE) = CAST(v_HRELAP_FromDate AS DATE) 
                AND "HRMLY_Id" = v_HRMLY_Id;

            IF (v_LeaveCode = 'COMPOFF' AND (v_FOHTWD_HolidayWDTypeFlag = 'PH' 
                OR v_FOHTWD_HolidayWDTypeFlag = 'WE' 
                OR v_FOHTWD_HolidayWDTypeFlag = 'WF')) THEN

                v_TimeDifference := (SELECT "dbo"."getonlymin"(p_HRELAPA_OutTime) - 
                    (SELECT "dbo"."getonlymin"(p_HRELAPA_InTime)));

                SELECT COUNT(COALESCE("HRELS_CreditedLeaves", 0)) INTO v_HRELS_CreditedLeaves
                FROM "HR_Emp_Leave_Status"
                WHERE "HRME_Id" = v_EMPHRMEID 
                    AND "HRML_Id" = v_HRML_Id 
                    AND "HRMLY_Id" = v_HRMLY_Id;

                SELECT COALESCE("HRELS_TotalLeaves", 0) INTO v_HRELS_TotalLeaves
                FROM "HR_Emp_Leave_Status"
                WHERE "HRME_Id" = v_EMPHRMEID 
                    AND "HRML_Id" = v_HRML_Id 
                    AND "HRMLY_Id" = v_HRMLY_Id;

                SELECT COALESCE("HRELS_CBLeaves", 0) INTO v_HRELS_CBLeaves
                FROM "HR_Emp_Leave_Status"
                WHERE "HRME_Id" = v_EMPHRMEID 
                    AND "HRML_Id" = v_HRML_Id 
                    AND "HRMLY_Id" = v_HRMLY_Id;

                IF (v_TimeDifference::INT >= 180 AND v_TimeDifference::INT <= 360) THEN

                    IF (v_HRELS_CreditedLeaves > 0) THEN

                        UPDATE "HR_Emp_Leave_Status" 
                        SET "HRELS_CreditedLeaves" = v_HRELS_CreditedLeaves + 0.5,
                            "HRELS_TotalLeaves" = v_HRELS_TotalLeaves + 0.5,
                            "HRELS_CBLeaves" = v_HRELS_CBLeaves + 0.5
                        WHERE "HRME_Id" = v_EMPHRMEID 
                            AND "HRML_Id" = v_HRML_Id 
                            AND "HRMLY_Id" = v_HRMLY_Id;

                    ELSE

                        INSERT INTO "HR_Emp_Leave_Status"(
                            "MI_Id", "HRME_Id", "HRML_Id", "HRMLY_Id", "HRELS_OBLeaves", 
                            "HRELS_CreditedLeaves", "HRELS_TotalLeaves", "HRELS_TransLeaves", 
                            "HRELS_EncashedLeaves", "HRELS_CBLeaves", "CreatedDate", 
                            "UpdatedDate", "HRELS_CreatedBy", "HRELS_UpdatedBy")
                        VALUES(v_MIID, v_EMPHRMEID, v_HRML_Id, v_HRMLY_Id, 0.5, 0.5, 
                            0.5, 0.5, 0.5, 0.5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                            p_HRME_Id, p_HRME_Id);

                    END IF;

                ELSIF (v_TimeDifference::INT > 360) THEN

                    IF (v_HRELS_CreditedLeaves > 0) THEN

                        UPDATE "HR_Emp_Leave_Status" 
                        SET "HRELS_CreditedLeaves" = v_HRELS_CreditedLeaves + 1,
                            "HRELS_TotalLeaves" = v_HRELS_TotalLeaves + 1,
                            "HRELS_CBLeaves" = v_HRELS_CBLeaves + 1
                        WHERE "HRME_Id" = v_EMPHRMEID 
                            AND "HRML_Id" = v_HRML_Id 
                            AND "HRMLY_Id" = v_HRMLY_Id;

                    ELSE

                        INSERT INTO "HR_Emp_Leave_Status"(
                            "MI_Id", "HRME_Id", "HRML_Id", "HRMLY_Id", "HRELS_OBLeaves", 
                            "HRELS_CreditedLeaves", "HRELS_TotalLeaves", "HRELS_TransLeaves", 
                            "HRELS_EncashedLeaves", "HRELS_CBLeaves", "CreatedDate", 
                            "UpdatedDate", "HRELS_CreatedBy", "HRELS_UpdatedBy")
                        VALUES(v_MIID, v_EMPHRMEID, v_HRML_Id, v_HRMLY_Id, 1, 1, 
                            1, 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                            p_HRME_Id, p_HRME_Id);

                    END IF;

                ELSE
                    RAISE NOTICE 'Compoff cannot be applied';
                END IF;

            ELSIF (v_LeaveCode = 'OD') THEN

                SELECT COUNT(*) INTO v_punchcout
                FROM "fo"."FO_Emp_Punch" 
                WHERE "HRME_Id" = v_EMPHRMEID 
                    AND CAST("FOEP_PunchDate" AS DATE) = v_HRELAP_FromDate;

                IF (v_punchcout = 0) THEN

                    SELECT COUNT(*) INTO v_HOlidayCount
                    FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."MI_Id" = v_MIID 
                        AND CAST("FOMHWDD_FromDate" AS DATE) = v_HRELAP_FromDate 
                        AND "FOMHWD_ActiveFlg" = 1;

                    IF (v_HOlidayCount > 0) THEN

                        INSERT INTO "fo"."FO_Emp_Punch" (
                            "MI_Id", "HRME_Id", "FOEP_PunchDate", "FOEP_HolidayPunchFlg", 
                            "FOEP_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_EMPHRMEID, v_HRELAP_FromDate, 1, 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        SELECT "FOEP_Id" INTO v_FOEP_Id 
                        FROM "fo"."FO_Emp_Punch" 
                        WHERE "HRME_Id" = v_EMPHRMEID 
                            AND "MI_Id" = v_MIID 
                            AND CAST("FOEP_PunchDate" AS DATE) = v_HRELAP_FromDate;

                        INSERT INTO "fo"."FO_Emp_Punch_Details" (
                            "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                            "FOEPD_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_FOEP_Id, p_HRELAPA_InTime, 'I', 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        INSERT INTO "fo"."FO_Emp_Punch_Details" (
                            "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                            "FOEPD_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_FOEP_Id, p_HRELAPA_OutTime, 'O', 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    ELSE

                        INSERT INTO "fo"."FO_Emp_Punch" (
                            "MI_Id", "HRME_Id", "FOEP_PunchDate", "FOEP_HolidayPunchFlg", 
                            "FOEP_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_EMPHRMEID, v_HRELAP_FromDate, 0, 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        SELECT "FOEP_Id" INTO v_FOEP_Id 
                        FROM "fo"."FO_Emp_Punch" 
                        WHERE "HRME_Id" = v_EMPHRMEID 
                            AND "MI_Id" = v_MIID 
                            AND CAST("FOEP_PunchDate" AS DATE) = v_HRELAP_FromDate;

                        INSERT INTO "fo"."FO_Emp_Punch_Details" (
                            "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                            "FOEPD_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_FOEP_Id, p_HRELAPA_InTime, 'I', 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        INSERT INTO "fo"."FO_Emp_Punch_Details" (
                            "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                            "FOEPD_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_FOEP_Id, p_HRELAPA_OutTime, 'O', 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    END IF;

                ELSIF (v_punchcout > 0) THEN

                    SELECT "FOEP_Id" INTO v_FOEP_Id 
                    FROM "fo"."FO_Emp_Punch" 
                    WHERE "HRME_Id" = v_EMPHRMEID 
                        AND "MI_Id" = v_MIID 
                        AND CAST("FOEP_PunchDate" AS DATE) = v_HRELAP_FromDate;

                    SELECT "FOEPD_InOutFlg" INTO v_FOEPD_InOutFlg 
                    FROM "fo"."FO_Emp_Punch_Details" 
                    WHERE "FOEP_Id" = v_FOEP_Id;

                    IF (v_FOEPD_InOutFlg = 'I') THEN

                        INSERT INTO "fo"."FO_Emp_Punch_Details" (
                            "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                            "FOEPD_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_FOEP_Id, p_HRELAPA_OutTime, 'O', 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    ELSIF (v_FOEPD_InOutFlg = 'O') THEN

                        INSERT INTO "fo"."FO_Emp_Punch_Details" (
                            "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                            "FOEPD_Flag", "CreatedDate", "UpdatedDate")
                        VALUES(v_MIID, v_FOEP_Id, p_HRELAPA_InTime, 'I', 1, 
                            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                    END IF;

                END IF;

            END IF;

        ELSE

            UPDATE "HR_Emp_Leave_Appl_Details" 
            SET "HRELAPD_LeaveStatus" = 'Partial Approved' 
            WHERE "HRELAP_Id" = p_HRELAP_Id;

            UPDATE "HR_Emp_Leave_Application" 
            SET "HRELAP_ApplicationStatus" = 'Partial Approved',
                "HRELAP_SanctioningLevel" = v_HRPAON_SanctionLevelNo 
            WHERE "HRELAP_Id" = p_HRELAP_Id;

            INSERT INTO "HR_Emp_Leave_Appl_Authorisation"(
                "HRELAP_Id", "HRME_Id", "HRELAPA_SanctioningLevel", "HRELAPA_Remarks", 
                "HRELAPA_FinalFlag", "CreatedDate", "UpdatedDate", "HRELAPA_InTime", 
                "HRELAPA_OutTime", "HRELAPA_LeaveStatus", "IVRMUL_Id")
            VALUES(p_HRELAP_Id, p_HRME_Id, '1', p_HRELAPA_Remarks, '1', 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_HRELAPA_InTime, 
                p_HRELAPA_OutTime, p_Status, v_IVRMUL_ID);

        END IF;

    END IF;

    RETURN;

END;
$$;