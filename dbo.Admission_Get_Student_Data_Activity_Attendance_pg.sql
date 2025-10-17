CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_Student_Data_Activity_Attendance"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FLAG" TEXT,
    "@DATE" VARCHAR(10),
    "@ASSC_EntryForFlg" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "amsT_AdmNo" VARCHAR,
    "amsT_RegistrationNo" VARCHAR,
    "amaY_RollNo" INTEGER,
    "ALSSC_AttendanceCount" VARCHAR,
    "ALSSC_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

IF "@FLAG" = '1' THEN

    RETURN QUERY
    SELECT DISTINCT A."AMST_Id",
        (CASE WHEN A."AMST_FirstName" IS NULL THEN '' ELSE A."AMST_FirstName" END ||
        CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
        CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END) AS studentname,
        A."AMST_AdmNo" AS amsT_AdmNo,
        A."AMST_RegistrationNo" AS amsT_RegistrationNo,
        B."AMAY_RollNo" AS amaY_RollNo,
        NULL::VARCHAR AS "ALSSC_AttendanceCount",
        NULL::BIGINT AS "ALSSC_Id"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = B."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" D ON D."ASMS_Id" = B."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
    WHERE A."MI_Id" = "@MI_Id"::BIGINT
        AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT
        AND B."ASMS_Id" = "@ASMS_Id"::BIGINT
        AND A."AMST_SOL" = 'S'
        AND A."AMST_ActiveFlag" = 1
        AND B."AMAY_ActiveFlag" = 1
    ORDER BY studentname;

ELSIF "@FLAG" = '2' THEN

    RETURN QUERY
    SELECT DISTINCT A."AMST_Id",
        (CASE WHEN A."AMST_FirstName" IS NULL THEN '' ELSE A."AMST_FirstName" END ||
        CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
        CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END) AS studentname,
        A."AMST_AdmNo" AS amsT_AdmNo,
        A."AMST_RegistrationNo" AS amsT_RegistrationNo,
        B."AMAY_RollNo" AS amaY_RollNo,
        F."ALSSC_AttendanceCount"::VARCHAR AS "ALSSC_AttendanceCount",
        F."ALSSC_Id"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = B."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" D ON D."ASMS_Id" = B."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
    INNER JOIN "Attendance_Lunch_Students_SmartCard" F ON F."AMST_Id" = B."AMST_Id"
        AND F."ASMCL_Id" = C."ASMCL_Id"
        AND F."ASMS_Id" = D."ASMS_Id"
        AND F."ASMAY_Id" = E."ASMAY_Id"
    WHERE A."MI_Id" = "@MI_Id"::BIGINT
        AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT
        AND B."ASMS_Id" = "@ASMS_Id"::BIGINT
        AND F."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND F."ASMCL_Id" = "@ASMCL_Id"::BIGINT
        AND F."ASMS_Id" = "@ASMS_Id"::BIGINT
        AND A."AMST_SOL" = 'S'
        AND A."AMST_ActiveFlag" = 1
        AND B."AMAY_ActiveFlag" = 1
        AND F."ASSC_AttendanceDate" = "@DATE"::DATE
        AND F."ASSC_EntryForFlg" = "@ASSC_EntryForFlg"
    ORDER BY studentname;

END IF;

RETURN;

END;
$$;