CREATE OR REPLACE FUNCTION "dbo"."Alumni_Interaction_View_Reply" (
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ALSMINT_Id" BIGINT
)
RETURNS TABLE (
    "ALSTINT_Id" BIGINT,
    "ALSMINT_Id" BIGINT,
    "ALSMINT_GroupOrIndFlg" VARCHAR(200),
    "ALSTINT_Attachment" TEXT,
    "ALSTINT_ToFlg" VARCHAR(200),
    "ALSTINT_ComposedById" BIGINT,
    "ALSTINT_Interaction" TEXT,
    "ALSTINT_DateTime" TIMESTAMP,
    "ALSTINT_ComposedByFlg" VARCHAR(200),
    "ALSTINT_InteractionOrder" INTEGER,
    "Sender" TEXT,
    "Receiver" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ALSMINT_GroupOrIndFlg" VARCHAR(200);
BEGIN

    SELECT DISTINCT "ALSMINT_GroupOrIndFlg" INTO "v_ALSMINT_GroupOrIndFlg"
    FROM "alu"."Alumni_School_Master_Interactions" 
    WHERE "MI_Id" = "Alumni_Interaction_View_Reply"."MI_Id" 
    AND "ALSMINT_Id" = "Alumni_Interaction_View_Reply"."ALSMINT_Id";

    RETURN QUERY
    SELECT DISTINCT 
        b."ALSTINT_Id", 
        b."ALSMINT_Id",
        a."ALSMINT_GroupOrIndFlg", 
        b."ALSTINT_Attachment", 
        b."ALSTINT_ToFlg",
        b."ALSTINT_ComposedById",
        b."ALSTINT_Interaction",
        b."ALSTINT_DateTime",
        b."ALSTINT_ComposedByFlg",
        b."ALSTINT_InteractionOrder",
        
        (CASE WHEN b."ALSTINT_ComposedByFlg" = 'Alumni' THEN 
            (SELECT DISTINCT (
                CASE WHEN s."ALMST_FirstName" IS NULL OR s."ALMST_FirstName" = '' THEN '' ELSE s."ALMST_FirstName" END ||
                CASE WHEN s."ALMST_MiddleName" IS NULL OR s."ALMST_MiddleName" = '' OR s."ALMST_MiddleName" = '0' THEN '' ELSE ' ' || s."ALMST_MiddleName" END ||
                CASE WHEN s."ALMST_LastName" IS NULL OR s."ALMST_LastName" = '' OR s."ALMST_LastName" = '0' THEN '' ELSE ' ' || s."ALMST_LastName" END
            )
            FROM "alu"."Alumni_Master_Student" s
            WHERE s."MI_Id" = "Alumni_Interaction_View_Reply"."MI_Id" 
            AND s."ALMST_Id" = b."ALSTINT_ComposedById")
        WHEN b."ALSTINT_ComposedByFlg" = 'Staff' THEN 
            (SELECT DISTINCT (
                CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
                CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END ||
                CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END
            )
            FROM "HR_Master_Employee" e
            WHERE e."MI_Id" = "Alumni_Interaction_View_Reply"."MI_Id" 
            AND e."HRME_Id" = b."ALSTINT_ComposedById")
        END)::TEXT AS "Sender",
        
        (CASE WHEN b."ALSTINT_ToFlg" = 'Alumni' THEN 
            (SELECT DISTINCT (
                CASE WHEN s."ALMST_FirstName" IS NULL OR s."ALMST_FirstName" = '' THEN '' ELSE s."ALMST_FirstName" END ||
                CASE WHEN s."ALMST_MiddleName" IS NULL OR s."ALMST_MiddleName" = '' OR s."ALMST_MiddleName" = '0' THEN '' ELSE ' ' || s."ALMST_MiddleName" END ||
                CASE WHEN s."ALMST_LastName" IS NULL OR s."ALMST_LastName" = '' OR s."ALMST_LastName" = '0' THEN '' ELSE ' ' || s."ALMST_LastName" END
            )
            FROM "alu"."Alumni_Master_Student" s
            WHERE s."MI_Id" = "Alumni_Interaction_View_Reply"."MI_Id" 
            AND s."ALMST_Id" = b."ALSTINT_ToId")
        WHEN b."ALSTINT_ToFlg" = 'Staff' THEN 
            (SELECT DISTINCT (
                CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
                CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END ||
                CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END
            )
            FROM "HR_Master_Employee" e
            WHERE e."MI_Id" = "Alumni_Interaction_View_Reply"."MI_Id" 
            AND e."HRME_Id" = b."ALSTINT_ToId")
        END)::TEXT AS "Receiver"
        
    FROM "alu"."Alumni_School_Master_Interactions" a
    INNER JOIN "alu"."Alumni_School_Transaction_Interactions" b 
        ON a."ALSMINT_Id" = b."ALSMINT_Id" AND a."ALSMINT_ActiveFlag" = TRUE
    WHERE a."MI_Id" = "Alumni_Interaction_View_Reply"."MI_Id" 
        AND a."ALSMINT_GroupOrIndFlg" = "v_ALSMINT_GroupOrIndFlg"
        AND a."ALSMINT_Id" = "Alumni_Interaction_View_Reply"."ALSMINT_Id"
        AND b."ALSTINT_InteractionOrder" != 1 
        AND a."ALSMINT_ActiveFlag" = TRUE 
        AND b."ALSTINT_ActiveFlag" = TRUE
    ORDER BY b."ALSTINT_DateTime";

    RETURN;
END;
$$;