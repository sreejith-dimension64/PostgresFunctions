CREATE OR REPLACE FUNCTION "dbo"."adm_student_list_not_in_att"(
    p_asmcl_id TEXT,
    p_asms_id TEXT,
    p_fromdate TEXT,
    p_mi_id TEXT,
    p_asmay_id TEXT,
    p_month TEXT,
    p_monthid TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "studentname" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "amsT_RegistrationNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_startDate DATE;
    v_endDate DATE;
    v_year INTEGER;
    v_current_date DATE;
    v_dates DATE;
BEGIN

    IF p_month = 'M' THEN
    
        CREATE TEMP TABLE "NewTable1"(
            "id" SERIAL NOT NULL,
            "MonthId" INTEGER,
            "AYear" INTEGER
        ) ON COMMIT DROP;

        SELECT "ASMAY_From_Date" INTO v_startDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;
        
        SELECT "ASMAY_To_Date" INTO v_endDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;

        v_current_date := v_startDate;
        
        WHILE v_current_date <= v_endDate LOOP
            INSERT INTO "NewTable1"("MonthId", "AYear")
            SELECT EXTRACT(MONTH FROM v_current_date)::INTEGER, EXTRACT(YEAR FROM v_current_date)::INTEGER;
            
            v_current_date := v_current_date + INTERVAL '1 month';
        END LOOP;

        SELECT "AYear" INTO v_year 
        FROM "NewTable1" 
        WHERE "MonthId" = p_monthid::INTEGER 
        LIMIT 1;

        RETURN QUERY
        SELECT 
            a."AMST_Id" AS "AMST_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) AS "studentname",
            a."AMST_AdmNo" AS "AMST_AdmNo",
            b."AMAY_RollNo" AS "AMAY_RollNo",
            a."amsT_RegistrationNo" AS "amsT_RegistrationNo"
        FROM "Adm_M_Student" a 
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        WHERE b."AMST_Id" NOT IN (
            SELECT c."AMST_Id" 
            FROM "Adm_Student_Attendance_Students" c 
            INNER JOIN "Adm_Student_Attendance" d ON c."ASA_Id" = d."ASA_Id"
            WHERE (EXTRACT(MONTH FROM d."ASA_FromDate")::INTEGER = p_monthid::INTEGER OR EXTRACT(MONTH FROM d."ASA_ToDate")::INTEGER = p_monthid::INTEGER)
            AND (EXTRACT(YEAR FROM d."ASA_FromDate")::INTEGER = v_year OR EXTRACT(YEAR FROM d."ASA_ToDate")::INTEGER = v_year)
            AND d."ASMCL_Id" = p_asmcl_id 
            AND d."ASMS_Id" = p_asms_id 
            AND d."MI_Id" = p_mi_id
            AND d."ASMAY_Id" = p_asmay_id 
            AND d."ASA_Activeflag" = 1
        )
        AND b."ASMCL_Id" = p_asmcl_id 
        AND b."ASMS_Id" = p_asms_id 
        AND a."MI_Id" = p_mi_id
        AND EXTRACT(MONTH FROM a."amst_date")::INTEGER <= p_monthid::INTEGER 
        AND EXTRACT(YEAR FROM a."amst_date")::INTEGER <= EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INTEGER
        AND b."ASMAY_Id" = p_asmay_id 
        AND a."AMST_SOL" = 'S'
        AND a."AMST_ActiveFlag" = 1 
        AND b."AMAY_ActiveFlag" = 1;

    ELSE
    
        RETURN QUERY
        SELECT 
            a."AMST_Id" AS "AMST_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) AS "studentname",
            a."AMST_AdmNo" AS "AMST_AdmNo",
            b."AMAY_RollNo" AS "AMAY_RollNo",
            a."amsT_RegistrationNo" AS "amsT_RegistrationNo"
        FROM "Adm_M_Student" a 
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        WHERE b."AMST_Id" NOT IN (
            SELECT c."AMST_Id" 
            FROM "Adm_Student_Attendance_Students" c 
            INNER JOIN "Adm_Student_Attendance" d ON c."ASA_Id" = d."ASA_Id"
            WHERE d."ASA_FromDate" = p_fromdate::DATE 
            AND d."ASMCL_Id" = p_asmcl_id 
            AND d."ASMS_Id" = p_asms_id 
            AND d."MI_Id" = p_mi_id
            AND d."ASMAY_Id" = p_asmay_id 
            AND d."ASA_Activeflag" = 1
        )
        AND b."ASMCL_Id" = p_asmcl_id 
        AND b."ASMS_Id" = p_asms_id 
        AND a."MI_Id" = p_mi_id
        AND a."amst_date" <= p_fromdate::DATE 
        AND b."ASMAY_Id" = p_asmay_id 
        AND a."AMST_SOL" = 'S'
        AND a."AMST_ActiveFlag" = 1 
        AND b."AMAY_ActiveFlag" = 1;

    END IF;

    RETURN;

END;
$$;