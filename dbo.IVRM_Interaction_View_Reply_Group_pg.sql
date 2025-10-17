CREATE OR REPLACE FUNCTION "IVRM_Interaction_View_Reply_Group"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "ISMINT_Id" bigint,
    "STORHRMEID" bigint,
    "SRole" text
)
RETURNS TABLE(
    "ISTINT_Id" bigint,
    "ISMINT_Id" bigint,
    "ISMINT_GroupOrIndFlg" varchar,
    "ISTINT_Attachment" text,
    "ISTINT_ToFlg" varchar,
    "ISTINT_ComposedById" bigint,
    "ISTINT_Interaction" text,
    "ISTINT_DateTime" timestamp,
    "ISTINT_ComposedByFlg" varchar,
    "ISTINT_InteractionOrder" integer,
    "Sender" text,
    "Receiver" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "SRole" = 'student' THEN
    
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
            (CASE WHEN b."ISTINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT (
                    CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName" = '' THEN '' ELSE s."AMST_FirstName" END ||
                    CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END ||
                    CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END
                )
                FROM "Adm_M_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMST_Id" = b."ISTINT_ComposedById" AND b."ISTINT_ComposedById" = "STORHRMEID")
            WHEN b."ISTINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT (
                    CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END ||
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END
                )
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = b."ISTINT_ComposedById")
            END) AS "Sender",
            (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
                (SELECT DISTINCT (
                    CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName" = '' THEN '' ELSE s."AMST_FirstName" END ||
                    CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END ||
                    CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END
                )
                FROM "Adm_M_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMST_Id" = b."ISTINT_ToId" AND b."ISTINT_ToId" = "STORHRMEID")
            WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT (
                    CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END ||
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END
                )
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = b."ISTINT_ToId")
            END) AS "Receiver"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
        WHERE a."MI_Id" = "MI_Id" 
            AND a."ISMINT_GroupOrIndFlg" = 'Group' 
            AND a."ISMINT_Id" = "ISMINT_Id" 
            AND b."ISTINT_InteractionOrder" != 1
            AND a."ISMINT_ActiveFlag" = true 
            AND b."ISTINT_ActiveFlag" = true 
            AND (b."ISTINT_ComposedById" = "STORHRMEID" OR b."ISTINT_ToId" = "STORHRMEID")
        ORDER BY b."ISTINT_DateTime";
    
    ELSE
    
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
            (CASE WHEN b."ISTINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT (
                    CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName" = '' THEN '' ELSE s."AMST_FirstName" END ||
                    CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END ||
                    CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END
                )
                FROM "Adm_M_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMST_Id" = b."ISTINT_ComposedById")
            WHEN b."ISTINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT (
                    CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END ||
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END
                )
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = b."ISTINT_ComposedById" AND b."ISTINT_ComposedById" = "STORHRMEID")
            END) AS "Sender",
            (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
                (SELECT DISTINCT (
                    CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName" = '' THEN '' ELSE s."AMST_FirstName" END ||
                    CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END ||
                    CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END
                )
                FROM "Adm_M_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMST_Id" = b."ISTINT_ToId")
            WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT (
                    CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END ||
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END
                )
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = 4 AND e."HRME_Id" = b."ISTINT_ToId" AND b."ISTINT_ToId" = "STORHRMEID")
            END) AS "Receiver"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
        WHERE a."MI_Id" = "MI_Id" 
            AND a."ISMINT_GroupOrIndFlg" = 'Group' 
            AND a."ISMINT_Id" = "ISMINT_Id" 
            AND b."ISTINT_InteractionOrder" != 1
            AND a."ISMINT_ActiveFlag" = true 
            AND b."ISTINT_ActiveFlag" = true
        ORDER BY b."ISTINT_DateTime";
    
    END IF;

    RETURN;

END;
$$;