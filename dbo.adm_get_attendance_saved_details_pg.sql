CREATE OR REPLACE FUNCTION "dbo"."adm_get_attendance_saved_details"(
    p_yearid bigint,
    p_miid bigint,
    p_att_type varchar,
    p_classid bigint,
    p_secid bigint,
    p_monthid bigint,
    p_count bigint,
    p_fromdate text
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "studentname" text,
    "amsT_AdmNo" varchar,
    "amaY_RollNo" varchar,
    "ASMS_Id" bigint,
    "ASMCL_Id" bigint,
    "ASA_ClassHeld" numeric,
    "pdays" numeric,
    "ASAET_Att_Type" varchar,
    "ASAS_Id" bigint,
    "ASA_Dailytwice_Flag" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_att_type = 'M' THEN
    
        IF p_count > 0 THEN
            RETURN QUERY
            SELECT DISTINCT 
                MAX("Adm_M_Student"."AMST_Id") AS "AMST_Id",
                MAX("Adm_M_Student"."AMST_FirstName" || '  ' || "Adm_M_Student"."AMST_LastName") AS "studentname",
                MAX("Adm_M_Student"."AMST_AdmNo") AS "amsT_AdmNo",
                MAX("Adm_School_Y_Student"."AMAY_RollNo") AS "amaY_RollNo",
                "Adm_Student_Attendance"."ASMS_Id",
                "Adm_School_Class_Held"."ASMCL_Id",
                "Adm_Student_Attendance"."ASA_ClassHeld",
                "Adm_Student_Attendance"."ASA_Class_Attended" AS "pdays",
                "Adm_School_Attendance_EntryType"."ASAET_Att_Type",
                "Adm_Student_Attendance_Students"."ASAS_Id",
                NULL::varchar AS "ASA_Dailytwice_Flag"
            FROM "dbo"."Adm_School_Class_Held"
            INNER JOIN "dbo"."Adm_School_Attendance_EntryType" ON "Adm_School_Class_Held"."ASMCL_Id" = "Adm_School_Attendance_EntryType"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students"
            INNER JOIN "dbo"."Adm_Student_Attendance" ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            ON "Adm_School_Class_Held"."ASMCL_Id" = "Adm_Student_Attendance"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_School_Class_Held"."ASMCL_Id" = p_classid 
                AND "Adm_Student_Attendance"."ASMS_Id" = p_secid 
                AND "Adm_Student_Attendance"."ASMAY_Id" = p_yearid 
                AND "Adm_Student_Attendance"."MI_Id" = p_miid 
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = p_monthid 
                AND EXTRACT(YEAR FROM "Adm_Student_Attendance"."ASA_FromDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
                AND "Adm_School_Attendance_EntryType"."ASAET_Att_Type" = p_att_type 
                AND "Adm_M_Student"."AMST_ActiveFlag" = true 
                AND "Adm_M_Student"."amst_sol" = 'S'
            GROUP BY "Adm_M_Student"."AMST_Id", "Adm_Student_Attendance"."ASMS_Id", "Adm_School_Class_Held"."ASMCL_Id",
                "Adm_Student_Attendance"."ASA_ClassHeld", "Adm_Student_Attendance"."ASA_Class_Attended", 
                "Adm_School_Attendance_EntryType"."ASAET_Att_Type", "Adm_Student_Attendance_Students"."ASAS_Id";
        ELSE
            RETURN QUERY
            SELECT 
                MAX(mstd."AMST_Id") AS "AMST_Id",
                MAX(mstd."AMST_FirstName" || '  ' || mstd."AMST_LastName") AS "studentname",
                MAX(mstd."AMST_AdmNo") AS "amsT_AdmNo",
                MAX(ystd."AMAY_RollNo") AS "amaY_RollNo",
                NULL::bigint AS "ASMS_Id",
                NULL::bigint AS "ASMCL_Id",
                NULL::numeric AS "ASA_ClassHeld",
                0::numeric AS "pdays",
                NULL::varchar AS "ASAET_Att_Type",
                NULL::bigint AS "ASAS_Id",
                NULL::varchar AS "ASA_Dailytwice_Flag"
            FROM "dbo"."Adm_M_Student" mstd
            LEFT JOIN "dbo"."Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            WHERE ystd."ASMCL_Id" = p_classid 
                AND ystd."ASMS_Id" = p_secid
                AND mstd."AMST_ActiveFlag" = true 
                AND ystd."ASMAY_Id" = p_yearid 
                AND ystd."MI_Id" = p_miid 
                AND mstd."amst_sol" = 'S'
            GROUP BY mstd."AMST_Id";
        END IF;
        
    ELSIF p_att_type = 'D' THEN
    
        IF p_count > 0 THEN
            RETURN QUERY
            SELECT DISTINCT 
                MAX("Adm_M_Student"."AMST_Id") AS "AMST_Id",
                MAX("Adm_M_Student"."AMST_FirstName" || '  ' || "Adm_M_Student"."AMST_LastName") AS "studentname",
                MAX("Adm_M_Student"."AMST_AdmNo") AS "amsT_AdmNo",
                MAX("Adm_School_Y_Student"."AMAY_RollNo") AS "amaY_RollNo",
                "Adm_Student_Attendance"."ASMS_Id",
                "Adm_School_Class_Held"."ASMCL_Id",
                "Adm_Student_Attendance"."ASA_ClassHeld",
                "Adm_Student_Attendance"."ASA_Class_Attended" AS "pdays",
                "Adm_School_Attendance_EntryType"."ASAET_Att_Type",
                "Adm_Student_Attendance_Students"."ASAS_Id",
                NULL::varchar AS "ASA_Dailytwice_Flag"
            FROM "dbo"."Adm_School_Class_Held"
            INNER JOIN "dbo"."Adm_School_Attendance_EntryType" ON "Adm_School_Class_Held"."ASMCL_Id" = "Adm_School_Attendance_EntryType"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students"
            INNER JOIN "dbo"."Adm_Student_Attendance" ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            ON "Adm_School_Class_Held"."ASMCL_Id" = "Adm_Student_Attendance"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_School_Class_Held"."ASMCL_Id" = p_classid 
                AND "Adm_Student_Attendance"."ASMS_Id" = p_secid 
                AND "Adm_Student_Attendance"."ASMAY_Id" = p_yearid 
                AND "Adm_Student_Attendance"."MI_Id" = p_miid 
                AND "Adm_Student_Attendance"."ASA_FromDate"::date = TO_DATE(p_fromdate, 'DD/MM/YYYY')
                AND "Adm_School_Attendance_EntryType"."ASAET_Att_Type" = p_att_type 
                AND "Adm_M_Student"."AMST_ActiveFlag" = true 
                AND "Adm_M_Student"."amst_sol" = 'S'
            GROUP BY "Adm_M_Student"."AMST_Id", "Adm_Student_Attendance"."ASMS_Id", "Adm_School_Class_Held"."ASMCL_Id",
                "Adm_Student_Attendance"."ASA_ClassHeld", "Adm_Student_Attendance"."ASA_Class_Attended", 
                "Adm_School_Attendance_EntryType"."ASAET_Att_Type", "Adm_Student_Attendance_Students"."ASAS_Id";
        ELSE
            RETURN QUERY
            SELECT 
                MAX(mstd."AMST_Id") AS "AMST_Id",
                MAX(mstd."AMST_FirstName" || '  ' || mstd."AMST_LastName") AS "studentname",
                MAX(mstd."AMST_AdmNo") AS "amsT_AdmNo",
                MAX(ystd."AMAY_RollNo") AS "amaY_RollNo",
                NULL::bigint AS "ASMS_Id",
                NULL::bigint AS "ASMCL_Id",
                NULL::numeric AS "ASA_ClassHeld",
                0::numeric AS "pdays",
                NULL::varchar AS "ASAET_Att_Type",
                NULL::bigint AS "ASAS_Id",
                NULL::varchar AS "ASA_Dailytwice_Flag"
            FROM "dbo"."Adm_M_Student" mstd
            LEFT JOIN "dbo"."Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            WHERE ystd."ASMCL_Id" = p_classid 
                AND ystd."ASMS_Id" = p_secid
                AND mstd."AMST_ActiveFlag" = true 
                AND ystd."ASMAY_Id" = p_yearid 
                AND ystd."MI_Id" = p_miid 
                AND mstd."amst_sol" = 'S'
            GROUP BY mstd."AMST_Id";
        END IF;
        
    ELSIF p_att_type = 'H' THEN
    
        IF p_count > 0 THEN
            RETURN QUERY
            SELECT DISTINCT 
                MAX("Adm_M_Student"."AMST_Id") AS "AMST_Id",
                MAX("Adm_M_Student"."AMST_FirstName" || '  ' || "Adm_M_Student"."AMST_LastName") AS "studentname",
                MAX("Adm_M_Student"."AMST_AdmNo") AS "amsT_AdmNo",
                MAX("Adm_School_Y_Student"."AMAY_RollNo") AS "amaY_RollNo",
                "Adm_Student_Attendance"."ASMS_Id",
                "Adm_School_Class_Held"."ASMCL_Id",
                "Adm_Student_Attendance"."ASA_ClassHeld",
                "Adm_Student_Attendance"."ASA_Class_Attended" AS "pdays",
                "Adm_School_Attendance_EntryType"."ASAET_Att_Type",
                "Adm_Student_Attendance_Students"."ASAS_Id",
                "Adm_Student_Attendance_Students"."ASA_Dailytwice_Flag"
            FROM "dbo"."Adm_School_Class_Held"
            INNER JOIN "dbo"."Adm_School_Attendance_EntryType" ON "Adm_School_Class_Held"."ASMCL_Id" = "Adm_School_Attendance_EntryType"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students"
            INNER JOIN "dbo"."Adm_Student_Attendance" ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            ON "Adm_School_Class_Held"."ASMCL_Id" = "Adm_Student_Attendance"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_School_Class_Held"."ASMCL_Id" = p_classid 
                AND "Adm_Student_Attendance"."ASMS_Id" = p_secid 
                AND "Adm_Student_Attendance"."ASMAY_Id" = p_yearid 
                AND "Adm_Student_Attendance"."MI_Id" = p_miid 
                AND "Adm_Student_Attendance"."ASA_FromDate"::date = TO_DATE(p_fromdate, 'DD/MM/YYYY')
                AND "Adm_School_Attendance_EntryType"."ASAET_Att_Type" = p_att_type 
                AND "Adm_M_Student"."AMST_ActiveFlag" = true 
                AND "Adm_M_Student"."amst_sol" = 'S'
            GROUP BY "Adm_M_Student"."AMST_Id", "Adm_Student_Attendance"."ASMS_Id", "Adm_School_Class_Held"."ASMCL_Id",
                "Adm_Student_Attendance"."ASA_ClassHeld", "Adm_Student_Attendance"."ASA_Class_Attended", 
                "Adm_School_Attendance_EntryType"."ASAET_Att_Type", "Adm_Student_Attendance_Students"."ASAS_Id",
                "Adm_Student_Attendance_Students"."ASA_Dailytwice_Flag";
        ELSE
            RETURN QUERY
            SELECT 
                MAX(mstd."AMST_Id") AS "AMST_Id",
                MAX(mstd."AMST_FirstName" || '  ' || mstd."AMST_LastName") AS "studentname",
                MAX(mstd."AMST_AdmNo") AS "amsT_AdmNo",
                MAX(ystd."AMAY_RollNo") AS "amaY_RollNo",
                NULL::bigint AS "ASMS_Id",
                NULL::bigint AS "ASMCL_Id",
                NULL::numeric AS "ASA_ClassHeld",
                0::numeric AS "pdays",
                NULL::varchar AS "ASAET_Att_Type",
                NULL::bigint AS "ASAS_Id",
                NULL::varchar AS "ASA_Dailytwice_Flag"
            FROM "dbo"."Adm_M_Student" mstd
            LEFT JOIN "dbo"."Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            WHERE ystd."ASMCL_Id" = p_classid 
                AND ystd."ASMS_Id" = p_secid
                AND mstd."AMST_ActiveFlag" = true 
                AND ystd."ASMAY_Id" = p_yearid 
                AND ystd."MI_Id" = p_miid 
                AND mstd."amst_sol" = 'S'
            GROUP BY mstd."AMST_Id";
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;