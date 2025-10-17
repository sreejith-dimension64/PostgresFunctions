CREATE OR REPLACE FUNCTION "IVRM_Login_History_insertproc"(
    p_MI_Id bigint,
    p_IVRMUL_Id bigint,
    p_ILOGHIS_LogInDate date,
    p_ILOGHIS_LoginTime time,
    p_ILOGHIS_IPV4Address varchar,
    p_ILOGHIS_IPV6Address varchar,
    p_ILOGHIS_NetworkIp varchar,
    p_ILOGHIS_MACAddrress varchar,
    p_ILOGHIS_LogoutDateTime timestamp
)
RETURNS void
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
    VALUES (
        p_MI_Id,
        p_IVRMUL_Id,
        p_ILOGHIS_LogInDate,
        p_ILOGHIS_LoginTime,
        p_ILOGHIS_IPV4Address,
        p_ILOGHIS_IPV6Address,
        p_ILOGHIS_NetworkIp,
        p_ILOGHIS_MACAddrress,
        p_ILOGHIS_LogoutDateTime
    );

END;
$$;