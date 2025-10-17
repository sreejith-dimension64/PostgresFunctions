CREATE OR REPLACE FUNCTION "dbo"."Attendance_Monthwise_TotalClassHeld"(
    p_ASMAY_Id TEXT,
    p_ASMCL_ID TEXT,
    p_ASMS_Id TEXT,
    p_monthid TEXT,
    p_mi_id TEXT
)
RETURNS TABLE(classheld BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT SUM("ASA_ClassHeld")::BIGINT AS classheld 
    FROM "Adm_Student_Attendance" 
    WHERE "MI_Id" = p_mi_id 
        AND "ASMCL_Id" = p_ASMCL_ID 
        AND "ASMS_Id" = p_ASMS_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND EXTRACT(MONTH FROM "ASA_FromDate")::TEXT = p_monthid 
        AND "ASA_Activeflag" = 1;
END;
$$;