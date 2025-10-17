CREATE OR REPLACE FUNCTION "dbo"."FA_Rec_Voucher_InsertFeeMaster"(
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_IMFY_Id bigint,
    p_CFAMLED_Id bigint,
    p_r_no varchar(100),
    p_date timestamp,
    p_TOTamount double precision,
    p_remarks varchar(250),
    p_DFAMLED_Id bigint,
    p_BoolBank boolean,
    p_BankName varchar(50),
    p_ChequeNo varchar(20),
    p_ChequeDate timestamp,
    p_insert_master integer,
    INOUT p_FAMVOU_Id bigint
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_insert_master = 1 THEN
    
        INSERT INTO "dbo"."FA_M_Voucher"("MI_Id","FAMCOMP_Id","IMFY_Id","FAMVOU_VoucherType","FAMVOU_VoucherNo","FAMVOU_VoucherDate","FAMVOU_Narration","FAMVOU_Suffix","FAMVOU_Prefix","FAMVOU_VNo","FAMVOU_UserVoucherType","FAMVOU_APIReferenceNo","FAMVOU_BillwiseFlg","FAMVOU_Description","FAMVOU_ActiveFlg","FAMVOU_CreatedDate","FAMVOU_UpdatedDate")
        VALUES(p_MI_Id, p_FAMCOMP_Id, p_IMFY_Id, 'ReceiptVoucher', '', p_date, p_remarks, '', '', '', 'ReceiptVoucher', '', 0, p_r_no, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        SELECT "FAMVOU_Id" INTO p_FAMVOU_Id 
        FROM "dbo"."FA_M_Voucher" 
        WHERE "MI_Id" = p_MI_Id 
            AND "IMFY_Id" = p_IMFY_Id 
            AND "FAMCOMP_Id" = p_FAMCOMP_Id 
            AND CAST("FAMVOU_VoucherDate" AS date) = CAST(p_date AS date);

    END IF;

    IF p_BoolBank = false THEN
    
        INSERT INTO "dbo"."FA_T_Voucher"("FAMVOU_Id","FAMLED_Id","FATVOU_Amount","FATVOU_CRDRFlg","FATVOU_TransactionTypeFlg","FATVOU_Narration","FATVOU_ChequNo","FATVOU_ChequeDate","FATVOU_BankName","FATVOU_ReferrenceNo","FATVOU_BillwiseFlg","FATVOU_Description","FATVOU_ActiveFlg","FATVOU_CreatedDate","FATVOU_UpdatedDate")
        VALUES (p_FAMVOU_Id, p_DFAMLED_Id, p_TOTamount, 'Dr', '', NULL, '', '', '', '', 0, '', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
          
    ELSE
    
        INSERT INTO "dbo"."FA_T_Voucher" ("FAMVOU_Id","FAMLED_Id","FATVOU_Amount","FATVOU_CRDRFlg","FATVOU_TransactionTypeFlg","FATVOU_Narration","FATVOU_ChequNo","FATVOU_ChequeDate","FATVOU_BankName","FATVOU_ReferrenceNo","FATVOU_BillwiseFlg","FATVOU_Description","FATVOU_ActiveFlg","FATVOU_CreatedDate","FATVOU_UpdatedDate")
        VALUES (p_FAMVOU_Id, p_DFAMLED_Id, p_TOTamount, 'Dr', '', NULL, p_chequeno, p_chequedate, p_bankname, '', 0, '', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

    END IF;

    PERFORM "dbo"."FA_Autoupdation"(p_DFAMLED_Id, p_IMFY_Id);

    RETURN;
END;
$$;