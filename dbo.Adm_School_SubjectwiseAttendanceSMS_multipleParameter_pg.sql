```sql
CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectwiseAttendanceSMS_multipleParameter"(
    "p_MI_Id" VARCHAR(100),
    "p_ASMAY_Id" VARCHAR(200),
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_FromDate" VARCHAR(10),
    "p_ToDate" VARCHAR(10),
    "p_ISMS_Id" TEXT,
    "p_AMST_Id" TEXT
)
RETURNS TABLE(
    "SUBJECTS" TEXT,
    "STUDENT_NAME" TEXT,
    "CLASS" TEXT,
    "DATE" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := 'SELECT DISTINCT STRING_AGG(DISTINCT ''"IMS"."ISMS_SubjectName"'', '', '') as "SUBJECTS",
COALESCE("AMS"."AMST_FirstName",'''') || '' '' || COALESCE("AMS"."AMST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMST_LastName",'''') AS "STUDENT_NAME",
("ASMC"."ASMCL_ClassName" || '' Class '' || "ASMS"."ASMC_SectionName") || '' Section'' as "CLASS",
TO_CHAR(CAST(''' || "p_FromDate" || ''' AS DATE), ''DD/MM/YYYY'') as "DATE"
FROM "Adm_Student_Attendance" "ASA"
INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" AND "IMS"."MI_Id" = ' || "p_MI_Id" || '
INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" AND "MP"."MI_Id" = ' || "p_MI_Id" || '
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ASAST"."AMST_Id" AND "ASYS"."ASMAY_Id" = "ASA"."ASMAY_Id"
INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
WHERE "ASA"."MI_Id" = ' || "p_MI_Id" || ' AND "ASA"."ASMAY_Id" = ' || "p_ASMAY_Id" || '
AND "ASYS"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND "ASA"."ASMCL_Id" IN (' || "p_ASMCL_Id" || ')
AND "ASA"."ASMS_Id" IN (' || "p_ASMS_Id" || ') AND "ASAS"."ISMS_Id" IN (' || "p_ISMS_Id" || ')
AND "ASAST"."ASA_Class_Attended" = 0.00 AND "ASAST"."AMST_Id" IN (' || "p_AMST_Id" || ')
AND CAST("ASA"."ASA_FromDate" AS DATE) = ''' || "p_FromDate" || '''
AND "ASA"."ASA_Activeflag" = 1 AND "ASA"."ASA_Att_Type" = ''Period'' 
AND "ASYS"."AMAY_ActiveFlag" = 1 AND "AMS"."AMST_ActiveFlag" = 1 AND "AMS"."AMST_SOL" = ''S''
GROUP BY "ASAST"."AMST_Id", "ASA"."ASA_FromDate", "ASMC"."ASMCL_ClassName", "AMS"."AMST_AdmNo", 
"AMS"."AMST_Id", "AMS"."AMST_MobileNo", "AMS"."AMST_FirstName", "AMS"."AMST_MiddleName", 
"AMS"."AMST_LastName", "ASMS"."ASMC_SectionName"';

    RAISE NOTICE '%', v_query;

    RETURN QUERY EXECUTE v_query;
END;
$$;
```