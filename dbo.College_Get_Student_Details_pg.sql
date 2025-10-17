
CREATE OR REPLACE FUNCTION "clg"."College_Get_Student_Details"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_AMCST_Id" TEXT,
    "p_totdays" BIGINT
)
RETURNS TABLE(
    "studentname" TEXT,
    "admno" TEXT,
    "regno" TEXT,
    "doa" TEXT,
    "balancefee" BIGINT,
    "totalfeepaid" BIGINT,
    "totalfee" BIGINT,
    "refund" BIGINT,
    "cancel" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_studentname" TEXT;
    "v_admno" TEXT;
    "v_regno" TEXT;
    "v_doa" TEXT;
    "v_paid" BIGINT;
    "v_balance" BIGINT;
    "v_totalfee" BIGINT;
    "v_refundper" BIGINT;
    "v_cancelper" BIGINT;
BEGIN
    SELECT 
        (COALESCE(a."AMCST_FirstName", '') || COALESCE(a."AMCST_MiddleName", '') || COALESCE(a."AMCST_LastName", '')),
        a."AMCST_AdmNo",
        a."AMCST_RegistrationNo",
        TO_CHAR(a."AMCST_Date", 'DD/MM/YYYY')
    INTO 
        "v_studentname",
        "v_admno",
        "v_regno",
        "v_doa"
    FROM "clg"."Adm_Master_College_Student" a
    INNER JOIN "clg"."Adm_Master_Course" b ON a."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" c ON c."AMB_Id" = a."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" d ON d."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
    WHERE a."MI_Id" = "p_MI_Id" 
        AND a."AMCO_Id" = "p_AMCO_Id" 
        AND a."AMB_Id" = "p_AMB_Id" 
        AND a."AMSE_Id" = "p_AMSE_Id" 
        AND a."AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND a."AMCST_Id" = "p_AMCST_Id";

    SELECT 
        SUM("FCSS_ToBePaid"),
        SUM("FCSS_PaidAmount"),
        SUM("FCSS_CurrentYrCharges")
    INTO 
        "v_balance",
        "v_paid",
        "v_totalfee"
    FROM "clg"."Fee_College_Student_Status"
    WHERE "ASMAY_Id" = "p_ASMAY_Id" 
        AND "AMCST_Id" = "p_AMCST_Id";

    SELECT 
        "ACACC_RefundAmountPer",
        "ACACC_CancellationPer"
    INTO 
        "v_refundper",
        "v_cancelper"
    FROM "clg"."Adm_College_AC_Config"
    WHERE "MI_Id" = "p_MI_Id" 
        AND ("p_totdays" BETWEEN "ACACC_FromDays" AND "ACACC_ToDays");

    RETURN QUERY
    SELECT 
        "v_studentname",
        "v_admno",
        "v_regno",
        "v_doa",
        "v_balance",
        "v_paid",
        "v_totalfee",
        "v_refundper",
        "v_cancelper";

    RETURN;
END;
$$;