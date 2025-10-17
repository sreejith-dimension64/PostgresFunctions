CREATE OR REPLACE FUNCTION "dbo"."College_Attendace_PeriodWise_Scheduler_List"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_ACSA_AttendanceDate" TEXT,
    "p_AMSE_Id" TEXT,
    "p_ACMS_Id" TEXT,
    "p_ISMS_Id" TEXT,
    "p_TTMP_Id" TEXT
)
RETURNS TABLE(
    "AMCST_MobileNo" TEXT,
    "AMCST_Id" BIGINT,
    "DATE" TEXT,
    "NAME" TEXT,
    "SUBJECTS" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ASC_DefaultSMS_Flag" TEXT;
BEGIN
    -- Get default SMS flag
    SELECT "ASC_DefaultSMS_Flag" INTO "v_ASC_DefaultSMS_Flag" 
    FROM "Adm_School_Configuration" 
    WHERE "mi_id" = "p_MI_Id"::BIGINT;

    -- Drop temporary tables if they exist
    DROP TABLE IF EXISTS "TEMPCOURSE";
    DROP TABLE IF EXISTS "TEMPBRNACH";
    DROP TABLE IF EXISTS "TEMPSEMESTER";
    DROP TABLE IF EXISTS "TEMPSECTION";
    DROP TABLE IF EXISTS "TEMPPERIOD";
    DROP TABLE IF EXISTS "temp1modify";

    -- Create temporary tables
    EXECUTE 'CREATE TEMP TABLE "TEMPCOURSE" AS SELECT * FROM "CLG"."ADM_MASTER_COURSE" WHERE "MI_ID" = ' || "p_MI_Id" || ' AND "AMCO_Id" IN (' || "p_AMCO_Id" || ')';
    
    EXECUTE 'CREATE TEMP TABLE "TEMPBRNACH" AS SELECT * FROM "CLG"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || "p_MI_Id" || ' AND "AMB_Id" IN (' || "p_AMB_Id" || ')';
    
    EXECUTE 'CREATE TEMP TABLE "TEMPSEMESTER" AS SELECT * FROM "CLG"."ADM_MASTER_SEMESTER" WHERE "MI_ID" = ' || "p_MI_Id" || ' AND "AMSE_Id" IN (' || "p_AMSE_Id" || ')';
    
    EXECUTE 'CREATE TEMP TABLE "TEMPPERIOD" AS SELECT * FROM "TT_Master_Period" WHERE "MI_ID" = ' || "p_MI_Id" || ' AND "TTMP_id" IN (' || "p_TTMP_Id" || ')';
    
    EXECUTE 'CREATE TEMP TABLE "TEMPSECTION" AS SELECT * FROM "clg"."Adm_College_Master_Section" WHERE "MI_ID" = ' || "p_MI_Id" || ' AND "ACMS_Id" IN (' || "p_ACMS_Id" || ')';

    IF "v_ASC_DefaultSMS_Flag" = 'F' THEN
        
        CREATE TEMP TABLE "temp1modify" AS
        SELECT 
            (CASE WHEN "dd"."AMCST_FirstName" IS NULL OR "dd"."AMCST_FirstName" = '' THEN '' ELSE "dd"."AMCST_FirstName" END ||
            CASE WHEN "dd"."AMCST_MiddleName" IS NULL OR "dd"."AMCST_MiddleName" = '' OR "dd"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_MiddleName" END ||
            CASE WHEN "dd"."AMCST_LastName" IS NULL OR "dd"."AMCST_LastName" = '' OR "dd"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject : ' || COALESCE("sub"."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE("j"."TTMP_PeriodName", '') AS subject,
            "dd"."AMCST_FatherMobleNo" AS "AMCST_MobileNo",
            "a"."MI_Id",
            "a"."ACSA_AttendanceDate",
            "d"."AMCST_Id"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "c" ON "c"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "d" ON "d"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "dd" ON "dd"."AMCST_Id" = "d"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "e" ON "e"."AMCO_Id" = "a"."AMCO_Id" AND "e"."AMCO_Id" = "d"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "a"."AMB_Id" AND "f"."AMB_Id" = "d"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "g" ON "g"."AMSE_Id" = "a"."AMSE_Id" AND "g"."AMSE_Id" = "d"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "h" ON "h"."ACMS_Id" = "a"."ACMS_Id" AND "h"."ACMS_Id" = "d"."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "i" ON "i"."ISMS_Id" = "a"."ISMS_Id"
        INNER JOIN "TT_Master_Period" "j" ON "j"."TTMP_Id" = "c"."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" "sub" ON "sub"."ISMS_Id" = "a"."ISMS_Id"
        WHERE "a"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "dd"."AMCST_SOL" = 'S'
        AND "dd"."AMCST_ActiveFlag" = 1
        AND "d"."ACYST_ActiveFlag" = 1
        AND "a"."ACSA_ActiveFlag" = 1
        AND "b"."ACSAS_ClassAttended" = 0.00
        AND "a"."ACSA_AttendanceDate" = "p_ACSA_AttendanceDate"::DATE
        AND "a"."MI_Id" = "p_MI_Id"::BIGINT
        AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "dd"."AMCST_FatherMobleNo" IS NOT NULL
        AND "a"."AMCO_Id" IN (SELECT "AMCO_Id" FROM "TEMPCOURSE")
        AND "a"."AMB_Id" IN (SELECT "AMB_Id" FROM "TEMPBRNACH")
        AND "a"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "TEMPSEMESTER")
        AND "a"."ACMS_Id" IN (SELECT "ACMS_Id" FROM "TEMPSECTION")
        AND "a"."ISMS_Id" = "p_ISMS_Id"::BIGINT
        AND "c"."TTMP_Id" IN (SELECT "TTMP_Id" FROM "TEMPPERIOD")
        AND "d"."AMCO_Id" IN (SELECT "AMCO_Id" FROM "TEMPCOURSE")
        AND "d"."AMB_Id" IN (SELECT "AMB_Id" FROM "TEMPBRNACH")
        AND "d"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "TEMPSEMESTER")
        AND "d"."ACMS_Id" IN (SELECT "ACMS_Id" FROM "TEMPSECTION");

        RETURN QUERY
        SELECT 
            "B"."AMCST_MobileNo",
            "B"."AMCST_Id",
            TO_CHAR("B"."ACSA_AttendanceDate", 'DD/MM/YYYY') AS "DATE",
            "B"."AMCST_FirstName" AS "NAME",
            STRING_AGG("A".subject, ', ' ORDER BY "A".subject) AS "SUBJECTS"
        FROM "temp1modify" "B"
        LEFT JOIN "temp1modify" "A" ON "A"."AMCST_MobileNo" = "B"."AMCST_MobileNo" AND "A"."AMCST_FirstName" = "B"."AMCST_FirstName"
        GROUP BY "B"."AMCST_MobileNo", "B"."AMCST_FirstName", "B"."MI_Id", "B"."ACSA_AttendanceDate", "B"."AMCST_Id";

    ELSIF "v_ASC_DefaultSMS_Flag" = 'M' THEN

        CREATE TEMP TABLE "temp1modify" AS
        SELECT 
            (CASE WHEN "dd"."AMCST_FirstName" IS NULL OR "dd"."AMCST_FirstName" = '' THEN '' ELSE "dd"."AMCST_FirstName" END ||
            CASE WHEN "dd"."AMCST_MiddleName" IS NULL OR "dd"."AMCST_MiddleName" = '' OR "dd"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_MiddleName" END ||
            CASE WHEN "dd"."AMCST_LastName" IS NULL OR "dd"."AMCST_LastName" = '' OR "dd"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject : ' || COALESCE("sub"."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE("j"."TTMP_PeriodName", '') AS subject,
            "dd"."AMCST_MotherMobleNo" AS "AMCST_MobileNo",
            "a"."MI_Id",
            "a"."ACSA_AttendanceDate",
            "d"."AMCST_Id"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "c" ON "c"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "d" ON "d"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "dd" ON "dd"."AMCST_Id" = "d"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "e" ON "e"."AMCO_Id" = "a"."AMCO_Id" AND "e"."AMCO_Id" = "d"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "a"."AMB_Id" AND "f"."AMB_Id" = "d"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "g" ON "g"."AMSE_Id" = "a"."AMSE_Id" AND "g"."AMSE_Id" = "d"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "h" ON "h"."ACMS_Id" = "a"."ACMS_Id" AND "h"."ACMS_Id" = "d"."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "i" ON "i"."ISMS_Id" = "a"."ISMS_Id"
        INNER JOIN "TT_Master_Period" "j" ON "j"."TTMP_Id" = "c"."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" "sub" ON "sub"."ISMS_Id" = "a"."ISMS_Id"
        WHERE "a"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "dd"."AMCST_SOL" = 'S'
        AND "dd"."AMCST_ActiveFlag" = 1
        AND "d"."ACYST_ActiveFlag" = 1
        AND "a"."ACSA_ActiveFlag" = 1
        AND "b"."ACSAS_ClassAttended" = 0.00
        AND "a"."ACSA_AttendanceDate" = "p_ACSA_AttendanceDate"::DATE
        AND "a"."MI_Id" = "p_MI_Id"::BIGINT
        AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "dd"."AMCST_MotherMobleNo" IS NOT NULL
        AND "a"."AMCO_Id" IN (SELECT "AMCO_Id" FROM "TEMPCOURSE")
        AND "a"."AMB_Id" IN (SELECT "AMB_Id" FROM "TEMPBRNACH")
        AND "a"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "TEMPSEMESTER")
        AND "a"."ACMS_Id" IN (SELECT "ACMS_Id" FROM "TEMPSECTION")
        AND "a"."ISMS_Id" = "p_ISMS_Id"::BIGINT
        AND "c"."TTMP_Id" IN (SELECT "TTMP_Id" FROM "TEMPPERIOD")
        AND "d"."AMCO_Id" IN (SELECT "AMCO_Id" FROM "TEMPCOURSE")
        AND "d"."AMB_Id" IN (SELECT "AMB_Id" FROM "TEMPBRNACH")
        AND "d"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "TEMPSEMESTER")
        AND "d"."ACMS_Id" IN (SELECT "ACMS_Id" FROM "TEMPSECTION");

        RETURN QUERY
        SELECT 
            "B"."AMCST_MobileNo",
            "B"."AMCST_Id",
            TO_CHAR("B"."ACSA_AttendanceDate", 'DD/MM/YYYY') AS "DATE",
            "B"."AMCST_FirstName" AS "NAME",
            STRING_AGG("A".subject, ', ' ORDER BY "A".subject) AS "SUBJECTS"
        FROM "temp1modify" "B"
        LEFT JOIN "temp1modify" "A" ON "A"."AMCST_MobileNo" = "B"."AMCST_MobileNo" AND "A"."AMCST_FirstName" = "B"."AMCST_FirstName"
        GROUP BY "B"."AMCST_MobileNo", "B"."AMCST_FirstName", "B"."MI_Id", "B"."ACSA_AttendanceDate", "B"."AMCST_Id";

    ELSE

        CREATE TEMP TABLE "temp1modify" AS
        SELECT 
            (CASE WHEN "dd"."AMCST_FirstName" IS NULL OR "dd"."AMCST_FirstName" = '' THEN '' ELSE "dd"."AMCST_FirstName" END ||
            CASE WHEN "dd"."AMCST_MiddleName" IS NULL OR "dd"."AMCST_MiddleName" = '' OR "dd"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_MiddleName" END ||
            CASE WHEN "dd"."AMCST_LastName" IS NULL OR "dd"."AMCST_LastName" = '' OR "dd"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject : ' || COALESCE("sub"."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE("j"."TTMP_PeriodName", '') AS subject,
            "dd"."AMCST_MobileNo",
            "a"."MI_Id",
            "a"."ACSA_AttendanceDate",
            "d"."AMCST_Id"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "c" ON "c"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "d" ON "d"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "dd" ON "dd"."AMCST_Id" = "d"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "e" ON "e"."AMCO_Id" = "a"."AMCO_Id" AND "e"."AMCO_Id" = "d"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "a"."AMB_Id" AND "f"."AMB_Id" = "d"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "g" ON "g"."AMSE_Id" = "a"."AMSE_Id" AND "g"."AMSE_Id" = "d"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "h" ON "h"."ACMS_Id" = "a"."ACMS_Id" AND "h"."ACMS_Id" = "d"."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "i" ON "i"."ISMS_Id" = "a"."ISMS_Id"
        INNER JOIN "TT_Master_Period" "j" ON "j"."TTMP_Id" = "c"."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" "sub" ON "sub"."ISMS_Id" = "a"."ISMS_Id"
        WHERE "a"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "dd"."AMCST_SOL" = 'S'
        AND "dd"."AMCST_ActiveFlag" = 1
        AND "d"."ACYST_ActiveFlag" = 1
        AND "a"."ACSA_ActiveFlag" = 1
        AND "b"."ACSAS_ClassAttended" = 0.00
        AND "a"."ACSA_AttendanceDate" = "p_ACSA_AttendanceDate"::DATE
        AND "a"."MI_Id" = "p_MI_Id"::BIGINT
        AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        AND "dd"."AMCST_MobileNo" IS NOT NULL
        AND "a"."AMCO_Id" IN (SELECT "AMCO_Id" FROM "TEMPCOURSE")
        AND "a"."AMB_Id" IN (SELECT "AMB_Id" FROM "TEMPBRNACH")
        AND "a"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "TEMPSEMESTER")
        AND "a"."ACMS_Id" IN (SELECT "ACMS_Id" FROM "TEMPSECTION")
        AND "a"."ISMS_Id" = "p_ISMS_Id"::BIGINT
        AND "c"."TTMP_Id" IN (SELECT "TTMP_Id" FROM "TEMPPERIOD")
        AND "d"."AMCO_Id" IN (SELECT "AMCO_Id" FROM "TEMPCOURSE")
        AND "d"."AMB_Id" IN (SELECT "AMB_Id" FROM "TEMPBRNACH")
        AND "d"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "TEMPSEMESTER")
        AND "d"."ACMS_Id" IN (SELECT "ACMS_Id" FROM "TEMPSECTION");

        BEGIN
            RETURN QUERY
            SELECT 
                "B"."AMCST_MobileNo",
                "B"."AMCST_Id",
                TO_CHAR("B"."ACSA_AttendanceDate", 'DD/MM/YYYY') AS "DATE",
                "B"."AMCST_FirstName" AS "NAME",
                STRING_AGG("A".subject, ', ' ORDER BY "A".subject) AS "SUBJECTS"
            FROM "temp1modify" "B"
            LEFT JOIN "temp1modify" "A" ON "A"."AMCST_MobileNo" = "B"."AMCST_MobileNo" AND "A"."AMCST_FirstName" = "B"."AMCST_FirstName"
            GROUP BY "B"."AMCST_MobileNo", "B"."AMCST_FirstName", "B"."MI_Id", "B"."ACSA_AttendanceDate", "B"."AMCST_Id";
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error occurred: %', SQLERRM;
                RETURN;
        END;

    END IF;

    RETURN;

END;
$$;