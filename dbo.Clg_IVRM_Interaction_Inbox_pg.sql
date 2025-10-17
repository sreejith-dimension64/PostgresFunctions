CREATE OR REPLACE FUNCTION "dbo"."Clg_IVRM_Interaction_Inbox"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "roleflg" VARCHAR(50)
)
RETURNS TABLE(
    "ISTINT_Attachment" TEXT,
    "ISMINT_Id" BIGINT,
    "ISTINT_Id" BIGINT,
    "ISMINT_ComposedById" BIGINT,
    "ISMINT_InteractionId" TEXT,
    "ISMINT_Subject" TEXT,
    "ISMINT_Interaction" TEXT,
    "ISMINT_GroupOrIndFlg" TEXT,
    "ISMINT_ComposedByFlg" TEXT,
    "ISTINT_DateTime" TIMESTAMP,
    "Sender" TEXT,
    "Receiver" TEXT,
    "ISMINT_DateTime" TIMESTAMP,
    "ISMINT_ActiveFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "roleflg" = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."ISTINT_Attachment", 
            a."ISMINT_Id",
            b."ISTINT_Id", 
            a."ISMINT_ComposedById",
            a."ISMINT_InteractionId",
            a."ISMINT_Subject",
            a."ISMINT_Interaction",
            a."ISMINT_GroupOrIndFlg",
            a."ISMINT_ComposedByFlg",
            b."ISTINT_DateTime",
            (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT (CASE WHEN s."AMCST_FirstName" IS NULL OR s."AMCST_FirstName" = '' THEN '' ELSE s."AMCST_FirstName" END || 
                    CASE WHEN s."AMCST_MiddleName" IS NULL OR s."AMCST_MiddleName" = '' OR s."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMCST_MiddleName" END || 
                    CASE WHEN s."AMCST_LastName" IS NULL OR s."AMCST_LastName" = '' OR s."AMCST_LastName" = '0' THEN '' ELSE ' ' || s."AMCST_LastName" END) 
                FROM "clg"."Adm_Master_College_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMCST_Id" = a."ISMINT_ComposedById")
            WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END || 
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END) 
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = a."ISMINT_ComposedById")
            END) AS "Sender",
            (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
                (SELECT DISTINCT (CASE WHEN s."AMCST_FirstName" IS NULL OR s."AMCST_FirstName" = '' THEN '' ELSE s."AMCST_FirstName" END || 
                    CASE WHEN s."AMCST_MiddleName" IS NULL OR s."AMCST_MiddleName" = '' OR s."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMCST_MiddleName" END || 
                    CASE WHEN s."AMCST_LastName" IS NULL OR s."AMCST_LastName" = '' OR s."AMCST_LastName" = '0' THEN '' ELSE ' ' || s."AMCST_LastName" END) 
                FROM "clg"."Adm_Master_College_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMCST_Id" = b."ISTINT_ToId")
            WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END || 
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END) 
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = b."ISTINT_ToId")
            END) AS "Receiver",
            a."ISMINT_DateTime",
            a."ISMINT_ActiveFlag"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = TRUE
        WHERE a."MI_Id" = "MI_Id" AND a."ASMAY_Id" = "ASMAY_Id" AND a."ISMINT_ActiveFlag" = TRUE AND b."ISTINT_ActiveFlag" = TRUE 
            AND (b."ISTINT_ToId" = "AMCST_Id" OR b."ISTINT_ComposedById" = "AMCST_Id") 
        ORDER BY b."ISTINT_DateTime" DESC;
    END IF;

    IF "roleflg" = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."ISTINT_Attachment", 
            a."ISMINT_Id",
            b."ISTINT_Id", 
            a."ISMINT_ComposedById",
            a."ISMINT_InteractionId",
            a."ISMINT_Subject",
            a."ISMINT_Interaction",
            a."ISMINT_GroupOrIndFlg",
            a."ISMINT_ComposedByFlg",
            b."ISTINT_DateTime",
            (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
                (SELECT DISTINCT (CASE WHEN s."AMCST_FirstName" IS NULL OR s."AMCST_FirstName" = '' THEN '' ELSE s."AMCST_FirstName" END || 
                    CASE WHEN s."AMCST_MiddleName" IS NULL OR s."AMCST_MiddleName" = '' OR s."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMCST_MiddleName" END || 
                    CASE WHEN s."AMCST_LastName" IS NULL OR s."AMCST_LastName" = '' OR s."AMCST_LastName" = '0' THEN '' ELSE ' ' || s."AMCST_LastName" END) 
                FROM "clg"."Adm_Master_College_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMCST_Id" = a."ISMINT_ComposedById")
            WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END || 
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END) 
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = a."ISMINT_ComposedById")
            END) AS "Sender",
            (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
                (SELECT DISTINCT (CASE WHEN s."AMCST_FirstName" IS NULL OR s."AMCST_FirstName" = '' THEN '' ELSE s."AMCST_FirstName" END || 
                    CASE WHEN s."AMCST_MiddleName" IS NULL OR s."AMCST_MiddleName" = '' OR s."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMCST_MiddleName" END || 
                    CASE WHEN s."AMCST_LastName" IS NULL OR s."AMCST_LastName" = '' OR s."AMCST_LastName" = '0' THEN '' ELSE ' ' || s."AMCST_LastName" END) 
                FROM "clg"."Adm_Master_College_Student" s 
                WHERE s."MI_Id" = "MI_Id" AND s."AMCST_Id" = b."ISTINT_ToId")
            WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName" = '' THEN '' ELSE e."HRME_EmployeeFirstName" END || 
                    CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
                    CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END) 
                FROM "HR_Master_Employee" e 
                WHERE e."MI_Id" = "MI_Id" AND e."HRME_Id" = b."ISTINT_ToId")
            END) AS "Receiver",
            a."ISMINT_DateTime",
            a."ISMINT_ActiveFlag"
        FROM "IVRM_School_Master_Interactions" a
        INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = TRUE
        WHERE a."MI_Id" = "MI_Id" AND a."ASMAY_Id" = "ASMAY_Id" AND a."ISMINT_ActiveFlag" = TRUE AND b."ISTINT_ActiveFlag" = TRUE 
            AND (b."ISTINT_ToId" = "HRME_Id" OR b."ISTINT_ComposedById" = "HRME_Id") 
        ORDER BY b."ISTINT_DateTime" DESC;
    END IF;

    RETURN;
END;
$$;