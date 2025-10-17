CREATE OR REPLACE FUNCTION "dbo"."installment_transaction_details_CLG"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_Amcst_id TEXT,
    p_fyp_id TEXT
)
RETURNS TABLE(
    "amcsT_FirstName" VARCHAR,
    "amcsT_MiddleName" VARCHAR,
    "amcsT_LastName" VARCHAR,
    "fmH_FeeName" VARCHAR,
    "fyP_ReceiptNo" VARCHAR,
    "ftcP_PaidAmount" NUMERIC,
    "ftcP_ConcessionAmount" NUMERIC,
    "ftcP_FineAmount" NUMERIC,
    "fyP_ReceiptDate" TIMESTAMP,
    "amcO_CourseName" VARCHAR,
    "amB_BranchName" VARCHAR,
    "amsE_SEMName" VARCHAR,
    "fyP_PayModeType" VARCHAR,
    "amcsT_Id" BIGINT,
    "amcsT_AdmNo" VARCHAR,
    "amcsT_RegistrationNo" VARCHAR,
    "fmH_Id" BIGINT,
    "amcsT_FatherName" VARCHAR,
    "amcsT_MotherName" VARCHAR,
    "fyP_Remarks" TEXT,
    "acysT_RollNo" VARCHAR,
    "fcsS_TotalCharges" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "CLG"."Adm_Master_College_Student"."AMCST_FirstName"::VARCHAR AS "amcsT_FirstName",
        "CLG"."Adm_Master_College_Student"."AMCST_MiddleName"::VARCHAR AS "amcsT_MiddleName",
        "CLG"."Adm_Master_College_Student"."AMCST_LastName"::VARCHAR AS "amcsT_LastName",
        "dbo"."Fee_Master_Head"."FMH_FeeName"::VARCHAR AS "fmH_FeeName",
        "CLG"."Fee_Y_Payment"."FYP_ReceiptNo"::VARCHAR AS "fyP_ReceiptNo",
        SUM("CLG"."Fee_T_College_Payment"."FTCP_PaidAmount") AS "ftcP_PaidAmount",
        SUM("CLG"."Fee_T_College_Payment"."FTCP_ConcessionAmount") AS "ftcP_ConcessionAmount",
        SUM("CLG"."Fee_T_College_Payment"."FTCP_FineAmount") AS "ftcP_FineAmount",
        "CLG"."Fee_Y_Payment"."FYP_ReceiptDate"::TIMESTAMP AS "fyP_ReceiptDate",
        "CLG"."Adm_Master_Course"."AMCO_CourseName"::VARCHAR AS "amcO_CourseName",
        "CLG"."Adm_Master_Branch"."AMB_BranchName"::VARCHAR AS "amB_BranchName",
        "CLG"."Adm_Master_Semester"."AMSE_SEMName"::VARCHAR AS "amsE_SEMName",
        "CLG"."Fee_Y_Payment"."FYP_PayModeType"::VARCHAR AS "fyP_PayModeType",
        "CLG"."Adm_Master_College_Student"."AMCST_Id"::BIGINT AS "amcsT_Id",
        "CLG"."Adm_Master_College_Student"."AMCST_AdmNo"::VARCHAR AS "amcsT_AdmNo",
        "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo"::VARCHAR AS "amcsT_RegistrationNo",
        "dbo"."Fee_Master_Head"."FMH_Id"::BIGINT AS "fmH_Id",
        "CLG"."Adm_Master_College_Student"."AMCST_FatherName"::VARCHAR AS "amcsT_FatherName",
        "CLG"."Adm_Master_College_Student"."AMCST_MotherName"::VARCHAR AS "amcsT_MotherName",
        "CLG"."Fee_Y_Payment"."FYP_Remarks"::TEXT AS "fyP_Remarks",
        "CLG"."Adm_College_Yearly_Student"."ACYST_RollNo"::VARCHAR AS "acysT_RollNo",
        "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Amount"::NUMERIC AS "fcsS_TotalCharges"
    FROM "CLG"."Adm_Master_College_Student"
    INNER JOIN "CLG"."Fee_Y_Payment_College_Student" 
        ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" 
        ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Course" 
        ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" 
        ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Branch"."AMB_Id"
    INNER JOIN "CLG"."Fee_Y_Payment" 
        ON "CLG"."Fee_Y_Payment_College_Student"."FYP_Id" = "CLG"."Fee_Y_Payment"."FYP_Id"
    INNER JOIN "CLG"."Fee_T_College_Payment" 
        ON "CLG"."Fee_Y_Payment"."FYP_Id" = "CLG"."Fee_T_College_Payment"."FYP_Id"
    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" 
        ON "CLG"."Fee_T_College_Payment"."FCMAS_Id" = "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
    INNER JOIN "CLG"."Fee_College_Master_Amount" 
        ON "CLG"."Fee_College_Master_Amount"."FCMA_Id" = "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" 
        ON "CLG"."Fee_College_Master_Amount_Semesterwise"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id"
    INNER JOIN "dbo"."Fee_Master_Head" 
        ON "CLG"."Fee_College_Master_Amount"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" 
        ON "dbo"."Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Master_Amount"."FTI_Id"
    INNER JOIN "dbo"."Fee_Master_Installment" 
        ON "dbo"."Fee_T_Installment"."FMI_Id" = "dbo"."Fee_Master_Installment"."FMI_Id"
    WHERE "CLG"."Adm_Master_College_Student"."AMCST_Id"::TEXT = p_Amcst_id
        AND "CLG"."Fee_Y_Payment"."FYP_Id"::TEXT = p_fyp_id
        AND "CLG"."Fee_Y_Payment"."MI_Id"::TEXT = p_MI_Id
        AND "CLG"."Adm_College_Yearly_Student"."ASMAY_ID"::TEXT = p_ASMAY_Id
        AND "CLG"."Adm_Master_College_Student"."AMCST_SOL" = 'S'
        AND "CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" = 1
    GROUP BY 
        "CLG"."Adm_Master_College_Student"."AMCST_FirstName",
        "CLG"."Adm_Master_College_Student"."AMCST_MiddleName",
        "CLG"."Adm_Master_College_Student"."AMCST_LastName",
        "dbo"."Fee_Master_Head"."FMH_FeeName",
        "CLG"."Fee_Y_Payment"."FYP_ReceiptNo",
        "CLG"."Fee_Y_Payment"."FYP_ReceiptDate",
        "CLG"."Adm_Master_Course"."AMCO_CourseName",
        "CLG"."Adm_Master_Branch"."AMB_BranchName",
        "CLG"."Fee_Y_Payment"."FYP_PayModeType",
        "CLG"."Adm_Master_College_Student"."AMCST_Id",
        "dbo"."Fee_Master_Installment"."FMI_Name",
        "CLG"."Adm_Master_College_Student"."AMCST_AdmNo",
        "CLG"."Adm_Master_College_Student"."AMCST_RegistrationNo",
        "dbo"."Fee_Master_Head"."FMH_Id",
        "CLG"."Adm_Master_College_Student"."AMCST_FatherName",
        "CLG"."Adm_Master_College_Student"."AMCST_MotherName",
        "CLG"."Adm_College_Yearly_Student"."ACYST_RollNo",
        "CLG"."Fee_Y_Payment"."FYP_Remarks",
        "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Amount",
        "CLG"."Adm_Master_Semester"."AMSE_SEMName";
END;
$$;