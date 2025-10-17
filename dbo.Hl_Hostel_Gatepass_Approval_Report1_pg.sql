CREATE OR REPLACE FUNCTION "Hl_Hostel_Gatepass_Approval_Report1"(
    p_Comingbackdate TIMESTAMP,
    p_Comingbacktime VARCHAR(300)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCST_Id BIGINT;
    v_Totaldays BIGINT;
    v_HLHSTGP_Id BIGINT;
    v_count BIGINT;
    v_Id BIGINT;
    v_HLHSTGPAPP_Remarks TEXT;
    v_userid BIGINT;
    v_HLHSTGP_GoingOutDate TIMESTAMP;
    v_HLHSTGP_ComingBackDate TIMESTAMP;
    v_HLHSTGP_GoingOutTime VARCHAR(300);
    v_HLHSTGP_CameBackTime VARCHAR(300);
    rec RECORD;
BEGIN
    FOR rec IN 
        SELECT "HLHSTGPAPP_Id" 
        FROM "HL_Hostel_Student_Gatepass_Approval" 
        WHERE "HLHSTGP_Id" = v_HLHSTGP_Id
    LOOP
        v_HLHSTGP_Id := rec."HLHSTGPAPP_Id";
        
        SELECT EXTRACT(DAY FROM ("HLHSTGP_ComingBackDate" - "HLHSTGP_GoingOutDate"))::BIGINT
        INTO v_Totaldays
        FROM "HL_Hostel_Student_Gatepass"
        WHERE "AMCST_Id" = v_AMCST_Id;
        
        UPDATE "HL_Hostel_Student_Gatepass"
        SET "HLHSTGP_ComingBackDate" = v_HLHSTGP_ComingBackDate,
            "HLHSTGP_CameBackTime" = v_HLHSTGP_CameBackTime,
            "HLHSTGP_TotalDays" = v_Totaldays
        WHERE "HLHSTGP_Id" = v_HLHSTGP_Id;
    END LOOP;
    
    RETURN;
END;
$$;