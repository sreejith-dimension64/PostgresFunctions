CREATE OR REPLACE FUNCTION "dbo"."AttendanceStudent_perc_shortageAlert"(
    p_ASMAY_Id VARCHAR(100),
    p_MI_Id VARCHAR(100),
    p_AMCST_Id VARCHAR(100)
)
RETURNS TABLE(per NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMCL_Id VARCHAR(100);
    v_ASMS_Id VARCHAR(200);
    v_perc VARCHAR(200);
    v_COUNT INTEGER;
    v_query TEXT;
BEGIN
    SELECT "ASMCL_Id" INTO v_ASMCL_Id 
    FROM "adm_school_y_student" 
    WHERE "asmay_id" = p_ASMAY_Id AND "AMST_Id" = p_AMCST_Id;
    
    SELECT "ASMS_Id" INTO v_ASMS_Id 
    FROM "adm_school_y_student" 
    WHERE "asmay_id" = p_ASMAY_Id AND "AMST_Id" = p_AMCST_Id;
    
    SELECT COUNT("AMST_Id") INTO v_COUNT 
    FROM "Adm_Student_Attendance_Shortage_Students" 
    WHERE "AMST_Id" = p_AMCST_Id;
    
    RAISE NOTICE '%', v_COUNT;
    
    IF v_COUNT > 0 THEN
        v_query := 'SELECT (SUM(COALESCE(b."ASA_Class_Attended",0)) * 100.0) / SUM(COALESCE(a."ASA_ClassHeld",0)) as per
        FROM "Adm_Student_Attendance" a
        INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" c ON c."amst_id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" adm_M_student ON adm_M_student."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id" AND e."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = a."ASMCL_Id" AND f."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = a."ASMS_Id" AND g."ASMS_Id" = c."ASMS_Id"
        WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND c."ASMAY_Id" = ' || p_ASMAY_Id || ' AND c."AMST_Id" = ' || p_AMCST_Id || ' AND "ASA_Activeflag" = 1
        GROUP BY adm_M_student."AMST_Id", adm_M_student."AMST_AdmNo", adm_M_student."AMST_RegistrationNo",
        "AMST_FirstName", "AMST_MiddleName", "Amst_LastName", f."ASMCL_ClassName", g."ASMC_SectionName", adm_M_student."AMST_MobileNo", f."ASMCL_Id", g."ASMS_Id"';
        
        RAISE NOTICE '%', v_query;
        
        RETURN QUERY EXECUTE v_query;
    END IF;
    
    RETURN;
END;
$$;