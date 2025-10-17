CREATE OR REPLACE FUNCTION "dbo"."Get_Student_LateInd_Record"(
    "@MI_Id" BIGINT,
    "@ASMAY_ID" BIGINT
)
RETURNS TABLE (
    "ALIEOS_Id" BIGINT,
    "ALIEOS_AttendanceDate" TIMESTAMP,
    "ALIEOS_PunchDate" TIMESTAMP,
    "ALIEOS_PunchTime" TIME,
    "ALIEOS_Reason" TEXT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMAY_Year" VARCHAR,
    "studentName" TEXT,
    "AMST_AdmNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ALIEOS_Id",
        a."ALIEOS_AttendanceDate",
        a."ALIEOS_PunchDate",
        a."ALIEOS_PunchTime",
        a."ALIEOS_Reason",
        a."ASMAY_Id",
        a."ASMCL_Id",
        a."ASMS_Id",
        a."AMST_Id",
        c."ASMCL_ClassName",
        s."ASMC_SectionName",
        yr."ASMAY_Year",
        COALESCE(st."AMST_FirstName", '') || '' || COALESCE(st."AMST_MiddleName", '') || '' || COALESCE(st."AMST_LastName", '') AS "studentName",
        st."AMST_AdmNo"
    FROM "Attendance_LateIn_Students" a
    INNER JOIN "Adm_School_Y_Student" b ON a."ASMAY_Id" = b."ASMAY_Id" 
        AND b."ASMCL_Id" = a."ASMCL_Id" 
        AND b."ASMS_Id" = a."ASMS_Id" 
        AND b."AMST_Id" = a."AMST_Id"
    INNER JOIN "Adm_School_M_Class" c ON b."ASMCL_Id" = c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" s ON b."ASMS_Id" = s."ASMS_Id"
    INNER JOIN "Adm_M_Student" st ON b."AMST_Id" = st."AMST_Id" 
        AND a."MI_Id" = st."MI_Id" 
        AND st."AMST_SOL" = 'S'
    INNER JOIN "Adm_School_M_Academic_Year" yr ON yr."ASMAY_Id" = b."ASMAY_Id" 
        AND a."MI_Id" = yr."MI_Id"
    WHERE a."MI_Id" = "@MI_Id" 
        AND a."ASMAY_Id" = "@ASMAY_ID" 
        AND b."AMAY_ActiveFlag" = 1;
END;
$$;