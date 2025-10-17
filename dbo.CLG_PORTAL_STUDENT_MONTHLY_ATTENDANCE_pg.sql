CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STUDENT_MONTHLY_ATTENDANCE"(
    p_asmay_id TEXT,
    p_mi_id TEXT,
    p_amcst_id TEXT
)
RETURNS TABLE(
    "MONTH_NAME" TEXT,
    "TOTAL_PRESENT" NUMERIC,
    "CLASS_HELD" TEXT
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
    SELECT 
        TO_CHAR(a."ACSA_AttendanceDate", 'Month') AS "MONTH_NAME",
        SUM(b."ACSAS_ClassAttended") AS "TOTAL_PRESENT",
        CAST(CAST(ROUND(SUM(a."ACSA_ClassHeld")::NUMERIC, 0) AS INTEGER) AS TEXT) AS "CLASS_HELD"
    FROM "CLG"."Adm_College_Student_Attendance" a
    INNER JOIN "CLG"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id"
    WHERE a."MI_Id" = p_mi_id 
        AND c."ASMAY_Id" = p_asmay_id 
        AND b."AMCST_Id" = p_amcst_id
    GROUP BY EXTRACT(MONTH FROM a."ACSA_AttendanceDate"), 
             TO_CHAR(a."ACSA_AttendanceDate", 'Month'),
             EXTRACT(YEAR FROM a."ACSA_AttendanceDate")
    ORDER BY EXTRACT(MONTH FROM a."ACSA_AttendanceDate"), 
             TO_CHAR(a."ACSA_AttendanceDate", 'Month'),
             EXTRACT(YEAR FROM a."ACSA_AttendanceDate") DESC;
    
    RETURN;
END;
$$;