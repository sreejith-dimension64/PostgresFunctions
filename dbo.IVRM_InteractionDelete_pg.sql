CREATE OR REPLACE FUNCTION "dbo"."IVRM_InteractionDelete"(
    p_MI_Id bigint,
    p_Fromdate timestamp,
    p_Todate timestamp
)
RETURNS TABLE(
    employeename text,
    "ISTINT_Interaction" text,
    "DeleteDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (COALESCE("b"."HRME_EmployeeFirstName", '') || COALESCE("b"."HRME_EmployeeMiddleName", '') || COALESCE("b"."HRME_EmployeeLastName", ''))::text AS employeename,
        "a"."ISTINT_Interaction",
        "a"."UpdatedDate" AS "DeleteDate"
    FROM "IVRM_School_Transaction_Interactions" "a"
    INNER JOIN "IVRM_School_Master_Interactions" "c" ON "a"."ISMINT_Id" = "c"."ISMINT_Id"
    INNER JOIN "HR_Master_Employee" "b" ON "a"."ISTINT_ComposedById" = "b"."HRME_Id" AND "b"."MI_Id" = p_MI_Id
    WHERE "a"."ISTINT_DateTime"::date BETWEEN p_Fromdate::date AND p_Todate::date 
        AND "a"."ISTINT_ActiveFlag" = false
    ORDER BY "a"."UpdatedDate" DESC;
END;
$$;