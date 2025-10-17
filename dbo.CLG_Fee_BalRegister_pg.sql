CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_BalRegister"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id bigint,
    p_FMG_Id text,
    p_FMH_Id text,
    p_AMCST_Id text
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "AMCO_Id" bigint,
    "AMB_Id" bigint,
    "AMSE_Id" bigint,
    "ACMS_Id" bigint,
    "StudentName" text,
    "AMCST_FatherName" text,
    "AMCST_AdmNo" text,
    "AMCST_RegistrationNo" text,
    "FMH_FeeName" text,
    "FYP_ReceiptNo" text,
    "FYPPM_TransactionTypeFlag" text,
    "Amount" numeric,
    "FYP_DOE" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamicsql text;
BEGIN

    IF p_ACMS_Id > 0 THEN
        
        v_Dynamicsql := 'SELECT a."AMCST_Id",a."AMCO_Id", a."AMB_Id", a."AMSE_Id",a."ACMS_Id",(COALESCE(b."AMCST_FirstName",'''')|| '' ''||COALESCE(b."AMCST_MiddleName",'''')||'' ''||COALESCE(b."AMCST_LastName",'''')) AS "StudentName",
b."AMCST_FatherName", b."AMCST_AdmNo",b."AMCST_RegistrationNo",l."FMH_FeeName",h."FYP_ReceiptNo","FYPP"."FYPPM_TransactionTypeFlag",SUM(i."FTCP_PaidAmount") AS "Amount", TO_CHAR(h."FYP_ReceiptDate",''DD/MM/YYYY'') AS "FYP_DOE"
FROM "clg"."Adm_College_Yearly_Student" a 
INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id"=b."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id"=a."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id"=a."AMSE_Id"
INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id"=a."ASMAY_Id"
INNER JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id"= a."AMCST_Id"
INNER JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id"=g."FYP_Id"
INNER JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id"=h."FYP_Id"
INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id"=i."FCMAS_Id"
INNER JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id"=j."FCMA_Id"
INNER JOIN "Fee_Master_Head" l ON l."FMH_Id"=k."FMH_Id"
INNER JOIN "CLG"."Fee_Y_Payment_PaymentMode" "FYPP" ON "FYPP"."FYP_Id"=h."FYP_Id"
WHERE a."AMCO_Id"=' || p_AMCO_Id || ' AND a."AMB_Id"=' || p_AMB_Id || ' AND a."AMSE_Id"=' || p_AMSE_Id || ' AND k."FMG_Id" IN(' || p_FMG_Id || ') AND h."MI_Id"=' || p_MI_Id || ' AND h."ASMAY_Id"=' || p_ASMAY_Id || '
AND a."AMCST_Id" IN (' || p_AMCST_Id || ') AND a."ACMS_Id"=' || p_ACMS_Id || ' 
GROUP BY a."AMCST_Id",a."AMCO_Id", a."AMB_Id", a."AMSE_Id",a."ACMS_Id",(COALESCE(b."AMCST_FirstName",'''')|| '' ''||COALESCE(b."AMCST_MiddleName",'''')||'' ''||COALESCE(b."AMCST_LastName",'''')),b."AMCST_FatherName", b."AMCST_AdmNo",b."AMCST_RegistrationNo",l."FMH_FeeName",h."FYP_ReceiptNo","FYPP"."FYPPM_TransactionTypeFlag",h."FYP_ReceiptDate"';

    ELSE
        
        v_Dynamicsql := 'SELECT a."AMCST_Id",a."AMCO_Id", a."AMB_Id", a."AMSE_Id",a."ACMS_Id",(COALESCE(b."AMCST_FirstName",'''')|| '' ''||COALESCE(b."AMCST_MiddleName",'''')||'' ''||COALESCE(b."AMCST_LastName",'''')) AS "StudentName",
b."AMCST_FatherName", b."AMCST_AdmNo",b."AMCST_RegistrationNo",l."FMH_FeeName",h."FYP_ReceiptNo","FYPP"."FYPPM_TransactionTypeFlag",SUM(i."FTCP_PaidAmount") AS "Amount", TO_CHAR(h."FYP_ReceiptDate",''DD/MM/YYYY'') AS "FYP_DOE"
FROM "clg"."Adm_College_Yearly_Student" a 
INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id"=b."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id"=a."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id"=a."AMSE_Id"
INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id"=a."ASMAY_Id"
INNER JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id"= a."AMCST_Id"
INNER JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id"=g."FYP_Id"
INNER JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id"=h."FYP_Id"
INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id"=i."FCMAS_Id"
INNER JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id"=j."FCMA_Id"
INNER JOIN "Fee_Master_Head" l ON l."FMH_Id"=k."FMH_Id"
INNER JOIN "CLG"."Fee_Y_Payment_PaymentMode" "FYPP" ON "FYPP"."FYP_Id"=h."FYP_Id"
WHERE a."AMCO_Id"=' || p_AMCO_Id || ' AND a."AMB_Id"=' || p_AMB_Id || ' AND a."AMSE_Id"=' || p_AMSE_Id || ' AND k."FMG_Id" IN(' || p_FMG_Id || ') AND h."MI_Id"=' || p_MI_Id || ' AND h."ASMAY_Id"=' || p_ASMAY_Id || '
AND a."AMCST_Id" IN (' || p_AMCST_Id || ')  
GROUP BY a."AMCST_Id",a."AMCO_Id", a."AMB_Id", a."AMSE_Id",a."ACMS_Id",(COALESCE(b."AMCST_FirstName",'''')|| '' ''||COALESCE(b."AMCST_MiddleName",'''')||'' ''||COALESCE(b."AMCST_LastName",'''')),b."AMCST_FatherName", b."AMCST_AdmNo",b."AMCST_RegistrationNo",l."FMH_FeeName",h."FYP_ReceiptNo","FYPP"."FYPPM_TransactionTypeFlag",h."FYP_ReceiptDate"';

    END IF;

    RETURN QUERY EXECUTE v_Dynamicsql;

END;
$$;