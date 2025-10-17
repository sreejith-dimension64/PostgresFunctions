CREATE OR REPLACE FUNCTION "dbo"."IVRM_ClassHomeworkGrid_List"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "HRME_Id" bigint,
    "Login_Id" bigint,
    "Type" varchar(30)
)
RETURNS TABLE(
    "asmcL_ClassName" varchar,
    "asmcL_Id" bigint,
    "asmC_SectionName" varchar,
    "asmS_Id" bigint,
    "ismS_SubjectName" varchar,
    "ismS_Id" bigint,
    "IHW_AssignmentNo" varchar,
    "ihW_Attachment" varchar,
    "ihW_Assignment" text,
    "ihW_Date" timestamp,
    "ihW_Topic" varchar,
    "ihW_ActiveFlag" boolean,
    "ihW_Id" bigint,
    "asmaY_Id" bigint,
    "IVRMUL_Id" bigint,
    "IHW_FilePath" varchar,
    "icW_Id" bigint,
    "icW_Content" text,
    "icW_Topic" varchar,
    "icW_SubTopic" varchar,
    "icW_FromDate" timestamp,
    "icW_ToDate" timestamp,
    "icW_ActiveFlag" boolean,
    "icW_Assignment" varchar,
    "icW_TeachingAid" varchar,
    "icW_Evaluation" varchar,
    "icW_Attachment" varchar,
    "icW_FilePath" varchar,
    "mI_Id" bigint,
    "FilesCount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "role" varchar(50);
    "HRME_Id_local" bigint;
BEGIN
    "HRME_Id_local" := "HRME_Id";

    SELECT b."IVRMRT_Role" INTO "role"
    FROM "ApplicationUserRole" a
    INNER JOIN "IVRM_Role_Type" b ON a."RoleTypeId" = b."IVRMRT_Id"
    WHERE a."UserId" = "Login_Id";

    IF "role" = 'HOD' THEN
        SELECT "Emp_Code" INTO "HRME_Id_local"
        FROM "IVRM_Staff_User_Login"
        WHERE "id" = "Login_Id";
    END IF;

    IF "Type" = 'Homework' THEN
        IF "HRME_Id_local" = 0 THEN
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName"::varchar AS "asmcL_ClassName",
                NULL::bigint AS "asmcL_Id",
                o."ASMC_SectionName"::varchar AS "asmC_SectionName",
                NULL::bigint AS "asmS_Id",
                p."ISMS_SubjectName"::varchar AS "ismS_SubjectName",
                NULL::bigint AS "ismS_Id",
                m."IHW_AssignmentNo"::varchar,
                m."IHW_Attachment"::varchar AS "ihW_Attachment",
                m."IHW_Assignment"::text AS "ihW_Assignment",
                m."IHW_Date"::timestamp AS "ihW_Date",
                m."IHW_Topic"::varchar AS "ihW_Topic",
                m."IHW_ActiveFlag"::boolean AS "ihW_ActiveFlag",
                m."IHW_Id"::bigint AS "ihW_Id",
                m."ASMAY_Id"::bigint AS "asmaY_Id",
                m."IVRMUL_Id"::bigint,
                m."IHW_FilePath"::varchar,
                NULL::bigint AS "icW_Id",
                NULL::text AS "icW_Content",
                NULL::varchar AS "icW_Topic",
                NULL::varchar AS "icW_SubTopic",
                NULL::timestamp AS "icW_FromDate",
                NULL::timestamp AS "icW_ToDate",
                NULL::boolean AS "icW_ActiveFlag",
                NULL::varchar AS "icW_Assignment",
                NULL::varchar AS "icW_TeachingAid",
                NULL::varchar AS "icW_Evaluation",
                NULL::varchar AS "icW_Attachment",
                NULL::varchar AS "icW_FilePath",
                NULL::bigint AS "mI_Id",
                (SELECT count(*) FROM "IVRM_HomeWork_Attatchment" HA WHERE HA."IHW_Id" = m."IHW_Id")::bigint AS "FilesCount"
            FROM "IVRM_HomeWork" m
            LEFT JOIN "Adm_School_M_Class" n ON m."ASMCL_Id" = n."ASMCL_Id" AND n."MI_Id" = "MI_Id"
            LEFT JOIN "Adm_School_M_Section" o ON m."ASMS_Id" = o."ASMS_Id" AND o."MI_Id" = "MI_Id"
            LEFT JOIN "IVRM_Master_Subjects" p ON m."ISMS_Id" = p."ISMS_Id" AND p."MI_Id" = "MI_Id"
            WHERE m."MI_Id" = "MI_Id" AND m."ASMAY_Id" = "ASMAY_Id" AND p."MI_Id" = "MI_Id"
            ORDER BY m."IHW_Id" DESC;
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName"::varchar AS "asmcL_ClassName",
                NULL::bigint AS "asmcL_Id",
                o."ASMC_SectionName"::varchar AS "asmC_SectionName",
                NULL::bigint AS "asmS_Id",
                p."ISMS_SubjectName"::varchar AS "ismS_SubjectName",
                NULL::bigint AS "ismS_Id",
                m."IHW_AssignmentNo"::varchar,
                m."IHW_Attachment"::varchar AS "ihW_Attachment",
                m."IHW_Assignment"::text AS "ihW_Assignment",
                m."IHW_Date"::timestamp AS "ihW_Date",
                m."IHW_Topic"::varchar AS "ihW_Topic",
                m."IHW_ActiveFlag"::boolean AS "ihW_ActiveFlag",
                m."IHW_Id"::bigint AS "ihW_Id",
                m."ASMAY_Id"::bigint AS "asmaY_Id",
                m."IVRMUL_Id"::bigint,
                m."IHW_FilePath"::varchar,
                NULL::bigint AS "icW_Id",
                NULL::text AS "icW_Content",
                NULL::varchar AS "icW_Topic",
                NULL::varchar AS "icW_SubTopic",
                NULL::timestamp AS "icW_FromDate",
                NULL::timestamp AS "icW_ToDate",
                NULL::boolean AS "icW_ActiveFlag",
                NULL::varchar AS "icW_Assignment",
                NULL::varchar AS "icW_TeachingAid",
                NULL::varchar AS "icW_Evaluation",
                NULL::varchar AS "icW_Attachment",
                NULL::varchar AS "icW_FilePath",
                NULL::bigint AS "mI_Id",
                (SELECT count(*) FROM "IVRM_HomeWork_Attatchment" HA WHERE HA."IHW_Id" = m."IHW_Id")::bigint AS "FilesCount"
            FROM "IVRM_HomeWork" m
            INNER JOIN "Adm_School_M_Class" n ON m."ASMCL_Id" = n."ASMCL_Id" AND n."MI_Id" = "MI_Id"
            INNER JOIN "Adm_School_M_Section" o ON m."ASMS_Id" = o."ASMS_Id" AND o."MI_Id" = "MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON m."ISMS_Id" = p."ISMS_Id" AND p."MI_Id" = "MI_Id"
            LEFT JOIN "IVRM_Staff_User_Login" z ON m."IVRMUL_Id" = z."Id" AND z."MI_Id" = "MI_Id"
            WHERE m."IVRMUL_Id" = "Login_Id" AND m."MI_Id" = "MI_Id" AND m."ASMAY_Id" = "ASMAY_Id" AND p."MI_Id" = "MI_Id"
            ORDER BY m."IHW_Id" DESC;
        END IF;
    ELSIF "Type" = 'Classwork' THEN
        IF "HRME_Id_local" = 0 THEN
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName"::varchar AS "asmcL_ClassName",
                n."ASMCL_Id"::bigint AS "asmcL_Id",
                o."ASMC_SectionName"::varchar AS "asmC_SectionName",
                o."ASMS_Id"::bigint AS "asmS_Id",
                p."ISMS_SubjectName"::varchar AS "ismS_SubjectName",
                p."ISMS_Id"::bigint AS "ismS_Id",
                NULL::varchar AS "IHW_AssignmentNo",
                NULL::varchar AS "ihW_Attachment",
                NULL::text AS "ihW_Assignment",
                NULL::timestamp AS "ihW_Date",
                NULL::varchar AS "ihW_Topic",
                NULL::boolean AS "ihW_ActiveFlag",
                NULL::bigint AS "ihW_Id",
                m."ASMAY_Id"::bigint AS "asmaY_Id",
                NULL::bigint AS "IVRMUL_Id",
                NULL::varchar AS "IHW_FilePath",
                m."ICW_Id"::bigint AS "icW_Id",
                m."ICW_Content"::text AS "icW_Content",
                m."ICW_Topic"::varchar AS "icW_Topic",
                m."ICW_SubTopic"::varchar AS "icW_SubTopic",
                m."ICW_FromDate"::timestamp AS "icW_FromDate",
                m."ICW_ToDate"::timestamp AS "icW_ToDate",
                m."ICW_ActiveFlag"::boolean AS "icW_ActiveFlag",
                m."ICW_Assignment"::varchar AS "icW_Assignment",
                m."ICW_TeachingAid"::varchar AS "icW_TeachingAid",
                m."ICW_Evaluation"::varchar AS "icW_Evaluation",
                m."ICW_Attachment"::varchar AS "icW_Attachment",
                m."ICW_FilePath"::varchar AS "icW_FilePath",
                m."MI_Id"::bigint AS "mI_Id",
                (SELECT count(*) FROM "IVRM_ClassWork_Attatchment" HA WHERE HA."ICW_Id" = m."ICW_Id")::bigint AS "FilesCount"
            FROM "IVRM_Assignment" m
            INNER JOIN "Adm_School_M_Section" o ON m."ASMS_Id" = o."ASMS_Id" AND o."MI_Id" = "MI_Id"
            INNER JOIN "Adm_School_M_Class" n ON m."ASMCL_Id" = n."ASMCL_Id" AND n."MI_Id" = "MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON m."ISMS_Id" = p."ISMS_Id" AND p."MI_Id" = "MI_Id"
            WHERE m."MI_Id" = "MI_Id" AND m."ASMAY_Id" = "ASMAY_Id"
            ORDER BY m."ICW_Id" DESC;
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
                n."ASMCL_ClassName"::varchar AS "asmcL_ClassName",
                n."ASMCL_Id"::bigint AS "asmcL_Id",
                o."ASMC_SectionName"::varchar AS "asmC_SectionName",
                o."ASMS_Id"::bigint AS "asmS_Id",
                p."ISMS_SubjectName"::varchar AS "ismS_SubjectName",
                p."ISMS_Id"::bigint AS "ismS_Id",
                NULL::varchar AS "IHW_AssignmentNo",
                NULL::varchar AS "ihW_Attachment",
                NULL::text AS "ihW_Assignment",
                NULL::timestamp AS "ihW_Date",
                NULL::varchar AS "ihW_Topic",
                NULL::boolean AS "ihW_ActiveFlag",
                NULL::bigint AS "ihW_Id",
                m."ASMAY_Id"::bigint AS "asmaY_Id",
                NULL::bigint AS "IVRMUL_Id",
                NULL::varchar AS "IHW_FilePath",
                m."ICW_Id"::bigint AS "icW_Id",
                m."ICW_Content"::text AS "icW_Content",
                m."ICW_Topic"::varchar AS "icW_Topic",
                m."ICW_SubTopic"::varchar AS "icW_SubTopic",
                m."ICW_FromDate"::timestamp AS "icW_FromDate",
                m."ICW_ToDate"::timestamp AS "icW_ToDate",
                m."ICW_ActiveFlag"::boolean AS "icW_ActiveFlag",
                m."ICW_Assignment"::varchar AS "icW_Assignment",
                m."ICW_TeachingAid"::varchar AS "icW_TeachingAid",
                m."ICW_Evaluation"::varchar AS "icW_Evaluation",
                m."ICW_Attachment"::varchar AS "icW_Attachment",
                m."ICW_FilePath"::varchar AS "icW_FilePath",
                m."MI_Id"::bigint AS "mI_Id",
                (SELECT count(*) FROM "IVRM_ClassWork_Attatchment" HA WHERE HA."ICW_Id" = m."ICW_Id")::bigint AS "FilesCount"
            FROM "IVRM_Assignment" m
            INNER JOIN "Adm_School_M_Section" o ON m."ASMS_Id" = o."ASMS_Id" AND o."MI_Id" = "MI_Id"
            INNER JOIN "Adm_School_M_Class" n ON m."ASMCL_Id" = n."ASMCL_Id" AND n."MI_Id" = "MI_Id"
            INNER JOIN "IVRM_Master_Subjects" p ON m."ISMS_Id" = p."ISMS_Id" AND p."MI_Id" = "MI_Id"
            LEFT JOIN "IVRM_Staff_User_Login" z ON m."Login_Id" = z."Id" AND z."MI_Id" = "MI_Id"
            WHERE m."MI_Id" = "MI_Id" AND m."Login_Id" = "Login_Id" AND m."ASMAY_Id" = "ASMAY_Id"
            ORDER BY m."ICW_Id" DESC;
        END IF;
    END IF;

    RETURN;
END;
$$;