CREATE OR REPLACE FUNCTION "dbo"."Adm_Attendancestaffentry_Notdone"(
    p_MI_ID VARCHAR(50),
    p_ASMAY_ID VARCHAR(50),
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FROMDATE VARCHAR(10),
    p_TODATE VARCHAR(10),
    p_ENTRY_TYPE VARCHAR(20),
    p_ISMS_ID TEXT
)
RETURNS TABLE(
    "HRME_EmployeeFirstName" TEXT,
    "CLASSNAME" TEXT,
    "SECTIONNAME" TEXT,
    "NOTENTERED_DATE" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_dt DATE;
    v_MI_Id_CUR BIGINT;
    v_ASMAY_Id_CUR BIGINT;
    v_ASMCL_Id_CUR BIGINT;
    v_ASMS_Id_CUR BIGINT;
    v_COUNT INT;
    v_HRME_EmployeeFirstName TEXT;
    v_CLASSNAME TEXT;
    v_SECTIONNAME TEXT;
    v_DYNAMIC TEXT;
    rec_attendance RECORD;
BEGIN
    DROP TABLE IF EXISTS "Attendancestaff_Temp1";
    DROP TABLE IF EXISTS "EMPLOYEENOTENTERED_TEMP";
    
    CREATE TEMP TABLE "EMPLOYEENOTENTERED_TEMP" (
        "HRME_EmployeeFirstName" TEXT,
        "CLASSNAME" TEXT,
        "SECTIONNAME" TEXT,
        "NOTENTERED_DATE" DATE
    );

    v_DYNAMIC := '
    CREATE TEMP TABLE "Attendancestaff_Temp1" AS
    SELECT DISTINCT A."MI_Id", A."ASMAY_Id", B."ASMCL_Id", B."ASMS_ID"
    FROM "Adm_School_Attendance_Login_User" A 
    INNER JOIN "Adm_School_Attendance_Login_User_Class" B ON A."ASALU_Id" = B."ASALU_Id"
    WHERE A."MI_Id" = ' || p_MI_ID || ' 
    AND A."ASMAY_Id" = ' || p_ASMAY_ID || ' 
    AND B."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
    AND B."ASMS_Id" IN (' || p_ASMS_Id || ')';
    
    EXECUTE v_DYNAMIC;

    FOR v_dt IN 
        SELECT dt::DATE 
        FROM "dbo"."alldates"(p_FROMDATE::DATE, p_TODATE::DATE) 
        WHERE TRIM(TO_CHAR(dt, 'Day')) != 'Sunday'
    LOOP
        FOR rec_attendance IN 
            SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_ID" 
            FROM "Attendancestaff_Temp1"
        LOOP
            v_MI_Id_CUR := rec_attendance."MI_Id";
            v_ASMAY_Id_CUR := rec_attendance."ASMAY_Id";
            v_ASMCL_Id_CUR := rec_attendance."ASMCL_Id";
            v_ASMS_Id_CUR := rec_attendance."ASMS_ID";

            IF p_ENTRY_TYPE = 'D' THEN
                SELECT COUNT(*) INTO v_COUNT 
                FROM "Adm_Student_Attendance" 
                WHERE "MI_Id" = v_MI_Id_CUR 
                AND "ASMAY_Id" = v_ASMAY_Id_CUR 
                AND "ASMCL_Id" = v_ASMCL_Id_CUR 
                AND "ASMS_Id" = v_ASMS_Id_CUR 
                AND ("ASA_FromDate" = v_dt OR "ASA_ToDate" = v_dt) 
                AND "ASA_Att_Type" = 'Dailyonce';

            ELSIF p_ENTRY_TYPE = 'H' THEN
                SELECT COUNT(*) INTO v_COUNT 
                FROM "Adm_Student_Attendance" 
                WHERE "MI_Id" = v_MI_Id_CUR 
                AND "ASMAY_Id" = v_ASMAY_Id_CUR 
                AND "ASMCL_Id" = v_ASMCL_Id_CUR 
                AND "ASMS_Id" = v_ASMS_Id_CUR 
                AND ("ASA_FromDate" = v_dt OR "ASA_ToDate" = v_dt) 
                AND "ASA_Att_Type" = 'Dailytwice';

            ELSIF p_ENTRY_TYPE = 'M' THEN
                SELECT COUNT(*) INTO v_COUNT 
                FROM "Adm_Student_Attendance" 
                WHERE "MI_Id" = v_MI_Id_CUR 
                AND "ASMAY_Id" = v_ASMAY_Id_CUR 
                AND "ASMCL_Id" = v_ASMCL_Id_CUR 
                AND "ASMS_Id" = v_ASMS_Id_CUR 
                AND "ASA_FromDate" BETWEEN p_FROMDATE::TIMESTAMP AND p_TODATE::TIMESTAMP 
                AND "ASA_Att_Type" = 'monthly';

            ELSIF p_ENTRY_TYPE = 'All' THEN
                SELECT COUNT(*) INTO v_COUNT 
                FROM "Adm_Student_Attendance" 
                WHERE "MI_Id" = v_MI_Id_CUR 
                AND "ASMAY_Id" = v_ASMAY_Id_CUR 
                AND "ASMCL_Id" = v_ASMCL_Id_CUR 
                AND "ASMS_Id" = v_ASMS_Id_CUR 
                AND ("ASA_FromDate" = v_dt OR "ASA_ToDate" = v_dt) 
                AND "ASA_Att_Type" IN ('Dailytwice', 'Dailyonce');
            END IF;

            IF COALESCE(v_COUNT, 0) = 0 THEN
                SELECT DISTINCT CONCAT(
                    COALESCE(C."HRME_EmployeeFirstName", ''), ' ', 
                    COALESCE(C."HRME_EmployeeMiddleName", ''), ' ', 
                    COALESCE(C."HRME_EmployeeLastName", '')
                ) INTO v_HRME_EmployeeFirstName
                FROM "Adm_School_Attendance_Login_User" A
                INNER JOIN "Adm_School_Attendance_Login_User_Class" B ON A."ASALU_Id" = B."ASALU_Id"
                INNER JOIN "HR_Master_Employee" C ON C."HRME_ID" = A."HRME_ID"
                WHERE A."MI_Id" = v_MI_Id_CUR 
                AND A."ASMAY_Id" = v_ASMAY_Id_CUR 
                AND B."ASMCL_Id" = v_ASMCL_Id_CUR 
                AND B."ASMS_ID" = v_ASMS_Id_CUR;

                SELECT "ASMCL_ClassName" INTO v_CLASSNAME 
                FROM "Adm_School_M_Class" 
                WHERE "ASMCL_Id" = v_ASMCL_Id_CUR 
                AND "ASMCL_ActiveFlag" = 1;

                SELECT "ASMC_SectionName" INTO v_SECTIONNAME 
                FROM "Adm_School_M_Section" 
                WHERE "ASMS_Id" = v_ASMS_Id_CUR 
                AND "ASMC_ActiveFlag" = 1;

                INSERT INTO "EMPLOYEENOTENTERED_TEMP" 
                VALUES(v_HRME_EmployeeFirstName, v_CLASSNAME, v_SECTIONNAME, v_dt);
            END IF;
        END LOOP;
    END LOOP;

    IF p_ENTRY_TYPE IN ('D', 'H', 'All') THEN
        RETURN QUERY 
        SELECT DISTINCT 
            "HRME_EmployeeFirstName", 
            "CLASSNAME", 
            "SECTIONNAME", 
            "NOTENTERED_DATE"::TEXT 
        FROM "EMPLOYEENOTENTERED_TEMP";
    ELSIF p_ENTRY_TYPE = 'M' THEN
        RETURN QUERY 
        SELECT DISTINCT 
            "HRME_EmployeeFirstName", 
            "CLASSNAME", 
            "SECTIONNAME",
            CONCAT(TO_CHAR("NOTENTERED_DATE", 'Month'), '-', EXTRACT(YEAR FROM "NOTENTERED_DATE")::TEXT) AS "NOTENTERED_DATE"
        FROM "EMPLOYEENOTENTERED_TEMP";
    END IF;

    DROP TABLE IF EXISTS "Attendancestaff_Temp1";
    DROP TABLE IF EXISTS "EMPLOYEENOTENTERED_TEMP";
END;
$$;