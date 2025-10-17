CREATE OR REPLACE FUNCTION "dbo"."Fee_Detailed_Report"(
    "mi_id" TEXT,
    "asmay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT,
    "acms_id" TEXT,
    "type" TEXT,
    "fmg_id" TEXT,
    "from_date" TEXT,
    "to_date" TEXT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "Amount1" NUMERIC,
    "Amount2" NUMERIC,
    "Date1" TIMESTAMP,
    "Date2" TIMESTAMP,
    "Field1" TEXT,
    "Field2" TEXT,
    "Field3" TEXT,
    "Field4" TEXT,
    "Field5" TEXT,
    "SQLQuery" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql1head" TEXT;
    "date" TEXT;
BEGIN

    IF "type" = 'OB' THEN
    
        "date" := 'TO_DATE("CLG"."Fee_College_Master_Opening_Balance"."FCMOB_EntryDate"::TEXT, ''YYYY-MM-DD'') BETWEEN TO_DATE(''' || "from_date" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''', ''DD/MM/YYYY'')';
        
        "sql1head" := 'SELECT "CLG"."Adm_Master_College_Student"."AMCST_FirstName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_MiddleName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_LastName" as "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo", "CLG"."Fee_College_Master_Opening_Balance"."FCMOB_Student_Due", "CLG"."Fee_College_Master_Opening_Balance"."FCMOB_Institution_Due", "FCMOB_EntryDate", NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT FROM "CLG"."Adm_Master_College_Student" INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" INNER JOIN "CLG"."Fee_College_Master_Opening_Balance" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Fee_College_Master_Opening_Balance"."AMCST_Id" AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Master_Opening_Balance"."ASMAY_Id" WHERE "CLG"."Fee_College_Master_Opening_Balance"."MI_Id" = ' || "mi_id" || ' AND "CLG"."Fee_College_Master_Opening_Balance"."ASMAY_Id" = ' || "asmay_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = ' || "amco_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = ' || "amb_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = ' || "amse_id" || ' AND "CLG"."Adm_College_Yearly_Student"."ACMS_Id" IN (' || "acms_id" || ') AND "FCMOB_ActiveFlg" = TRUE AND "CLG"."Fee_College_Master_Opening_Balance"."fmg_id" IN (' || "fmg_id" || ') AND ' || "date";
    
    END IF;

    IF "type" = 'WO' THEN
    
        "date" := 'TO_DATE("CLG"."Fee_College_Student_WaivedOff"."FCSWO_Date"::TEXT, ''YYYY-MM-DD'') BETWEEN TO_DATE(''' || "from_date" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''', ''DD/MM/YYYY'')';
        
        "sql1head" := 'SELECT "CLG"."Adm_Master_College_Student"."AMCST_FirstName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_MiddleName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_LastName" as "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo", "CLG"."Fee_College_Student_WaivedOff"."FCSWO_WaivedOffAmount", NULL::NUMERIC, "FCSWO_Date", NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT FROM "CLG"."Adm_Master_College_Student" INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" INNER JOIN "CLG"."Fee_College_Student_WaivedOff" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Fee_College_Student_WaivedOff"."AMCST_Id" AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Student_WaivedOff"."ASMAY_Id" WHERE "CLG"."Fee_College_Student_WaivedOff"."MI_Id" = ' || "mi_id" || ' AND "CLG"."Fee_College_Student_WaivedOff"."ASMAY_Id" = ' || "asmay_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = ' || "amco_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = ' || "amb_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = ' || "amse_id" || ' AND "CLG"."Adm_College_Yearly_Student"."ACMS_Id" IN (' || "acms_id" || ') AND "FCSWO_ActiveFlag" = TRUE AND "CLG"."Fee_College_Student_WaivedOff"."fmg_id" IN (' || "fmg_id" || ') AND ' || "date";
    
    END IF;

    IF "type" = 'CB' THEN
    
        "date" := 'TO_DATE("CLG"."Fee_College_Cheque_Bounce"."FCCB_Date"::TEXT, ''YYYY-MM-DD'') BETWEEN TO_DATE(''' || "from_date" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''', ''DD/MM/YYYY'')';
        
        "sql1head" := 'SELECT "CLG"."Adm_Master_College_Student"."AMCST_FirstName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_MiddleName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_LastName" as "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo", "CLG"."Fee_College_Cheque_Bounce"."FCCB_Amount", NULL::NUMERIC, "FCCB_Date", NULL::TIMESTAMP, "FCCB_Remarks", NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT FROM "CLG"."Adm_Master_College_Student" INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" INNER JOIN "CLG"."Fee_College_Cheque_Bounce" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Fee_College_Cheque_Bounce"."AMCST_Id" AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Cheque_Bounce"."ASMAY_Id" WHERE "CLG"."Fee_College_Cheque_Bounce"."MI_Id" = ' || "mi_id" || ' AND "CLG"."Fee_College_Cheque_Bounce"."ASMAY_Id" = ' || "asmay_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = ' || "amco_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = ' || "amb_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = ' || "amse_id" || ' AND "CLG"."Adm_College_Yearly_Student"."ACMS_Id" IN (' || "acms_id" || ') AND ' || "date";
    
    END IF;

    IF "type" = 'RF' THEN
    
        "date" := 'TO_DATE("CLG"."Fee_College_Refund"."FCR_Date"::TEXT, ''YYYY-MM-DD'') BETWEEN TO_DATE(''' || "from_date" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "to_date" || ''', ''DD/MM/YYYY'')';
        
        "sql1head" := 'SELECT "CLG"."Adm_Master_College_Student"."AMCST_FirstName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_MiddleName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_LastName" as "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo", "CLG"."Fee_College_Refund"."FCR_RefundAmount", NULL::NUMERIC, "FCR_Date", "FCR_ChequeDDDate", "FCR_ModeOfPayment", "FCR_ChequeDDNo", "FCR_Bank", "FCR_RefundRemarks", NULL::TEXT FROM "CLG"."Adm_Master_College_Student" INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" INNER JOIN "CLG"."Fee_College_Refund" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Fee_College_Refund"."AMCST_Id" AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Refund"."ASMAY_Id" WHERE "CLG"."Fee_College_Refund"."MI_Id" = ' || "mi_id" || ' AND "CLG"."Fee_College_Refund"."ASMAY_Id" = ' || "asmay_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = ' || "amco_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = ' || "amb_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = ' || "amse_id" || ' AND "CLG"."Adm_College_Yearly_Student"."ACMS_Id" IN (' || "acms_id" || ') AND "CLG"."Fee_College_Refund"."fmg_id" IN (' || "fmg_id" || ') AND ' || "date";
    
    END IF;

    IF "type" = 'EX' THEN
    
        "sql1head" := 'SELECT "CLG"."Adm_Master_College_Student"."AMCST_FirstName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_MiddleName" || '' '' || "CLG"."Adm_Master_College_Student"."AMCST_LastName" as "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo", "CLG"."Fee_College_Student_Status"."FCSS_PaidAmount", NULL::NUMERIC, NULL::TIMESTAMP, NULL::TIMESTAMP, "Fee_Master_Head"."FMH_FeeName", "Fee_T_Installment"."FTI_Name", NULL::TEXT, NULL::TEXT, NULL::TEXT FROM "CLG"."Adm_Master_College_Student" INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id" AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Student_Status"."ASMAY_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id" WHERE "CLG"."Fee_College_Student_Status"."MI_Id" = ' || "mi_id" || ' AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "asmay_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = ' || "amco_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMB_Id" = ' || "amb_id" || ' AND "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = ' || "amse_id" || ' AND "CLG"."Adm_College_Yearly_Student"."ACMS_Id" IN (' || "acms_id" || ') AND "FMH_Flag" = ''E'' AND "CLG"."Fee_College_Student_Status"."fmg_id" IN (' || "fmg_id" || ')';
    
    END IF;

    RETURN QUERY EXECUTE "sql1head";
    
    RETURN QUERY SELECT NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::NUMERIC, NULL::TIMESTAMP, NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, "sql1head";

END;
$$;