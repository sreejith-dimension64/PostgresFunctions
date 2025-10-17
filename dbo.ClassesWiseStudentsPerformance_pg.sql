CREATE OR REPLACE FUNCTION "dbo"."ClassesWiseStudentsPerformance"(
    p_MI_Id VARCHAR(100),
    p_ASMAY_Id VARCHAR(100),
    p_ASMCL_Id VARCHAR(100),
    p_ASMS_Id VARCHAR(100),
    p_ISMS_Id TEXT
)
RETURNS TABLE(
    "ClassSection" TEXT,
    "EME_ExamName" TEXT,
    "EME_Id" INTEGER,
    "Details" TEXT,
    "Strength" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_sqldynamic1 TEXT;
    v_sqldynamic2 TEXT;
    v_sqldynamic3 TEXT;
    v_sqldynamic4 TEXT;
BEGIN
    DROP TABLE IF EXISTS "ExamStudentStrength_Temp";
    DROP TABLE IF EXISTS "ExamStudentStrength_Temp1";
    DROP TABLE IF EXISTS "ExamStudentStrength_Temp2";
    DROP TABLE IF EXISTS "ExamStudentStrength_Temp3";
    DROP TABLE IF EXISTS "ExamStudentStrength_Temp4";

    v_sqldynamic := 'CREATE TEMP TABLE "ExamStudentStrength_Temp" AS 
    SELECT "ClassSection","EME_ExamName","EME_Id",''Totalnoofstudents'' as "Details","Strength" FROM (
    SELECT DISTINCT A."EME_Id","EME_ExamName",("ASMCL_ClassName" ||''-''|| "ASMC_SectionName") AS "ClassSection",count(DISTINCT ASYS."AMST_Id") AS "Strength"
    FROM "Adm_School_Y_Student" ASYS
    LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" A ON A."AMST_Id"=ASYS."AMST_Id" AND ASYS."ASMAY_Id"=A."ASMAY_Id" AND ASYS."ASMCL_Id"=A."ASMCL_Id" AND ASYS."ASMS_Id"=A."ASMS_Id" AND ASYS."AMAY_ActiveFlag"=1
    LEFT JOIN "Adm_School_M_Class" B ON B."ASMCL_Id"=A."ASMCL_Id"
    LEFT JOIN "Adm_School_M_Section" C ON C."ASMS_Id"=A."ASMS_Id"
    LEFT JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id"=A."EME_Id" AND A."MI_Id"=D."MI_Id"
    LEFT JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id"=A."ISMS_Id" AND F."MI_Id"=D."MI_Id"
    WHERE A."MI_Id"=' || p_MI_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND A."ASMS_Id" IN (' || p_ASMS_Id || ') AND A."ISMS_Id"=' || p_ISMS_Id || '
    GROUP BY "ASMCL_ClassName","ASMC_SectionName","EME_ExamName",A."EME_Id" ) AS New';

    EXECUTE v_sqldynamic;

    v_sqldynamic1 := 'CREATE TEMP TABLE "ExamStudentStrength_Temp1" AS 
    SELECT "ClassSection","EME_ExamName","EME_Id",''Passed Students'' as "Details",COALESCE("Strength",0) "Strength" FROM (
    SELECT A."EME_Id","EME_ExamName",("ASMCL_ClassName" ||''-''|| "ASMC_SectionName") AS "ClassSection",count(DISTINCT A."AMST_Id") AS "Strength"
    FROM "Adm_School_Y_Student" ASYS
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" A ON A."AMST_Id"=ASYS."AMST_Id" AND ASYS."ASMAY_Id"=A."ASMAY_Id" AND ASYS."ASMCL_Id"=A."ASMCL_Id" AND ASYS."ASMS_Id"=A."ASMS_Id" AND ASYS."AMAY_ActiveFlag"=1
    INNER JOIN "Adm_School_M_Class" B ON B."ASMCL_Id"=A."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" C ON C."ASMS_Id"=A."ASMS_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id"=A."EME_Id" AND A."MI_Id"=D."MI_Id"
    INNER JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id"=A."ISMS_Id" AND F."MI_Id"=D."MI_Id"
    WHERE A."MI_Id"=' || p_MI_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND A."ASMS_Id" IN (' || p_ASMS_Id || ') AND A."ISMS_Id"=' || p_ISMS_Id || ' AND A."ESTMPS_PassFailFlg"=''Pass''
    GROUP BY "ASMCL_ClassName","ASMC_SectionName","EME_ExamName",A."EME_Id" ) AS New';

    EXECUTE v_sqldynamic1;

    v_sqldynamic2 := 'CREATE TEMP TABLE "ExamStudentStrength_Temp2" AS 
    SELECT "ClassSection","EME_ExamName","EME_Id",''Failed Students'' as "Details",COALESCE("Strength",0) "Strength" FROM (
    SELECT A."EME_Id","EME_ExamName",("ASMCL_ClassName" ||''-''|| "ASMC_SectionName") AS "ClassSection",count(DISTINCT A."AMST_Id") AS "Strength"
    FROM "Adm_School_Y_Student" ASYS
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" A ON A."AMST_Id"=ASYS."AMST_Id" AND ASYS."ASMAY_Id"=A."ASMAY_Id" AND ASYS."ASMCL_Id"=A."ASMCL_Id" AND ASYS."ASMS_Id"=A."ASMS_Id" AND ASYS."AMAY_ActiveFlag"=1
    INNER JOIN "Adm_School_M_Class" B ON B."ASMCL_Id"=A."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" C ON C."ASMS_Id"=A."ASMS_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id"=A."EME_Id" AND A."MI_Id"=D."MI_Id"
    INNER JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id"=A."ISMS_Id" AND F."MI_Id"=D."MI_Id"
    WHERE A."MI_Id"=' || p_MI_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND A."ASMS_Id" IN (' || p_ASMS_Id || ') AND A."ISMS_Id"=' || p_ISMS_Id || ' AND A."ESTMPS_PassFailFlg"=''Fail''
    GROUP BY "ASMCL_ClassName","ASMC_SectionName","EME_ExamName",A."EME_Id" ) AS New';

    EXECUTE v_sqldynamic2;

    v_sqldynamic3 := 'CREATE TEMP TABLE "ExamStudentStrength_Temp3" AS 
    SELECT "ClassSection","EME_ExamName","EME_Id",''Topper Marks'' as "Details",COALESCE("Strength",0) "Strength" FROM (
    SELECT A."EME_Id","EME_ExamName",("ASMCL_ClassName" ||''-''|| "ASMC_SectionName") AS "ClassSection",Max("ESTMPS_ObtainedMarks") AS "Strength"
    FROM "Adm_School_Y_Student" ASYS
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" A ON A."AMST_Id"=ASYS."AMST_Id" AND ASYS."ASMAY_Id"=A."ASMAY_Id" AND ASYS."ASMCL_Id"=A."ASMCL_Id" AND ASYS."ASMS_Id"=A."ASMS_Id" AND ASYS."AMAY_ActiveFlag"=1
    INNER JOIN "Adm_School_M_Class" B ON B."ASMCL_Id"=A."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" C ON C."ASMS_Id"=A."ASMS_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id"=A."EME_Id" AND A."MI_Id"=D."MI_Id"
    INNER JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id"=A."ISMS_Id" AND F."MI_Id"=D."MI_Id"
    WHERE A."MI_Id"=' || p_MI_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND A."ASMS_Id" IN (' || p_ASMS_Id || ') AND A."ISMS_Id"=' || p_ISMS_Id || ' AND A."ESTMPS_PassFailFlg"=''Pass''
    GROUP BY "ASMCL_ClassName","ASMC_SectionName","EME_ExamName",A."EME_Id" ) AS New';

    EXECUTE v_sqldynamic3;

    v_sqldynamic4 := 'CREATE TEMP TABLE "ExamStudentStrength_Temp4" AS 
    SELECT "ClassSection","EME_ExamName","EME_Id",''Section Average Marks'' as "Details",COALESCE("Strength",0) "Strength" FROM (
    SELECT A."EME_Id","EME_ExamName",("ASMCL_ClassName" ||''-''|| "ASMC_SectionName") AS "ClassSection",Max("ESTMPS_SectionAverage") AS "Strength"
    FROM "Adm_School_Y_Student" ASYS
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" A ON A."AMST_Id"=ASYS."AMST_Id" AND ASYS."ASMAY_Id"=A."ASMAY_Id" AND ASYS."ASMCL_Id"=A."ASMCL_Id" AND ASYS."ASMS_Id"=A."ASMS_Id" AND ASYS."AMAY_ActiveFlag"=1
    INNER JOIN "Adm_School_M_Class" B ON B."ASMCL_Id"=A."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" C ON C."ASMS_Id"=A."ASMS_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id"=A."EME_Id" AND A."MI_Id"=D."MI_Id"
    INNER JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id"=A."ISMS_Id" AND F."MI_Id"=D."MI_Id"
    WHERE A."MI_Id"=' || p_MI_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMAY_Id"=' || p_ASMAY_Id || ' AND A."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND A."ASMS_Id" IN (' || p_ASMS_Id || ') AND A."ISMS_Id"=' || p_ISMS_Id || ' AND A."ESTMPS_PassFailFlg"=''Pass''
    GROUP BY "ASMCL_ClassName","ASMC_SectionName","EME_ExamName",A."EME_Id" ) AS New';

    EXECUTE v_sqldynamic4;

    RETURN QUERY
    SELECT * FROM "ExamStudentStrength_Temp"
    UNION ALL
    SELECT * FROM "ExamStudentStrength_Temp1"
    UNION ALL
    SELECT * FROM "ExamStudentStrength_Temp2"
    UNION ALL
    SELECT * FROM "ExamStudentStrength_Temp3"
    UNION ALL
    SELECT * FROM "ExamStudentStrength_Temp4"
    ORDER BY "EME_Id";

END;
$$;