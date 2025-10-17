CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectwiseAttendanceSMS_multiple_bkp"(
    p_MI_Id varchar(100),
    p_ASMAY_Id varchar(200),
    p_ASMCL_Id text,
    p_ASMS_Id text,
    p_FromDate varchar(10),
    p_ToDate varchar(10),
    p_ISMS_Id text,
    p_AMST_Id text
)
RETURNS TABLE(
    "SUBJECT1" text,
    "Subject2" text,
    "SUBJECTS" text,
    "STUDENT_NAME" text,
    "AMST_Id" bigint,
    "AMST_AdmNo" varchar,
    "AMST_MobileNo" bigint,
    "ASA_FromDate" date,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "ASA_Class_Attended" text,
    "CLASS" text,
    "DATE" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query text;
BEGIN

    v_query := 'CREATE TEMP TABLE temp_result AS 
    SELECT DISTINCT STRING_AGG(DISTINCT ''"'' || IMS."ISMS_SubjectName" || ''"'','','') as "SUBJECTS",
    COALESCE(AMS."AMST_FirstName",'''') || '' '' || COALESCE(AMS."AMST_MiddleName",'''') || '' '' || COALESCE(AMS."AMST_LastName",'''') AS "STUDENT_NAME",
    AMS."AMST_Id",
    AMS."AMST_AdmNo",
    AMS."AMST_MobileNo",
    CAST(ASA."ASA_FromDate" as date) as "ASA_FromDate",
    ASMC."ASMCL_ClassName",
    ASMS."ASMC_SectionName",
    STRING_AGG((CASE WHEN ASAST."ASA_Class_Attended"=1.00 then CAST(MP."TTMP_PeriodName" as varchar) || '':'' || ''P'' WHEN ASAST."ASA_Class_Attended"=0.00 then CAST(MP."TTMP_PeriodName" as varchar) || '':'' || ''A'' END ),'', '') as "ASA_Class_Attended",
    (ASMC."ASMCL_ClassName" || '' Class '' || ASMS."ASMC_SectionName") || '' Section'' as "CLASS",
    TO_CHAR(CAST(''' || p_FromDate || ''' as date),''DD/MM/YYYY'') as "DATE"
    FROM "Adm_Student_Attendance" ASA
    INNER JOIN "Adm_Student_Attendance_Periodwise" ASAP ON ASA."ASA_Id"=ASAP."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Subjects" ASAS ON ASAS."ASA_Id"=ASA."ASA_Id"
    INNER JOIN "IVRM_Master_Subjects" IMS ON IMS."ISMS_Id"=ASAS."ISMS_Id" and IMS."MI_Id"=' || p_MI_Id::varchar || '
    INNER JOIN "Adm_Student_Attendance_Students" ASAST ON ASAST."ASA_Id"=ASA."ASA_Id"
    INNER JOIN "TT_Master_Period" MP ON MP."TTMP_Id"=ASAP."TTMP_Id" and MP."MI_Id"=' || p_MI_Id::varchar || '
    INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id"=ASAST."AMST_Id" and ASYS."ASMAY_Id"=ASA."ASMAY_Id"
    INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id"=ASYS."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id"=ASYS."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id"=ASYS."ASMS_Id"
    WHERE ASA."MI_Id"=' || p_MI_Id::varchar || ' and ASA."ASMAY_Id"=' || p_ASMAY_Id::varchar || '
    AND ASYS."ASMAY_Id"=' || p_ASMAY_Id::varchar || ' and ASA."ASMCL_Id" IN (' || p_ASMCL_Id || ')
    AND ASA."ASMS_Id" IN (' || p_ASMS_Id || ') and ASAS."ISMS_Id" IN (' || p_ISMS_Id || ')
    and ASAST."ASA_Class_Attended"=0.00 and ASAST."AMST_Id" IN (' || p_AMST_Id || ')
    AND CAST(ASA."ASA_FromDate" as date)=''' || p_FromDate || '''
    AND ASA."ASA_Activeflag"=true and ASA."ASA_Att_Type"=''Period'' and ASYS."AMAY_ActiveFlag"=1 and AMS."AMST_ActiveFlag"=1 and AMS."AMST_SOL"=''S''
    GROUP BY ASAST."AMST_Id",ASA."ASA_FromDate",ASMC."ASMCL_ClassName",AMS."AMST_AdmNo",AMS."AMST_Id",AMS."AMST_MobileNo",AMS."AMST_FirstName",AMS."AMST_MiddleName",AMS."AMST_LastName",ASMS."ASMC_SectionName"';

    EXECUTE v_query;

    RETURN QUERY EXECUTE 
    'SELECT 
        case when POSITION('','' in t."SUBJECTS")=0 or POSITION('','' in SUBSTRING(t."SUBJECTS",POSITION('','' in t."SUBJECTS")+1))=0 
            then t."SUBJECTS" 
            else SUBSTRING(t."SUBJECTS",1,POSITION('','' in SUBSTRING(t."SUBJECTS",POSITION('','' in t."SUBJECTS")+1)) + POSITION('','' in t."SUBJECTS")-1) 
        end as "SUBJECT1",
        case when TRIM(SUBSTRING(t."SUBJECTS", POSITION('','' in SUBSTRING(t."SUBJECTS",POSITION('','' in t."SUBJECTS")+1)) + POSITION('','' in t."SUBJECTS")+1, LENGTH(t."SUBJECTS") - (POSITION('','' in SUBSTRING(t."SUBJECTS",POSITION('','' in t."SUBJECTS")+1)) + POSITION('','' in t."SUBJECTS"))))='''' 
            then '''' 
            else SUBSTRING(t."SUBJECTS", POSITION('','' in SUBSTRING(t."SUBJECTS",POSITION('','' in t."SUBJECTS")+1)) + POSITION('','' in t."SUBJECTS")+1, LENGTH(t."SUBJECTS") - (POSITION('','' in SUBSTRING(t."SUBJECTS",POSITION('','' in t."SUBJECTS")+1)) + POSITION('','' in t."SUBJECTS")))
        end as "Subject2",
        t."SUBJECTS",
        t."STUDENT_NAME",
        t."AMST_Id",
        t."AMST_AdmNo",
        t."AMST_MobileNo",
        t."ASA_FromDate",
        t."ASMCL_ClassName",
        t."ASMC_SectionName",
        t."ASA_Class_Attended",
        t."CLASS",
        t."DATE"
    FROM temp_result t';

    DROP TABLE IF EXISTS temp_result;

END;
$$;