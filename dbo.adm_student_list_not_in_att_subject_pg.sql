CREATE OR REPLACE FUNCTION "dbo"."adm_student_list_not_in_att_subject"(
    "@asmcl_id" TEXT,
    "@asms_id" TEXT,
    "@fromdate" TEXT,
    "@mi_id" TEXT,
    "@asmay_id" TEXT,
    "@month" TEXT,
    "@monthid" TEXT,
    "@isms_id" TEXT,
    "@ttmp_id" TEXT
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
BEGIN

    IF "@month" = 'M' THEN
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
            WHERE (EXTRACT(MONTH FROM d."ASA_FromDate") = "@monthid"::INTEGER OR EXTRACT(MONTH FROM d."ASA_ToDate") = "@monthid"::INTEGER)
              AND (EXTRACT(YEAR FROM d."ASA_FromDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP) OR EXTRACT(YEAR FROM d."ASA_ToDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP))
              AND d."ASMCL_Id" = "@asmcl_id"
              AND d."ASMS_Id" = "@asms_id"
              AND d."MI_Id" = "@mi_id"
              AND d."ASMAY_Id" = "@asmay_id"
              AND d."ASA_Activeflag" = 1
        )
        AND b."ASMCL_Id" = "@asmcl_id"
        AND b."ASMS_Id" = "@asms_id"
        AND a."MI_Id" = "@mi_id"
        AND EXTRACT(MONTH FROM a."amst_date") <= "@monthid"::INTEGER
        AND EXTRACT(YEAR FROM a."amst_date") <= EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
        AND b."ASMAY_Id" = "@asmay_id"
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
        INNER JOIN "exm"."Exm_Studentwise_Subjects" e ON e."AMST_Id" = b."AMST_Id"
        WHERE b."AMST_Id" NOT IN (
            SELECT c."AMST_Id"
            FROM "Adm_Student_Attendance_Students" c
            INNER JOIN "Adm_Student_Attendance" d ON c."ASA_Id" = d."ASA_Id"
            INNER JOIN "Adm_Student_Attendance_Periodwise" g ON g."ASA_Id" = d."ASA_Id"
            INNER JOIN "Adm_Student_Attendance_Subjects" h ON h."ASA_Id" = d."ASA_Id"
            WHERE d."ASA_FromDate" = "@fromdate"::TIMESTAMP
              AND d."ASMCL_Id" = "@asmcl_id"
              AND d."ASMS_Id" = "@asms_id"
              AND d."MI_Id" = "@mi_id"
              AND d."ASMAY_Id" = "@asmay_id"
              AND g."TTMP_Id" = "@ttmp_id"
              AND h."ISMS_Id" = "@isms_id"
              AND d."ASA_Activeflag" = 1
        )
        AND b."ASMCL_Id" = "@asmcl_id"
        AND b."ASMS_Id" = "@asms_id"
        AND a."MI_Id" = "@mi_id"
        AND a."amst_date" <= "@fromdate"::TIMESTAMP
        AND b."ASMAY_Id" = "@asmay_id"
        AND a."AMST_SOL" = 'S'
        AND a."AMST_ActiveFlag" = 1
        AND b."AMAY_ActiveFlag" = 1
        AND e."ISMS_Id" = "@isms_id";
    END IF;

    RETURN;
END;
$$;