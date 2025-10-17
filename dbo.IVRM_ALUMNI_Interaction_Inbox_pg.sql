CREATE OR REPLACE FUNCTION "dbo"."IVRM_ALUMNI_Interaction_Inbox"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ALMST_Id BIGINT,
    p_HRME_Id BIGINT,
    p_roleflg VARCHAR(50)
)
RETURNS TABLE(
    "ALSMINT_Id" BIGINT,
    "ALSTINT_Id" BIGINT,
    "ALSMINT_InteractionId" VARCHAR,
    "ALSMINT_Subject" VARCHAR,
    "ALSMINT_Interaction" TEXT,
    "ALSMINT_GroupOrIndFlg" VARCHAR,
    "ALSMINT_ComposedByFlg" VARCHAR,
    "ALSTINT_UpdatedDate" TIMESTAMP,
    "Sender" TEXT,
    "Receiver" TEXT,
    "ALSMINT_DateTime" TIMESTAMP,
    "ALSMINT_ActiveFlag" BOOLEAN,
    "ALSTINT_Attachment" TEXT,
    "ALSMINT_ComposedById" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_roleflg = 'Alumni' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            ASMI."ALSMINT_Id",
            ASTI."ALSTINT_Id",
            ASMI."ALSMINT_InteractionId",
            ASMI."ALSMINT_Subject",
            ASMI."ALSMINT_Interaction",
            ASMI."ALSMINT_GroupOrIndFlg",
            ASMI."ALSMINT_ComposedByFlg",
            ASTI."ALSTINT_UpdatedDate",
            (CASE WHEN ASMI."ALSMINT_ComposedByFlg" = 'Alumni' THEN 
                (SELECT DISTINCT (CASE WHEN "ALMST_FirstName" IS NULL OR "ALMST_FirstName" = '' THEN '' ELSE "ALMST_FirstName" END ||
                    CASE WHEN "ALMST_MiddleName" IS NULL OR "ALMST_MiddleName" = '' OR "ALMST_MiddleName" = '0' THEN '' ELSE ' ' || "ALMST_MiddleName" END ||
                    CASE WHEN "ALMST_LastName" IS NULL OR "ALMST_LastName" = '' OR "ALMST_LastName" = '0' THEN '' ELSE ' ' || "ALMST_LastName" END)
                FROM "ALU"."Alumni_Master_Student" WHERE "MI_Id" = p_MI_Id AND "ALMST_Id" = ASMI."ALSMINT_ComposedById")
            WHEN ASMI."ALSMINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = ASMI."ALSMINT_ComposedById")
            END) AS "Sender",
            (CASE WHEN ASTI."ALSTINT_ToFlg" = 'Alumni' THEN 
                (SELECT DISTINCT (CASE WHEN "ALMST_FirstName" IS NULL OR "ALMST_FirstName" = '' THEN '' ELSE "ALMST_FirstName" END ||
                    CASE WHEN "ALMST_MiddleName" IS NULL OR "ALMST_MiddleName" = '' OR "ALMST_MiddleName" = '0' THEN '' ELSE ' ' || "ALMST_MiddleName" END ||
                    CASE WHEN "ALMST_LastName" IS NULL OR "ALMST_LastName" = '' OR "ALMST_LastName" = '0' THEN '' ELSE ' ' || "ALMST_LastName" END)
                FROM "ALU"."Alumni_Master_Student" WHERE "MI_Id" = p_MI_Id AND "ALMST_Id" = ASTI."ALSTINT_ToId")
            WHEN ASTI."ALSTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = ASTI."ALSTINT_ToId")
            END) AS "Receiver",
            ASMI."ALSMINT_DateTime",
            ASMI."ALSMINT_ActiveFlag",
            ASTI."ALSTINT_Attachment",
            ASMI."ALSMINT_ComposedById"
        FROM "ALU"."Alumni_School_Master_Interactions" ASMI
        INNER JOIN "ALU"."Alumni_School_Transaction_Interactions" ASTI ON ASMI."ALSMINT_Id" = ASTI."ALSMINT_Id" AND ASMI."ALSMINT_ActiveFlag" = TRUE
        WHERE ASMI."MI_Id" = p_MI_Id AND ASMI."ASMAY_Id" = p_ASMAY_Id AND ASMI."ALSMINT_ActiveFlag" = TRUE 
            AND (ASTI."ALSTINT_ToId" = p_ALMST_Id OR ASTI."ALSTINT_ComposedById" = p_ALMST_Id)
        ORDER BY ASTI."ALSTINT_UpdatedDate" DESC;
        
    END IF;

    IF p_roleflg = 'Staff' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            ASMI."ALSMINT_Id",
            ASTI."ALSTINT_Id",
            ASMI."ALSMINT_InteractionId",
            ASMI."ALSMINT_Subject",
            ASMI."ALSMINT_Interaction",
            ASMI."ALSMINT_GroupOrIndFlg",
            ASMI."ALSMINT_ComposedByFlg",
            ASTI."ALSTINT_UpdatedDate",
            (CASE WHEN ASMI."ALSMINT_ComposedByFlg" = 'Alumni' THEN 
                (SELECT DISTINCT (CASE WHEN "ALMST_FirstName" IS NULL OR "ALMST_FirstName" = '' THEN '' ELSE "ALMST_FirstName" END ||
                    CASE WHEN "ALMST_MiddleName" IS NULL OR "ALMST_MiddleName" = '' OR "ALMST_MiddleName" = '0' THEN '' ELSE ' ' || "ALMST_MiddleName" END ||
                    CASE WHEN "ALMST_LastName" IS NULL OR "ALMST_LastName" = '' OR "ALMST_LastName" = '0' THEN '' ELSE ' ' || "ALMST_LastName" END)
                FROM "ALU"."Alumni_Master_Student" WHERE "MI_Id" = p_MI_Id AND "ALMST_Id" = ASMI."ALSMINT_ComposedById")
            WHEN ASMI."ALSMINT_ComposedByFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = ASMI."ALSMINT_ComposedById")
            END) AS "Sender",
            (CASE WHEN ASTI."ALSTINT_ToFlg" = 'Alumni' THEN 
                (SELECT DISTINCT (CASE WHEN "ALMST_FirstName" IS NULL OR "ALMST_FirstName" = '' THEN '' ELSE "ALMST_FirstName" END ||
                    CASE WHEN "ALMST_MiddleName" IS NULL OR "ALMST_MiddleName" = '' OR "ALMST_MiddleName" = '0' THEN '' ELSE ' ' || "ALMST_MiddleName" END ||
                    CASE WHEN "ALMST_LastName" IS NULL OR "ALMST_LastName" = '' OR "ALMST_LastName" = '0' THEN '' ELSE ' ' || "ALMST_LastName" END)
                FROM "ALU"."Alumni_Master_Student" WHERE "MI_Id" = p_MI_Id AND "ALMST_Id" = ASTI."ALSTINT_ToId")
            WHEN ASTI."ALSTINT_ToFlg" = 'Staff' THEN 
                (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = ASTI."ALSTINT_ToId")
            END) AS "Receiver",
            ASMI."ALSMINT_DateTime",
            ASMI."ALSMINT_ActiveFlag",
            ASTI."ALSTINT_Attachment",
            ASMI."ALSMINT_ComposedById"
        FROM "ALU"."Alumni_School_Master_Interactions" ASMI
        INNER JOIN "ALU"."Alumni_School_Transaction_Interactions" ASTI ON ASMI."ALSMINT_Id" = ASTI."ALSMINT_Id" AND ASMI."ALSMINT_ActiveFlag" = TRUE
        WHERE ASMI."MI_Id" = p_MI_Id AND ASMI."ASMAY_Id" = p_ASMAY_Id AND ASMI."ALSMINT_ActiveFlag" = TRUE 
            AND (ASTI."ALSTINT_ToId" = p_HRME_Id OR ASTI."ALSTINT_ComposedById" = p_HRME_Id)
        ORDER BY ASTI."ALSTINT_UpdatedDate" DESC;
        
    END IF;

    RETURN;

END;
$$;