CREATE OR REPLACE FUNCTION "dbo"."ISM_AssignedTO_Details"(
    "userId" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCR_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := '
        SELECT DISTINCT "TCAT"."ISMTCR_Id"
        FROM "dbo"."ISM_TaskCreation" "TC"
        INNER JOIN "dbo"."ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "TCAT"."ISMTCRASTO_ActiveFlg" = 1
        INNER JOIN "dbo"."IVRM_Staff_User_Login" "ISUL" ON "ISUL"."Emp_Code" = "TC"."HRME_Id" OR "ISUL"."Emp_Code" = "TCAT"."HRME_Id" OR "ISUL"."Emp_Code" = "TCAT"."ISMTCRASTO_AssignedBy"
        INNER JOIN "dbo"."ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "ISUL"."Id"
        INNER JOIN "dbo"."HR_Master_Employee" "HME" ON "TC"."HRME_Id" = "HME"."HRME_Id" OR "TCAT"."HRME_Id" = "HME"."HRME_Id" OR "UEM"."HRME_Id" = "HME"."HRME_Id"
        WHERE "TC"."ISMTCR_ActiveFlg" = 1
        AND ("HME"."HRME_Id" IN (SELECT DISTINCT "HRME_Id" FROM "dbo"."ISM_User_Employees_Mapping" WHERE "User_Id" = ' || "userId" || ') OR "UEM"."User_Id" = ' || "userId" || ')';

    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;