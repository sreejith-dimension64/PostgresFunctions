CREATE OR REPLACE FUNCTION "dbo"."College_Attendace_Manual_Scheduler_List"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ACSA_AttendanceDate" TEXT
)
RETURNS TABLE(
    "ACSA_AttendanceDate" DATE,
    "AMCST_FirstName" TEXT,
    "subject" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "AMCST_MobileNo" TEXT,
    "AMCST_Id" BIGINT,
    "MI_Id" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ASC_DefaultSMS_Flag" TEXT;
BEGIN

    SELECT "ASC_DefaultSMS_Flag" INTO "v_ASC_DefaultSMS_Flag" 
    FROM "Adm_School_Configuration" 
    WHERE "mi_id" = "p_MI_Id";

    DROP TABLE IF EXISTS "temp11";

    IF "v_ASC_DefaultSMS_Flag" = 'F' THEN
    
        CREATE TEMP TABLE "temp11" AS
        SELECT 
            (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '' THEN '' ELSE "AMCST_FirstName" END ||
            CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '' OR "AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCST_MiddleName" END ||
            CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '' OR "AMCST_LastName" = '0' THEN '' ELSE ' ' || "AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject:' || "sub"."ISMS_SubjectName" || '--' || 'Period:' || "j"."TTMP_PeriodName" AS "subject",
            "dd"."AMCST_FatherMobleNo" AS "AMCST_MobileNo",
            "a"."MI_Id",
            "a"."ACSA_AttendanceDate",
            "e"."AMCO_CourseName",
            "f"."AMB_BranchName",
            ("g"."AMSE_SEMName" || '-' || "h"."ACMS_SectionName") AS "AMSE_SEMName"
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
            AND "a"."ACSA_AttendanceDate"::DATE = "p_ACSA_AttendanceDate"::DATE 
            AND "a"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT;

        RETURN QUERY
        SELECT 
            "B"."ACSA_AttendanceDate"::DATE AS "ACSA_AttendanceDate",
            "B"."AMCST_FirstName" AS "AMCST_FirstName",
            STRING_AGG("A"."subject", ', ' ORDER BY "A"."subject") AS "subject",
            "B"."AMCO_CourseName",
            "B"."AMB_BranchName",
            "B"."AMSE_SEMName",
            "B"."AMCST_MobileNo",
            NULL::BIGINT AS "AMCST_Id",
            "B"."MI_Id"
        FROM "temp11" "B"
        LEFT JOIN "temp11" "A" ON "A"."AMCST_MobileNo" = "B"."AMCST_MobileNo" 
            AND "A"."AMCST_FirstName" = "B"."AMCST_FirstName"
        GROUP BY "B"."AMCST_MobileNo", "B"."AMCST_FirstName", "B"."MI_Id", "B"."ACSA_AttendanceDate", 
                 "B"."AMCO_CourseName", "B"."AMB_BranchName", "B"."AMSE_SEMName";

    ELSIF "v_ASC_DefaultSMS_Flag" = 'M' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            "a"."ACSA_AttendanceDate"::DATE AS "ACSA_AttendanceDate",
            (CASE WHEN "dd"."AMCST_FirstName" IS NULL OR "dd"."AMCST_FirstName" = '' THEN '' ELSE "dd"."AMCST_FirstName" END ||
            CASE WHEN "dd"."AMCST_MiddleName" IS NULL OR "dd"."AMCST_MiddleName" = '' OR "dd"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_MiddleName" END ||
            CASE WHEN "dd"."AMCST_LastName" IS NULL OR "dd"."AMCST_LastName" = '' OR "dd"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_LastName" END) AS "AMCST_FirstName",
            NULL::TEXT AS "subject",
            NULL::TEXT AS "AMCO_CourseName",
            NULL::TEXT AS "AMB_BranchName",
            NULL::TEXT AS "AMSE_SEMName",
            "dd"."AMCST_MotherMobleNo" AS "AMCST_MobileNo",
            "b"."AMCST_Id",
            "a"."MI_Id"
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
            AND "a"."ACSA_AttendanceDate"::DATE = "p_ACSA_AttendanceDate"::DATE 
            AND "a"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        ORDER BY "AMCST_FirstName";

    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            "a"."ACSA_AttendanceDate"::DATE AS "ACSA_AttendanceDate",
            (CASE WHEN "dd"."AMCST_FirstName" IS NULL OR "dd"."AMCST_FirstName" = '' THEN '' ELSE "dd"."AMCST_FirstName" END ||
            CASE WHEN "dd"."AMCST_MiddleName" IS NULL OR "dd"."AMCST_MiddleName" = '' OR "dd"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_MiddleName" END ||
            CASE WHEN "dd"."AMCST_LastName" IS NULL OR "dd"."AMCST_LastName" = '' OR "dd"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "dd"."AMCST_LastName" END) AS "AMCST_FirstName",
            NULL::TEXT AS "subject",
            NULL::TEXT AS "AMCO_CourseName",
            NULL::TEXT AS "AMB_BranchName",
            NULL::TEXT AS "AMSE_SEMName",
            "dd"."AMCST_MobileNo" AS "AMCST_MobileNo",
            "b"."AMCST_Id",
            "a"."MI_Id"
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
            AND "a"."ACSA_AttendanceDate"::DATE = "p_ACSA_AttendanceDate"::DATE 
            AND "a"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "d"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
        ORDER BY "AMCST_FirstName";

    END IF;

    RETURN;

END;
$$;