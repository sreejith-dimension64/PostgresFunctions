CREATE OR REPLACE FUNCTION "dbo"."Adm_Attendancestaffentry_countdetails"(
    "MI_ID" VARCHAR(50),
    "ASMAY_ID" VARCHAR(50),
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "FROMDATE" VARCHAR(10),
    "TODATE" VARCHAR(10),
    "ENTRY_TYPE" VARCHAR(20),
    "ISMS_ID" TEXT,
    "TYPE" VARCHAR(500)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "DYNAMIC" TEXT;
    "DYNAMIC1" TEXT;
    "ASAET_Att_Type" varchar(20);
    "PivotColumnNames" text;
    "PivotSelectColumnNames" text;
    "PivotColumnNames1" text;
    "PivotSelectColumnNames1" text;
    "PivotColumnNames2" text;
    "PivotSelectColumnNames2" text;
    "PivotColumnNames3" text;
    "PivotSelectColumnNames3" text;
    "PivotColumnNames4" text;
    "PivotSelectColumnNames4" text;
    "PivotColumnNames5" text;
    "PivotSelectColumnNames5" text;
    "PivotColumnNames6" text;
    "PivotSelectColumnNames6" text;
    "PivotColumnNames7" text;
    "PivotSelectColumnNames7" text;
BEGIN

    DROP TABLE IF EXISTS "Attendancestaff_Temp";
    DROP TABLE IF EXISTS "Attendancestaff_Temp1";

    IF "TYPE" = 'Entered' THEN

        IF "ENTRY_TYPE" = 'M' THEN

            "DYNAMIC" := '
            SELECT DISTINCT CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
            INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
            INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
            WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''monthly'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
            AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')';
            
            EXECUTE "DYNAMIC";

            SELECT STRING_AGG('''' || "ASA_FromDate" || '''', ',' ORDER BY "FINALDATE") INTO "PivotColumnNames"
            FROM "Attendancestaff_Temp";

            SELECT STRING_AGG('SUM(CASE WHEN "ASA_FromDate"=''' || "ASA_FromDate" || ''' THEN "ASA_ClassHeld" ELSE 0 END) AS "' || "ASA_FromDate" || '"', ',' ORDER BY "FINALDATE") INTO "PivotSelectColumnNames"
            FROM "Attendancestaff_Temp";

            "DYNAMIC1" := '
            SELECT "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName",' || "PivotSelectColumnNames" || ' 
            FROM (
                SELECT DISTINCT "D"."HRME_EmployeeFirstName","B"."ASMCL_ClassName","C"."ASMC_SectionName","A"."ASA_ClassHeld",
                CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate" "FINALDATE"
                FROM "Adm_Student_Attendance" "A"
                INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
                INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
                INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
                WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''monthly'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
                AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
            ) AS "New" 
            GROUP BY "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName"';

            EXECUTE "DYNAMIC1";

        ELSIF "ENTRY_TYPE" = 'P' THEN

            "DYNAMIC" := '
            SELECT DISTINCT TO_CHAR("E"."CreatedDate", ''DD Mon YYYY'') "CreatedDate","E"."CreatedDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp1"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_Student_Attendance_Subjects" "E" ON "E"."ASA_Id"="A"."ASA_Id"
            INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_ID"="E"."ISMS_Id"
            INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
            INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
            INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
            WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''period'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
            AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
            AND "F"."ISMS_Id" IN (' || "ISMS_ID" || ')';
            
            EXECUTE "DYNAMIC";

            SELECT STRING_AGG('''' || "CreatedDate" || '''', ',' ORDER BY "FINALDATE") INTO "PivotColumnNames1"
            FROM "Attendancestaff_Temp1";

            SELECT STRING_AGG('SUM(CASE WHEN "CreatedDate"=''' || "CreatedDate" || ''' THEN "ASA_ClassHeld" ELSE 0 END) AS "' || "CreatedDate" || '"', ',' ORDER BY "FINALDATE") INTO "PivotSelectColumnNames1"
            FROM "Attendancestaff_Temp1";

            "DYNAMIC1" := '
            SELECT "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName","ISMS_SubjectName",' || "PivotSelectColumnNames1" || ' 
            FROM (
                SELECT DISTINCT "D"."HRME_EmployeeFirstName","B"."ASMCL_ClassName","C"."ASMC_SectionName","F"."ISMS_SubjectName","A"."ASA_ClassHeld",
                TO_CHAR("E"."CreatedDate", ''DD Mon YYYY'') "CreatedDate","E"."CreatedDate" "FINALDATE"
                FROM "Adm_Student_Attendance" "A"
                INNER JOIN "Adm_Student_Attendance_Subjects" "E" ON "E"."ASA_Id"="A"."ASA_Id"
                INNER JOIN "Adm_Student_Attendance_Periodwise" "G" ON "G"."ASA_ID"="A"."ASA_ID"
                INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_ID"="E"."ISMS_Id"
                INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
                INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
                INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
                WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''period'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
                AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
                AND "F"."ISMS_Id" IN (' || "ISMS_ID" || ')
            ) AS "New" 
            GROUP BY "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName","ISMS_SubjectName"';

            EXECUTE "DYNAMIC1";

        ELSIF "ENTRY_TYPE" = 'DO' THEN

            "DYNAMIC" := '
            SELECT DISTINCT CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_Student_Attendance_Students" "E" ON "A"."ASA_ID"="E"."ASA_ID"
            INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
            INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
            INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
            WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''Dailyonce'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
            AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')';

            EXECUTE "DYNAMIC";

            SELECT STRING_AGG('''' || "ASA_FromDate" || '''', ',' ORDER BY "FINALDATE") INTO "PivotColumnNames2"
            FROM "Attendancestaff_Temp";

            SELECT STRING_AGG('SUM(CASE WHEN "ASA_FromDate"=''' || "ASA_FromDate" || ''' THEN "ASA_ClassHeld" ELSE 0 END) AS "' || "ASA_FromDate" || '"', ',' ORDER BY "FINALDATE") INTO "PivotSelectColumnNames2"
            FROM "Attendancestaff_Temp";

            "DYNAMIC1" := '
            SELECT "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName",' || "PivotSelectColumnNames2" || ' 
            FROM (
                SELECT DISTINCT "D"."HRME_EmployeeFirstName","B"."ASMCL_ClassName","C"."ASMC_SectionName","A"."ASA_ClassHeld",
                CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate" "FINALDATE"
                FROM "Adm_Student_Attendance" "A"
                INNER JOIN "Adm_Student_Attendance_Students" "E" ON "A"."ASA_ID"="E"."ASA_ID"
                INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
                INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
                INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
                WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''Dailyonce'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
                AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
            ) AS "New" 
            GROUP BY "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName"';

            EXECUTE "DYNAMIC1";

        ELSIF "ENTRY_TYPE" = 'DT' THEN

            "DYNAMIC" := '
            SELECT DISTINCT CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_Student_Attendance_Students" "E" ON "A"."ASA_ID"="E"."ASA_ID"
            INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
            INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
            INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
            WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''Dailytwice'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
            AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')';

            EXECUTE "DYNAMIC";

            SELECT STRING_AGG('''' || "ASA_FromDate" || '''', ',' ORDER BY "FINALDATE") INTO "PivotColumnNames3"
            FROM "Attendancestaff_Temp";

            SELECT STRING_AGG('SUM(CASE WHEN "ASA_FromDate"=''' || "ASA_FromDate" || ''' THEN "ASA_ClassHeld" ELSE 0 END) AS "' || "ASA_FromDate" || '"', ',' ORDER BY "FINALDATE") INTO "PivotSelectColumnNames3"
            FROM "Attendancestaff_Temp";

            "DYNAMIC1" := '
            SELECT "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName",' || "PivotSelectColumnNames3" || ' 
            FROM (
                SELECT DISTINCT "D"."HRME_EmployeeFirstName","B"."ASMCL_ClassName","C"."ASMC_SectionName","A"."ASA_ClassHeld",
                CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate" "FINALDATE"
                FROM "Adm_Student_Attendance" "A"
                INNER JOIN "Adm_Student_Attendance_Students" "E" ON "A"."ASA_ID"="E"."ASA_ID"
                INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
                INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
                INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
                WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''Dailytwice'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
                AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
            ) AS "New" 
            GROUP BY "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName"';

            EXECUTE "DYNAMIC1";

        END IF;

    ELSIF "TYPE" = 'Not Entered' THEN

        IF "ENTRY_TYPE" = 'M' THEN

            "DYNAMIC" := '
            SELECT DISTINCT CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
            INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
            INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
            WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''monthly'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
            AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')';
            
            EXECUTE "DYNAMIC";

            SELECT STRING_AGG('''' || "ASA_FromDate" || '''', ',' ORDER BY "FINALDATE") INTO "PivotColumnNames4"
            FROM "Attendancestaff_Temp";

            SELECT STRING_AGG('SUM(CASE WHEN "ASA_FromDate"=''' || "ASA_FromDate" || ''' THEN "ASA_ClassHeld" ELSE 0 END) AS "' || "ASA_FromDate" || '"', ',' ORDER BY "FINALDATE") INTO "PivotSelectColumnNames4"
            FROM "Attendancestaff_Temp";

            "DYNAMIC1" := '
            SELECT "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName",' || "PivotSelectColumnNames4" || ' 
            FROM (
                SELECT DISTINCT "D"."HRME_EmployeeFirstName","B"."ASMCL_ClassName","C"."ASMC_SectionName","A"."ASA_ClassHeld",
                CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate" "FINALDATE"
                FROM "Adm_Student_Attendance" "A"
                INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
                INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
                INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
                WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''monthly'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
                AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
                AND "A"."HRME_ID" NOT IN (
                    SELECT DISTINCT "A"."HRME_Id" FROM "Adm_School_Attendance_Login_User" "A"
                    INNER JOIN "Adm_School_Attendance_Login_User_Class" "B" ON "A"."ASALU_Id"="B"."ASALU_Id"
                    INNER JOIN "Adm_School_Attendance_Login_User_Class_Subjects" "C" ON "B"."ASALUC_Id"="C"."ASALUC_Id"
                    WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                    AND "B"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "B"."ASMS_ID" IN (' || "ASMS_Id" || ')
                )
            ) AS "New" 
            GROUP BY "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName"';

            EXECUTE "DYNAMIC1";

        ELSIF "ENTRY_TYPE" = 'P' THEN

            "DYNAMIC" := '
            SELECT DISTINCT TO_CHAR("E"."CreatedDate", ''DD Mon YYYY'') "CreatedDate","E"."CreatedDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp1"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_Student_Attendance_Subjects" "E" ON "E"."ASA_Id"="A"."ASA_Id"
            INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_ID"="E"."ISMS_Id"
            INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
            INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
            INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
            WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''period'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
            AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
            AND "F"."ISMS_Id" IN (' || "ISMS_ID" || ')';
            
            EXECUTE "DYNAMIC";

            SELECT STRING_AGG('''' || "CreatedDate" || '''', ',' ORDER BY "FINALDATE") INTO "PivotColumnNames5"
            FROM "Attendancestaff_Temp1";

            SELECT STRING_AGG('SUM(CASE WHEN "CreatedDate"=''' || "CreatedDate" || ''' THEN "ASA_ClassHeld" ELSE 0 END) AS "' || "CreatedDate" || '"', ',' ORDER BY "FINALDATE") INTO "PivotSelectColumnNames5"
            FROM "Attendancestaff_Temp1";

            "DYNAMIC1" := '
            SELECT "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName","ISMS_SubjectName",' || "PivotSelectColumnNames5" || ' 
            FROM (
                SELECT DISTINCT "D"."HRME_EmployeeFirstName","B"."ASMCL_ClassName","C"."ASMC_SectionName","F"."ISMS_SubjectName","A"."ASA_ClassHeld",
                TO_CHAR("E"."CreatedDate", ''DD Mon YYYY'') "CreatedDate","E"."CreatedDate" "FINALDATE"
                FROM "Adm_Student_Attendance" "A"
                INNER JOIN "Adm_Student_Attendance_Subjects" "E" ON "E"."ASA_Id"="A"."ASA_Id"
                INNER JOIN "Adm_Student_Attendance_Periodwise" "G" ON "G"."ASA_ID"="A"."ASA_ID"
                INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_ID"="E"."ISMS_Id"
                INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_ID"="A"."ASMCL_ID"
                INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_ID"="A"."ASMS_ID"
                INNER JOIN "HR_Master_Employee" "D" ON "D"."HRME_ID"="A"."HRME_ID"
                WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASA_Att_Type"=''period'' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                AND "A"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "A"."ASMS_Id" IN (' || "ASMS_Id" || ') 
                AND ("A"."ASA_FromDate"::DATE BETWEEN ''' || "FROMDATE" || ''' AND ''' || "TODATE" || ''')
                AND "F"."ISMS_Id" IN (' || "ISMS_ID" || ')
                AND "A"."HRME_Id" NOT IN (
                    SELECT DISTINCT "A"."HRME_Id" FROM "Adm_School_Attendance_Login_User" "A"
                    INNER JOIN "Adm_School_Attendance_Login_User_Class" "B" ON "A"."ASALU_Id"="B"."ASALU_Id"
                    INNER JOIN "Adm_School_Attendance_Login_User_Class_Subjects" "C" ON "B"."ASALUC_Id"="C"."ASALUC_Id"
                    WHERE "A"."MI_Id"=' || "MI_ID" || ' AND "A"."ASMAY_Id"=' || "ASMAY_ID" || ' 
                    AND "B"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "B"."ASMS_ID" IN (' || "ASMS_Id" || ') 
                    AND "C"."ISMS_Id" IN (' || "ISMS_ID" || ')
                )
            ) AS "New" 
            GROUP BY "HRME_EmployeeFirstName","ASMCL_ClassName","ASMC_SectionName","ISMS_SubjectName"';

            EXECUTE "DYNAMIC1";

        ELSIF "ENTRY_TYPE" = 'DO' THEN

            "DYNAMIC" := '
            SELECT DISTINCT CONCAT(TO_CHAR("A"."ASA_FromDate", ''Month''),''-'',EXTRACT(YEAR FROM "A"."ASA_FromDate")) "ASA_FromDate","A"."ASA_FromDate"::DATE "FINALDATE"
            INTO "Attendancestaff_Temp"
            FROM "A