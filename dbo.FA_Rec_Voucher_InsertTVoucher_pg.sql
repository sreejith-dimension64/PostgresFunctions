CREATE OR REPLACE FUNCTION "dbo"."FA_Rec_Voucher_InsertTVoucher"(
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_IMFY_Id bigint,
    p_CFAMLED_Id bigint,
    p_r_no varchar(100),
    p_date timestamp,
    p_amount numeric(9,2),
    p_Fine numeric(9,2),
    p_remarks varchar(250),
    p_DFAMLED_Id bigint,
    p_BoolBank boolean,
    p_BankName varchar(50),
    p_ChequeNo varchar(20),
    p_ChequeDate timestamp,
    INOUT p_FAMVOU_Id bigint DEFAULT NULL
)
RETURNS bigint
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

    SELECT "FAMVOU_Id" INTO p_FAMVOU_Id 
    FROM "dbo"."FA_M_Voucher" 
    WHERE "MI_Id" = p_MI_Id 
        AND "IMFY_Id" = p_IMFY_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id 
        AND CAST("FAMVOU_VoucherDate" AS DATE) = CAST(p_date AS DATE);

    INSERT INTO "dbo"."FA_T_Voucher"(
        "FAMVOU_Id",
        "FAMLED_Id",
        "FATVOU_Amount",
        "FATVOU_CRDRFlg",
        "FATVOU_TransactionTypeFlg",
        "FATVOU_Narration",
        "FATVOU_ChequNo",
        "FATVOU_ChequeDate",
        "FATVOU_BankName",
        "FATVOU_ReferrenceNo",
        "FATVOU_BillwiseFlg",
        "FATVOU_Description",
        "FATVOU_ActiveFlg",
        "FATVOU_CreatedDate",
        "FATVOU_UpdatedDate"
    )
    VALUES (
        p_FAMVOU_Id,
        p_DFAMLED_Id,
        p_amount,
        'Dr',
        '',
        NULL,
        '',
        '',
        '',
        '',
        0,
        '',
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    INSERT INTO "dbo"."FA_T_Voucher" (
        "FAMVOU_Id",
        "FAMLED_Id",
        "FATVOU_Amount",
        "FATVOU_CRDRFlg",
        "FATVOU_TransactionTypeFlg",
        "FATVOU_Narration",
        "FATVOU_ChequNo",
        "FATVOU_ChequeDate",
        "FATVOU_BankName",
        "FATVOU_ReferrenceNo",
        "FATVOU_BillwiseFlg",
        "FATVOU_Description",
        "FATVOU_ActiveFlg",
        "FATVOU_CreatedDate",
        "FATVOU_UpdatedDate"
    )
    VALUES (
        p_FAMVOU_Id,
        p_CFAMLED_Id,
        p_amount + p_Fine,
        'Cr',
        '',
        NULL,
        p_ChequeNo,
        p_ChequeDate,
        p_BankName,
        '',
        0,
        '',
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    PERFORM "dbo"."FA_Autoupdation"(p_DFAMLED_Id, p_IMFY_Id);
    PERFORM "dbo"."FA_Autoupdation"(p_CFAMLED_Id, p_IMFY_Id);

    RETURN p_FAMVOU_Id;

END;
$$;