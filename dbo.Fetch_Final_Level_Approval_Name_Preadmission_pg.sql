CREATE OR REPLACE FUNCTION "dbo"."Fetch_Final_Level_Approval_Name_Preadmission"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@PACA_Id" bigint,
    "@fyp_id" bigint
)
RETURNS TABLE(
    "EmpName" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        COALESCE("HME"."HRME_EmployeeFirstName", '') || ' ' || 
        COALESCE("HME"."HRME_EmployeeMiddleName", '') || ' ' || 
        COALESCE("HME"."HRME_EmployeeLastName", '') AS "EmpName"
    FROM "CLG"."Fee_Y_Payment" "FYP"
    INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" "CS" ON "FYP"."FYP_Id" = "CS"."FYP_Id"
    INNER JOIN "CLG"."Fee_Y_Payment_Approval" "FYPA" ON "FYPA"."FYP_Id" = "CS"."FYP_Id"
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code" = "FYPA"."HRME_Id"
    INNER JOIN "HR_Process_Auth_OrderNo" "PAO" ON "PAO"."IVRMUL_Id" = "SUL"."IVRMSTAUL_Id" 
        AND "PAO"."HRPAON_FinalFlg" = 1
    INNER JOIN "HR_Process_Authorisation" "PA" ON "PA"."HRPA_Id" = "PAO"."HRPA_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "SUL"."Emp_Code"
    WHERE "FYPA"."FYP_Id" = "@fyp_id" 
        AND "FYP"."ASMAY_Id" = "@ASMAY_Id" 
        AND "FYP"."MI_Id" = "@MI_Id" 
        AND "CS"."PACA_Id" = "@PACA_Id" 
        AND "PAO"."HRPAON_FinalFlg" = 1;

END;
$$;