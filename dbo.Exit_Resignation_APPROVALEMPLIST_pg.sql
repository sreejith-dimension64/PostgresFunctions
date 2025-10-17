CREATE OR REPLACE FUNCTION "dbo"."Exit_Resignation_APPROVALEMPLIST"(
    p_User_Id bigint
)
RETURNS TABLE(
    "ismresG_Id" varchar,
    "ismresG_ResignationDate" varchar,
    "hrmE_Id" varchar,
    "employeename1" varchar
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
    v_ISMRESG_Id bigint;
    v_Preuserid bigint;
    v_hrmeid bigint;
    v_HRME_IdRApply varchar;
    v_ISMRESG_Id2 varchar;
    v_HRME_IdRApply2 varchar;
    v_rec RECORD;
    v_rec1 RECORD;
BEGIN

    SELECT "Emp_Code" INTO v_hrmeid 
    FROM "IVRM_Staff_User_Login" 
    WHERE "Id" = p_User_Id;

    DROP TABLE IF EXISTS "Exit_resignation_approval_temp";

    CREATE TEMP TABLE "Exit_resignation_approval_temp"(
        "ismresG_Id" varchar,
        "ismresG_ResignationDate" varchar,
        "hrmE_Id" varchar,
        "HRME_EmployeeFirstname" varchar,
        "HRME_EmployeeMiddlename" varchar,
        "HRME_EmployeeLastname" varchar
    );

    v_Rcount1 := 0;

    SELECT count(*) INTO v_Rcount1 
    FROM "HR_Process_Authorisation" PA
    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
    WHERE "HRPA_TypeFlag" = 'ExitResignation' AND "IVRMUL_Id" = p_User_Id;

    v_SanctionLevelNo := 0;
    v_MaxSanctionLevelNo := 0;
    v_Preuserid := 0;

    SELECT Max("HRPAON_SanctionLevelNo") INTO v_MaxSanctionLevelNo
    FROM "HR_Process_Authorisation" PA
    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
    WHERE "HRPA_TypeFlag" = 'ExitResignation';

    SELECT "HRPAON_SanctionLevelNo" INTO v_SanctionLevelNo
    FROM "HR_Process_Authorisation" PA
    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
    WHERE "HRPA_TypeFlag" = 'ExitResignation' AND "IVRMUL_Id" = p_User_Id;

    FOR v_rec IN 
        SELECT DISTINCT "HRME_ID", "ISMRESG_Id" 
        FROM "ISM_Resignation" 
        WHERE "ISMRESG_MgmtApprRejFlg" = 'Pending' 
        AND "ISMRESG_Flg" = 'Resignation' 
        AND "ISMRESG_ActiveFlag" = 1
    LOOP
        v_HRME_IdRApply := v_rec."HRME_ID";
        v_ISMRESG_Id := v_rec."ISMRESG_Id";

        IF (v_SanctionLevelNo = 1) THEN

            v_Rcount := 0;

            SELECT Count(*) INTO v_Rcount 
            FROM "ISM_Resignation_ApprovedBy" 
            WHERE "ISMRESGAB_CreatedBy" = p_User_Id 
            AND "ISMRESG_Id" = v_ISMRESG_Id;

            IF (v_Rcount = 0) THEN

                INSERT INTO "Exit_resignation_approval_temp"
                ("ismresG_Id", "ismresG_ResignationDate", "hrmE_Id", "HRME_EmployeeFirstname", "HRME_EmployeeMiddlename", "HRME_EmployeeLastname")
                SELECT IR."ISMRESG_Id", IR."ISMRESG_ResignationDate", IR."HRME_Id", 
                       HME."HRME_EmployeeFirstname", HME."HRME_EmployeeMiddlename", HME."HRME_EmployeeLastname"
                FROM "ISM_Resignation" IR 
                INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = IR."HRME_Id"
                WHERE IR."ISMRESG_ActiveFlag" = 1 
                AND HME."HRME_ActiveFlag" = 1 
                AND IR."ISMRESG_MgmtApprRejFlg" = 'Pending' 
                AND "ISMRESG_Flg" = 'Resignation' 
                AND IR."HRME_ID" = v_HRME_IdRApply 
                AND HME."HRME_Id" NOT IN (
                    SELECT DISTINCT COALESCE("HRME_Id", 0) AS "HRME_Id" 
                    FROM "ISM_Resignation_ApprovedBy" 
                    WHERE "ISMRESGAB_CreatedBy" = p_User_Id 
                    AND "ISMRESGAB_ActiveFlag" = 1
                );

            END IF;

        END IF;

    END LOOP;

    IF (v_SanctionLevelNo > 1) THEN

        FOR v_rec1 IN 
            SELECT DISTINCT "ISMRESG_Id" 
            FROM "ISM_Resignation_ApprovedBy" 
            WHERE "HRME_Id" != v_hrmeid 
            AND "ISMRESGAB_AppRejFlg" = 'Approved' 
            AND "ISMRESG_Id" = v_ISMRESG_Id 
            AND "ISMRESGAB_ActiveFlag" = 1
        LOOP
            v_ISMRESG_Id2 := v_rec1."ISMRESG_Id";

            v_Rcount := 0;
            SELECT Count(*) INTO v_Rcount 
            FROM "ISM_Resignation_ApprovedBy" 
            WHERE "ISMRESG_Id" = v_ISMRESG_Id2;

            IF (v_Rcount > 0) AND (v_MaxSanctionLevelNo > v_SanctionLevelNo) THEN

                SELECT DISTINCT "IVRMUL_Id" INTO v_Preuserid
                FROM "HR_Process_Authorisation" PA
                INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id"
                WHERE "HRPA_TypeFlag" = 'ExitResignation' 
                AND "IVRMUL_Id" IN (
                    SELECT DISTINCT "IVRMUL_Id" 
                    FROM "HR_Process_Authorisation" PA 
                    INNER JOIN "HR_Process_Auth_OrderNo" AO ON PA."HRPA_Id" = AO."HRPA_Id" 
                    WHERE "HRPA_TypeFlag" = 'ExitResignation' 
                    AND "HRPAON_SanctionLevelNo" = v_SanctionLevelNo - 1
                );

                INSERT INTO "Exit_resignation_approval_temp"
                ("ismresG_Id", "ismresG_ResignationDate", "hrmE_Id", "HRME_EmployeeFirstname", "HRME_EmployeeMiddlename", "HRME_EmployeeLastname")
                SELECT IR."ISMRESG_Id", IR."ISMRESG_ResignationDate", IR."HRME_Id", 
                       HME."HRME_EmployeeFirstname", HME."HRME_EmployeeMiddlename", HME."HRME_EmployeeLastname"
                FROM "ISM_Resignation" IR 
                INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = IR."HRME_Id"
                INNER JOIN "ISM_Resignation_ApprovedBy" IRA ON IRA."ISMRESG_Id" = IR."ISMRESG_Id"
                WHERE IR."ISMRESG_ActiveFlag" = 1 
                AND "ISMRESG_Flg" = 'Resignation' 
                AND HME."HRME_ActiveFlag" = 1 
                AND IRA."ISMRESGAB_CreatedBy" = v_Preuserid 
                AND IRA."ISMRESGAB_CreatedBy" != p_User_Id;

            END IF;

            v_ApprCount := 0;
            SELECT Count(*) INTO v_ApprCount 
            FROM "ISM_Resignation_ApprovedBy" 
            WHERE "ISMRESG_Id" = v_ISMRESG_Id2;

            v_MaxSanctionLevelNo_New := v_MaxSanctionLevelNo - 1;

        END LOOP;

    END IF;

    RETURN QUERY
    SELECT "Exit_resignation_approval_temp"."ismresG_Id", 
           "Exit_resignation_approval_temp"."ismresG_ResignationDate", 
           "Exit_resignation_approval_temp"."hrmE_Id", 
           CONCAT("HRME_EmployeeFirstname", ' ', "HRME_EmployeeMiddlename", ' ', "HRME_EmployeeLastname") AS "employeename1"
    FROM "Exit_resignation_approval_temp";

    DROP TABLE IF EXISTS "Exit_resignation_approval_temp";

    RETURN;

END;
$$;