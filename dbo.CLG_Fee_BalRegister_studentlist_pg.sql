CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_BalRegister_studentlist"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id bigint,
    p_FMG_Id text,
    p_FMH_Id text,
    p_AMCST_Id text,
    p_fyp_Id text,
    p_FromDate varchar(10),
    p_ToDate varchar(10)
)
RETURNS TABLE(
    "AMCST_Id" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamicsql text;
    v_str1 text;
    v_datecompare text;
    v_StudentIds text;
BEGIN
    
    IF (p_FromDate != '' AND p_ToDate != '') AND (p_fyp_Id = '0' OR p_fyp_Id = '') THEN
        v_datecompare := ' and h."FYP_DOE"::date >= ''' || p_FromDate || '''::date and h."FYP_DOE"::date <= ''' || p_ToDate || '''::date ';
    ELSIF (p_FromDate = '' AND p_ToDate = '') AND p_fyp_Id != '0' THEN
        v_datecompare := ' and h."FYP_Id" IN (' || p_fyp_Id || ') ';
    ELSE
        v_datecompare := '';
    END IF;
    
    IF (p_AMCO_Id = 0 AND p_AMB_Id = 0 AND p_AMSE_Id = 0) THEN
        v_str1 := ' ';
    ELSIF (p_AMCO_Id != 0 AND p_AMB_Id = 0 AND p_AMSE_Id = 0) THEN
        v_str1 := 'a."AMCO_Id"=' || p_AMCO_Id::varchar || ' and ';
    ELSIF (p_AMCO_Id = 0 AND p_AMB_Id != 0 AND p_AMSE_Id = 0) THEN
        v_str1 := 'a."AMB_Id"=' || p_AMB_Id::varchar || ' and ';
    ELSIF (p_AMCO_Id != 0 AND p_AMB_Id = 0 AND p_AMSE_Id != 0) THEN
        v_str1 := 'a."AMCO_Id"=' || p_AMCO_Id::varchar || ' AND a."AMSE_Id"=' || p_AMSE_Id::varchar || ' and';
    ELSIF (p_AMCO_Id != 0 AND p_AMB_Id != 0 AND p_AMSE_Id = 0) THEN
        v_str1 := 'a."AMCO_Id"=' || p_AMCO_Id::varchar || ' and a."AMB_Id"=' || p_AMB_Id::varchar || ' and';
    ELSIF (p_AMCO_Id != 0 AND p_AMB_Id != 0 AND p_AMSE_Id != 0) THEN
        v_str1 := 'a."AMCO_Id"=' || p_AMCO_Id::varchar || ' and a."AMB_Id"=' || p_AMB_Id::varchar || ' AND a."AMSE_Id"=' || p_AMSE_Id::varchar || ' and ';
    ELSIF (p_AMCO_Id = 0 AND p_AMB_Id = 0 AND p_AMSE_Id != 0) THEN
        v_str1 := 'a."AMSE_Id"=' || p_AMSE_Id::varchar || ' and ';
    END IF;
    
    IF (p_AMCST_Id = '' OR p_AMCST_Id = '0') THEN
        v_StudentIds := '';
    ELSE
        v_StudentIds := 'and a."AMCST_Id" IN (' || p_AMCST_Id || ')';
    END IF;
    
    IF (p_ACMS_Id = 0) THEN
        
        v_Dynamicsql := 'select distinct a."AMCST_Id"
from "clg"."Adm_College_Yearly_Student" a 
inner join "clg"."Adm_Master_College_Student" b on a."AMCST_Id"=b."AMCST_Id"
inner join "clg"."Adm_Master_Course" c on c."AMCO_Id" = a."AMCO_Id"
inner join "clg"."Adm_Master_Branch" d on d."AMB_Id"=a."AMB_Id"
inner join "clg"."Adm_Master_Semester" e on e."AMSE_Id"=a."AMSE_Id"
inner join "Adm_School_M_Academic_Year" f on f."ASMAY_Id"=a."ASMAY_Id"
inner join "clg"."Fee_Y_Payment_College_Student" g on g."AMCST_Id"= a."AMCST_Id" and g."ASMAY_Id"=f."ASMAY_Id"
inner join "clg"."Fee_Y_Payment" h on h."FYP_Id"=g."FYP_Id"
inner join "clg"."Fee_T_College_Payment" i on i."FYP_Id"=h."FYP_Id"
inner join "clg"."Fee_College_Master_Amount_Semesterwise" j on j."FCMAS_Id"=i."FCMAS_Id"
inner join "clg"."Fee_College_Master_Amount" k on k."FCMA_Id"=j."FCMA_Id"
inner join "Fee_Master_Head" l on l."FMH_Id"=k."FMH_Id"
inner join "CLG"."Fee_Y_Payment_PaymentMode" FYPP ON FYPP."FYP_Id"=h."FYP_Id"
where ' || v_str1 || ' k."FMG_Id" IN (' || p_FMG_Id || ') and h."MI_Id"=' || p_MI_Id::varchar || ' and h."ASMAY_Id"=' || p_ASMAY_Id::varchar || ' 
and k."ASMAY_Id"=' || p_ASMAY_Id::varchar || ' and a."ASMAY_Id"=' || p_ASMAY_Id::varchar || ' ' || v_StudentIds || '
and "FTCP_PaidAmount">0 ' || v_datecompare || ' group by a."AMCST_Id",a."AMCO_Id", a."AMB_Id", a."AMSE_Id",a."ACMS_Id",(COALESCE(b."AMCST_FirstName",'''')|| '' ''||COALESCE(b."AMCST_MiddleName",'''')||'' ''||COALESCE(b."AMCST_LastName",'''')),b."AMCST_FatherName", b."AMCST_AdmNo",b."AMCST_RegistrationNo",d."AMB_BranchName",e."AMSE_SEMName",l."FMH_FeeName",h."FYP_ReceiptNo",FYPP."FYPPM_TransactionTypeFlag",h."FYP_ReceiptDate"';
        
    END IF;
    
    RETURN QUERY EXECUTE v_Dynamicsql;
    
END;
$$;