CREATE OR REPLACE FUNCTION "dbo"."adm_exam_student_attendance_details" (
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@from" date,
    "@to" date
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "classheld" bigint,
    "classattended" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        c."AMST_Id",
        SUM(a."ASA_ClassHeld") AS classheld,
        SUM(b."ASA_Class_Attended") AS classattended
    FROM "Adm_Student_Attendance" a 
    INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
    INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = c."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = c."ASMS_Id"
    WHERE c."ASMCL_Id" = "@ASMCL_Id" 
        AND c."ASMS_Id" = "@ASMS_Id" 
        AND c."ASMAY_Id" = "@ASMAY_Id" 
        AND d."MI_Id" = "@MI_Id"
        AND a."ASMCL_Id" = "@ASMCL_Id" 
        AND a."ASMS_Id" = "@ASMS_Id" 
        AND a."ASMAY_Id" = "@ASMAY_Id" 
        AND a."MI_Id" = "@MI_Id"
        AND (a."ASA_FromDate" BETWEEN "@from" AND "@to") 
        AND a."ASA_Activeflag" = 1 
        AND c."AMAY_ActiveFlag" = 1 
        AND d."AMST_SOL" = 'S' 
        AND d."AMST_ActiveFlag" = 1
    GROUP BY c."AMST_Id";

END;
$$;