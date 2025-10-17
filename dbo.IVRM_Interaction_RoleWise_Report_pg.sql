CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_RoleWise_Report"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_RoleType varchar(30),
    p_StuORStaffId bigint,
    p_FromDate varchar(10),
    p_ToDate varchar(10)
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
    "ISMINT_InteractionId" varchar,
    "ISMINT_Subject" text,
    "ISMINT_ComposedByFlg" varchar,
    "ISMINT_DateTime" timestamp,
    "Sender" text,
    "Receiver" text
)
LANGUAGE plpgsql
AS $$
BEGIN

IF (p_RoleType = 'Staff') THEN

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
    a."ISMINT_InteractionId",
    a."ISMINT_Subject",
    a."ISMINT_ComposedByFlg",
    a."ISMINT_DateTime",
    (CASE WHEN b."ISTINT_ComposedByFlg"='Student' THEN 
        (SELECT DISTINCT (CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName"='' THEN '' ELSE s."AMST_FirstName" END ||
         CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END || 
         CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END) 
         FROM "Adm_M_Student" s WHERE s."MI_Id"=p_MI_Id AND s."AMST_Id"=b."ISTINT_ComposedById" LIMIT 1)
    WHEN b."ISTINT_ComposedByFlg"='Staff' THEN 
        (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName"='' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
         CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
         CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" e WHERE e."MI_Id"=p_MI_Id AND e."HRME_Id"=b."ISTINT_ComposedById" AND b."ISTINT_ComposedById"=p_StuORStaffId LIMIT 1)
    END)::text AS "Sender",
    (CASE WHEN b."ISTINT_ToFlg"='Student' THEN 
        (SELECT DISTINCT (CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName"='' THEN '' ELSE s."AMST_FirstName" END ||
         CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END || 
         CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END) 
         FROM "Adm_M_Student" s WHERE s."MI_Id"=p_MI_Id AND s."AMST_Id"=b."ISTINT_ToId" LIMIT 1)
    WHEN b."ISTINT_ToFlg"='Staff' THEN 
        (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName"='' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
         CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
         CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" e WHERE e."MI_Id"=p_MI_Id AND e."HRME_Id"=b."ISTINT_ToId" AND b."ISTINT_ToId"=p_StuORStaffId LIMIT 1)
    END)::text AS "Receiver"
FROM "IVRM_School_Master_Interactions" a
INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id"=b."ISMINT_Id"
WHERE a."MI_Id"=p_MI_Id AND a."ASMAY_Id"=p_ASMAY_Id 
    AND CAST(a."ISMINT_DateTime" AS DATE) BETWEEN CAST(p_FromDate AS DATE) AND CAST(p_ToDate AS DATE)
ORDER BY b."ISTINT_DateTime";

ELSIF (p_RoleType = 'Student') THEN

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
    a."ISMINT_InteractionId",
    a."ISMINT_Subject",
    a."ISMINT_ComposedByFlg",
    a."ISMINT_DateTime",
    (CASE WHEN b."ISTINT_ComposedByFlg"='Student' THEN 
        (SELECT DISTINCT (CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName"='' THEN '' ELSE s."AMST_FirstName" END ||
         CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END || 
         CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END) 
         FROM "Adm_M_Student" s WHERE s."MI_Id"=p_MI_Id AND s."AMST_Id"=b."ISTINT_ComposedById" AND b."ISTINT_ComposedById"=p_StuORStaffId LIMIT 1)
    WHEN b."ISTINT_ComposedByFlg"='Staff' THEN 
        (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName"='' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
         CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
         CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" e WHERE e."MI_Id"=p_MI_Id AND e."HRME_Id"=b."ISTINT_ComposedById" LIMIT 1)
    END)::text AS "Sender",
    (CASE WHEN b."ISTINT_ToFlg"='Student' THEN 
        (SELECT DISTINCT (CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName"='' THEN '' ELSE s."AMST_FirstName" END ||
         CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END || 
         CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END) 
         FROM "Adm_M_Student" s WHERE s."MI_Id"=p_MI_Id AND s."AMST_Id"=b."ISTINT_ToId" AND b."ISTINT_ToId"=p_StuORStaffId LIMIT 1)
    WHEN b."ISTINT_ToFlg"='Staff' THEN 
        (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName"='' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
         CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
         CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" e WHERE e."MI_Id"=p_MI_Id AND e."HRME_Id"=b."ISTINT_ToId" LIMIT 1)
    END)::text AS "Receiver"
FROM "IVRM_School_Master_Interactions" a
INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id"=b."ISMINT_Id"
WHERE a."MI_Id"=p_MI_Id AND a."ASMAY_Id"=p_ASMAY_Id 
    AND CAST(a."ISMINT_DateTime" AS DATE) BETWEEN CAST(p_FromDate AS DATE) AND CAST(p_ToDate AS DATE)
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
    a."ISMINT_InteractionId",
    a."ISMINT_Subject",
    a."ISMINT_ComposedByFlg",
    a."ISMINT_DateTime",
    (CASE WHEN b."ISTINT_ComposedByFlg"='Student' THEN 
        (SELECT DISTINCT (CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName"='' THEN '' ELSE s."AMST_FirstName" END ||
         CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END || 
         CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END) 
         FROM "Adm_M_Student" s WHERE s."MI_Id"=p_MI_Id AND s."AMST_Id"=b."ISTINT_ComposedById" LIMIT 1)
    WHEN b."ISTINT_ComposedByFlg"='Staff' THEN 
        (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName"='' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
         CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
         CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" e WHERE e."MI_Id"=p_MI_Id AND e."HRME_Id"=b."ISTINT_ComposedById" LIMIT 1)
    END)::text AS "Sender",
    (CASE WHEN b."ISTINT_ToFlg"='Student' THEN 
        (SELECT DISTINCT (CASE WHEN s."AMST_FirstName" IS NULL OR s."AMST_FirstName"='' THEN '' ELSE s."AMST_FirstName" END ||
         CASE WHEN s."AMST_MiddleName" IS NULL OR s."AMST_MiddleName" = '' OR s."AMST_MiddleName" = '0' THEN '' ELSE ' ' || s."AMST_MiddleName" END || 
         CASE WHEN s."AMST_LastName" IS NULL OR s."AMST_LastName" = '' OR s."AMST_LastName" = '0' THEN '' ELSE ' ' || s."AMST_LastName" END) 
         FROM "Adm_M_Student" s WHERE s."MI_Id"=p_MI_Id AND s."AMST_Id"=b."ISTINT_ToId" LIMIT 1)
    WHEN b."ISTINT_ToFlg"='Staff' THEN 
        (SELECT DISTINCT (CASE WHEN e."HRME_EmployeeFirstName" IS NULL OR e."HRME_EmployeeFirstName"='' THEN '' ELSE e."HRME_EmployeeFirstName" END ||
         CASE WHEN e."HRME_EmployeeMiddleName" IS NULL OR e."HRME_EmployeeMiddleName" = '' OR e."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeMiddleName" END || 
         CASE WHEN e."HRME_EmployeeLastName" IS NULL OR e."HRME_EmployeeLastName" = '' OR e."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || e."HRME_EmployeeLastName" END)
         FROM "HR_Master_Employee" e WHERE e."MI_Id"=p_MI_Id AND e."HRME_Id"=b."ISTINT_ToId" LIMIT 1)
    END)::text AS "Receiver"
FROM "IVRM_School_Master_Interactions" a
INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id"=b."ISMINT_Id"
WHERE a."MI_Id"=p_MI_Id AND a."ASMAY_Id"=p_ASMAY_Id 
    AND CAST(a."ISMINT_DateTime" AS DATE) BETWEEN CAST(p_FromDate AS DATE) AND CAST(p_ToDate AS DATE)
ORDER BY b."ISTINT_DateTime";

END IF;

END;
$$;