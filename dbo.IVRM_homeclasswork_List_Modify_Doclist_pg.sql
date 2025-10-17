CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_List_Modify_Doclist"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@AMST_Id" text,
    "@Login_Id" bigint,
    "@Parameter" text,
    "@ISMS_Id" bigint,
    "@fromdate" varchar(40),
    "@todate" varchar(40)
)
RETURNS TABLE(
    "IHW_Id" bigint,
    "AMST_Id" bigint,
    "ihwuplatT_FileName" text,
    "ihwuplatT_Attachment" text,
    "studentname" text,
    "amst_admno" text,
    "IHW_Topic" text,
    "IHW_Assignment" text,
    "IHW_Date" varchar(10),
    "ISMS_SubjectName" text,
    "FilesCount" bigint,
    "IHWUPL_Id" bigint,
    "IHWUPL_StaffRemarks" text,
    "IHW_FilePath1" text,
    "IHWUPL_Marks" numeric,
    "ICWUPL_Id" bigint,
    "ICW_Id" bigint,
    "icwuplatT_Attachment" text,
    "icwuplatT_FileName" text,
    "icwuplatT_StaffUpload" text,
    "icwuplatT_StaffRemarks" text,
    "icwuplatT_Id" bigint,
    "ICW_Topic" text,
    "ICW_SubTopic" text,
    "ICW_Content" text,
    "ICW_Assignment" text,
    "ICW_FromDate" varchar(10),
    "ICW_ToDate" varchar(10),
    "ICW_FilePath1" text,
    "FileName1" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@sqlexec" text;
    "@ISMS_Id1" text;
    "@date" text;
BEGIN
    IF "@ISMS_Id" IS NOT NULL AND "@ISMS_Id" != 0 THEN
        "@ISMS_Id1" := 'and e."ISMS_Id"=' || "@ISMS_Id"::text || '';
    ELSE
        "@ISMS_Id1" := '';
    END IF;

    IF "@Parameter" = 'Homework' THEN
        IF ("@fromdate" IS NOT NULL AND "@fromdate" != '') AND ("@todate" IS NOT NULL AND "@todate" != '') THEN
            "@date" := 'and b."IHWUPL_Date"::date between ''' || "@fromdate" || ''' and ''' || "@todate" || '''';
        ELSE
            "@date" := '';
        END IF;

        RETURN QUERY EXECUTE 
        'select distinct b."IHW_Id", d."AMST_Id", g."IHWUPLATT_FileName" as ihwuplatT_FileName, g."IHWUPLATT_Attachment" as ihwuplatT_Attachment,
        (case when d."AMST_FirstName" is null or d."AMST_FirstName"='''' then '''' else d."AMST_FirstName" end ||
        case when d."AMST_MiddleName" is null or d."AMST_MiddleName"='''' then '''' else '' ''|| d."AMST_MiddleName" end ||
        case when d."AMST_LastName" is null or d."AMST_LastName"='''' then '''' else '' ''|| d."AMST_LastName" end) as studentname,
        d."amst_admno",
        COALESCE(e."IHW_Topic",'''') as "IHW_Topic", COALESCE(e."IHW_Assignment",'''') as "IHW_Assignment", to_char(e."IHW_Date", ''DD/MM/YYYY'') as "IHW_Date", f."ISMS_SubjectName",
        (select count(*) from "IVRM_HomeWork_Attatchment" HA where HA."IHW_Id"=e."IHW_Id") AS "FilesCount",
        b."IHWUPL_Id", COALESCE("IHWUPL_StaffRemarks",'''') as "IHWUPL_StaffRemarks", "IHWUPL_StaffUpload" as "IHW_FilePath1", "IHWUPL_Marks",
        NULL::bigint as "ICWUPL_Id", NULL::bigint as "ICW_Id", NULL::text as icwuplatT_Attachment, NULL::text as icwuplatT_FileName, NULL::text as icwuplatT_StaffUpload,
        NULL::text as icwuplatT_StaffRemarks, NULL::bigint as icwuplatT_Id, NULL::text as "ICW_Topic", NULL::text as "ICW_SubTopic", NULL::text as "ICW_Content",
        NULL::text as "ICW_Assignment", NULL::varchar(10) as "ICW_FromDate", NULL::varchar(10) as "ICW_ToDate", NULL::text as "ICW_FilePath1", NULL::text as "FileName1"
        from "Adm_School_Y_Student" a
        inner join "IVRM_HomeWork_Upload" b on a."AMST_Id"=b."AMST_Id"
        INNER JOIN "Adm_M_Student" d on d."AMST_Id"=a."AMST_Id"
        inner join "IVRM_HomeWork" e on e."IHW_Id"=b."IHW_Id"
        inner join "IVRM_Master_Subjects" f on f."ISMS_Id"=e."ISMS_Id"
        inner join "IVRM_HomeWork_Upload_Attatchment" g on g."IHWUPL_Id"=b."IHWUPL_Id"
        where a."ASMCL_Id"=' || "@ASMCL_Id"::text || ' and a."ASMS_Id"=' || "@ASMS_Id"::text || ' and a."ASMAY_Id"=' || "@ASMAY_Id"::text || '
        and f."MI_Id"=' || "@MI_Id"::text || ' and e."IVRMUL_Id"=' || "@Login_Id"::text || ' ' || "@ISMS_Id1" || ' ' || "@date" || ' order by b."IHW_Id" desc';

    ELSIF "@Parameter" = 'Classwork' THEN
        IF ("@fromdate" IS NOT NULL AND "@fromdate" != '') AND ("@todate" IS NOT NULL AND "@todate" != '') THEN
            "@date" := 'and b."ICWUPL_Date"::date between ''' || "@fromdate" || ''' and ''' || "@todate" || '''';
        ELSE
            "@date" := '';
        END IF;

        RETURN QUERY EXECUTE
        'select distinct NULL::bigint as "IHW_Id", d."AMST_Id", NULL::text as ihwuplatT_FileName, NULL::text as ihwuplatT_Attachment,
        (case when d."AMST_FirstName" is null or d."AMST_FirstName"='''' then '''' else d."AMST_FirstName" end ||
        case when d."AMST_MiddleName" is null or d."AMST_MiddleName"='''' then '''' else '' ''|| d."AMST_MiddleName" end ||
        case when d."AMST_LastName" is null or d."AMST_LastName"='''' then '''' else '' ''|| d."AMST_LastName" end) as studentname,
        d."amst_admno", NULL::text as "IHW_Topic", NULL::text as "IHW_Assignment", NULL::varchar(10) as "IHW_Date", f."ISMS_SubjectName",
        (select count(*) from "IVRM_ClassWork_Attatchment" CA where CA."ICW_Id"=e."ICW_Id") as "FilesCount",
        NULL::bigint as "IHWUPL_Id", NULL::text as "IHWUPL_StaffRemarks", NULL::text as "IHW_FilePath1", NULL::numeric as "IHWUPL_Marks",
        b."ICWUPL_Id", b."ICW_Id", g."ICWUPLATT_Attachment" as icwuplatT_Attachment, g."ICWUPLATT_FileName" as icwuplatT_FileName,
        g."ICWUPLATT_StaffUpload" as icwuplatT_StaffUpload, g."ICWUPLATT_StaffRemarks" as icwuplatT_StaffRemarks, g."ICWUPLATT_Id" as icwuplatT_Id,
        COALESCE(e."ICW_Topic",'''') as "ICW_Topic", COALESCE(e."ICW_SubTopic",'''') as "ICW_SubTopic", COALESCE("ICW_Content",'''') as "ICW_Content",
        COALESCE(e."ICW_Assignment",'''') as "ICW_Assignment", to_char(e."ICW_FromDate", ''DD/MM/YYYY'') as "ICW_FromDate",
        to_char(e."ICW_ToDate", ''DD/MM/YYYY'') as "ICW_ToDate", "ICWUPL_StaffUplaod" as "ICW_FilePath1", "ICWUPL_FileName" as "FileName1",
        COALESCE("ICWUPL_StaffRemarks",'''') as "ICWUPL_StaffRemarks_extra", b."ICWUPL_Marks"
        from "Adm_School_Y_Student" a
        inner join "IVRM_ClassWork_Upload" b on a."AMST_Id"=b."AMST_Id"
        INNER JOIN "Adm_M_Student" d on d."AMST_Id"=a."AMST_Id"
        inner join "IVRM_Assignment" e on e."ICW_Id"=b."ICW_Id"
        inner join "IVRM_Master_Subjects" f on f."ISMS_Id"=e."ISMS_Id"
        inner join "IVRM_ClassWork_Upload_Attatchment" g on b."ICWUPL_Id"=g."ICWUPL_Id"
        where a."ASMCL_Id"=' || "@ASMCL_Id"::text || ' and a."ASMS_Id"=' || "@ASMS_Id"::text || ' and a."ASMAY_Id"=' || "@ASMAY_Id"::text || '
        and f."MI_Id"=' || "@MI_Id"::text || ' and e."Login_Id"=' || "@Login_Id"::text || ' ' || "@ISMS_Id1" || ' ' || "@date" || '
        order by b."ICW_Id" desc';
    END IF;

    RETURN;
END;
$$;