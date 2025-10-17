CREATE OR REPLACE FUNCTION "Adm_Student_Attendance_Insert"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE(
    result_type TEXT,
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASA_Att_Type" VARCHAR,
    "ASA_Att_EntryType" VARCHAR,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "IMP_Id" BIGINT,
    "ASA_Entry_DateTime" TIMESTAMP,
    "ASA_FromDate" TIMESTAMP,
    "ASA_ToDate" TIMESTAMP,
    "ASA_ClassHeld" NUMERIC,
    "ASA_Network_IP" VARCHAR,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP,
    "HRME_Id" BIGINT,
    "ASALU_Id" BIGINT,
    "ASA_Activeflag" INTEGER,
    "ASA_CreatedBy" BIGINT,
    "ASA_UpdatedBy" BIGINT,
    "ASA_ID" BIGINT,
    "AMST_Id" BIGINT,
    "ASA_AttendanceFlag" VARCHAR,
    "ASA_Class_Attended" NUMERIC,
    "ASA_Dailytwice_Flag" VARCHAR,
    "ASAS_CreatedBy" BIGINT,
    "ASAS_UpdatedBy" BIGINT,
    "ASAS_Id" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASC_Att_DefaultEntry_Type VARCHAR(25);
    v_HRME_Id BIGINT;
    v_ASALU_Id BIGINT;
    v_COUNT BIGINT;
    v_ATTENDANCECOUNT BIGINT;
    v_attendancestudentcount BIGINT;
    v_AMST_ID BIGINT;
    v_ASMCL_ID BIGINT;
    v_ASMS_ID BIGINT;
    v_ASA_ID BIGINT;
    v_USERID BIGINT;
    v_IpAddress VARCHAR(50);
    rec RECORD;
BEGIN
    
    FOR rec IN
        SELECT DISTINCT B."AMST_ID", C."ASMCL_Id", C."ASMS_Id"
        FROM "Adm_m_Student" B
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_ID" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Class" A ON A."ASMCL_Id" = C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" D ON D."ASMS_Id" = C."ASMS_Id"
        WHERE B."MI_Id" = p_MI_Id 
            AND C."ASMAY_Id" = p_ASMAY_Id 
            AND B."AMST_ActiveFlag" = 1 
            AND A."ASMCL_ActiveFlag" = 1 
            AND C."AMAY_ActiveFlag" = 1
        ORDER BY C."ASMCL_Id", C."ASMS_Id"
    LOOP
        v_AMST_ID := rec."AMST_ID";
        v_ASMCL_ID := rec."ASMCL_Id";
        v_ASMS_ID := rec."ASMS_Id";
        
        SELECT COUNT(*) INTO v_COUNT 
        FROM "Adm_Student_Punch" 
        WHERE "AMST_Id" = v_AMST_ID 
            AND "ASPU_PunchDate"::DATE = CURRENT_DATE;
        
        SELECT COUNT(*) INTO v_ATTENDANCECOUNT 
        FROM "Adm_Student_Attendance" 
        WHERE "MI_ID" = p_MI_ID 
            AND "ASMAY_Id" = p_ASMAY_ID 
            AND "ASMCL_Id" = v_ASMCL_ID
            AND "ASMS_ID" = v_ASMS_ID 
            AND "ASA_FromDate"::DATE = CURRENT_DATE 
            AND "ASA_ToDate"::DATE = CURRENT_DATE;
        
        SELECT COUNT(*) INTO v_attendancestudentcount 
        FROM "Adm_Student_Attendance_Students" 
        WHERE "AMST_Id" = v_AMST_ID 
            AND "CreatedDate"::DATE = CURRENT_DATE;
        
        SELECT "HRME_Id" INTO v_HRME_Id 
        FROM "IVRM_Master_ClassTeacher"
        WHERE "MI_ID" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = v_ASMCL_ID 
            AND "ASMS_Id" = v_ASMS_ID;
        
        SELECT "Id" INTO v_USERID 
        FROM "IVRM_Staff_User_Login" 
        WHERE "Emp_Code" = v_HRME_Id;
        
        IF (COALESCE(v_ATTENDANCECOUNT, 0) = 0) THEN
            
            v_IpAddress := inet_client_addr()::VARCHAR;
            
            SELECT "ASALU_Id" INTO v_ASALU_Id 
            FROM "Adm_School_Attendance_Login_User" 
            WHERE "MI_ID" = p_MI_Id 
                AND "ASMAY_ID" = p_ASMAY_Id 
                AND "HRME_ID" = v_HRME_Id;
            
            SELECT CASE 
                    WHEN "ASC_Att_DefaultEntry_Type" = 'A' THEN 'Absent'
                    WHEN "ASC_Att_DefaultEntry_Type" = 'P' THEN 'Present' 
                END INTO v_ASC_Att_DefaultEntry_Type
            FROM "Adm_School_Configuration" 
            WHERE "MI_ID" = p_MI_Id;
            
            INSERT INTO "Adm_Student_Attendance"(
                "MI_Id", "ASMAY_Id", "ASA_Att_Type", "ASA_Att_EntryType", "ASMCL_Id", "ASMS_Id", "IMP_Id",
                "ASA_Entry_DateTime", "ASA_FromDate", "ASA_ToDate", "ASA_ClassHeld", "ASA_Network_IP", "CreatedDate",
                "UpdatedDate", "HRME_Id", "ASALU_Id", "ASA_Activeflag", "ASA_CreatedBy", "ASA_UpdatedBy"
            )
            VALUES(
                p_MI_Id, p_ASMAY_Id, 'Dailyonce', v_ASC_Att_DefaultEntry_Type, v_ASMCL_ID, v_ASMS_ID, 0, 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1.00,
                v_IpAddress, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_HRME_Id, v_ASALU_Id, 1, v_USERID, v_USERID
            );
        END IF;
        
        SELECT "ASA_ID" INTO v_ASA_ID 
        FROM "Adm_Student_Attendance" 
        WHERE "MI_ID" = p_MI_ID 
            AND "ASMAY_Id" = p_ASMAY_ID 
            AND "ASMCL_Id" = v_ASMCL_ID
            AND "ASMS_ID" = v_ASMS_ID 
            AND "ASA_FromDate"::DATE = CURRENT_DATE 
            AND "ASA_ToDate"::DATE = CURRENT_DATE;
        
        IF (COALESCE(v_COUNT, 0) > 0 AND COALESCE(v_attendancestudentcount, 0) = 0) THEN
            
            INSERT INTO "Adm_Student_Attendance_Students"(
                "ASA_Id", "AMST_Id", "ASA_AttendanceFlag", "ASA_Class_Attended", "CreatedDate", "UpdatedDate",
                "ASA_Dailytwice_Flag", "ASAS_CreatedBy", "ASAS_UpdatedBy"
            )
            VALUES(
                v_ASA_ID, v_AMST_ID, 'Present', 1.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                NULL, v_USERID, v_USERID
            );
            
        ELSIF (COALESCE(v_COUNT, 0) = 0 AND COALESCE(v_attendancestudentcount, 0) = 0) THEN
            
            INSERT INTO "Adm_Student_Attendance_Students"(
                "ASA_Id", "AMST_Id", "ASA_AttendanceFlag", "ASA_Class_Attended", "CreatedDate", "UpdatedDate",
                "ASA_Dailytwice_Flag", "ASAS_CreatedBy", "ASAS_UpdatedBy"
            )
            VALUES(
                v_ASA_ID, v_AMST_ID, 'Absent', 0.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
                NULL, v_USERID, v_USERID
            );
            
        END IF;
        
    END LOOP;
    
    RETURN QUERY
    SELECT 'attendance'::TEXT, 
        "MI_Id", "ASMAY_Id", "ASA_Att_Type", "ASA_Att_EntryType", "ASMCL_Id", "ASMS_Id", "IMP_Id",
        "ASA_Entry_DateTime", "ASA_FromDate", "ASA_ToDate", "ASA_ClassHeld", "ASA_Network_IP", "CreatedDate",
        "UpdatedDate", "HRME_Id", "ASALU_Id", "ASA_Activeflag", "ASA_CreatedBy", "ASA_UpdatedBy",
        "ASA_ID", NULL::BIGINT, NULL::VARCHAR, NULL::NUMERIC, NULL::VARCHAR, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT
    FROM "Adm_Student_Attendance" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASA_FromDate"::DATE = CURRENT_DATE 
        AND "ASA_ToDate"::DATE = CURRENT_DATE
    
    UNION ALL
    
    SELECT 'students'::TEXT,
        NULL::BIGINT, NULL::BIGINT, NULL::VARCHAR, NULL::VARCHAR, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
        NULL::TIMESTAMP, NULL::TIMESTAMP, NULL::TIMESTAMP, NULL::NUMERIC, NULL::VARCHAR, 
        "CreatedDate", "UpdatedDate", NULL::BIGINT, NULL::BIGINT, NULL::INTEGER, NULL::BIGINT, NULL::BIGINT,
        "ASA_Id", "AMST_Id", "ASA_AttendanceFlag", "ASA_Class_Attended", "ASA_Dailytwice_Flag", 
        "ASAS_CreatedBy", "ASAS_UpdatedBy", "ASAS_Id"
    FROM "Adm_Student_Attendance_Students" 
    WHERE "CreatedDate"::DATE = CURRENT_DATE;
    
END;
$$;