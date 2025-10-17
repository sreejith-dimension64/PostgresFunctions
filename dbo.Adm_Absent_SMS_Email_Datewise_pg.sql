CREATE OR REPLACE FUNCTION "dbo"."Adm_Absent_SMS_Email_Datewise"(
    p_ASMAY_ID TEXT,
    p_mi_id TEXT,
    p_fromdate VARCHAR(10)
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    studentname TEXT,
    classsection TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d."AMST_Id",
        (CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
         CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' OR d."AMST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
         CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' OR d."AMST_LastName" = '0' THEN '' ELSE ' ' || d."AMST_LastName" END) AS studentname,
        (e."ASMCL_ClassName" || '-' || f."ASMC_SectionName") AS classsection
    FROM "Adm_Student_Attendance_Students" a
    INNER JOIN "Adm_Student_Attendance" b ON a."ASA_Id" = b."ASA_Id"
    INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
    INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id"
    WHERE d."amst_sol" = 'S' 
        AND d."AMST_ActiveFlag" = 1 
        AND d."AMAY_ActiveFlag" = 1 
        AND b."ASA_FromDate" = p_fromdate 
        AND b."ASA_Class_Attended" = 0.00 
        AND b."MI_Id" = p_mi_id
        AND c."ASMAY_Id" = p_ASMAY_ID 
        AND b."ASA_Activeflag" = 1;
END;
$$;