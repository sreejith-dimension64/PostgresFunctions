CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_View_Reply" (
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ISMINT_Id BIGINT
)
RETURNS TABLE (
    "ISTINT_Id" BIGINT,
    "ISMINT_Id" BIGINT,
    "ISMINT_GroupOrIndFlg" VARCHAR(200),
    "ISTINT_Attachment" TEXT,
    "ISTINT_ToFlg" VARCHAR(200),
    "ISTINT_ComposedById" BIGINT,
    "ISTINT_Interaction" TEXT,
    "ISTINT_DateTime" TIMESTAMP,
    "ISTINT_ComposedByFlg" VARCHAR(200),
    "ISTINT_InteractionOrder" INTEGER,
    "Sender" TEXT,
    "Receiver" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ISMINT_GroupOrIndFlg VARCHAR(200);
BEGIN
    
    SELECT DISTINCT "ISMINT_GroupOrIndFlg" INTO v_ISMINT_GroupOrIndFlg 
    FROM "IVRM_School_Master_Interactions" 
    WHERE "MI_Id" = p_MI_Id AND "ISMINT_Id" = p_ISMINT_Id;

    RETURN QUERY
    SELECT DISTINCT 
        b."ISTINT_Id", 
        b."ISMINT_Id",
        a."ISMINT_GroupOrIndFlg", 
        b."ISTINT_Attachment", 
        b."ISTINT_ToFlg",
        b."ISTINT_ComposedById",
        b."ISTINT_Interaction",
        b."ISTINT_DateTime",
        b."ISTINT_ComposedByFlg",
        b."ISTINT_InteractionOrder",
        (CASE 
            WHEN b."ISTINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
                     CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
                     CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
                 FROM "Adm_M_Student" 
                 WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ComposedById")
            WHEN b."ISTINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                 FROM "HR_Master_Employee" 
                 WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ComposedById")
        END)::TEXT AS "Sender",
        (CASE 
            WHEN b."ISTINT_ToFlg" = 'Student' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
                     CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
                     CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
                 FROM "Adm_M_Student" 
                 WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
            WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                 FROM "HR_Master_Employee" 
                 WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
        END)::TEXT AS "Receiver"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ISMINT_GroupOrIndFlg" = v_ISMINT_GroupOrIndFlg 
        AND a."ISMINT_Id" = p_ISMINT_Id 
        AND b."ISTINT_InteractionOrder" != 1

    UNION

    SELECT DISTINCT 
        b."ISTINT_Id", 
        b."ISMINT_Id",
        a."ISMINT_GroupOrIndFlg", 
        b."ISTINT_Attachment", 
        b."ISTINT_ToFlg",
        b."ISTINT_ComposedById",
        b."ISTINT_Interaction",
        b."ISTINT_DateTime",
        b."ISTINT_ComposedByFlg",
        b."ISTINT_InteractionOrder",
        (CASE 
            WHEN b."ISTINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
                     CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
                     CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
                 FROM "Adm_M_Student" 
                 WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ComposedById")
            WHEN b."ISTINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                 FROM "HR_Master_Employee" 
                 WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ComposedById")
        END)::TEXT AS "Sender",
        (CASE 
            WHEN b."ISTINT_ToFlg" = 'Student' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
                     CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
                     CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
                 FROM "Adm_M_Student" 
                 WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
            WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT 
                    (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                 FROM "HR_Master_Employee" 
                 WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
        END)::TEXT AS "Receiver"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = 1
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ISMINT_GroupOrIndFlg" = v_ISMINT_GroupOrIndFlg 
        AND a."ISMINT_Id" = p_ISMINT_Id
    ORDER BY "ISTINT_DateTime"
    LIMIT 1;

    RETURN;
END;
$$;