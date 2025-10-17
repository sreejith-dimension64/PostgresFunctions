CREATE OR REPLACE FUNCTION "clg"."College_student_TC_Attendance_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@FLAG" TEXT,
    "@AMCST_Id" TEXT
)
RETURNS TABLE(
    "classheld" TEXT,
    "classattened" TEXT,
    "lastdate" date
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@CLASSHELD" TEXT;
    "@CLASSATTENDED" TEXT;
    "@LASTDATE" date;
BEGIN
    IF "@FLAG" = 'S' THEN
        
        SELECT 
            SUM("A"."ACSA_ClassHeld")::TEXT,
            SUM("B"."ACSAS_ClassAttended")::TEXT
        INTO 
            "@CLASSHELD",
            "@CLASSATTENDED"
        FROM "clg"."Adm_College_Student_Attendance" "A"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "B" ON "A"."ACSA_Id" = "B"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "C" ON "C"."ACSA_Id" = "A"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "D" ON "D"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "E" ON "E"."AMCST_Id" = "D"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "F" ON "F"."AMCO_Id" = "D"."AMCO_Id" AND "F"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "G" ON "G"."AMB_Id" = "D"."AMB_Id" AND "G"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "H" ON "H"."AMSE_Id" = "D"."AMSE_Id" AND "H"."AMSE_Id" = "A"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "I" ON "I"."ACMS_Id" = "D"."ACMS_Id" AND "I"."ACMS_Id" = "A"."ACMS_Id"
        WHERE "A"."ASMAY_Id" = "@ASMAY_Id" 
            AND "D"."ASMAY_Id" = "@ASMAY_Id" 
            AND "D"."ACYST_ActiveFlag" = 1 
            AND "A"."ACSA_ActiveFlag" = 1 
            AND "B"."AMCST_Id" = "@AMCST_Id" 
            AND "D"."AMCST_Id" = "@AMCST_Id";
        
        SELECT 
            MAX("A"."ACSA_AttendanceDate")::date
        INTO 
            "@LASTDATE"
        FROM "clg"."Adm_College_Student_Attendance" "A"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "B" ON "A"."ACSA_Id" = "B"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "C" ON "C"."ACSA_Id" = "A"."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "D" ON "D"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "E" ON "E"."AMCST_Id" = "D"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "F" ON "F"."AMCO_Id" = "D"."AMCO_Id" AND "F"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "G" ON "G"."AMB_Id" = "D"."AMB_Id" AND "G"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "H" ON "H"."AMSE_Id" = "D"."AMSE_Id" AND "H"."AMSE_Id" = "A"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" "I" ON "I"."ACMS_Id" = "D"."ACMS_Id" AND "I"."ACMS_Id" = "A"."ACMS_Id"
        WHERE "A"."ASMAY_Id" = "@ASMAY_Id" 
            AND "D"."ASMAY_Id" = "@ASMAY_Id" 
            AND "D"."ACYST_ActiveFlag" = 1 
            AND "A"."ACSA_ActiveFlag" = 1 
            AND "B"."AMCST_Id" = "@AMCST_Id" 
            AND "D"."AMCST_Id" = "@AMCST_Id";
        
        RETURN QUERY
        SELECT 
            "@CLASSHELD",
            "@CLASSATTENDED",
            "@LASTDATE";
            
    END IF;
    
    RETURN;
END;
$$;