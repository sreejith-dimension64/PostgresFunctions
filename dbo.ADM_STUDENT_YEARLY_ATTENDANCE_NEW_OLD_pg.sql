CREATE OR REPLACE FUNCTION "dbo"."ADM_STUDENT_YEARLY_ATTENDANCE_NEW_OLD"(
    p_asmay_id TEXT, 
    p_asmcl_id TEXT,
    p_asms_id TEXT, 
    p_mi_id TEXT, 
    p_flag TEXT
)
RETURNS TABLE(
    "name" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMAY_RollNo" TEXT
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
    rec RECORD;
BEGIN
    v_monthyearsd := '';
    v_monthyearsd1 := '';
    
    IF p_flag = 'indi' THEN
        FOR rec IN
            SELECT (TO_CHAR("asa_fromdate", 'Month') || ' ' || TO_CHAR("asa_fromdate", 'YYYY') || '(' || 
                    CAST(CAST(ROUND(SUM("ASA_ClassHeld"), 0) AS INTEGER) AS TEXT) || ')') AS "MONTH_NAME"
            FROM "Adm_Student_Attendance" a
            WHERE "MI_Id" = p_mi_id AND "ASMCL_Id" = p_asmcl_id AND "ASMS_Id" = p_asms_id 
                AND "ASMAY_Id" = p_asmay_id AND "ASA_Activeflag" = 1
            GROUP BY EXTRACT(MONTH FROM a."ASA_FromDate"), TO_CHAR(a."asa_fromdate", 'Month'), 
                     TO_CHAR("asa_fromdate", 'YYYY')
            ORDER BY EXTRACT(MONTH FROM a."ASA_FromDate"), TO_CHAR(a."asa_fromdate", 'Month'), 
                     TO_CHAR("asa_fromdate", 'YYYY') DESC
        LOOP
            v_cols := rec."MONTH_NAME";
            v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols || '"' || ', ', '');
            v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || COALESCE('COALESCE("' || v_cols || '", 0) AS "' || v_cols || '"' || ', ', '');
        END LOOP;
        
        v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 1);
        v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 1);
        
        v_query := 'SELECT s."name", s."AMST_AdmNo", s."AMST_RegistrationNo", s."AMAY_RollNo", ' || v_monthyearsd1 || 
                   ' FROM CROSSTAB(''SELECT s."AMST_Id"::TEXT || ''''|'''' || s."name" || ''''|'''' || s."AMST_AdmNo" || ''''|'''' || ' ||
                   's."AMST_RegistrationNo" || ''''|'''' || s."AMAY_RollNo" AS rowid, s."MONTH_NAME", s."TOTAL_PRESENT"::TEXT ' ||
                   'FROM (SELECT SUM(b."ASA_Class_Attended") AS "TOTAL_PRESENT", b."AMST_Id", ' ||
                   '(TO_CHAR(a."asa_fromdate", ''''Month'''') || '''' '''' || TO_CHAR(a."asa_fromdate", ''''YYYY'''') || ''''('''' || ' ||
                   'CAST(CAST(ROUND(SUM(a."ASA_ClassHeld"), 0) AS INTEGER) AS TEXT) || '''')'''' ) AS "MONTH_NAME", ' ||
                   '(COALESCE(d."AMST_FirstName", '''''''') || '''' '''' || COALESCE(d."AMST_MiddleName", '''''''') || '''' '''' || ' ||
                   'COALESCE(d."AMST_LastName", '''''''')) AS "name", d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo" ' ||
                   'FROM "adm_student_attendance" a INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                   'INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                   'INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                   'WHERE c."ASMAY_Id" = ' || p_asmay_id || ' AND a."ASMAY_Id" = ' || p_asmay_id || ' AND a."MI_Id" = ' || p_mi_id || 
                   ' AND "ASA_Activeflag" = 1 AND c."ASMCL_Id" = ' || p_asmcl_id || ' AND a."ASMCL_Id" = ' || p_asmcl_id || 
                   ' AND c."ASMS_Id" = ' || p_asms_id || ' AND a."ASMS_Id" = ' || p_asms_id || 
                   ' AND "amst_sol" = ''''S'''' AND "amst_activeflag" = 1 AND "amay_activeflag" = 1 ' ||
                   'GROUP BY b."AMST_Id", TO_CHAR(a."asa_fromdate", ''''Month''''), TO_CHAR(a."asa_fromdate", ''''YYYY''''), ' ||
                   'd."AMST_FirstName", d."AMST_MiddleName", d."AMST_LastName", d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo") s ' ||
                   'ORDER BY 1, 2'') AS ct(rowid TEXT, ' || v_monthyearsd || ') ' ||
                   'CROSS JOIN LATERAL (SELECT SPLIT_PART(ct.rowid, ''''|'''', 2) AS "name", ' ||
                   'SPLIT_PART(ct.rowid, ''''|'''', 3) AS "AMST_AdmNo", ' ||
                   'SPLIT_PART(ct.rowid, ''''|'''', 4) AS "AMST_RegistrationNo", ' ||
                   'SPLIT_PART(ct.rowid, ''''|'''', 5) AS "AMAY_RollNo") s';
                   
    ELSIF p_flag = 'all' THEN
        FOR rec IN
            SELECT (TO_CHAR("asa_fromdate", 'Month') || ' ' || TO_CHAR("asa_fromdate", 'YYYY') || '(' || 
                    CAST(CAST(ROUND(SUM("ASA_ClassHeld"), 0) AS INTEGER) AS TEXT) || ')') AS "MONTH_NAME"
            FROM "Adm_Student_Attendance" a
            WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id AND "ASA_Activeflag" = 1
            GROUP BY EXTRACT(MONTH FROM a."ASA_FromDate"), TO_CHAR(a."asa_fromdate", 'Month'), 
                     TO_CHAR("asa_fromdate", 'YYYY')
            ORDER BY EXTRACT(MONTH FROM a."ASA_FromDate"), TO_CHAR(a."asa_fromdate", 'Month'), 
                     TO_CHAR("asa_fromdate", 'YYYY') DESC
        LOOP
            v_cols := rec."MONTH_NAME";
            v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols || '"' || ', ', '');
            v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || COALESCE('COALESCE("' || v_cols || '", 0) AS "' || v_cols || '"' || ', ', '');
        END LOOP;
        
        v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 1);
        v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 1);
        
        v_query := 'SELECT s."name", s."AMST_AdmNo", s."AMST_RegistrationNo", s."AMAY_RollNo", ' || v_monthyearsd1 || 
                   ' FROM CROSSTAB(''SELECT s."AMST_Id"::TEXT || ''''|'''' || s."name" || ''''|'''' || s."AMST_AdmNo" || ''''|'''' || ' ||
                   's."AMST_RegistrationNo" || ''''|'''' || s."AMAY_RollNo" AS rowid, s."MONTH_NAME", s."TOTAL_PRESENT"::TEXT ' ||
                   'FROM (SELECT SUM(b."ASA_Class_Attended") AS "TOTAL_PRESENT", b."AMST_Id", ' ||
                   '(TO_CHAR(a."asa_fromdate", ''''Month'''') || '''' '''' || TO_CHAR(a."asa_fromdate", ''''YYYY'''') || ''''('''' || ' ||
                   'CAST(CAST(ROUND(SUM(a."ASA_ClassHeld"), 0) AS INTEGER) AS TEXT) || '''')'''' ) AS "MONTH_NAME", ' ||
                   '(COALESCE(d."AMST_FirstName", '''''''') || '''' '''' || COALESCE(d."AMST_MiddleName", '''''''') || '''' '''' || ' ||
                   'COALESCE(d."AMST_LastName", '''''''')) AS "name", d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo" ' ||
                   'FROM "adm_student_attendance" a INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                   'INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                   'INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                   'WHERE c."ASMAY_Id" = ' || p_asmay_id || ' AND a."MI_Id" = ' || p_mi_id || 
                   ' AND "ASA_Activeflag" = 1 AND "amst_sol" = ''''S'''' AND "amst_activeflag" = 1 AND "amay_activeflag" = 1 ' ||
                   'GROUP BY b."AMST_Id", TO_CHAR(a."asa_fromdate", ''''Month''''), TO_CHAR(a."asa_fromdate", ''''YYYY''''), ' ||
                   'd."AMST_FirstName", d."AMST_MiddleName", d."AMST_LastName", d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo") s ' ||
                   'ORDER BY 1, 2'') AS ct(rowid TEXT, ' || v_monthyearsd || ') ' ||
                   'CROSS JOIN LATERAL (SELECT SPLIT_PART(ct.rowid, ''''|'''', 2) AS "name", ' ||
                   'SPLIT_PART(ct.rowid, ''''|'''', 3) AS "AMST_AdmNo", ' ||
                   'SPLIT_PART(ct.rowid, ''''|'''', 4) AS "AMST_RegistrationNo", ' ||
                   'SPLIT_PART(ct.rowid, ''''|'''', 5) AS "AMAY_RollNo") s';
    END IF;
    
    RETURN QUERY EXECUTE v_query;
    
END;
$$;