CREATE OR REPLACE FUNCTION "dbo"."ADM_STUDENT_YEARLY_ATTENDANCE_NEW_HEADBINDING"(
    p_asmay_id TEXT,
    p_asmcl_id TEXT,
    p_asms_id TEXT,
    p_mi_id TEXT,
    p_flag TEXT
)
RETURNS TABLE(
    monthnamee TEXT,
    yearidname TEXT,
    monthidname DOUBLE PRECISION,
    "MONTH_NAME" TEXT,
    total INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_flag = 'all' THEN
        RETURN QUERY
        SELECT 
            TO_CHAR(a."ASA_FromDate", 'Month') AS monthnamee,
            EXTRACT(YEAR FROM a."ASA_FromDate")::TEXT AS yearidname,
            EXTRACT(MONTH FROM a."ASA_FromDate") AS monthidname,
            (TO_CHAR(a."ASA_FromDate", 'Month') || ' ' || 
             EXTRACT(YEAR FROM a."ASA_FromDate")::TEXT || 
             ' (' || ROUND(SUM(a."ASA_ClassHeld"))::INTEGER::TEXT || ')') AS "MONTH_NAME",
            ROUND(SUM(a."ASA_ClassHeld"))::INTEGER AS total
        FROM "Adm_Student_Attendance" a
        WHERE a."MI_Id" = p_mi_id 
          AND a."ASA_Activeflag" = 1 
          AND a."ASMAY_Id" = p_asmay_id
        GROUP BY 
            EXTRACT(MONTH FROM a."ASA_FromDate"),
            TO_CHAR(a."ASA_FromDate", 'Month'),
            EXTRACT(YEAR FROM a."ASA_FromDate")
        ORDER BY 
            EXTRACT(YEAR FROM a."ASA_FromDate"),
            EXTRACT(MONTH FROM a."ASA_FromDate"),
            TO_CHAR(a."ASA_FromDate", 'Month');
    ELSE
        RETURN QUERY
        SELECT 
            TO_CHAR(a."ASA_FromDate", 'Month') AS monthnamee,
            EXTRACT(YEAR FROM a."ASA_FromDate")::TEXT AS yearidname,
            EXTRACT(MONTH FROM a."ASA_FromDate") AS monthidname,
            (TO_CHAR(a."ASA_FromDate", 'Month') || ' ' || 
             EXTRACT(YEAR FROM a."ASA_FromDate")::TEXT || 
             ' (' || ROUND(SUM(a."ASA_ClassHeld"))::INTEGER::TEXT || ')') AS "MONTH_NAME",
            ROUND(SUM(a."ASA_ClassHeld"))::INTEGER AS total
        FROM "Adm_Student_Attendance" a
        WHERE a."MI_Id" = p_mi_id 
          AND a."ASMCL_Id" = p_asmcl_id 
          AND a."ASMS_Id" = p_asms_id 
          AND a."ASA_Activeflag" = 1 
          AND a."ASMAY_Id" = p_asmay_id
        GROUP BY 
            EXTRACT(MONTH FROM a."ASA_FromDate"),
            TO_CHAR(a."ASA_FromDate", 'Month'),
            EXTRACT(YEAR FROM a."ASA_FromDate")
        ORDER BY 
            EXTRACT(YEAR FROM a."ASA_FromDate"),
            EXTRACT(MONTH FROM a."ASA_FromDate"),
            TO_CHAR(a."ASA_FromDate", 'Month');
    END IF;

END;
$$;