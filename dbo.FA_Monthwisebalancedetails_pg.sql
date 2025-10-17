CREATE OR REPLACE FUNCTION "FA_Monthwisebalancedetails"(
    p_FAMLED_Id bigint,
    p_IMFY_Id bigint
)
RETURNS TABLE(
    "FAMLED_Id" bigint,
    "monthname" VARCHAR,
    "MonthOrder" INTEGER,
    "Credit" NUMERIC,
    "Debit" NUMERIC,
    "TotalBalance" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m."FAMLED_Id",
        p."monthname",
        p."MonthOrder",
        COALESCE((SELECT SUM(a."FATVOU_Amount")   
                  FROM "FA_T_Voucher" a  
                  INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                  WHERE a."FATVOU_CRDRFlg" = 'CR' AND a."FATVOU_Id" = m."FATVOU_Id"), 0) AS "Credit",
        COALESCE((SELECT SUM(a."FATVOU_Amount")  
                  FROM "FA_T_Voucher" a  
                  INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                  WHERE a."FATVOU_CRDRFlg" = 'DR' AND a."FATVOU_Id" = m."FATVOU_Id"), 0) AS "Debit",
        COALESCE(
            CASE 
                WHEN (SELECT SUM(a."FATVOU_Amount")   
                      FROM "FA_T_Voucher" a  
                      INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                      WHERE a."FATVOU_CRDRFlg" = 'CR' AND a."FATVOU_Id" = m."FATVOU_Id") >
                     (SELECT SUM(a."FATVOU_Amount")  
                      FROM "FA_T_Voucher" a  
                      INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                      WHERE a."FATVOU_CRDRFlg" = 'DR' AND a."FATVOU_Id" = m."FATVOU_Id") 
                THEN   
                    (SELECT SUM(a."FATVOU_Amount")   
                     FROM "FA_T_Voucher" a  
                     INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                     WHERE a."FATVOU_CRDRFlg" = 'CR' AND a."FATVOU_Id" = m."FATVOU_Id") -
                    (SELECT SUM(a."FATVOU_Amount")  
                     FROM "FA_T_Voucher" a  
                     INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                     WHERE a."FATVOU_CRDRFlg" = 'DR' AND a."FATVOU_Id" = m."FATVOU_Id") 
                ELSE  
                    ((SELECT SUM(a."FATVOU_Amount")   
                      FROM "FA_T_Voucher" a  
                      INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                      WHERE a."FATVOU_CRDRFlg" = 'DR' AND a."FATVOU_Id" = m."FATVOU_Id") -
                     (SELECT SUM(a."FATVOU_Amount")  
                      FROM "FA_T_Voucher" a  
                      INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"  
                      WHERE a."FATVOU_CRDRFlg" = 'CR' AND a."FATVOU_Id" = m."FATVOU_Id"))
            END, 0) AS "TotalBalance"
    FROM "FA_T_Voucher" m  
    INNER JOIN "FA_M_Ledger" n ON m."FAMLED_Id" = n."FAMLED_Id"  
    INNER JOIN "FA_M_Voucher" o ON m."FAMVOU_Id" = o."FAMVOU_Id"  
    INNER JOIN "Monthrecord" p ON p."MonthOrder" = EXTRACT(MONTH FROM o."FAMVOU_VoucherDate")::INTEGER  
    WHERE m."FAMLED_Id" = p_FAMLED_Id AND o."IMFY_Id" = p_IMFY_Id;
    
    RETURN;
END;
$$;