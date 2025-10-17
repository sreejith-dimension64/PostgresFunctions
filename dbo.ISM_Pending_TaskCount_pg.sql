CREATE OR REPLACE FUNCTION "dbo"."ISM_Pending_TaskCount"(
    "@HRME_Id" VARCHAR(100),
    "@userid" VARCHAR(100)
)
RETURNS TABLE (
    "Pendingtask" BIGINT,
    "ISMTCR_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN

    RETURN QUERY
    SELECT DISTINCT COUNT("TCAT"."ISMTCRASTO_Id") AS "Pendingtask", 
           "TC"."ISMTCR_Id"
    FROM "dbo"."ISM_TaskCreation" "TC"
    INNER JOIN "dbo"."ISM_TaskCreation_AssignedTo" "TCAT" 
        ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    INNER JOIN "dbo"."HR_Master_Employee" "ME" 
        ON "TCAT"."HRME_Id" = "ME"."HRME_Id" 
        AND "ME"."HRME_ActiveFlag" = 1 
        AND "ME"."HRME_LeftFlag" = 0
    INNER JOIN "dbo"."HR_Master_Priority" "MP" 
        ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" 
        AND "MP"."HRMP_ActiveFlag" = 1
    INNER JOIN "dbo"."IVRM_Staff_User_Login" "f" 
        ON "f"."Emp_Code" = "TC"."HRME_Id"
    INNER JOIN "dbo"."ISM_User_Employees_Mapping" "UEM" 
        ON "UEM"."User_Id" = "f"."Id"
    WHERE "TC"."ISMTCR_ActiveFlg" = 1 
        AND "TC"."ISMTCR_Status" IN ('Open', 'Inprogress')
        AND (("UEM"."User_Id" = "@userid") 
            OR "TC"."HRME_Id" IN ("@HRME_Id") 
            OR "TCAT"."HRME_Id" IN ("@HRME_Id"))
    GROUP BY "TC"."ISMTCR_Id"
    ORDER BY "ISMTCR_Id";

END;
$$;