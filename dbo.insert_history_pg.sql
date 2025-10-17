CREATE OR REPLACE FUNCTION "dbo"."insert_history"(
    p0 BIGINT,
    p1 BIGINT,
    p2 VARCHAR(100),
    p3 VARCHAR(100),
    p4 VARCHAR(100),
    p5 VARCHAR(100),
    p6 TIMESTAMP
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO "Preadmission_Student_Login_History" (
        "MI_Id",
        "IVRMSTUUL_Id",
        "PASLH_LoginDateTime",
        "PASLH_LogoutDateTime",
        "PASLH_MAACAdd",
        "PASLH_IPAdd",
        "PASLH_Attempt",
        "PASLH_NetIp"
    )
    VALUES (
        p0,
        p1,
        p6,
        p6,
        p2,
        p3,
        p4,
        p5
    );

END;
$$;