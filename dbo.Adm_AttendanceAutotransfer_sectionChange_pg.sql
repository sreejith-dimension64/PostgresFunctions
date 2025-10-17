CREATE OR REPLACE FUNCTION "dbo"."Adm_AttendanceAutotransfer_sectionChange"(
    p_amst_id BIGINT,
    p_asmcl_id BIGINT,
    p_newasms_id BIGINT,
    p_asms_id BIGINT,
    p_asmay_id BIGINT,
    p_MI_id BIGINT
)
RETURNS TABLE(
    result_type TEXT,
    "ASAS_Id" BIGINT,
    "ASA_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ASAS_AttendanceFlag" TEXT,
    "ASAS_ClassAttended" NUMERIC,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP,
    "flag" INTEGER,
    "NEWASAID" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASA_ID BIGINT;
    v_ASA_FromDate DATE;
    v_ASA_ToDate DATE;
    v_NEWASAID BIGINT;
    v_COUNT BIGINT;
    v_StudentCOUNT BIGINT;
    v_flag INTEGER := 0;
    asaid_cursor CURSOR FOR
        SELECT DISTINCT B."ASA_Id", B."ASA_FromDate", B."ASA_ToDate"
        FROM "dbo"."Adm_M_Student" A
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
        WHERE C."AMST_Id" = p_amst_id 
            AND B."ASMAY_Id" = p_asmay_id 
            AND A."MI_Id" = p_MI_id 
            AND B."ASMCL_Id" = p_asmcl_id 
            AND B."ASMS_Id" = p_asms_id;
BEGIN
    DROP TABLE IF EXISTS "ASAIDSection_TEMP";
    
    CREATE TEMP TABLE "ASAIDSection_TEMP" (
        "ASA_Id" BIGINT,
        "AMST_Id" BIGINT,
        "ASAS_AttendanceFlag" TEXT,
        "ASAS_ClassAttended" NUMERIC,
        "CreatedDate" TIMESTAMP,
        "UpdatedDate" TIMESTAMP
    ) ON COMMIT DROP;

    OPEN asaid_cursor;
    
    LOOP
        FETCH asaid_cursor INTO v_ASA_ID, v_ASA_FromDate, v_ASA_ToDate;
        EXIT WHEN NOT FOUND;
        
        TRUNCATE TABLE "ASAIDSection_TEMP";
        
        INSERT INTO "ASAIDSection_TEMP" ("ASA_Id", "AMST_Id", "ASAS_AttendanceFlag", "ASAS_ClassAttended", "CreatedDate", "UpdatedDate")
        SELECT "ASA_Id", "AMST_Id", "ASAS_AttendanceFlag", "ASAS_ClassAttended", "CreatedDate", "UpdatedDate"
        FROM "dbo"."Adm_Student_Attendance_Students"
        WHERE "ASA_Id" = v_ASA_ID AND "AMST_Id" = p_amst_id;
        
        SELECT COUNT(B."ASA_Id") INTO v_COUNT
        FROM "dbo"."Adm_Student_Attendance_Students" C
        INNER JOIN "dbo"."Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
        WHERE B."MI_Id" = p_MI_id 
            AND B."ASMAY_Id" = p_asmay_id 
            AND B."ASMCL_Id" = p_asmcl_id 
            AND B."ASMS_Id" = p_newasms_id
            AND B."ASA_FromDate" = v_ASA_FromDate 
            AND B."ASA_ToDate" = v_ASA_ToDate;
        
        SELECT COUNT(B."ASA_Id") INTO v_StudentCOUNT
        FROM "dbo"."Adm_Student_Attendance_Students" C
        INNER JOIN "dbo"."Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
        WHERE C."AMST_Id" = p_amst_id 
            AND B."MI_Id" = p_MI_id 
            AND B."ASMAY_Id" = p_asmay_id 
            AND B."ASMCL_Id" = p_asmcl_id
            AND B."ASMS_Id" = p_newasms_id
            AND B."ASA_FromDate" = v_ASA_FromDate 
            AND B."ASA_ToDate" = v_ASA_ToDate;
        
        IF (v_COUNT > 0 AND v_StudentCOUNT = 0) THEN
            SELECT DISTINCT B."ASA_Id" INTO v_NEWASAID
            FROM "dbo"."Adm_Student_Attendance_Students" C
            INNER JOIN "dbo"."Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
            WHERE B."MI_Id" = p_MI_id 
                AND B."ASMAY_Id" = p_asmay_id 
                AND B."ASMCL_Id" = p_asmcl_id
                AND B."ASMS_Id" = p_newasms_id
                AND B."ASA_FromDate" = v_ASA_FromDate 
                AND B."ASA_ToDate" = v_ASA_ToDate;
            
            result_type := 'NEWASAID';
            "ASAS_Id" := NULL;
            "ASA_Id" := NULL;
            "AMST_Id" := NULL;
            "ASAS_AttendanceFlag" := NULL;
            "ASAS_ClassAttended" := NULL;
            "CreatedDate" := NULL;
            "UpdatedDate" := NULL;
            "flag" := NULL;
            "NEWASAID" := v_NEWASAID;
            RETURN NEXT;
            
            RETURN QUERY
            SELECT 
                'ASAIDSection_TEMP'::TEXT,
                NULL::BIGINT,
                t."ASA_Id",
                t."AMST_Id",
                t."ASAS_AttendanceFlag",
                t."ASAS_ClassAttended",
                t."CreatedDate",
                t."UpdatedDate",
                NULL::INTEGER,
                NULL::BIGINT
            FROM "ASAIDSection_TEMP" t;
        END IF;
        
        v_flag := v_flag + 1;
    END LOOP;
    
    CLOSE asaid_cursor;
    
    result_type := 'flag';
    "ASAS_Id" := NULL;
    "ASA_Id" := NULL;
    "AMST_Id" := NULL;
    "ASAS_AttendanceFlag" := NULL;
    "ASAS_ClassAttended" := NULL;
    "CreatedDate" := NULL;
    "UpdatedDate" := NULL;
    "flag" := v_flag;
    "NEWASAID" := NULL;
    RETURN NEXT;
    
    RETURN QUERY
    SELECT 
        'final_result'::TEXT,
        C."ASAS_Id",
        C."ASA_Id",
        C."AMST_Id",
        C."ASAS_AttendanceFlag",
        C."ASAS_ClassAttended",
        C."CreatedDate",
        C."UpdatedDate",
        NULL::INTEGER,
        NULL::BIGINT
    FROM "dbo"."Adm_M_Student" A
    INNER JOIN "dbo"."Adm_Student_Attendance_Students" C ON C."AMST_Id" = A."AMST_Id"
    INNER JOIN "dbo"."Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
    WHERE C."AMST_Id" = p_amst_id 
        AND B."ASMAY_Id" = p_asmay_id 
        AND A."MI_Id" = p_MI_id 
        AND B."ASMCL_Id" = p_asmcl_id 
        AND B."ASMS_Id" = p_newasms_id;
    
    RETURN;
END;
$$;