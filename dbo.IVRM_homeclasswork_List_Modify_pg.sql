CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_List_Modify"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "AMST_Id" text,
    "Login_Id" bigint,
    "Parameter" text,
    "ISMS_Id" bigint,
    "fromdate" varchar(40),
    "todate" varchar(40)
)
RETURNS TABLE (
    "IHW_Id" bigint,
    "ICW_Id" bigint,
    "AMST_Id" bigint,
    "studentname" text,
    "amst_admno" varchar,
    "IHW_Topic" text,
    "IHW_Assignment" text,
    "IHW_Date" varchar,
    "ICW_Topic" text,
    "ICW_SubTopic" text,
    "ICW_Content" text,
    "ICW_Assignment" text,
    "ICW_FromDate" varchar,
    "ICW_ToDate" varchar,
    "ISMS_SubjectName" varchar,
    "FilesCount" bigint,
    "IHWUPL_Id" bigint,
    "ICWUPL_Id" bigint,
    "IHWUPL_StaffRemarks" text,
    "ICWUPL_StaffRemarks" text,
    "IHW_FilePath1" text,
    "ICW_FilePath1" text,
    "IHWUPL_Marks" numeric,
    "ICWUPL_Marks" numeric,
    "FileName1" varchar,
    "CreatedTime" text,
    "CreatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" text;
    "ISMS_Id1" text;
    "date" text;
BEGIN
    IF "ISMS_Id" IS NOT NULL AND "ISMS_Id" != 0 THEN
        "ISMS_Id1" := 'and e."ISMS_Id"=' || "ISMS_Id"::varchar || '';
    ELSE
        "ISMS_Id1" := '';
    END IF;

    IF "Parameter" = 'Homework' THEN
        
        IF ("fromdate" IS NOT NULL AND "fromdate" != '') AND ("todate" IS NOT NULL AND "todate" != '') THEN
            "date" := 'and b."IHWUPL_Date"::date between ''' || "fromdate" || '''::date and ''' || "todate" || '''::date';
        ELSE
            "date" := '';
        END IF;

        RETURN QUERY EXECUTE 
        'select distinct b."IHW_Id", NULL::bigint as "ICW_Id", d."AMST_Id",
        (case when d."AMST_FirstName" is null or d."AMST_FirstName"='''' then '''' else d."AMST_FirstName" end ||
        case when d."AMST_MiddleName" is null or d."AMST_MiddleName"='''' then '''' else '' ''|| d."AMST_MiddleName" end ||
        case when d."AMST_LastName" is null or d."AMST_LastName"='''' then '''' else '' ''|| d."AMST_LastName" end) as studentname,
        d."amst_admno", COALESCE(e."IHW_Topic",'''') as "IHW_Topic", COALESCE(e."IHW_Assignment",'''') as "IHW_Assignment",
        to_char(e."IHW_Date", ''DD/MM/YYYY'') as "IHW_Date",
        NULL::text as "ICW_Topic", NULL::text as "ICW_SubTopic", NULL::text as "ICW_Content", NULL::text as "ICW_Assignment",
        NULL::varchar as "ICW_FromDate", NULL::varchar as "ICW_ToDate",
        f."ISMS_SubjectName",
        (select count(*) from "IVRM_HomeWork_Attatchment" HA where HA."IHW_Id"=e."IHW_Id")::bigint AS "FilesCount",
        b."IHWUPL_Id", NULL::bigint as "ICWUPL_Id",
        COALESCE(b."IHWUPL_StaffRemarks",'''') as "IHWUPL_StaffRemarks",
        NULL::text as "ICWUPL_StaffRemarks",
        b."IHWUPL_StaffUpload" as "IHW_FilePath1",
        NULL::text as "ICW_FilePath1",
        b."IHWUPL_Marks",
        NULL::numeric as "ICWUPL_Marks",
        NULL::varchar as "FileName1",
        to_char(b."IHWUPL_Date" + interval ''330 minutes'', ''HH12:MI AM'') as "CreatedTime",
        b."IHWUPL_Date" as "CreatedDate"
        from "Adm_School_Y_Student" a
        inner join "IVRM_HomeWork_Upload" b on a."AMST_Id"=b."AMST_Id"
        INNER JOIN "Adm_M_Student" d on d."AMST_Id"=a."AMST_Id"
        inner join "IVRM_HomeWork" e on e."IHW_Id"=b."IHW_Id"
        inner join "IVRM_Master_Subjects" f on f."ISMS_Id"=e."ISMS_Id"
        where a."ASMCL_Id"=' || "ASMCL_Id" || ' and a."ASMS_Id"=' || "ASMS_Id" || '
        and a."ASMAY_Id"=' || "ASMAY_Id" || ' and f."MI_Id"=' || "MI_Id" || '
        and e."IVRMUL_Id"=' || "Login_Id" || ' ' || "ISMS_Id1" || ' ' || "date" || ' order by studentname, b."IHW_Id"';

    ELSIF "Parameter" = 'Classwork' THEN

        IF ("fromdate" IS NOT NULL AND "fromdate" != '') AND ("todate" IS NOT NULL AND "todate" != '') THEN
            "date" := 'and b."ICWUPL_Date"::date between ''' || "fromdate" || '''::date and ''' || "todate" || '''::date';
        ELSE
            "date" := '';
        END IF;

        RETURN QUERY EXECUTE
        'select distinct NULL::bigint as "IHW_Id", b."ICW_Id", d."AMST_Id",
        (case when d."AMST_FirstName" is null or d."AMST_FirstName"='''' then '''' else d."AMST_FirstName" end ||
        case when d."AMST_MiddleName" is null or d."AMST_MiddleName"='''' then '''' else '' ''|| d."AMST_MiddleName" end ||
        case when d."AMST_LastName" is null or d."AMST_LastName"='''' then '''' else '' ''|| d."AMST_LastName" end) as studentname,
        d."amst_admno",
        NULL::text as "IHW_Topic", NULL::text as "IHW_Assignment", NULL::varchar as "IHW_Date",
        COALESCE(e."ICW_Topic",'''') as "ICW_Topic", COALESCE(e."ICW_SubTopic",'''') as "ICW_SubTopic",
        COALESCE(e."ICW_Content",'''') as "ICW_Content", COALESCE(e."ICW_Assignment",'''') as "ICW_Assignment",
        to_char(e."ICW_FromDate", ''YYYY-MM-DD'') as "ICW_FromDate",
        to_char(e."ICW_ToDate", ''DD/MM/YYYY'') as "ICW_ToDate",
        f."ISMS_SubjectName",
        (select count(*) from "IVRM_ClassWork_Attatchment" CA where CA."ICW_Id"=e."ICW_Id")::bigint as "FilesCount",
        NULL::bigint as "IHWUPL_Id", b."ICWUPL_Id",
        NULL::text as "IHWUPL_StaffRemarks",
        COALESCE(b."ICWUPL_StaffRemarks",'''') as "ICWUPL_StaffRemarks",
        NULL::text as "IHW_FilePath1",
        b."ICWUPL_StaffUplaod" as "ICW_FilePath1",
        NULL::numeric as "IHWUPL_Marks",
        b."ICWUPL_Marks",
        b."ICWUPL_FileName" as "FileName1",
        to_char(b."ICWUPL_Date" + interval ''330 minutes'', ''HH12:MI AM'') as "CreatedTime",
        b."ICWUPL_Date" as "CreatedDate"
        from "Adm_School_Y_Student" a
        inner join "IVRM_ClassWork_Upload" b on a."AMST_Id"=b."AMST_Id"
        INNER JOIN "Adm_M_Student" d on d."AMST_Id"=a."AMST_Id"
        inner join "IVRM_Assignment" e on e."ICW_Id"=b."ICW_Id"
        inner join "IVRM_Master_Subjects" f on f."ISMS_Id"=e."ISMS_Id"
        where a."ASMCL_Id"=' || "ASMCL_Id" || ' and a."ASMS_Id"=' || "ASMS_Id" || '
        and a."ASMAY_Id"=' || "ASMAY_Id" || ' and f."MI_Id"=' || "MI_Id" || '
        and e."Login_Id"=' || "Login_Id" || ' ' || "ISMS_Id1" || ' ' || "date" || ' order by studentname, b."ICW_Id"';

    END IF;

    RETURN;
END;
$$;