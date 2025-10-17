CREATE OR REPLACE FUNCTION "dbo"."FA_Rec_Voucher_InsertRef"(
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_IMFY_Id bigint,
    p_CFAMLED_Id bigint,
    p_R_No VARCHAR(100),
    p_date TIMESTAMP,
    p_amount NUMERIC(9,2),
    p_remarks VARCHAR(250),
    p_DFAMLED_Id bigint,
    p_BoolBank BOOLEAN,
    p_BankName VARCHAR(50),
    p_ChequeNo VARCHAR(20),
    p_ChequeDate TIMESTAMP
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "dbo"."FA_M_Voucher"(
        "MI_Id",
        "FAMCOMP_Id",
        "IMFY_Id",
        "FAMVOU_VoucherType",
        "FAMVOU_VoucherNo",
        "FAMVOU_VoucherDate",
        "FAMVOU_Narration",
        "FAMVOU_Suffix",
        "FAMVOU_Prefix",
        "FAMVOU_VNo",
        "FAMVOU_UserVoucherType",
        "FAMVOU_APIReferenceNo",
        "FAMVOU_BillwiseFlg",
        "FAMVOU_Description",
        "FAMVOU_ActiveFlg",
        "FAMVOU_CreatedDate",
        "FAMVOU_UpdatedDate"
    )
    VALUES(
        p_MI_Id,
        p_FAMCOMP_Id,
        p_IMFY_Id,
        'PaymentVoucher',
        '',
        p_date,
        p_remarks,
        '',
        '',
        '',
        'PaymentVoucher',
        '',
        0,
        p_r_no,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
    
    RETURN;
END;
$$;