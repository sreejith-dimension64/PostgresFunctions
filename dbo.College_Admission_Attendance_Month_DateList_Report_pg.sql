CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Attendance_Month_DateList_Report"(
    "p_asmay_id" TEXT,
    "p_mi_id" TEXT,
    "p_month" TEXT,
    "p_amco_id" TEXT,
    "p_amb_id" TEXT,
    "p_amse_id" TEXT,
    "p_acms_id" TEXT,
    "p_isms_id" TEXT
)
RETURNS TABLE(
    "student" TEXT,
    "admno" TEXT,
    "regno" TEXT,
    "coursename" TEXT,
    "branchname" TEXT,
    "sectionname" TEXT,
    "semestername" TEXT,
    "subjectname" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Query" TEXT;
    "v_Year" INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    "v_sqlquery" TEXT;
    "v_cursorValue" TEXT;
    "v_Cl" TEXT;
    "v_C2" TEXT;
    "v_query1" TEXT;
    "v_cols" TEXT;
    "v_monthyearsd" TEXT := '';
    "v_monthyearsd1" TEXT := '';
    "v_cols1" TEXT;
    "v_startDate" DATE;
    "v_endDate" DATE;
    "v_date_rec" RECORD;
    "v_cal_rec" RECORD;
BEGIN

    CREATE TEMP TABLE IF NOT EXISTS "NewTablemonthcollege"(
        "id" SERIAL NOT NULL,
        "MonthId" INT,
        "AYear" INT
    ) ON COMMIT DROP;

    SELECT "ASMAY_From_Date" INTO "v_startDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id"::INT AND "ASMAY_Id" = "p_ASMAY_Id"::INT;
    
    SELECT "ASMAY_To_Date" INTO "v_endDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id"::INT AND "ASMAY_Id" = "p_ASMAY_Id"::INT;

    WITH RECURSIVE "CTE" AS (
        SELECT "v_startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 MONTH')::DATE 
        FROM "CTE" 
        WHERE ("Dates" + INTERVAL '1 MONTH')::DATE <= "v_endDate"::DATE
    )
    INSERT INTO "NewTablemonthcollege"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INT, EXTRACT(YEAR FROM "Dates")::INT 
    FROM "CTE";

    SELECT "AYear" INTO "v_year" 
    FROM "NewTablemonthcollege" 
    WHERE "monthid" = "p_month"::INT;

    DROP TABLE IF EXISTS "calendercollege";
    CREATE TEMP TABLE "calendercollege"(
        "day" INT, 
        "date" VARCHAR(50)
    ) ON COMMIT DROP;

    "v_Query" := 'WITH "N"("N") AS (
        SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1)) "M"("N")
    ),
    "tally"("N") AS (
        SELECT ROW_NUMBER() OVER(ORDER BY "N"."N") 
        FROM "N", "N" "a"
    )
    SELECT "N" "day", 
           REPLACE(TO_CHAR(MAKE_DATE(' || "v_year"::TEXT || ', ' || "p_month" || ', "N"), ''DD-MM-YYYY''), '' '', ''-'') "date" 
    FROM "tally"
    WHERE "N" <= EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', MAKE_DATE(' || "v_year"::TEXT || ', ' || "p_month" || ', 1)) + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))';

    EXECUTE "v_Query";

    INSERT INTO "calendercollege"("day", "date")
    EXECUTE "v_Query";

    FOR "v_cal_rec" IN 
        SELECT "date", "day" FROM "calendercollege" 
    LOOP
        "v_cols" := "v_cal_rec"."date";
        "v_cols1" := "v_cal_rec"."day"::TEXT;
        
        "v_monthyearsd" := COALESCE("v_monthyearsd", '') || COALESCE('"' || "v_cols1" || '"' || ', ', '');
        "v_monthyearsd1" := COALESCE("v_monthyearsd1", '') || 
            ('CASE WHEN "' || "v_cols1" || '" = 1.00 THEN ''P'' WHEN "' || "v_cols1" || '" = 0.00 THEN ''A'' ELSE '''' END AS "' || "v_cols1" || '", ');
    END LOOP;

    "v_monthyearsd" := LEFT("v_monthyearsd", LENGTH("v_monthyearsd") - 1);
    "v_monthyearsd1" := LEFT("v_monthyearsd1", LENGTH("v_monthyearsd1") - 1);

    "v_query1" := 'SELECT "student", "admno", "regno", "coursename", "branchname", "sectionname", "semestername", "subjectname", ' || "v_monthyearsd1" || 
    ' FROM (
        SELECT (COALESCE("stuadm"."AMCST_FirstName", '''') || '' '' || COALESCE("stuadm"."AMCST_MiddleName", '''') || '' '' || COALESCE("stuadm"."AMCST_LastName", '''')) AS "student",
        "stuadm"."AMCST_AdmNo" AS "admno", 
        "stuadm"."AMCST_RegistrationNo" AS "regno", 
        "AMCO_CourseName" AS "coursename",
        "AMB_BranchName" AS "branchname", 
        "AMSE_SEMName" AS "semestername", 
        "ACMS_SectionName" AS "sectionname", 
        "ISMS_SubjectName" AS "subjectname", 
        EXTRACT(DAY FROM "att"."ACSA_AttendanceDate"::TIMESTAMP) AS "ACSA_AttendanceDate",
        "ACSAS_ClassAttended" AS "TOTAL_PRESENT",
        "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"
        FROM "clg"."Adm_College_Student_Attendance" "att" 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "attstu" ON "att"."ACSA_Id" = "attstu"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "attstupre" ON "attstupre"."ACSA_Id" = "attstu"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "stuyear" ON "stuyear"."AMCST_Id" = "attstu"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "stuadm" ON "stuadm"."AMCST_Id" = "stuyear"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "co" ON "co"."AMCO_Id" = "att"."AMCO_Id" AND "co"."AMCO_Id" = "stuyear"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "bo" ON "bo"."AMB_Id" = "att"."AMB_Id" AND "bo"."AMB_Id" = "stuyear"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "sem" ON "sem"."AMSE_Id" = "att"."AMSE_Id" AND "sem"."AMSE_Id" = "stuyear"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "sec" ON "sec"."ACMS_Id" = "att"."ACMS_Id" AND "sec"."ACMS_Id" = "stuyear"."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "sub" ON "sub"."ISMS_Id" = "att"."ISMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "yer" ON "yer"."ASMAY_Id" = "att"."ASMAY_Id" AND "yer"."ASMAY_Id" = "stuyear"."ASMAY_Id"
        WHERE "att"."ASMAY_Id" = ' || "p_asmay_id" || ' AND "stuyear"."ASMAY_Id" = ' || "p_asmay_id" || '
        AND "att"."AMCO_Id" = ' || "p_amco_id" || ' AND "stuyear"."AMCO_Id" = ' || "p_amco_id" || '
        AND "att"."AMB_Id" IN (' || "p_amb_id" || ') AND "stuyear"."AMB_Id" IN (' || "p_amb_id" || ')
        AND "att"."AMSE_Id" = ' || "p_amse_id" || ' AND "stuyear"."AMSE_Id" = ' || "p_amse_id" || '
        AND "att"."ACMS_Id" = ' || "p_acms_id" || ' AND "stuyear"."ACMS_Id" = ' || "p_acms_id" || ' AND "att"."ACSA_ActiveFlag" = TRUE
        AND "att"."ISMS_Id" = ' || "p_isms_id" || ' AND "stuadm"."AMCST_SOL" = ''S'' 
        AND EXTRACT(MONTH FROM "att"."ACSA_AttendanceDate") = ' || "p_month" || '
        AND EXTRACT(YEAR FROM "att"."ACSA_AttendanceDate") = ' || "v_year"::TEXT || '
        AND "stuadm"."AMCST_ActiveFlag" = TRUE
        ORDER BY "student", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder" LIMIT 100
    ) AS "s"
    -- PIVOT logic would need to use crosstab or dynamic query generation
    ORDER BY "AMB_Order", "student"';

    RETURN QUERY EXECUTE "v_query1";

END;
$$;