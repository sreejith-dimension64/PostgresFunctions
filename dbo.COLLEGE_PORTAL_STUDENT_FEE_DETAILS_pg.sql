CREATE OR REPLACE FUNCTION "dbo"."COLLEGE_PORTAL_STUDENT_FEE_DETAILS"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@AMCST_Id" BIGINT,
    "@fromdate" TEXT,
    "@todate" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "AMCST_Id" BIGINT,
    "studentName" TEXT,
    "AMCST_AdmNo" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "FYP_DOE" TIMESTAMP,
    "FYP_ReceiptNo" VARCHAR,
    "FYP_TotalPaidAmount" NUMERIC,
    "FYP_PayModeType" VARCHAR,
    "FYP_ReceiptDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "Yr"."ASMAY_Year",
        "CS"."AMCST_Id",
        COALESCE("AMCST_FirstName", '') || '' || COALESCE("AMCST_MiddleName", '') || '' || COALESCE("AMCST_LastName", '') AS "studentName",
        "CS"."AMCST_AdmNo",
        "AMCO_CourseName",
        "AMB_BranchName",
        "AMSE_SEMName",
        "FYP_DOE",
        "FYP_ReceiptNo",
        "FYP"."FYP_TotalPaidAmount",
        "FYP_PayModeType",
        "FYP"."FYP_ReceiptDate"
    FROM "clg"."Adm_Master_College_Student" "CS"
    INNER JOIN "clg"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "CS"."AMCST_Id"
    INNER JOIN "clg"."Fee_Y_Payment" "FYP" ON "YS"."ASMAY_Id" = "FYP"."ASMAY_Id"
    INNER JOIN "clg"."Fee_Y_Payment_College_Student" "FYCS" ON "FYP"."FYP_Id" = "FYCS"."FYP_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "Yr" ON "YS"."ASMAY_Id" = "Yr"."ASMAY_Id"
    INNER JOIN "Clg"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "YS"."AMB_Id" = "MB"."AMB_Id"
    INNER JOIN "Clg"."Adm_Master_Semester" "MS" ON "YS"."AMSE_Id" = "MS"."AMSE_Id"
    WHERE "CS"."MI_Id" = "@MI_Id" 
        AND "CS"."AMCST_SOL" = 'S' 
        AND "YS"."ASMAY_Id" = "@ASMAY_Id" 
        AND "YS"."AMCST_Id" = "@AMCST_Id"
        AND CAST("FYP"."FYP_ReceiptDate" AS DATE) BETWEEN CAST("@fromdate" AS DATE) AND CAST("@todate" AS DATE);
END;
$$;