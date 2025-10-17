CREATE OR REPLACE FUNCTION "dbo"."College_Exam_Cumulative_Avg_Best_Report"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT, 
    p_AMCO_Id TEXT, 
    p_AMB_Id TEXT, 
    p_AMSE_Id TEXT, 
    p_ACMS_Id TEXT, 
    p_ISMS_Id TEXT, 
    p_FLAG TEXT, 
    p_EME_Id TEXT, 
    p_ACSS_Id TEXT, 
    p_ACST_Id TEXT, 
    p_BEST INT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "REGNO" TEXT,
    "ADMNO" TEXT,
    "STUDENTNAME" TEXT,
    "ECSTMPS_MaxMarks" NUMERIC,
    "CLASSHELD" BIGINT,
    "PRESENT" BIGINT,
    "final" NUMERIC
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCST_Id TEXT;
    v_REGNO TEXT;
    v_ADMNO TEXT;
    v_SQLQUERY TEXT;
    v_Dynamic TEXT;
    v_EMEIDNEW TEXT;
    v_EMEIDNEW1 TEXT;
    v_EMEIDNEWSUM TEXT;
    v_SQLQUERY1 TEXT;
BEGIN

    DROP TABLE IF EXISTS "ExamIds_Temp";
    DROP TABLE IF EXISTS "college_examwise_marks_temp";
    DROP TABLE IF EXISTS "college_temp_best_marks";
    DROP TABLE IF EXISTS "StudentBestMarks_Temp";

    CREATE TEMP TABLE "ExamIds_Temp"("EME_Id" VARCHAR(150));

    v_Dynamic := 'SELECT "EME_Id" FROM "Exm"."Exm_Master_Exam" WHERE "EME_Id"::TEXT IN (' || p_EME_Id || ')';
    
    EXECUTE 'INSERT INTO "ExamIds_Temp" ' || v_Dynamic;

    SELECT (LENGTH(p_EME_Id) - LENGTH(REPLACE(p_EME_Id, ',', '')) + 1) INTO v_EMEIDNEW1;

    v_EMEIDNEW1 := (v_EMEIDNEW1 - 1)::TEXT;

    SELECT STRING_AGG(DISTINCT '","' || "EME_Id", '') || '"' INTO v_EMEIDNEW
    FROM "ExamIds_Temp";
    
    v_EMEIDNEW := SUBSTRING(v_EMEIDNEW FROM 3);

    SELECT STRING_AGG(DISTINCT '" + "' || "EME_Id", '') || '"' INTO v_EMEIDNEWSUM
    FROM "ExamIds_Temp";
    
    v_EMEIDNEWSUM := SUBSTRING(v_EMEIDNEWSUM FROM 4);

    IF p_FLAG = 'Average' THEN

        v_SQLQUERY := 'SELECT "AMCST_Id", "REGNO", "ADMNO", "STUDENTNAME", "ECSTMPS_MaxMarks", ' || v_EMEIDNEW || 
                      ', CAST(SUM(' || v_EMEIDNEWSUM || ') / ' || v_EMEIDNEW1 || ' AS NUMERIC(18,2)) AS final, "CLASSHELD", "PRESENT" ' ||
                      'FROM (SELECT DISTINCT B."AMCST_Id", COALESCE(A."AMCST_RegistrationNo", '''') AS "REGNO", COALESCE(A."AMCST_AdmNo", '''') AS "ADMNO", ' ||
                      '(CASE WHEN A."AMCST_FirstName" = '''' OR A."AMCST_FirstName" IS NULL THEN '''' ELSE A."AMCST_FirstName" END || ' ||
                      'CASE WHEN A."AMCST_MiddleName" = '''' OR A."AMCST_MiddleName" IS NULL THEN '''' ELSE '' '' || A."AMCST_MiddleName" END || ' ||
                      'CASE WHEN A."AMCST_LastName" = '''' OR A."AMCST_LastName" IS NULL THEN '''' ELSE '' '' || A."AMCST_LastName" END) AS "STUDENTNAME", ' ||
                      '"ECSTMPS_MaxMarks", "ECSTMPS_ObtainedMarks", "EME_Id", ' ||
                      'SUM(K."ACSA_ClassHeld") AS "CLASSHELD", SUM(J."ACSAS_ClassAttended") AS "PRESENT" ' ||
                      'FROM "CLG"."Adm_Master_College_Student" A ' ||
                      'INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = B."AMCO_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = B."AMB_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = B."AMSE_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Master_Section" F ON F."ACMS_Id" = B."ACMS_Id" ' ||
                      'INNER JOIN "Adm_School_M_Academic_Year" G ON G."ASMAY_Id" = B."ASMAY_Id" ' ||
                      'INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" H ON H."AMCST_Id" = B."AMCST_Id" AND H."AMCO_Id" = C."AMCO_Id" AND H."AMB_Id" = D."AMB_Id" AND H."AMSE_Id" = E."AMSE_Id" AND H."ACMS_Id" = F."ACMS_Id" AND H."ASMAY_Id" = G."ASMAY_Id" ' ||
                      'INNER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" I ON I."AMCST_Id" = B."AMCST_Id" AND I."AMCO_Id" = C."AMCO_Id" AND I."AMB_Id" = D."AMB_Id" AND I."AMSE_Id" = E."AMSE_Id" AND I."ACMS_Id" = F."ACMS_Id" AND I."ASMAY_Id" = G."ASMAY_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Student_Attendance_Students" J ON J."AMCST_Id" = B."AMCST_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Student_Attendance" K ON K."ACSA_Id" = J."ACSA_Id" AND K."AMCO_Id" = C."AMCO_Id" AND K."AMB_Id" = D."AMB_Id" AND K."AMSE_Id" = E."AMSE_Id" AND K."ACMS_Id" = F."ACMS_Id" AND K."ASMAY_Id" = G."ASMAY_Id" ' ||
                      'WHERE B."AMCO_Id" = ' || p_AMCO_Id || ' AND B."AMB_Id" = ' || p_AMB_Id || ' AND B."AMSE_Id" = ' || p_AMSE_Id || ' AND B."ACMS_Id" = ' || p_ACMS_Id || ' AND B."ASMAY_Id" = ' || p_ASMAY_Id || ' ' ||
                      'AND H."AMCO_Id" = ' || p_AMCO_Id || ' AND H."AMB_Id" = ' || p_AMB_Id || ' AND H."AMSE_Id" = ' || p_AMSE_Id || ' AND H."ACMS_Id" = ' || p_ACMS_Id || ' AND H."ASMAY_Id" = ' || p_ASMAY_Id || ' AND H."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                      'AND I."AMCO_Id" = ' || p_AMCO_Id || ' AND I."AMB_Id" = ' || p_AMB_Id || ' AND I."AMSE_Id" = ' || p_AMSE_Id || ' AND I."ACMS_Id" = ' || p_ACMS_Id || ' AND I."ASMAY_Id" = ' || p_ASMAY_Id || ' AND I."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                      'AND I."MI_Id" = ' || p_MI_Id || ' AND H."MI_Id" = ' || p_MI_Id || ' ' ||
                      'AND K."AMCO_Id" = ' || p_AMCO_Id || ' AND K."AMB_Id" = ' || p_AMB_Id || ' AND K."AMSE_Id" = ' || p_AMSE_Id || ' AND K."ACMS_Id" = ' || p_ACMS_Id || ' AND K."ASMAY_Id" = ' || p_ASMAY_Id || ' AND K."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                      'AND I."EME_Id"::TEXT IN (' || p_EME_Id || ') ' ||
                      'GROUP BY B."AMCST_Id", A."AMCST_RegistrationNo", A."AMCST_AdmNo", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "ECSTMPS_MaxMarks", "ECSTMPS_ObtainedMarks", "EME_Id") AS d ' ||
                      'CROSS JOIN LATERAL (SELECT ' || v_EMEIDNEW || ') AS pvt ' ||
                      'GROUP BY "AMCST_Id", "REGNO", "ADMNO", "STUDENTNAME", "ECSTMPS_MaxMarks", "CLASSHELD", "PRESENT", ' || v_EMEIDNEW || ' ' ||
                      'ORDER BY "STUDENTNAME"';

        RETURN QUERY EXECUTE v_SQLQUERY;

    ELSIF p_FLAG = 'Best' THEN

        v_SQLQUERY := 'CREATE TEMP TABLE "college_examwise_marks_temp" AS ' ||
                      'SELECT "AMCST_Id", "REGNO", "ADMNO", "STUDENTNAME", "ECSTMPS_MaxMarks", ' || v_EMEIDNEW || ', "CLASSHELD", "PRESENT" ' ||
                      'FROM (SELECT DISTINCT B."AMCST_Id", COALESCE(A."AMCST_RegistrationNo", '''') AS "REGNO", COALESCE(A."AMCST_AdmNo", '''') AS "ADMNO", ' ||
                      '(CASE WHEN A."AMCST_FirstName" = '''' OR A."AMCST_FirstName" IS NULL THEN '''' ELSE A."AMCST_FirstName" END || ' ||
                      'CASE WHEN A."AMCST_MiddleName" = '''' OR A."AMCST_MiddleName" IS NULL THEN '''' ELSE '' '' || A."AMCST_MiddleName" END || ' ||
                      'CASE WHEN A."AMCST_LastName" = '''' OR A."AMCST_LastName" IS NULL THEN '''' ELSE '' '' || A."AMCST_LastName" END) AS "STUDENTNAME", ' ||
                      '"ECSTMPS_MaxMarks", "ECSTMPS_ObtainedMarks", "EME_Id", ' ||
                      'SUM(K."ACSA_ClassHeld") AS "CLASSHELD", SUM(J."ACSAS_ClassAttended") AS "PRESENT" ' ||
                      'FROM "CLG"."Adm_Master_College_Student" A ' ||
                      'INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = B."AMCO_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = B."AMB_Id" ' ||
                      'INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = B."AMSE_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Master_Section" F ON F."ACMS_Id" = B."ACMS_Id" ' ||
                      'INNER JOIN "Adm_School_M_Academic_Year" G ON G."ASMAY_Id" = B."ASMAY_Id" ' ||
                      'INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" H ON H."AMCST_Id" = B."AMCST_Id" AND H."AMCO_Id" = C."AMCO_Id" AND H."AMB_Id" = D."AMB_Id" AND H."AMSE_Id" = E."AMSE_Id" AND H."ACMS_Id" = F."ACMS_Id" AND H."ASMAY_Id" = G."ASMAY_Id" ' ||
                      'INNER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" I ON I."AMCST_Id" = B."AMCST_Id" AND I."AMCO_Id" = C."AMCO_Id" AND I."AMB_Id" = D."AMB_Id" AND I."AMSE_Id" = E."AMSE_Id" AND I."ACMS_Id" = F."ACMS_Id" AND I."ASMAY_Id" = G."ASMAY_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Student_Attendance_Students" J ON J."AMCST_Id" = B."AMCST_Id" ' ||
                      'INNER JOIN "CLG"."Adm_College_Student_Attendance" K ON K."ACSA_Id" = J."ACSA_Id" AND K."AMCO_Id" = C."AMCO_Id" AND K."AMB_Id" = D."AMB_Id" AND K."AMSE_Id" = E."AMSE_Id" AND K."ACMS_Id" = F."ACMS_Id" AND K."ASMAY_Id" = G."ASMAY_Id" ' ||
                      'WHERE B."AMCO_Id" = ' || p_AMCO_Id || ' AND B."AMB_Id" = ' || p_AMB_Id || ' AND B."AMSE_Id" = ' || p_AMSE_Id || ' AND B."ACMS_Id" = ' || p_ACMS_Id || ' AND B."ASMAY_Id" = ' || p_ASMAY_Id || ' ' ||
                      'AND H."AMCO_Id" = ' || p_AMCO_Id || ' AND H."AMB_Id" = ' || p_AMB_Id || ' AND H."AMSE_Id" = ' || p_AMSE_Id || ' AND H."ACMS_Id" = ' || p_ACMS_Id || ' AND H."ASMAY_Id" = ' || p_ASMAY_Id || ' AND H."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                      'AND I."AMCO_Id" = ' || p_AMCO_Id || ' AND I."AMB_Id" = ' || p_AMB_Id || ' AND I."AMSE_Id" = ' || p_AMSE_Id || ' AND I."ACMS_Id" = ' || p_ACMS_Id || ' AND I."ASMAY_Id" = ' || p_ASMAY_Id || ' AND I."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                      'AND I."MI_Id" = ' || p_MI_Id || ' AND H."MI_Id" = ' || p_MI_Id || ' ' ||
                      'AND K."AMCO_Id" = ' || p_AMCO_Id || ' AND K."AMB_Id" = ' || p_AMB_Id || ' AND K."AMSE_Id" = ' || p_AMSE_Id || ' AND K."ACMS_Id" = ' || p_ACMS_Id || ' AND K."ASMAY_Id" = ' || p_ASMAY_Id || ' AND K."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                      'AND I."EME_Id"::TEXT IN (' || p_EME_Id || ') ' ||
                      'GROUP BY B."AMCST_Id", A."AMCST_RegistrationNo", A."AMCST_AdmNo", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "ECSTMPS_MaxMarks", "ECSTMPS_ObtainedMarks", "EME_Id") AS d ' ||
                      'CROSS JOIN LATERAL (SELECT ' || v_EMEIDNEW || ') AS pvt ' ||
                      'GROUP BY "AMCST_Id", "REGNO", "ADMNO", "STUDENTNAME", "ECSTMPS_MaxMarks", "CLASSHELD", "PRESENT", ' || v_EMEIDNEW || ' ' ||
                      'ORDER BY "STUDENTNAME"';

        EXECUTE v_SQLQUERY;

        v_SQLQUERY1 := 'CREATE TEMP TABLE "college_temp_best_marks" AS ' ||
                       'SELECT DISTINCT B."AMCST_Id", COALESCE(A."AMCST_RegistrationNo", '''') AS "REGNO", COALESCE(A."AMCST_AdmNo", '''') AS "ADMNO", ' ||
                       '(CASE WHEN A."AMCST_FirstName" = '''' OR A."AMCST_FirstName" IS NULL THEN '''' ELSE A."AMCST_FirstName" END || ' ||
                       'CASE WHEN A."AMCST_MiddleName" = '''' OR A."AMCST_MiddleName" IS NULL THEN '''' ELSE '' '' || A."AMCST_MiddleName" END || ' ||
                       'CASE WHEN A."AMCST_LastName" = '''' OR A."AMCST_LastName" IS NULL THEN '''' ELSE '' '' || A."AMCST_LastName" END) AS "STUDENTNAME", ' ||
                       '"ECSTMPS_MaxMarks", "ECSTMPS_ObtainedMarks", "EME_Id", ' ||
                       'SUM(K."ACSA_ClassHeld") AS "CLASSHELD", SUM(J."ACSAS_ClassAttended") AS "PRESENT" ' ||
                       'FROM "CLG"."Adm_Master_College_Student" A ' ||
                       'INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id" ' ||
                       'INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = B."AMCO_Id" ' ||
                       'INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = B."AMB_Id" ' ||
                       'INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = B."AMSE_Id" ' ||
                       'INNER JOIN "CLG"."Adm_College_Master_Section" F ON F."ACMS_Id" = B."ACMS_Id" ' ||
                       'INNER JOIN "Adm_School_M_Academic_Year" G ON G."ASMAY_Id" = B."ASMAY_Id" ' ||
                       'INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" H ON H."AMCST_Id" = B."AMCST_Id" AND H."AMCO_Id" = C."AMCO_Id" AND H."AMB_Id" = D."AMB_Id" AND H."AMSE_Id" = E."AMSE_Id" AND H."ACMS_Id" = F."ACMS_Id" AND H."ASMAY_Id" = G."ASMAY_Id" ' ||
                       'INNER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" I ON I."AMCST_Id" = B."AMCST_Id" AND I."AMCO_Id" = C."AMCO_Id" AND I."AMB_Id" = D."AMB_Id" AND I."AMSE_Id" = E."AMSE_Id" AND I."ACMS_Id" = F."ACMS_Id" AND I."ASMAY_Id" = G."ASMAY_Id" ' ||
                       'INNER JOIN "CLG"."Adm_College_Student_Attendance_Students" J ON J."AMCST_Id" = B."AMCST_Id" ' ||
                       'INNER JOIN "CLG"."Adm_College_Student_Attendance" K ON K."ACSA_Id" = J."ACSA_Id" AND K."AMCO_Id" = C."AMCO_Id" AND K."AMB_Id" = D."AMB_Id" AND K."AMSE_Id" = E."AMSE_Id" AND K."ACMS_Id" = F."ACMS_Id" AND K."ASMAY_Id" = G."ASMAY_Id" ' ||
                       'WHERE B."AMCO_Id" = ' || p_AMCO_Id || ' AND B."AMB_Id" = ' || p_AMB_Id || ' AND B."AMSE_Id" = ' || p_AMSE_Id || ' AND B."ACMS_Id" = ' || p_ACMS_Id || ' AND B."ASMAY_Id" = ' || p_ASMAY_Id || ' ' ||
                       'AND H."AMCO_Id" = ' || p_AMCO_Id || ' AND H."AMB_Id" = ' || p_AMB_Id || ' AND H."AMSE_Id" = ' || p_AMSE_Id || ' AND H."ACMS_Id" = ' || p_ACMS_Id || ' AND H."ASMAY_Id" = ' || p_ASMAY_Id || ' AND H."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                       'AND I."AMCO_Id" = ' || p_AMCO_Id || ' AND I."AMB_Id" = ' || p_AMB_Id || ' AND I."AMSE_Id" = ' || p_AMSE_Id || ' AND I."ACMS_Id" = ' || p_ACMS_Id || ' AND I."ASMAY_Id" = ' || p_ASMAY_Id || ' AND I."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                       'AND I."MI_Id" = ' || p_MI_Id || ' AND H."MI_Id" = ' || p_MI_Id || ' ' ||
                       'AND K."AMCO_Id" = ' || p_AMCO_Id || ' AND K."AMB_Id" = ' || p_AMB_Id || ' AND K."AMSE_Id" = ' || p_AMSE_Id || ' AND K."ACMS_Id" = ' || p_ACMS_Id || ' AND K."ASMAY_Id" = ' || p_ASMAY_Id || ' AND K."ISMS_Id" = ' || p_ISMS_Id || ' ' ||
                       'AND I."EME_Id"::TEXT IN (' || p_EME_Id || ') ' ||
                       'GROUP BY B."AMCST_Id", A."AMCST_RegistrationNo", A."AMCST_AdmNo", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "ECSTMPS_MaxMarks", "ECSTMPS_ObtainedMarks", "EME_Id"';

        EXECUTE v_SQLQUERY1;

        CREATE TEMP TABLE "StudentBestMarks_Temp" AS
        WITH cte AS (
            SELECT "AMCST_Id", "ADMNO", "REGNO", "STUDENTNAME", "CLASSHELD", "PRESENT", "ECSTMPS_ObtainedMarks",
                   ROW_NUMBER() OVER(PARTITION BY "STUDENTNAME" ORDER BY "ECSTMPS_ObtainedMarks" DESC) AS "RN"
            FROM "college_temp_best_marks"
        )
        SELECT A."AMCST_Id", A."ADMNO", A."REGNO", A."STUDENTNAME", A."CLASSHELD", A."PRESENT",
               CAST(SUM(A."ECSTMPS_ObtainedMarks") / p_BEST AS NUMERIC(18,2)) AS "StudentBestMarks"
        FROM cte A
        WHERE "RN" <= p_BEST
        GROUP BY A."AMCST_Id", A."REGNO", A."ADMNO", A."STUDENTNAME", A."CLASSHELD", A."PRESENT";

        ALTER TABLE "college_examwise_marks_temp" ADD COLUMN "final" NUMERIC(18,2);

        UPDATE "college_examwise_marks_temp" A 
        SET "final" = B."StudentBestMarks"
        FROM "StudentBestMarks_Temp" B
        WHERE A."AMCST_Id" = B."AMCST_Id";

        RETURN QUERY 
        SELECT A."AMCST_Id", A."REGNO", A."ADMNO", A."STUDENTNAME", A."ECSTMPS_MaxMarks", A."CLASSHELD", A."PRESENT", A."final"
        FROM "college_examwise_marks_temp" A
        ORDER BY A."STUDENTNAME";

    END IF;

END;
$$;