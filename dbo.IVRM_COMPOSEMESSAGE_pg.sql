CREATE OR REPLACE FUNCTION "dbo"."IVRM_COMPOSEMESSAGE"(
    p_MI_Id BIGINT,
    p_HRME_Id BIGINT,
    p_AMST_Id BIGINT,
    p_role VARCHAR(50)
)
RETURNS TABLE(
    "IINTS_Id" BIGINT,
    "IINTS_InteractionId" VARCHAR,
    "ASMAY_Id" BIGINT,
    "AMST_Id" BIGINT,
    "IINTS_Subject" VARCHAR,
    "IINTS_Date" TIMESTAMP,
    "IINTS_Interaction" TEXT,
    "HRME_Id" BIGINT,
    "IINTS_Flag" VARCHAR,
    "IINTS_ActiveFlag" BOOLEAN,
    "IINTS_ComposeFlag" VARCHAR,
    "studentName" TEXT,
    "employeeName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_role = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."IINTS_Id",
            a."IINTS_InteractionId",
            a."ASMAY_Id",
            a."AMST_Id",
            a."IINTS_Subject",
            a."IINTS_Date",
            a."IINTS_Interaction",
            a."HRME_Id",
            a."IINTS_Flag",
            a."IINTS_ActiveFlag",
            a."IINTS_ComposeFlag",
            (CASE WHEN b."AMST_FirstName" IS NULL OR b."AMST_FirstName" = '' THEN '' ELSE b."AMST_FirstName" END ||
             CASE WHEN b."AMST_MiddleName" IS NULL OR b."AMST_MiddleName" = '' OR b."AMST_MiddleName" = '0' THEN '' ELSE ' ' || b."AMST_MiddleName" END ||
             CASE WHEN b."AMST_LastName" IS NULL OR b."AMST_LastName" = '' OR b."AMST_LastName" = '0' THEN '' ELSE ' ' || b."AMST_LastName" END) AS "studentName",
            (CASE WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' ELSE c."HRME_EmployeeFirstName" END ||
             CASE WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' OR c."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeMiddleName" END ||
             CASE WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' OR c."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeLastName" END) AS "employeeName"
        FROM "IVRM_Interactions_Student" a,
             "Adm_M_Student" b,
             "HR_Master_Employee" c
        WHERE a."AMST_Id" = b."AMST_Id" 
          AND a."HRME_Id" = c."HRME_Id" 
          AND a."MI_Id" = p_MI_Id 
          AND a."AMST_Id" = p_AMST_Id
        ORDER BY a."IINTS_Date" DESC;
    
    ELSIF p_role = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."IINTS_Id",
            a."IINTS_InteractionId",
            a."ASMAY_Id",
            a."AMST_Id",
            a."IINTS_Subject",
            a."IINTS_Date",
            a."IINTS_Interaction",
            a."HRME_Id",
            a."IINTS_Flag",
            a."IINTS_ActiveFlag",
            a."IINTS_ComposeFlag",
            (CASE WHEN b."AMST_FirstName" IS NULL OR b."AMST_FirstName" = '' THEN '' ELSE b."AMST_FirstName" END ||
             CASE WHEN b."AMST_MiddleName" IS NULL OR b."AMST_MiddleName" = '' OR b."AMST_MiddleName" = '0' THEN '' ELSE ' ' || b."AMST_MiddleName" END ||
             CASE WHEN b."AMST_LastName" IS NULL OR b."AMST_LastName" = '' OR b."AMST_LastName" = '0' THEN '' ELSE ' ' || b."AMST_LastName" END) AS "studentName",
            (CASE WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' ELSE c."HRME_EmployeeFirstName" END ||
             CASE WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' OR c."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeMiddleName" END ||
             CASE WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' OR c."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeLastName" END) AS "employeeName"
        FROM "IVRM_Interactions_Student" a,
             "Adm_M_Student" b,
             "HR_Master_Employee" c
        WHERE a."AMST_Id" = b."AMST_Id" 
          AND a."HRME_Id" = c."HRME_Id" 
          AND a."MI_Id" = p_MI_Id 
          AND a."HRME_Id" = p_HRME_Id
        ORDER BY a."IINTS_Date" DESC;
    END IF;
    
    RETURN;
END;
$$;