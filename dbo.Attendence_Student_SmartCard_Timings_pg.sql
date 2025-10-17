CREATE OR REPLACE FUNCTION "dbo"."Attendence_Student_SmartCard_Timings" (
    "p_AYST_Id" TEXT,
    "p_Section_Id" TEXT,
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASSC_AttendanceDate" TEXT,
    "p_flagFHSH" TEXT
)
RETURNS TABLE (
    "AMST_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_FH_FromTime" TEXT;
    "v_FH_ToTime" TEXT;
BEGIN

    IF "p_flagFHSH" = 'FH' THEN
    
        SELECT "ASSCT_FH_TimeFrom", "ASSCT_FH_TimeTo" 
        INTO "v_FH_FromTime", "v_FH_ToTime"
        FROM "Attendance_Students_SmartCard_Timings" 
        WHERE "mi_id" = "p_MI_Id" AND "ASSCT_Activeflag" = 1;

        RETURN QUERY
        SELECT b."AMST_Id" 
        FROM "Adm_School_Y_Student" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
        WHERE b."AMST_Id" NOT IN (
            SELECT "AMST_Id" 
            FROM "Attendance_Students_SmartCard" a 
            WHERE a."ASCC_Flag" = 1 
            AND a."ASMCL_Id" = "p_AYST_Id" 
            AND a."ASMS_Id" = "p_Section_Id" 
            AND "MI_Id" = "p_MI_Id"  
            AND a."ASMAY_Id" = "p_ASMAY_Id" 
            AND a."ASSC_AttendanceDate" = "p_ASSC_AttendanceDate" 
            AND a."ASSC_PunchTime" BETWEEN "v_FH_FromTime" AND "v_FH_ToTime"
        ) 
        AND "MI_Id" = "p_MI_Id"  
        AND a."ASMCL_Id" = "p_AYST_Id" 
        AND a."ASMS_Id" = "p_Section_Id" 
        AND a."ASMAY_Id" = "p_ASMAY_Id" 
        AND b."AMST_ActiveFlag" = 1 
        AND b."AMST_SOL" = 'S' 
        AND a."AMAY_ActiveFlag" = 1;

    ELSIF "p_flagFHSH" = 'SH' THEN

        SELECT "ASSCT_SH_TimeFrom", "ASSCT_SH_TimeTo" 
        INTO "v_FH_FromTime", "v_FH_ToTime"
        FROM "Attendance_Students_SmartCard_Timings" 
        WHERE "mi_id" = "p_MI_Id" AND "ASSCT_Activeflag" = 1;

        RETURN QUERY
        SELECT b."AMST_Id" 
        FROM "Adm_School_Y_Student" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
        WHERE b."AMST_Id" NOT IN (
            SELECT "AMST_Id" 
            FROM "Attendance_Students_SmartCard" a 
            WHERE a."ASCC_Flag" = 1 
            AND a."ASMCL_Id" = "p_AYST_Id" 
            AND a."ASMS_Id" = "p_Section_Id" 
            AND "MI_Id" = "p_MI_Id"  
            AND a."ASMAY_Id" = "p_ASMAY_Id" 
            AND a."ASSC_AttendanceDate" = "p_ASSC_AttendanceDate" 
            AND a."ASSC_PunchTime" BETWEEN "v_FH_FromTime" AND "v_FH_ToTime"
        ) 
        AND "MI_Id" = "p_MI_Id"  
        AND a."ASMCL_Id" = "p_AYST_Id" 
        AND a."ASMS_Id" = "p_Section_Id" 
        AND a."ASMAY_Id" = "p_ASMAY_Id" 
        AND b."AMST_ActiveFlag" = 1 
        AND b."AMST_SOL" = 'S' 
        AND a."AMAY_ActiveFlag" = 1;

    END IF;

    RETURN;

END;
$$;