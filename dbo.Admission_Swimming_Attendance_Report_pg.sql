CREATE OR REPLACE FUNCTION "dbo"."Admission_Swimming_Attendance_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT,
    p_REPORTTYPE TEXT,
    p_DATE VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMST_Id TEXT;
    v_COUNT BIGINT;
BEGIN
    IF p_REPORTTYPE = 'Swimming' THEN
        
        IF p_FLAG = '1' THEN
            
            DROP TABLE IF EXISTS swimmingtable;
            
            CREATE TEMP TABLE swimmingtable AS
            SELECT "AMST_Id", SUM("ALSSC_AttendanceCount") AS "ALSSC_AttendanceCount"
            FROM "Attendance_Lunch_Students_SmartCard"
            WHERE "ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id
                AND "ASSC_EntryForFlg" = p_REPORTTYPE
            GROUP BY "AMST_Id";
            
            SELECT MAX("ALSSC_AttendanceCount") INTO v_COUNT FROM swimmingtable;
            
            DROP TABLE IF EXISTS swimmingtabledetails;
            
            CREATE TEMP TABLE swimmingtabledetails AS
            SELECT 
                (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN "AMST_FirstName" ELSE '' END ||
                 CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' THEN "AMST_MiddleName" ELSE '' END ||
                 CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' THEN "AMST_LastName" ELSE '' END) AS "STUDENTNAME",
                "AMST_AdmNo",
                "AMST_RegistrationNo",
                B."AMAY_RollNo",
                SUM("ALSSC_AttendanceCount") AS "ATTENED"
            FROM "Attendance_Lunch_Students_SmartCard" A
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_M_Student" C ON C."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = B."ASMAY_Id" AND D."ASMAY_Id" = A."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = B."ASMCL_Id" AND E."ASMCL_Id" = A."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = B."ASMS_Id" AND F."ASMS_Id" = A."ASMS_Id"
            WHERE A."ASMAY_Id" = p_ASMAY_Id 
                AND B."ASMAY_Id" = p_ASMAY_Id 
                AND A."ASMCL_Id" = p_ASMCL_Id 
                AND B."ASMCL_Id" = p_ASMCL_Id
                AND A."ASMS_Id" = p_ASMS_Id 
                AND B."ASMS_Id" = p_ASMS_Id
            GROUP BY "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMST_AdmNo", "AMST_RegistrationNo", B."AMAY_RollNo"
            ORDER BY "STUDENTNAME";
            
            RAISE NOTICE 'Returning result set for FLAG=1';
            
        ELSIF p_FLAG = '2' THEN
            
            DROP TABLE IF EXISTS swimmingtablenew;
            
            CREATE TEMP TABLE swimmingtablenew AS
            SELECT "AMST_Id", SUM("ALSSC_AttendanceCount") AS "ALSSC_AttendanceCount"
            FROM "Attendance_Lunch_Students_SmartCard"
            WHERE "ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id
                AND TO_TIMESTAMP("ASSC_AttendanceDate", 'DD/MM/YYYY')::DATE = TO_DATE(p_DATE, 'DD/MM/YYYY')
                AND "ASSC_EntryForFlg" = p_REPORTTYPE
            GROUP BY "AMST_Id";
            
            SELECT MAX("ALSSC_AttendanceCount") INTO v_COUNT FROM swimmingtablenew;
            
            DROP TABLE IF EXISTS swimmingtabledetailsnew;
            
            CREATE TEMP TABLE swimmingtabledetailsnew AS
            SELECT 
                (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN "AMST_FirstName" ELSE '' END ||
                 CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' THEN "AMST_MiddleName" ELSE '' END ||
                 CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' THEN "AMST_LastName" ELSE '' END) AS "STUDENTNAME",
                "AMST_AdmNo",
                "AMST_RegistrationNo",
                B."AMAY_RollNo",
                SUM("ALSSC_AttendanceCount") AS "ATTENED"
            FROM "Attendance_Lunch_Students_SmartCard" A
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_M_Student" C ON C."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = B."ASMAY_Id" AND D."ASMAY_Id" = A."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = B."ASMCL_Id" AND E."ASMCL_Id" = A."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = B."ASMS_Id" AND F."ASMS_Id" = A."ASMS_Id"
            WHERE A."ASMAY_Id" = p_ASMAY_Id 
                AND B."ASMAY_Id" = p_ASMAY_Id 
                AND A."ASMCL_Id" = p_ASMCL_Id 
                AND B."ASMCL_Id" = p_ASMCL_Id
                AND A."ASMS_Id" = p_ASMS_Id 
                AND B."ASMS_Id" = p_ASMS_Id
                AND TO_TIMESTAMP("ASSC_AttendanceDate", 'DD/MM/YYYY')::DATE = TO_DATE(p_DATE, 'DD/MM/YYYY')
            GROUP BY "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMST_AdmNo", "AMST_RegistrationNo", B."AMAY_RollNo"
            ORDER BY "STUDENTNAME";
            
            RAISE NOTICE 'Returning result set for FLAG=2';
            
        END IF;
        
    END IF;
    
    RETURN;
END;
$$;