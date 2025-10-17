CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_edit_modfiy"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "IHW_Id" bigint,
    "AMST_Id" bigint,
    "Parameter" varchar(50)
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "studentname" text,
    "amst_admno" varchar,
    "IHW_Id" bigint,
    "IHW_Topic" text,
    "IHW_Assignment" text,
    "IHW_Date" varchar,
    "IHWUPL_Marks" numeric,
    "ISMS_SubjectName" varchar,
    "IHW_FilePath1" text,
    "IHWUPL_StaffRemarks" text,
    "FilesCount" bigint,
    "IHWUPL_Id" bigint,
    "ICW_Id" bigint,
    "ICW_Topic" text,
    "ICW_Assignment" text,
    "ICW_FromDate" varchar,
    "ICW_ToDate" varchar,
    "ICWUPL_Marks" numeric,
    "ICW_SubTopic" text,
    "ICW_FilePath1" text,
    "ICWUPL_StaffRemarks" text,
    "ICWUPL_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "Parameter" = 'Homework' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."AMST_Id",
            (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
             CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
             CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' THEN '' ELSE ' ' || d."AMST_LastName" END)::text AS "studentname",
            d."amst_admno",
            a."IHW_Id",
            COALESCE(a."IHW_Topic", '')::text AS "IHW_Topic",
            COALESCE(a."IHW_Assignment", '')::text AS "IHW_Assignment",
            TO_CHAR(a."IHW_Date", 'DD/MM/YYYY') AS "IHW_Date",
            c."IHWUPL_Marks",
            e."ISMS_SubjectName",
            c."IHWUPL_StaffUpload"::text AS "IHW_FilePath1",
            c."IHWUPL_StaffRemarks"::text,
            (SELECT COUNT(*) FROM "IVRM_HomeWork_Attatchment" CA WHERE CA."IHW_Id" = a."IHW_Id") AS "FilesCount",
            c."IHWUPL_Id",
            NULL::bigint AS "ICW_Id",
            NULL::text AS "ICW_Topic",
            NULL::text AS "ICW_Assignment",
            NULL::varchar AS "ICW_FromDate",
            NULL::varchar AS "ICW_ToDate",
            NULL::numeric AS "ICWUPL_Marks",
            NULL::text AS "ICW_SubTopic",
            NULL::text AS "ICW_FilePath1",
            NULL::text AS "ICWUPL_StaffRemarks",
            NULL::bigint AS "ICWUPL_Id"
        FROM "IVRM_HomeWork" a
        INNER JOIN "Adm_School_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
            AND YS."ASMCL_Id" = a."ASMCL_Id" 
            AND YS."ASMS_Id" = a."ASMS_Id" 
            AND YS."ASMAY_Id" = "ASMAY_Id"
        INNER JOIN "IVRM_HomeWork_Attatchment" b ON b."IHW_Id" = a."IHW_Id"
        INNER JOIN "IVRM_HomeWork_Upload" c ON c."IHW_Id" = b."IHW_Id" 
            AND c."AMST_Id" = YS."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" 
            AND d."MI_Id" = "MI_Id"
        INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = a."ISMS_ID" 
            AND e."MI_Id" = "MI_Id"
        WHERE c."AMST_Id" = "AMST_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."MI_Id" = "MI_Id" 
            AND c."IHW_Id" = "IHW_Id";

    ELSIF "Parameter" = 'Classwork' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."AMST_Id",
            (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
             CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
             CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' THEN '' ELSE ' ' || d."AMST_LastName" END)::text AS "studentname",
            d."amst_admno",
            NULL::bigint AS "IHW_Id",
            NULL::text AS "IHW_Topic",
            NULL::text AS "IHW_Assignment",
            NULL::varchar AS "IHW_Date",
            NULL::numeric AS "IHWUPL_Marks",
            e."ISMS_SubjectName",
            NULL::text AS "IHW_FilePath1",
            NULL::text AS "IHWUPL_StaffRemarks",
            NULL::bigint AS "FilesCount",
            NULL::bigint AS "IHWUPL_Id",
            a."ICW_Id",
            COALESCE(a."ICW_Topic", '')::text AS "ICW_Topic",
            COALESCE(a."ICW_Assignment", '')::text AS "ICW_Assignment",
            TO_CHAR(a."ICW_FromDate", 'DD/MM/YYYY') AS "ICW_FromDate",
            TO_CHAR(a."ICW_ToDate", 'DD/MM/YYYY') AS "ICW_ToDate",
            c."ICWUPL_Marks",
            a."ICW_SubTopic"::text,
            c."ICWUPL_StaffUplaod"::text AS "ICW_FilePath1",
            c."ICWUPL_StaffRemarks"::text,
            c."ICWUPL_Id"
        FROM "IVRM_Assignment" a
        INNER JOIN "Adm_School_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
            AND YS."ASMCL_Id" = a."ASMCL_Id" 
            AND YS."ASMS_Id" = a."ASMS_Id" 
            AND YS."ASMAY_Id" = "ASMAY_Id"
        INNER JOIN "IVRM_ClassWork_Attatchment" b ON b."ICW_Id" = a."ICW_Id"
        INNER JOIN "IVRM_ClassWork_Upload" c ON c."ICW_Id" = a."ICW_Id" 
            AND c."AMST_Id" = YS."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" 
            AND d."MI_Id" = "MI_Id"
        INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = a."ISMS_ID"
        WHERE c."AMST_Id" = "AMST_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."MI_Id" = "MI_Id" 
            AND c."ICW_Id" = "IHW_Id";

    END IF;

    RETURN;

END;
$$;