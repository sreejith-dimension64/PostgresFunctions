CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Y_Payment_School_Student"(
    p_fypid BIGINT,
    p_amstid BIGINT,
    p_asmayid BIGINT,
    p_fyptotam DECIMAL,
    p_fypwaived DECIMAL,
    p_fypconcessionamt DECIMAL,
    p_fypfine DECIMAL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "Fee_Y_Payment_School_Student"(
        "FYP_Id",
        "AMST_Id",
        "ASMAY_Id",
        "FTP_TotalPaidAmount",
        "FTP_TotalWaivedAmount",
        "FTP_TotalConcessionAmount",
        "FTP_TotalFineAmount"
    )
    VALUES (
        p_fypid,
        p_amstid,
        p_asmayid,
        p_fyptotam,
        p_fypwaived,
        p_fypconcessionamt,
        p_fypfine
    );
END;
$$;