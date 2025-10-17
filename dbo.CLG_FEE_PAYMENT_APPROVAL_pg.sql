CREATE OR REPLACE FUNCTION "dbo"."CLG_FEE_PAYMENT_APPROVAL"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FromDate varchar(10),
    p_ToDate varchar(10),
    p_User_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_SanctionLevelNo bigint;
    v_Rcount bigint;
    v_Rcount1 bigint;
    v_MaxSanctionLevelNo bigint;
    v_MaxSanctionLevelNo_New bigint;
    v_ApprCount bigint;
    v_HRME_Id bigint;
    v_Preuserid bigint;
    v_FYP_Id bigint;
    v_FYPRCount int;
BEGIN

    v_Rcount1 := 0;

    SELECT count(*) INTO v_Rcount1
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'CLGFEE' AND "IVRMUL_Id" = p_User_Id;

    IF v_Rcount1 > 0 THEN

        v_SanctionLevelNo := 0;
        v_MaxSanctionLevelNo := 0;
        v_Preuserid := 0;

        SELECT Max("HRPAON_SanctionLevelNo") INTO v_MaxSanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'CLGFEE';

        SELECT "HRPAON_SanctionLevelNo" INTO v_SanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'CLGFEE' AND "IVRMUL_Id" = p_User_Id;

        FOR v_FYP_Id IN 
            SELECT DISTINCT "FYP"."FYP_Id"
            FROM "CLG"."Fee_Y_Payment" "FYP"
            INNER JOIN "CLG"."Fee_Y_Payment_College_Student" "CS" ON "CS"."FYP_Id" = "FYP"."FYP_Id"
            INNER JOIN "CLG"."Fee_T_College_Payment" "FTCP" ON "FTCP"."FYP_Id" = "CS"."FYP_Id"
            WHERE "MI_Id" = p_MI_Id 
                AND "FYP"."ASMAY_Id" = p_ASMAY_Id 
                AND CAST("FYP_DOE" AS date) BETWEEN CAST(p_FromDate AS date) AND CAST(p_ToDate AS date)
                AND (COALESCE("FYP_ApprovedFlg", 0) = 0)
        LOOP

            IF (v_SanctionLevelNo = 1) THEN

                v_Rcount := 0;
                SELECT count(*) INTO v_Rcount
                FROM "CLG"."Fee_Y_Payment_Approval"
                WHERE "HRME_Id" = v_HRME_Id AND "FYP_Id" = v_FYP_Id;

                RAISE NOTICE '%', v_Rcount;

                IF (v_Rcount = 0) THEN

                    SELECT "emp_code" INTO v_HRME_Id
                    FROM "IVRM_Staff_User_Login"
                    WHERE "Id" = p_User_Id;

                    INSERT INTO "CLG"."Fee_Y_Payment_Approval"(
                        "FYP_Id", "HRME_Id", "FYPAPP_ApprovedFlg", "FYPAPP_Remarks", 
                        "FYPAPP_DateTime", "FYPAPP_ActiveFlg", "FYPAPP_CreatedDate", "FYPAPP_UpdatedDate"
                    )
                    VALUES(v_FYP_Id, v_HRME_Id, 1, '', CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                END IF;

            END IF;

            v_Rcount := 0;
            SELECT count(*) INTO v_Rcount
            FROM "CLG"."Fee_Y_Payment_Approval"
            WHERE "FYP_Id" = v_FYP_Id;

            IF (v_Rcount > 0) THEN

                SELECT DISTINCT "IVRMUL_Id" INTO v_Preuserid
                FROM "HR_Process_Authorisation" "PA"
                INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                WHERE "HRPA_TypeFlag" = 'CLGFEE' 
                    AND "IVRMUL_Id" IN (
                        SELECT DISTINCT "IVRMUL_Id"
                        FROM "HR_Process_Authorisation" "PA"
                        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                        WHERE "HRPA_TypeFlag" = 'CLGFEE' AND "HRPAON_SanctionLevelNo" = v_SanctionLevelNo - 1
                    )
                LIMIT 1;

                SELECT "emp_code" INTO v_HRME_Id
                FROM "IVRM_Staff_User_Login"
                WHERE "Id" = p_User_Id;

                v_FYPRCount := 0;
                SELECT count(*) INTO v_FYPRCount
                FROM "CLG"."Fee_Y_Payment_Approval"
                WHERE "FYP_Id" = v_FYP_Id AND "HRME_Id" = v_HRME_Id;

                IF (v_FYPRCount = 0) THEN
                    INSERT INTO "CLG"."Fee_Y_Payment_Approval"(
                        "FYP_Id", "HRME_Id", "FYPAPP_ApprovedFlg", "FYPAPP_Remarks", 
                        "FYPAPP_DateTime", "FYPAPP_ActiveFlg", "FYPAPP_CreatedDate", "FYPAPP_UpdatedDate"
                    )
                    VALUES(v_FYP_Id, v_HRME_Id, 1, '', CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;

            END IF;

            v_ApprCount := 0;
            SELECT count(*) INTO v_ApprCount
            FROM "CLG"."Fee_Y_Payment_Approval"
            WHERE "FYP_Id" = v_FYP_Id;

            IF (v_MaxSanctionLevelNo = v_SanctionLevelNo) THEN

                SELECT "emp_code" INTO v_HRME_Id
                FROM "IVRM_Staff_User_Login"
                WHERE "Id" = p_User_Id;

                v_FYPRCount := 0;
                SELECT count(*) INTO v_FYPRCount
                FROM "CLG"."Fee_Y_Payment_Approval"
                WHERE "FYP_Id" = v_FYP_Id AND "HRME_Id" = v_HRME_Id;

                IF (v_FYPRCount = 0) THEN
                    INSERT INTO "CLG"."Fee_Y_Payment_Approval"(
                        "FYP_Id", "HRME_Id", "FYPAPP_ApprovedFlg", "FYPAPP_Remarks", 
                        "FYPAPP_DateTime", "FYPAPP_ActiveFlg", "FYPAPP_CreatedDate", "FYPAPP_UpdatedDate"
                    )
                    VALUES(v_FYP_Id, v_HRME_Id, 1, '', CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                END IF;

                UPDATE "CLG"."Fee_Y_Payment"
                SET "FYP_ApprovedFlg" = 1
                WHERE "FYP_Id" = v_FYP_Id AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

            END IF;

        END LOOP;

    END IF;

    RETURN;

END;
$$;