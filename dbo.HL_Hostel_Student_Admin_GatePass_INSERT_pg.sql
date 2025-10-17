CREATE OR REPLACE FUNCTION "dbo"."HL_Hostel_Student_Admin_GatePass_INSERT"(
    p_AMCST_Id bigint,
    p_MI_Id bigint,
    p_HLHSTGP_Id bigint,
    p_HLHSTGP_TypeFlg text,
    p_HLHSTGP_GoingOutDate timestamp,
    p_HLHSTGP_GoingOutTime text,
    p_HLHSTGP_Reason text,
    p_HLHSTGP_ComingBackDate timestamp,
    p_userid bigint,
    p_HLHSTGP_ActiveFlg boolean
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_HLHSTGP_TotalDays bigint;
BEGIN
    SELECT EXTRACT(DAY FROM (p_HLHSTGP_ComingBackDate - p_HLHSTGP_GoingOutDate))::bigint
    INTO v_HLHSTGP_TotalDays;

    IF (p_HLHSTGP_Id > 0) THEN
        UPDATE "HL_Hostel_Student_Gatepass" 
        SET 
            "HLHSTGP_TypeFlg" = p_HLHSTGP_TypeFlg,
            "HLHSTGP_GoingOutDate" = p_HLHSTGP_GoingOutDate,
            "HLHSTGP_GoingOutTime" = p_HLHSTGP_GoingOutTime,
            "HLHSTGP_Reason" = p_HLHSTGP_Reason,
            "HLHSTGP_ComingBackDate" = p_HLHSTGP_ComingBackDate,
            "HLHSTGP_TotalDays" = v_HLHSTGP_TotalDays
        WHERE "HLHSTGP_Id" = p_HLHSTGP_Id;
    ELSE
        INSERT INTO "HL_Hostel_Student_Gatepass"
        ("MI_Id", "AMCST_Id", "HLHSTGP_TypeFlg", "HLHSTGP_GoingOutDate", "HLHSTGP_GoingOutTime", 
         "HLHSTGP_Reason", "HLHSTGP_ComingBackDate", "HLHSTGP_TotalDays", "HLHSTGP_ActiveFlg")
        VALUES
        (p_MI_Id, p_AMCST_Id, p_HLHSTGP_TypeFlg, p_HLHSTGP_GoingOutDate, p_HLHSTGP_GoingOutTime,
         p_HLHSTGP_Reason, p_HLHSTGP_ComingBackDate, v_HLHSTGP_TotalDays, p_HLHSTGP_ActiveFlg);
    END IF;

    RETURN;
END;
$$;