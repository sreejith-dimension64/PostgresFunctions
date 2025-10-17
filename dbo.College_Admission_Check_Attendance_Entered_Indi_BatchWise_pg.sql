CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Check_Attendance_Entered_Indi_BatchWise"(
    "@MI_ID" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ACMS_Id" TEXT,
    "@TTMP_Id" TEXT,
    "@ACSA_AttendanceDate" TEXT,
    "@ACAB_Id" TEXT
)
RETURNS TABLE(
    "ACSA_Id" INTEGER,
    "TTMP_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@ACAB_Id" = '0' THEN
    
        RETURN QUERY
        SELECT DISTINCT "c"."ACSA_Id", "c"."TTMP_Id"
        FROM "CLG"."Adm_College_Student_Attendance" AS "a"
        INNER JOIN "CLG"."Adm_College_Student_Attendance_Students" AS "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "CLG"."Adm_College_Student_Attendance_Periodwise" AS "c" ON "a"."ACSA_Id" = "c"."ACSA_Id"
        INNER JOIN "Adm_School_M_Academic_Year" AS "d" ON "a"."ASMAY_Id" = "d"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS "e" ON "a"."AMCO_Id" = "e"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS "f" ON "a"."AMB_Id" = "f"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS "g" ON "a"."AMSE_Id" = "g"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS "h" ON "a"."ACMS_Id" = "h"."ACMS_Id"
        INNER JOIN "TT_Master_Period" AS "i" ON "i"."TTMP_Id" = "c"."TTMP_Id"
        WHERE "a"."ASMAY_Id" = "@ASMAY_Id" 
            AND "a"."AMCO_Id" = "@AMCO_Id" 
            AND "a"."AMB_Id" = "@AMB_Id" 
            AND "a"."AMSE_Id" = "@AMSE_Id" 
            AND "a"."ACMS_Id" = "@ACMS_Id"
            AND "c"."TTMP_Id" = "@TTMP_Id" 
            AND "a"."ACSA_AttendanceDate" = "@ACSA_AttendanceDate" 
            AND "a"."ACSA_ActiveFlag" = 1;
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT "l"."ACSA_Id", "l"."TTMP_Id" 
        FROM "clg"."Adm_Master_College_Student" "a"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "b" ON "a"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" "k" ON "k"."AMCO_Id" = "b"."AMCO_Id" 
            AND "k"."AMB_Id" = "b"."AMB_Id" 
            AND "k"."AMSE_Id" = "b"."AMSE_Id" 
            AND "k"."ACMS_Id" = "b"."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "l" ON "l"."ACSA_Id" = "k"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "m" ON "m"."ACSA_Id" = "k"."ACSA_Id" 
            AND "m"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" "c" ON "c"."AMCST_Id" = "b"."AMCST_Id" 
            AND "m"."AMCST_Id" = "c"."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" "d" ON "d"."ACABS_Id" = "c"."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" "e" ON "e"."ACAB_Id" = "d"."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" "f" ON "f"."AMCO_Id" = "b"."AMCO_Id" 
            AND "f"."AMCO_Id" = "d"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "g" ON "g"."AMB_Id" = "b"."AMB_Id" 
            AND "g"."AMB_Id" = "d"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "h" ON "h"."AMSE_Id" = "b"."AMSE_Id" 
            AND "h"."AMSE_Id" = "d"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "i" ON "i"."ACMS_Id" = "b"."ACMS_Id" 
            AND "i"."ACMS_Id" = "d"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "j" ON "j"."ASMAY_Id" = "b"."ASMAY_Id" 
            AND "j"."ASMAY_Id" = "d"."ASMAY_Id"
        WHERE "b"."ASMAY_Id" = "@ASMAY_Id" 
            AND "b"."AMCO_Id" = "@AMCO_Id" 
            AND "b"."AMB_Id" = "@AMB_Id" 
            AND "b"."AMSE_Id" = "@AMSE_Id"
            AND "k"."ASMAY_Id" = "@ASMAY_Id" 
            AND "k"."AMCO_Id" = "@AMCO_Id" 
            AND "k"."AMB_Id" = "@AMB_Id" 
            AND "k"."AMSE_Id" = "@AMSE_Id"
            AND "k"."ACMS_Id" = "@ACMS_Id" 
            AND "l"."TTMP_Id" = "@TTMP_Id" 
            AND "k"."ACSA_AttendanceDate" = "@ACSA_AttendanceDate"
            AND "d"."ACAB_Id" = "@ACAB_Id" 
            AND "k"."ACSA_ActiveFlag" = 1;
    
    END IF;

END;
$$;