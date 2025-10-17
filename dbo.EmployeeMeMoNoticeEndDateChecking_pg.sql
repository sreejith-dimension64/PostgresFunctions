CREATE OR REPLACE FUNCTION "dbo"."EmployeeMeMoNoticeEndDateChecking"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ISMEMN_Id" bigint;
    "v_HRME_Id" bigint;
    "v_ISMEMN_CompleByDate" date;
    "v_CurrentDate" date;
    "v_Rcount" int;
    "v_HRMDC_Id" bigint;
    "v_DeptHeadEmp_Id" bigint;
    "v_DeptHeadUser_Id" bigint;
    "v_MI_Id" bigint;
    "v_Rcount1" bigint;
    "rec" RECORD;
BEGIN

    FOR "rec" IN 
        SELECT "ISMEMN_Id", "HRME_Id", "MI_Id", "ISMEMN_CompleByDate"::date AS "ISMEMN_CompleByDate" 
        FROM "ISM_EMPLOYEE_MEMO_NOTICE" 
        WHERE "ISMEMN_Type" = 'Notice' 
        AND "ISMEMN_CompleByDate"::date < CURRENT_DATE
    LOOP
        "v_ISMEMN_Id" := "rec"."ISMEMN_Id";
        "v_HRME_Id" := "rec"."HRME_Id";
        "v_MI_Id" := "rec"."MI_Id";
        "v_ISMEMN_CompleByDate" := "rec"."ISMEMN_CompleByDate";

        "v_CurrentDate" := CURRENT_DATE;

        "v_Rcount" := 0;

        SELECT COUNT(*) INTO "v_Rcount"
        FROM "ISM_Task_Planner" "TP"
        INNER JOIN "ISM_Task_Planner_Tasks" "TPT" ON "TP"."ISMTPL_Id" = "TPT"."ISMTPL_Id"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "ENT" ON "ENT"."ISMTPLTA_Id" = "TPT"."ISMTPLTA_Id"
        WHERE "HRME_Id" = "v_HRME_Id" 
        AND "ISMTPLTA_Status" IN ('In Progress', 'Open', 'ReOpen') 
        AND "ENT"."ISMEMN_Id" = "v_ISMEMN_Id";

        IF ("v_ISMEMN_CompleByDate" < "v_CurrentDate") AND "v_Rcount" <> 0 THEN
            
            "v_HRMDC_Id" := NULL;
            SELECT DISTINCT "HRMDC_Id" INTO "v_HRMDC_Id"
            FROM "HR_Master_Employee" "HME"
            INNER JOIN "HR_Master_Department" "HMD" ON "HME"."HRMD_Id" = "HMD"."HRMD_Id" 
                AND "HMD"."MI_Id" = "HMD"."MI_Id"
            WHERE "HRME_Id" = "v_HRME_Id";

            "v_DeptHeadEmp_Id" := NULL;
            SELECT DISTINCT "HRME_Id" INTO "v_DeptHeadEmp_Id"
            FROM "HR_Master_DepartmentCode_Head" 
            WHERE "HRMDC_Id" = "v_HRMDC_Id";

            "v_DeptHeadUser_Id" := NULL;
            SELECT DISTINCT "id" INTO "v_DeptHeadUser_Id"
            FROM "IVRM_Staff_User_Login" 
            WHERE "Emp_Code" = "v_DeptHeadEmp_Id";

            "v_Rcount1" := 0;
            SELECT COUNT(*) INTO "v_Rcount1"
            FROM "ISM_Block_Employee" 
            WHERE "HRME_Id" = "v_HRME_Id" 
            AND "ISMBE_Reason" = 'Tasks are Pending' 
            AND "ISMBE_BlockFlg" = true 
            AND "ISMBE_ActiveFlg" = true;

            IF "v_Rcount1" = 0 THEN
                INSERT INTO "ISM_Block_Employee" 
                ("MI_Id", "HRME_Id", "ISMBE_BlockDate", "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg", 
                 "CreatedDate", "UpdatedDate", "ISMBE_CreatedBy", "ISMBE_UpdatedBy")
                VALUES("v_Mi_Id", "v_HRME_Id", "v_CurrentDate", 'Tasks are Pending', true, true, 
                       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, "v_DeptHeadUser_Id", "v_DeptHeadUser_Id");
            END IF;

        END IF;

    END LOOP;

    RETURN;

END;
$$;