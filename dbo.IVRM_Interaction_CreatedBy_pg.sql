CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_CreatedBy"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_loginuserid BIGINT,
    p_ISMINT_Id BIGINT
)
RETURNS TABLE(
    "ISMINT_Id" BIGINT,
    "ISMINT_InteractionId" VARCHAR,
    "ISMINT_Subject" VARCHAR,
    "ISMINT_Interaction" TEXT,
    "ISMINT_GroupOrIndFlg" VARCHAR,
    "ISMINT_ComposedByFlg" VARCHAR,
    "createdby" TEXT,
    "ISMINT_ComposedById" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ISMINT_Id", 
        a."ISMINT_InteractionId",
        a."ISMINT_Subject",
        a."ISMINT_Interaction",
        a."ISMINT_GroupOrIndFlg",
        a."ISMINT_ComposedByFlg",
        (CASE 
            WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
                     CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
                     CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
                FROM "Adm_M_Student" 
                WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
            WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" 
                WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
        END) AS "createdby",
        a."ISMINT_ComposedById"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b 
        ON a."ISMINT_Id" = b."ISMINT_Id" 
        AND a."ISMINT_ActiveFlag" = 1 
        AND b."ISTINT_InteractionOrder" = 1
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."ISMINT_ActiveFlag" = 1 
        AND b."ISTINT_ToId" = p_loginuserid 
        AND a."ISMINT_Id" = p_ISMINT_Id
    ORDER BY a."ISMINT_Id"
    LIMIT 100;
    
    RETURN;
END;
$$;