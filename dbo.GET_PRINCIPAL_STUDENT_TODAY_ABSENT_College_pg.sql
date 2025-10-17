CREATE OR REPLACE FUNCTION "dbo"."GET_PRINCIPAL_STUDENT_TODAY_ABSENT_College"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "stdname" text,
    "AMB_Id" bigint,
    "AMB_BranchName" text,
    "AMCO_Id" bigint,
    "AMCO_CourseName" text,
    "AMCST_AdmNo" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "C"."AMCST_Id",
        CONCAT("C"."AMCST_FirstName", ' ', "C"."AMCST_MiddleName", ' ', "C"."AMCST_LastName") AS "stdname",
        "A"."AMB_Id",
        "D"."AMB_BranchName",
        "A"."AMCO_Id",
        "E"."AMCO_CourseName",
        "C"."AMCST_AdmNo"
    FROM 
        "clg"."Adm_College_Student_Attendance" AS "A" 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" AS "B" ON "A"."ACSA_Id" = "B"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" AS "C" ON "C"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" AS "f" ON "f"."AMCST_Id" = "C"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" AS "D" ON "D"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Course" AS "E" ON "E"."AMCO_Id" = "A"."AMCO_Id"
    WHERE
        "A"."ACSA_ActiveFlag" = 1 
        AND "B"."ACSAS_ClassAttended" = 0
        AND "C"."AMCST_SOL" = 'S' 
        AND "C"."AMCST_ActiveFlag" = 1;
END;
$$;