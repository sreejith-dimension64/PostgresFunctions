CREATE OR REPLACE FUNCTION "dbo"."FA_Rec_Voucher_InsertMVoucher"(
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_IMFY_Id bigint,
    p_CFAMLED_Id bigint,
    p_r_no varchar(100),
    p_date timestamp,
    p_amount numeric(9,2),
    p_remarks varchar(250),
    p_DFAMLED_Id bigint,
    p_BoolBank boolean,
    p_BankName varchar(50),
    p_ChequeNo varchar(20),
    p_ChequeDate timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "FA_M_Voucher"(
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
END;
$$;