CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STAFF_STUDENT_ATTENDANCE"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "MONTH_NAME" TEXT,
    "TOTAL_PRESENT" NUMERIC,
    "CLASS_HELD" TEXT,
    "IVRM_Month_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_query TEXT;
    v_monthyearsd TEXT;
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_monthyearsd1 TEXT;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."AMCST_Id",
        TO_CHAR(a."ACSA_AttendanceDate", 'Month') AS "MONTH_NAME",
        SUM(b."ACSAS_ClassAttended") AS "TOTAL_PRESENT",
        CAST(CAST(ROUND(SUM(a."ACSA_ClassHeld"), 0) AS INTEGER) AS TEXT) AS "CLASS_HELD",
        M."IVRM_Month_Id"
    FROM "clg"."Adm_College_Student_Attendance" a
    INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b 
        ON a."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" c 
        ON c."ACSA_Id" = a."ACSA_Id" AND c."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" d 
        ON d."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" e 
        ON e."amcst_id" = d."AMCST_Id"
    INNER JOIN "IVRM_Month" M 
        ON M."IVRM_Month_Name" = TO_CHAR(a."ACSA_AttendanceDate", 'Month')
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id 
        AND "AMCST_SOL" = 'S' 
        AND "AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1
        AND b."AMCST_Id" = p_AMCST_Id 
        AND d."AMCST_Id" = p_AMCST_Id
    GROUP BY 
        EXTRACT(MONTH FROM a."ACSA_AttendanceDate"),
        TO_CHAR(a."ACSA_AttendanceDate", 'Month'),
        TO_CHAR(a."ACSA_AttendanceDate", 'Year'),
        b."AMCST_Id",
        M."IVRM_Month_Id"
    ORDER BY M."IVRM_Month_Id";
    
    RETURN;
END;
$$;