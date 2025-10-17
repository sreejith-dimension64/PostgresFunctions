CREATE OR REPLACE FUNCTION "dbo"."Adm_School_Attendance_DeletionRecords_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FromDate VARCHAR(10),
    p_Todate VARCHAR(10),
    p_HRME_Id TEXT,
    p_Flag TEXT
)
RETURNS TABLE(
    "ASA_Id" INTEGER,
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_FromDate" VARCHAR,
    "ASA_Todate" VARCHAR,
    "ASA_Entry_DateTime" VARCHAR,
    "EmpName" TEXT,
    "ISMS_SubjectName" VARCHAR,
    "TTMP_PeriodName" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "ASA_FromDateTemp" DATE,
    "DeletedDate" VARCHAR,
    "ASA_Att_Type" VARCHAR,
    "DeletedBy" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_SECTIONWHERECONDITION TEXT;
    v_CLASSWHERECONDITION TEXT;
BEGIN

    IF p_Flag = 'All' THEN
    
        v_CLASSWHERECONDITION := 'SELECT "ASMCL_Id" FROM "Adm_School_M_Class" where "MI_Id"=' || p_MI_Id || '';
        
        v_SECTIONWHERECONDITION := 'SELECT "ASMS_Id" FROM "Adm_School_M_Section" where "MI_Id"=' || p_MI_Id || '';
    
    ELSE
    
        v_CLASSWHERECONDITION := 'SELECT "ASMCL_Id" FROM "Adm_School_M_Class" where "MI_Id"=' || p_MI_Id || ' AND  "ASMCL_Id"=' || p_ASMCL_Id || '';
        
        v_SECTIONWHERECONDITION := 'SELECT "ASMS_Id" FROM "Adm_School_M_Section" where "MI_Id"=' || p_MI_Id || 'AND  "ASMS_Id" IN (' || p_ASMS_Id || ')';
    
    END IF;

    v_sqldynamic := '
    select DISTINCT "ASA"."ASA_Id", "ASMAY"."ASMAY_Year", "ASMCL_ClassName", "ASMS"."ASMC_SectionName",
    TO_CHAR("ASA"."ASA_FromDate", ''DD/MM/YYYY'') AS "ASA_FromDate",
    TO_CHAR("ASA"."ASA_Todate", ''DD/MM/YYYY'') AS "ASA_Todate",
    TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY'') AS "ASA_Entry_DateTime",
    COALESCE("HME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName", '''') AS "EmpName",
    "ISMS_SubjectName", "TTMP"."TTMP_PeriodName", "ASMCL_Order", "ASMC_Order", 
    CAST("ASA"."ASA_FromDate" AS Date) AS "ASA_FromDateTemp",
    TO_CHAR("ASA"."UpdatedDate", ''DD/MM/YYYY'') AS "DeletedDate",
    "ASA_Att_Type",
    COALESCE((select "UserName" from "Adm_Student_Attendance" "SA" INNER JOIN "Applicationuser" "AU" ON "AU"."id" = "SA"."ASA_UpdatedBy"
    where "SA"."ASA_Id" = "ASA"."ASA_Id"), '''') AS "DeletedBy"
    FROM "Adm_Student_Attendance" "ASA" 
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASAP"."ASA_Id" = "ASAS"."ASA_Id"
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASA"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASA"."ASMS_Id"
    INNER JOIN "IVRM_Master_Subjects" "ISMS" ON "ISMS"."ISMS_Id" = "ASAS"."ISMS_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ASA"."HRME_Id"
    INNER JOIN "TT_Master_Period" "TTMP" ON "TTMP"."TTMP_Id" = "ASAP"."TTMP_Id"
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASA"."ASMAY_Id"
    where "ASA"."MI_Id" = ' || p_MI_Id || ' and "ASA"."ASMAY_Id" = ' || p_ASMAY_Id || ' and "ASMAY"."MI_Id" = ' || p_MI_Id || ' 
    and "ASA"."ASMCL_Id" IN (' || v_CLASSWHERECONDITION || ') 
    and "ASA"."ASMS_Id" IN (' || v_SECTIONWHERECONDITION || ') 
    and CAST("ASA"."ASA_FromDate" AS DATE) >= ''' || p_FromDate || ''' and CAST("ASA"."ASA_ToDate" AS DATE) <= ''' || p_Todate || '''
    and "ASA"."ASA_Activeflag" = false and "ASA_Att_Type" = ''period''
    GROUP BY "ASA"."ASA_Id", "ASMAY"."ASMAY_Year", "ASMCL_ClassName", "ASMS"."ASMC_SectionName", "ISMS_SubjectName", "TTMP"."TTMP_PeriodName",
    TO_CHAR("ASA"."ASA_FromDate", ''DD/MM/YYYY''), TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY''),
    COALESCE("HME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName", ''''),
    "ISMS_SubjectName", "TTMP"."TTMP_PeriodName", "ASMCL_Order", "ASMC_Order", CAST("ASA"."ASA_FromDate" AS Date), "ASA_Att_Type",
    TO_CHAR("ASA"."ASA_Todate", ''DD/MM/YYYY''), TO_CHAR("ASA"."UpdatedDate", ''DD/MM/YYYY'')

    UNION

    select DISTINCT "ASA"."ASA_Id", "ASMAY"."ASMAY_Year", "ASMCL_ClassName", "ASMS"."ASMC_SectionName",
    TO_CHAR("ASA"."ASA_FromDate", ''DD/MM/YYYY'') AS "ASA_FromDate",
    TO_CHAR("ASA"."ASA_Todate", ''DD/MM/YYYY'') AS "ASA_Todate",
    TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY'') AS "ASA_Entry_DateTime",
    COALESCE("HME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName", '''') AS "EmpName",
    '''' AS "ISMS_SubjectName", '''' AS "TTMP_PeriodName", "ASMCL_Order", "ASMC_Order", 
    CAST("ASA"."ASA_FromDate" AS Date) AS "ASA_FromDateTemp",
    TO_CHAR("ASA"."UpdatedDate", ''DD/MM/YYYY'') AS "DeletedDate",
    "ASA_Att_Type",
    COALESCE((select COALESCE("UserName", '''') from "Adm_Student_Attendance" "SA" INNER JOIN "Applicationuser" "AU" ON "AU"."id" = "SA"."ASA_UpdatedBy"
    where "SA"."ASA_Id" = "ASA"."ASA_Id"), '''') AS "DeletedBy"
    FROM "Adm_Student_Attendance" "ASA" 
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASA"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASA"."ASMS_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ASA"."HRME_Id"
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASA"."ASMAY_Id"
    where "ASA"."MI_Id" = ' || p_MI_Id || ' and "ASA"."ASMAY_Id" = ' || p_ASMAY_Id || ' and "ASMAY"."MI_Id" = ' || p_MI_Id || ' 
    and "ASA"."ASMCL_Id" IN (' || v_CLASSWHERECONDITION || ') 
    and "ASA"."ASMS_Id" IN (' || v_SECTIONWHERECONDITION || ') 
    and CAST("ASA"."UpdatedDate" AS DATE) >= ''' || p_FromDate || ''' and CAST("ASA"."UpdatedDate" AS DATE) <= ''' || p_Todate || '''
    and "ASA"."ASA_Activeflag" = false and "ASA_Att_Type" != ''period''
    GROUP BY "ASA"."ASA_Id", "ASMAY"."ASMAY_Year", "ASMCL_ClassName", "ASMS"."ASMC_SectionName",
    TO_CHAR("ASA"."ASA_FromDate", ''DD/MM/YYYY''), TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY''),
    COALESCE("HME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName", ''''),
    "ASMCL_Order", "ASMC_Order", CAST("ASA"."ASA_FromDate" AS Date), "ASA_Att_Type",
    TO_CHAR("ASA"."ASA_Todate", ''DD/MM/YYYY''), TO_CHAR("ASA"."UpdatedDate", ''DD/MM/YYYY'')
    ORDER BY "ASMCL_Order", "ASMC_Order", "ASA_FromDateTemp"';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;