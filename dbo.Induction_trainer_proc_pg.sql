
CREATE OR REPLACE FUNCTION "dbo"."Induction_trainer_proc"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "hrmE_Id" bigint,
    "hrmE_EmployeeFirstName" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HRME_Id" AS "hrmE_Id",
        (COALESCE("HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '')) AS "hrmE_EmployeeFirstName"
    FROM "Hr_Master_Employee"
    WHERE "HRME_Id" NOT IN (
        SELECT "HRME_Id" 
        FROM "HR_Training_Create_Participants"
    )
    AND "HRME_ActiveFlag" = 1 
    AND "HRME_LeftFlag" = 0 
    AND "MI_Id" IN (
        SELECT "MI_Id" 
        FROM "Master_Institution"
    );
END;
$$;