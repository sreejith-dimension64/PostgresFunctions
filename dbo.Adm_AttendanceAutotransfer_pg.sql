CREATE OR REPLACE FUNCTION "dbo"."Adm_AttendanceAutotransfer"(
    p_amst_id BIGINT,
    p_asmcl_id BIGINT,
    p_newasmcl_id BIGINT,
    p_asms_id BIGINT,
    p_asmay_id BIGINT,
    p_MI_id BIGINT
)
RETURNS TABLE(
    "ASAS_Id" BIGINT,
    "ASA_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ASAS_AttendanceFlag" VARCHAR,
    "ASAS_ClassAttended" NUMERIC,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP
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
    rec RECORD;
BEGIN

    FOR rec IN 
        SELECT DISTINCT B."ASA_Id", B."ASA_FromDate", B."ASA_ToDate"
        FROM "Adm_M_Student" A
        INNER JOIN "Adm_Student_Attendance_Students" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
        WHERE C."AMST_Id" = p_amst_id 
            AND B."ASMAY_Id" = p_asmay_id 
            AND A."MI_Id" = p_MI_id 
            AND B."ASMCL_Id" = p_asmcl_id 
            AND B."ASMS_Id" = p_asms_id
    LOOP
        v_ASA_ID := rec."ASA_Id";
        v_ASA_FromDate := rec."ASA_FromDate";
        v_ASA_ToDate := rec."ASA_ToDate";

        DROP TABLE IF EXISTS "ASAID_TEMP";

        CREATE TEMP TABLE "ASAID_TEMP" AS 
        SELECT 
            "ASA_Id",
            "AMST_Id",
            "ASAS_AttendanceFlag",
            "ASAS_ClassAttended",
            "CreatedDate",
            "UpdatedDate"
        FROM "Adm_Student_Attendance_Students" 
        WHERE "ASA_Id" = v_ASA_ID AND "AMST_Id" = p_amst_id;

        SELECT COUNT(B."ASA_Id") INTO v_COUNT
        FROM "Adm_Student_Attendance_Students" C 
        INNER JOIN "Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
        WHERE B."MI_Id" = p_MI_id 
            AND B."ASMAY_Id" = p_asmay_id 
            AND B."ASMCL_Id" = p_newasmcl_id
            AND B."ASMS_Id" = p_asms_id
            AND B."ASA_FromDate" = v_ASA_FromDate 
            AND B."ASA_ToDate" = v_ASA_ToDate;

        SELECT COUNT(B."ASA_Id") INTO v_StudentCOUNT
        FROM "Adm_Student_Attendance_Students" C 
        INNER JOIN "Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
        WHERE C."AMST_Id" = p_amst_id 
            AND B."MI_Id" = p_MI_id 
            AND B."ASMAY_Id" = p_asmay_id 
            AND B."ASMCL_Id" = p_newasmcl_id
            AND B."ASMS_Id" = p_asms_id
            AND B."ASA_FromDate" = v_ASA_FromDate 
            AND B."ASA_ToDate" = v_ASA_ToDate;

        IF (v_COUNT > 0 AND v_StudentCOUNT = 0) THEN

            SELECT DISTINCT B."ASA_Id" INTO v_NEWASAID
            FROM "Adm_Student_Attendance_Students" C 
            INNER JOIN "Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
            WHERE B."MI_Id" = p_MI_id 
                AND B."ASMAY_Id" = p_asmay_id 
                AND B."ASMCL_Id" = p_newasmcl_id
                AND B."ASMS_Id" = p_asms_id
                AND B."ASA_FromDate" = v_ASA_FromDate 
                AND B."ASA_ToDate" = v_ASA_ToDate;

            UPDATE "ASAID_TEMP" 
            SET "ASA_Id" = v_NEWASAID,
                "CreatedDate" = v_ASA_FromDate,
                "UpdatedDate" = v_ASA_ToDate;

            INSERT INTO "Adm_Student_Attendance_Students"
            SELECT * FROM "ASAID_TEMP";

            DELETE FROM "Adm_Student_Attendance_Students" 
            WHERE "ASA_Id" = v_ASA_ID AND "AMST_Id" = p_amst_id;

        END IF;

    END LOOP;

    DROP TABLE IF EXISTS "ASAID_TEMP";

    RETURN QUERY
    SELECT C."ASAS_Id", C."ASA_Id", C."AMST_Id", C."ASAS_AttendanceFlag", 
           C."ASAS_ClassAttended", C."CreatedDate", C."UpdatedDate"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_Student_Attendance_Students" C ON C."AMST_Id" = A."AMST_Id"
    INNER JOIN "Adm_Student_Attendance" B ON B."ASA_Id" = C."ASA_Id"
    WHERE C."AMST_Id" = p_amst_id 
        AND B."ASMAY_Id" = p_asmay_id 
        AND A."MI_Id" = p_MI_id 
        AND B."ASMCL_Id" = p_newasmcl_id 
        AND B."ASMS_Id" = p_asms_id;

END;
$$;