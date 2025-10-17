CREATE OR REPLACE FUNCTION "dbo"."Fetch_Final_Level_Approval_Name"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@AMCST_Id" bigint,
    "@fyp_id" bigint
)
RETURNS TABLE("EmpName" text)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        COALESCE("HRME_EmployeeFirstName", '') || ' ' || 
        COALESCE("HRME_EmployeeMiddleName", '') || ' ' || 
        COALESCE("HRME_EmployeeLastName", '') AS "EmpName"
    FROM "CLG"."Fee_Y_Payment" "FYP"
    INNER JOIN "CLG"."Fee_Y_Payment_College_Student" "CS" ON "FYP"."FYP_Id" = "CS"."FYP_Id"
    INNER JOIN "CLG"."Fee_Y_Payment_Approval" "FYPA" ON "FYPA"."FYP_Id" = "CS"."FYP_Id"
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code" = "FYPA"."HRME_Id"
    INNER JOIN "HR_Process_Auth_OrderNo" "PAO" ON "PAO"."IVRMUL_Id" = "SUL"."IVRMSTAUL_Id" 
        AND "PAO"."HRPAON_FinalFlg" = 1
    INNER JOIN "HR_Process_Authorisation" "PA" ON "PA"."HRPA_Id" = "PAO"."HRPA_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "SUL"."Emp_Code"
    WHERE "FYPA"."FYP_Id" = "@fyp_id" 
        AND "CS"."ASMAY_Id" = "@ASMAY_Id" 
        AND "FYP"."MI_Id" = "@MI_Id" 
        AND "CS"."AMCST_Id" = "@AMCST_Id" 
        AND "PAO"."HRPAON_FinalFlg" = 1;
END;
$$;