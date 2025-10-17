CREATE OR REPLACE FUNCTION "dbo"."Insert_fee_tables"(
    "@mi_id" VARCHAR(50),
    "@asmay_id" VARCHAR(50),
    "@studentis" VARCHAR(50),
    "@classid" VARCHAR(50),
    "@amount" VARCHAR(50),
    "@transid" VARCHAR(50),
    "@checkid" VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@setstatus" BIGINT;
    "@lastid" BIGINT;
    "@fma_id" BIGINT;
BEGIN
    "@fma_id" := 186;

    RAISE NOTICE 'sucess';
    
    INSERT INTO "Fee_Y_Payment" (
        "ASMAY_ID",
        "FTCU_Id",
        "FYP_Receipt_No",
        "FYP_Bank_Name",
        "FYP_Bank_Or_Cash",
        "FYP_DD_Cheque_No",
        "FYP_DD_Cheque_Date",
        "FYP_Date",
        "FYP_Tot_Amount",
        "FYP_Tot_Waived_Amt",
        "FYP_Tot_Fine_Amt",
        "FYP_Tot_Concession_Amt",
        "FYP_Remarks",
        "user_id",
        "FYP_Chq_Bounce",
        "MI_Id",
        "DOE",
        "CreatedDate",
        "UpdatedDate"
    ) 
    VALUES (
        "@asmay_id",
        1,
        "@transid",
        '',
        'O',
        0,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        "@amount",
        0,
        0,
        0,
        "@checkid",
        '1',
        'CL',
        "@mi_id",
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    SELECT CURRVAL(pg_get_serial_sequence('"Fee_Y_Payment"', 'identity_column_name'))
    INTO "@lastid";

    INSERT INTO "Fee_T_Payment" 
    VALUES ("@lastid", "@fma_id", "@amount", 0, 0, 0, '', 0);

    INSERT INTO "Fee_Y_Payment_PA_Application" 
    VALUES ("@lastid", "@studentis", "@amount", 1, 'P');

    RETURN;
END;
$$;