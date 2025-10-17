CREATE OR REPLACE FUNCTION "dbo"."Admission_Smartcard_FirstHalf_SecondHalf_Check"(
    "p_MI_Id" TEXT,
    "p_Punchtime" TEXT,
    "p_flag" TEXT
)
RETURNS TABLE(
    "ASSCT_Id" INTEGER,
    "ASSCT_FH_TimeFrom" TIME,
    "ASSCT_FH_TimeTo" TIME,
    "ASSCT_SH_TimeFrom" TIME,
    "ASSCT_SH_TimeTo" TIME,
    "MI_Id" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "p_flag" = 'FH' THEN
        RETURN QUERY
        SELECT 
            "a"."ASSCT_Id", 
            "a"."ASSCT_FH_TimeFrom", 
            "a"."ASSCT_FH_TimeTo", 
            "a"."ASSCT_SH_TimeFrom", 
            "a"."ASSCT_SH_TimeTo", 
            "a"."MI_Id"
        FROM "Attendance_Students_SmartCard_Timings" AS "a"
        WHERE "a"."MI_Id" = "p_MI_Id" 
            AND "p_Punchtime"::TIME BETWEEN "a"."ASSCT_FH_TimeFrom" AND "a"."ASSCT_FH_TimeTo"
            AND "a"."assct_activeflag" = 1;
    
    ELSIF "p_flag" = 'SH' THEN
        RETURN QUERY
        SELECT 
            "a"."ASSCT_Id", 
            "a"."ASSCT_FH_TimeFrom", 
            "a"."ASSCT_FH_TimeTo", 
            "a"."ASSCT_SH_TimeFrom", 
            "a"."ASSCT_SH_TimeTo", 
            "a"."MI_Id"
        FROM "Attendance_Students_SmartCard_Timings" AS "a"
        WHERE "a"."MI_Id" = "p_MI_Id" 
            AND "p_Punchtime"::TIME BETWEEN "a"."ASSCT_SH_TimeFrom" AND "a"."ASSCT_SH_TimeTo"
            AND "a"."assct_activeflag" = 1;
    
    END IF;
    
    RETURN;
END;
$$;