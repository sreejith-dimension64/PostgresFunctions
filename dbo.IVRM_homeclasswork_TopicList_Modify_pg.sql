CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_TopicList_Modify"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@AMST_Id" text,
    "@Login_Id" bigint,
    "@Parameter" text,
    "@ISMS_Id" bigint,
    "@fromdate" varchar(40),
    "@todate" varchar(40),
    "@Topic_Id" bigint
)
RETURNS TABLE(
    "IHW_Id" bigint,
    "ICW_Id" bigint,
    "ICWUPL_Id" bigint,
    "AMST_Id" bigint,
    "studentname" text,
    "amst_admno" text,
    "IHW_Topic" text,
    "ICW_Topic" text,
    "ICW_SubTopic" text,
    "ICW_Content" text,
    "IHW_Assignment" text,
    "ICW_Assignment" text,
    "IHW_Date" text,
    "ICW_FromDate" text,
    "ICW_ToDate" text,
    "ISMS_SubjectName" text,
    "FilesCount" bigint,
    "IHWUPL_Id" bigint,
    "IHWUPL_StaffRemarks" text,
    "ICWUPL_StaffRemarks" text,
    "IHW_FilePath1" text,
    "ICW_FilePath1" text,
    "IHWUPL_Marks" numeric,
    "ICWUPL_Marks" numeric,
    "AMST_Photoname" text,
    "FileName1" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@sqlexec" text;
    "@ISMS_Id1" text;
    "@date" text;
    "@topic_ids" text;
BEGIN
    IF "@ISMS_Id" IS NOT NULL AND "@ISMS_Id" != 0 THEN
        "@ISMS_Id1" := 'AND e."ISMS_Id"=' || "@ISMS_Id"::varchar;
    ELSE
        "@ISMS_Id1" := '';
    END IF;

    IF "@Topic_Id" > 0 AND "@Parameter" = 'Classwork' THEN
        "@topic_ids" := 'AND e."ICW_Id"=' || "@Topic_Id"::varchar;
    ELSE
        "@topic_ids" := '';
    END IF;

    IF "@Topic_Id" > 0 AND "@Parameter" = 'Homework' THEN
        "@topic_ids" := 'AND e."IHW_Id"=' || "@Topic_Id"::varchar;
    ELSE
        "@topic_ids" := '';
    END IF;

    IF "@Parameter" = 'Homework' THEN
        IF "@fromdate" IS NOT NULL AND "@fromdate" != '' AND "@todate" IS NOT NULL AND "@todate" != '' THEN
            "@date" := 'AND b."IHWUPL_Date"::date BETWEEN ''' || "@fromdate" || '''::date AND ''' || "@todate" || '''::date';
        ELSE
            "@date" := '';
        END IF;

        "@sqlexec" := '
        SELECT DISTINCT b."IHW_Id", NULL::bigint AS "ICW_Id", NULL::bigint AS "ICWUPL_Id", d."AMST_Id",
        (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName"='''' THEN '''' ELSE d."AMST_FirstName" END ||
        CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName"='''' THEN '''' ELSE '' '' || d."AMST_MiddleName" END ||
        CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName"='''' THEN '''' ELSE '' '' || d."AMST_LastName" END) AS studentname,
        d."amst_admno",
        COALESCE(e."IHW_Topic", '''') AS "IHW_Topic",
        NULL::text AS "ICW_Topic",
        NULL::text AS "ICW_SubTopic",
        NULL::text AS "ICW_Content",
        COALESCE(e."IHW_Assignment", '''') AS "IHW_Assignment",
        NULL::text AS "ICW_Assignment",
        TO_CHAR(e."IHW_Date", ''DD/MM/YYYY'') AS "IHW_Date",
        NULL::text AS "ICW_FromDate",
        NULL::text AS "ICW_ToDate",
        f."ISMS_SubjectName",
        (SELECT COUNT(*) FROM "IVRM_HomeWork_Attatchment" HA WHERE HA."IHW_Id" = e."IHW_Id") AS "FilesCount",
        b."IHWUPL_Id",
        COALESCE(b."IHWUPL_StaffRemarks", '''') AS "IHWUPL_StaffRemarks",
        NULL::text AS "ICWUPL_StaffRemarks",
        b."IHWUPL_StaffUpload" AS "IHW_FilePath1",
        NULL::text AS "ICW_FilePath1",
        b."IHWUPL_Marks",
        NULL::numeric AS "ICWUPL_Marks",
        d."AMST_Photoname",
        NULL::text AS "FileName1"
        FROM "Adm_School_Y_Student" a
        INNER JOIN "IVRM_HomeWork_Upload" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = a."AMST_Id"
        INNER JOIN "IVRM_HomeWork" e ON e."IHW_Id" = b."IHW_Id"
        INNER JOIN "IVRM_Master_Subjects" f ON f."ISMS_Id" = e."ISMS_Id"
        WHERE a."ASMCL_Id" = ' || "@ASMCL_Id"::varchar || ' AND a."ASMS_Id" = ' || "@ASMS_Id"::varchar || 
        ' AND a."ASMAY_Id" = ' || "@ASMAY_Id"::varchar || 
        ' AND f."MI_Id" = ' || "@MI_Id"::varchar || ' AND e."IVRMUL_Id" = ' || "@Login_Id"::varchar || ' ' || 
        "@ISMS_Id1" || ' ' || "@date" || ' ' || "@topic_ids" || ' ORDER BY b."IHW_Id" DESC';

        RETURN QUERY EXECUTE "@sqlexec";

    ELSIF "@Parameter" = 'Classwork' THEN
        IF "@fromdate" IS NOT NULL AND "@fromdate" != '' AND "@todate" IS NOT NULL AND "@todate" != '' THEN
            "@date" := 'AND b."ICWUPL_Date"::date BETWEEN ''' || "@fromdate" || '''::date AND ''' || "@todate" || '''::date';
        ELSE
            "@date" := '';
        END IF;

        "@sqlexec" := '
        SELECT DISTINCT NULL::bigint AS "IHW_Id", b."ICW_Id", b."ICWUPL_Id", d."AMST_Id",
        (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName"='''' THEN '''' ELSE d."AMST_FirstName" END ||
        CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName"='''' THEN '''' ELSE '' '' || d."AMST_MiddleName" END ||
        CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName"='''' THEN '''' ELSE '' '' || d."AMST_LastName" END) AS studentname,
        d."amst_admno",
        NULL::text AS "IHW_Topic",
        COALESCE(e."ICW_Topic", '''') AS "ICW_Topic",
        COALESCE(e."ICW_SubTopic", '''') AS "ICW_SubTopic",
        COALESCE(e."ICW_Content", '''') AS "ICW_Content",
        NULL::text AS "IHW_Assignment",
        COALESCE(e."ICW_Assignment", '''') AS "ICW_Assignment",
        NULL::text AS "IHW_Date",
        TO_CHAR(e."ICW_FromDate", ''DD/MM/YYYY'') AS "ICW_FromDate",
        TO_CHAR(e."ICW_ToDate", ''DD/MM/YYYY'') AS "ICW_ToDate",
        f."ISMS_SubjectName",
        (SELECT COUNT(*) FROM "IVRM_ClassWork_Attatchment" CA WHERE CA."ICW_Id" = e."ICW_Id") AS "FilesCount",
        NULL::bigint AS "IHWUPL_Id",
        NULL::text AS "IHWUPL_StaffRemarks",
        COALESCE(b."ICWUPL_StaffRemarks", '''') AS "ICWUPL_StaffRemarks",
        NULL::text AS "IHW_FilePath1",
        b."ICWUPL_StaffUplaod" AS "ICW_FilePath1",
        NULL::numeric AS "IHWUPL_Marks",
        b."ICWUPL_Marks",
        d."AMST_Photoname",
        b."ICWUPL_FileName" AS "FileName1"
        FROM "Adm_School_Y_Student" a
        INNER JOIN "IVRM_ClassWork_Upload" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = a."AMST_Id"
        INNER JOIN "IVRM_Assignment" e ON e."ICW_Id" = b."ICW_Id"
        INNER JOIN "IVRM_Master_Subjects" f ON f."ISMS_Id" = e."ISMS_Id"
        WHERE a."ASMCL_Id" = ' || "@ASMCL_Id"::varchar || ' AND a."ASMS_Id" = ' || "@ASMS_Id"::varchar || 
        ' AND a."ASMAY_Id" = ' || "@ASMAY_Id"::varchar || 
        ' AND f."MI_Id" = ' || "@MI_Id"::varchar || ' AND e."Login_Id" = ' || "@Login_Id"::varchar || ' ' || 
        "@ISMS_Id1" || ' ' || "@date" || ' ' || "@topic_ids" || ' ORDER BY b."ICW_Id" DESC';

        RETURN QUERY EXECUTE "@sqlexec";
    END IF;

    RETURN;
END;
$$;