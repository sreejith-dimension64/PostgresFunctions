CREATE OR REPLACE FUNCTION "dbo"."ADM_STUDENT_YEARLY_ATTENDANCE_NEW"(
    "asmay_id" TEXT,
    "asmcl_id" TEXT,
    "asms_id" TEXT,
    "mi_id" TEXT,
    "flag" TEXT
)
RETURNS TABLE(
    "TOTAL_PRESENT" NUMERIC,
    "AMST_Id" INTEGER,
    "name" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMAY_RollNo" TEXT,
    "yearidname" DOUBLE PRECISION,
    "monthidname" DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
BEGIN
   
    IF "flag" = 'indi' THEN
        RETURN QUERY
        SELECT 
            SUM(b."ASA_Class_Attended") AS "TOTAL_PRESENT",
            b."AMST_Id",
            (COALESCE(d."AMST_FirstName", '') || ' ' || COALESCE(d."AMST_MiddleName", '') || ' ' || COALESCE(d."AMST_LastName", '')) AS "name",
            d."AMST_AdmNo",
            d."AMST_RegistrationNo",
            c."AMAY_RollNo",
            EXTRACT(YEAR FROM a."asa_fromdate") AS "yearidname",
            EXTRACT(MONTH FROM a."ASA_FromDate") AS "monthidname"
        FROM "adm_student_attendance" a 
        INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id"
        INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
        WHERE c."ASMAY_Id" = "asmay_id"::INTEGER 
            AND a."ASMAY_Id" = "asmay_id"::INTEGER 
            AND a."MI_Id" = "mi_id"::INTEGER 
            AND a."ASA_Activeflag" = 1 
            AND c."ASMCL_Id" = "asmcl_id"::INTEGER
            AND a."ASMCL_Id" = "asmcl_id"::INTEGER
            AND c."ASMS_Id" = "asms_id"::INTEGER 
            AND a."ASMS_Id" = "asms_id"::INTEGER
            AND d."amst_sol" = 'S' 
            AND d."amst_activeflag" = 1 
            AND c."amay_activeflag" = 1
        GROUP BY 
            b."AMST_Id",
            TO_CHAR(a."asa_fromdate", 'Month'),
            TO_CHAR(a."asa_fromdate", 'YYYY'),
            d."AMST_FirstName",
            d."AMST_MiddleName",
            d."AMST_LastName",
            d."AMST_AdmNo",
            d."AMST_RegistrationNo",
            c."AMAY_RollNo",
            EXTRACT(MONTH FROM a."ASA_FromDate"),
            EXTRACT(YEAR FROM a."asa_fromdate");
    ELSE
        RETURN QUERY
        SELECT 
            SUM(b."ASA_Class_Attended") AS "TOTAL_PRESENT",
            b."AMST_Id",
            (COALESCE(d."AMST_FirstName", '') || ' ' || COALESCE(d."AMST_MiddleName", '') || ' ' || COALESCE(d."AMST_LastName", '')) AS "name",
            d."AMST_AdmNo",
            d."AMST_RegistrationNo",
            c."AMAY_RollNo",
            EXTRACT(YEAR FROM a."asa_fromdate") AS "yearidname",
            EXTRACT(MONTH FROM a."ASA_FromDate") AS "monthidname"
        FROM "adm_student_attendance" a 
        INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id"
        INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
        WHERE c."ASMAY_Id" = "asmay_id"::INTEGER 
            AND a."MI_Id" = "mi_id"::INTEGER 
            AND a."ASA_Activeflag" = 1 
            AND d."amst_sol" = 'S'
            AND d."amst_activeflag" = 1 
            AND c."amay_activeflag" = 1
        GROUP BY 
            b."AMST_Id",
            TO_CHAR(a."asa_fromdate", 'Month'),
            TO_CHAR(a."asa_fromdate", 'YYYY'),
            d."AMST_FirstName",
            d."AMST_MiddleName",
            d."AMST_LastName",
            d."AMST_AdmNo",
            d."AMST_RegistrationNo",
            c."AMAY_RollNo",
            EXTRACT(MONTH FROM a."ASA_FromDate"),
            EXTRACT(YEAR FROM a."asa_fromdate");
    END IF;

END;
$$;