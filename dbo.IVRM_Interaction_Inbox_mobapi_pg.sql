CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_Inbox_mobapi"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_Id BIGINT,
    p_HRME_Id BIGINT,
    p_roleflg VARCHAR(50)
)
RETURNS TABLE(
    "ISTINT_DateTime" TIMESTAMP,
    "ISTINT_Attachment" TEXT,
    "ISMINT_Id" BIGINT,
    "ISTINT_Id" BIGINT,
    "ISMINT_InteractionId" TEXT,
    "ISMINT_Subject" TEXT,
    "ISMINT_Interaction" TEXT,
    "ISMINT_GroupOrIndFlg" TEXT,
    "ISMINT_ComposedByFlg" TEXT,
    "ISTINT_ToFlg" TEXT,
    "ISTINT_ToId" BIGINT,
    "ISMINT_ComposedById" BIGINT,
    "Sender" TEXT,
    "sender_sender_filepath" TEXT,
    "role" TEXT,
    "Receiver" TEXT,
    "Receiver_filepath" TEXT,
    "ISMINT_DateTime" TIMESTAMP,
    "ISMINT_ActiveFlag" BOOLEAN,
    "ISTINT_ReadFlg" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

DROP TABLE IF EXISTS "StudentInt_Temptest1";
DROP TABLE IF EXISTS "StudentInt_Temptest2";
DROP TABLE IF EXISTS "StudentInt_Temptestfinal";
DROP TABLE IF EXISTS "StudentInt_Temptestfinal_read";
DROP TABLE IF EXISTS "StudentInt_Temptest6";
DROP TABLE IF EXISTS "StudentInt_Temptest3";
DROP TABLE IF EXISTS "StudentInt_Temptest4";
DROP TABLE IF EXISTS "StudentInt_Temptest5";

IF p_roleflg = 'Student' THEN

    CREATE TEMP TABLE "StudentInt_Temptest1" AS
    SELECT DISTINCT b."ISTINT_DateTime", b."ISTINT_Attachment", a."ISMINT_Id", b."ISTINT_Id", a."ISMINT_InteractionId", a."ISMINT_Subject", a."ISMINT_Interaction", a."ISMINT_GroupOrIndFlg", a."ISMINT_ComposedByFlg", b."ISTINT_ToFlg", b."ISTINT_ToId", a."ISMINT_ComposedById",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS "Sender",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS sender_sender_filepath,
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 'Staff' ELSE 'student' END) AS role,
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver",
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver_filepath",
    a."ISMINT_DateTime", a."ISMINT_ActiveFlag"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
    INNER JOIN "Adm_m_student" AM ON AM."AMST_ID" = b."ISTINT_ComposedById"
    WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ISMINT_ActiveFlag" = true AND b."ISTINT_ActiveFlag" = true 
      AND b."ISTINT_ComposedById" = p_AMST_Id AND b."ISTINT_ComposedByFlg" = 'Student'
    ORDER BY b."ISTINT_DateTime";

    CREATE TEMP TABLE "StudentInt_Temptest2" AS
    SELECT DISTINCT b."ISTINT_DateTime", b."ISTINT_Attachment", a."ISMINT_Id", b."ISTINT_Id", a."ISMINT_InteractionId", a."ISMINT_Subject", a."ISMINT_Interaction", a."ISMINT_GroupOrIndFlg", a."ISMINT_ComposedByFlg", b."ISTINT_ToFlg", b."ISTINT_ToId", a."ISMINT_ComposedById",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS "Sender",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS sender_filepath,
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 'Staff' ELSE 'student' END) AS role,
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver",
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver_filepath",
    a."ISMINT_DateTime", a."ISMINT_ActiveFlag"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
    INNER JOIN "Adm_m_student" AM ON AM."AMST_ID" = b."ISTINT_ToId"
    WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ISMINT_ActiveFlag" = true AND b."ISTINT_ActiveFlag" = true 
      AND b."ISTINT_ToId" = p_AMST_Id AND b."ISTINT_ToFlg" = 'Student'
    ORDER BY b."ISTINT_DateTime";

    CREATE TEMP TABLE "StudentInt_Temptestfinal" AS
    SELECT * FROM "StudentInt_Temptest1"
    UNION ALL
    SELECT * FROM "StudentInt_Temptest2";

END IF;

IF p_roleflg = 'Staff' THEN

    CREATE TEMP TABLE "StudentInt_Temptest1" AS
    SELECT DISTINCT b."ISTINT_Attachment", a."ISMINT_Id", b."ISTINT_Id", a."ISMINT_InteractionId", a."ISMINT_Subject", a."ISMINT_Interaction", a."ISMINT_GroupOrIndFlg", a."ISMINT_ComposedByFlg", b."ISTINT_ToFlg", a."ISMINT_ComposedById", b."ISTINT_ToId", b."ISTINT_DateTime",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS "Sender",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS sender_filepath,
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 'Staff' ELSE 'student' END) AS role,
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver",
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver_filepath",
    a."ISMINT_DateTime", a."ISMINT_ActiveFlag"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
    INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ComposedById"
    WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ISMINT_ActiveFlag" = true AND b."ISTINT_ActiveFlag" = true 
      AND b."ISTINT_ComposedById" = p_HRME_Id AND b."ISTINT_ComposedByFlg" = 'Staff'
    ORDER BY b."ISTINT_DateTime";

    CREATE TEMP TABLE "StudentInt_Temptest2" AS
    SELECT DISTINCT b."ISTINT_Attachment", a."ISMINT_Id", b."ISTINT_Id", a."ISMINT_InteractionId", a."ISMINT_Subject", a."ISMINT_Interaction", a."ISMINT_GroupOrIndFlg", a."ISMINT_ComposedByFlg", b."ISTINT_ToFlg", a."ISMINT_ComposedById", b."ISTINT_ToId", b."ISTINT_DateTime",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS "Sender",
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = a."ISMINT_ComposedById")
    WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = a."ISMINT_ComposedById")
    END) AS sender_filepath,
    (CASE WHEN a."ISMINT_ComposedByFlg" = 'Staff' THEN 'Staff' ELSE 'student' END) AS role,
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
         CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver",
    (CASE WHEN b."ISTINT_ToFlg" = 'Student' THEN 
        (SELECT DISTINCT (CASE WHEN "AMST_Photoname" IS NULL OR "AMST_Photoname" = '' THEN '' ELSE "AMST_Photoname" END)
         FROM "Adm_M_Student" WHERE "MI_Id" = p_MI_Id AND "AMST_Id" = b."ISTINT_ToId")
    WHEN b."ISTINT_ToFlg" = 'Staff' THEN 
        (SELECT DISTINCT (CASE WHEN "HRME_Photo" IS NULL OR "HRME_Photo" = '' THEN '' ELSE "HRME_Photo" END)
         FROM "HR_Master_Employee" WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = b."ISTINT_ToId")
    END) AS "Receiver_filepath",
    a."ISMINT_DateTime", a."ISMINT_ActiveFlag"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
    INNER JOIN "HR_MASTER_EMPLOYEE" HR ON HR."HRME_ID" = b."ISTINT_ToId"
    WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ISMINT_ActiveFlag" = true AND b."ISTINT_ActiveFlag" = true 
      AND b."ISTINT_ToId" = p_HRME_Id AND b."ISTINT_ToFlg" = 'Staff'
    ORDER BY