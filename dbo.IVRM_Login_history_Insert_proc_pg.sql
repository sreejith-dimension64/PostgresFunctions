CREATE OR REPLACE FUNCTION "IVRM_Login_history_Insert_proc"(
    p_MI_ID BIGINT,
    p_IVRMUL_ID BIGINT,
    p_ILOGHIS_NetworkIp VARCHAR(250),
    p_ILOGHIS_MACAddrress VARCHAR(250)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO "IVRM_Login_History"(
        "MI_Id",
        "IVRMUL_Id",
        "ILOGHIS_LogInDate",
        "ILOGHIS_LoginTime",
        "ILOGHIS_IPV4Address",
        "ILOGHIS_IPV6Address",
        "ILOGHIS_NetworkIp",
        "ILOGHIS_MACAddrress",
        "ILOGHIS_LogoutDateTime"
    )
    VALUES(
        p_MI_ID,
        p_IVRMUL_Id,
        CURRENT_TIMESTAMP::DATE,
        CURRENT_TIMESTAMP::TIME,
        0,
        0,
        p_ILOGHIS_NetworkIp,
        p_ILOGHIS_MACAddrress,
        CURRENT_TIMESTAMP
    );

END;
$$;