CREATE OR REPLACE FUNCTION "HL_Hostel_Student_Admin_GatePass_TimeUpdate"(
    p_HLHSTGP_Id bigint,
    p_HLHSTGP_CameBackDate timestamp,
    p_HLHSTGP_CameBackTime text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "HL_Hostel_Student_Gatepass" 
    SET "HLHSTGP_CameBackTime" = p_HLHSTGP_CameBackTime,
        "HLHSTGP_CameBackDate" = p_HLHSTGP_CameBackDate
    WHERE "HLHSTGP_Id" = p_HLHSTGP_Id;
END;
$$;