CREATE OR REPLACE FUNCTION "dbo"."CLG_Mobile_PORTAL_STUDENT_MONTHLY_ATTENDANCE"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "monthname" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "TOTAL_PRESENT" NUMERIC,
    "CLASS_HELD" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."AMCST_Id",
        g."IVRM_Month_Name" as monthname,
        f."ISMS_SubjectName",
        SUM(b."ACSAS_ClassAttended") as TOTAL_PRESENT,
        CAST(CAST(ROUND(SUM(a."ACSA_ClassHeld"),0) AS INTEGER) AS VARCHAR(10)) as CLASS_HELD
    FROM "clg"."Adm_College_Student_Attendance" a
    INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id" AND c."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" e ON e."amcst_id" = d."AMCST_Id"
    INNER JOIN "IVRM_Master_Subjects" f ON a."ISMS_Id" = f."ISMS_Id"
    INNER JOIN "IVRM_Month" g ON g."IVRM_Month_Id" = EXTRACT(MONTH FROM a."ACSA_AttendanceDate")
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id 
        AND e."AMCST_SOL" = 'S'
        AND e."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 
        AND b."AMCST_Id" = p_AMCST_Id 
        AND d."AMCST_Id" = p_AMCST_Id
    GROUP BY b."AMCST_Id", f."ISMS_SubjectName", g."IVRM_Month_Name";
    
    RETURN;
END;
$$;