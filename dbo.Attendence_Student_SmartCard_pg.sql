CREATE OR REPLACE FUNCTION "dbo"."Attendence_Student_SmartCard" (
    "AYST_Id" TEXT,
    "Section_Id" TEXT,
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASSC_AttendanceDate" TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b."AMST_Id" 
    FROM "dbo"."Adm_School_Y_Student" a 
    INNER JOIN "dbo"."Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
    WHERE b."AMST_Id" NOT IN (
        SELECT a."AMST_Id" 
        FROM "dbo"."Attendance_Students_SmartCard" a 
        WHERE a."ASCC_Flag" = 1 
        AND a."ASMCL_Id" = "AYST_Id" 
        AND a."ASMS_Id" = "Section_Id" 
        AND a."MI_Id" = "MI_Id" 
        AND a."ASMAY_Id" = "ASMAY_Id"
        AND a."ASSC_AttendanceDate" = "ASSC_AttendanceDate"
    ) 
    AND a."MI_Id" = "MI_Id" 
    AND a."ASMCL_Id" = "AYST_Id" 
    AND a."ASMS_Id" = "Section_Id" 
    AND a."ASMAY_Id" = "ASMAY_Id"
    AND b."AMST_ActiveFlag" = 1 
    AND b."AMST_SOL" = 'S' 
    AND a."AMAY_ActiveFlag" = 1;
END;
$$;