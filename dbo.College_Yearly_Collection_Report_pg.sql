CREATE OR REPLACE FUNCTION "dbo"."College_Yearly_Collection_Report"(
    "Asmay_id" VARCHAR(100),
    "Mi_Id" VARCHAR(100),
    "amco_ids" TEXT,
    "amb_ids" TEXT,
    "amse_ids" TEXT,
    "fmg_id" TEXT,
    "option" VARCHAR(100)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "amst_sol" TEXT;
    "mi" BIGINT;
    "dt" BIGINT;
    "mt" BIGINT;
    "ftdd_day" BIGINT;
    "ftdd_month" BIGINT;
    "endyr" BIGINT;
    "startyr" BIGINT;
    "duedate" TIMESTAMP;
    "duedate1" TIMESTAMP;
    "fromdate" TIMESTAMP;
    "todate" TIMESTAMP;
    "oResult" VARCHAR(50);
    "days" VARCHAR(50);
    "months" VARCHAR(50);
    "query" TEXT;
    "date" TEXT;
    "str1" TEXT;
BEGIN
    "amst_sol" := '';
    "mi" := 0;
    "ftdd_day" := 0;
    "ftdd_month" := 0;
    "endyr" := 0;
    "startyr" := 0;
    "days" := '0';
    "months" := '0';
    "dt" := 0;
    "mt" := 0;

    IF "option" = 'FSW' THEN
        "query" := 'SELECT (COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '' '') || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '''') || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '' '')) AS "StudentName",
        "CLG"."Adm_Master_Course"."AMCO_CourseName", "CLG"."Adm_Master_Branch"."AMB_BranchName" AS "ASMCL_ClassName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", "Adm_Master_Semester"."AMSE_SEMName", "CLG"."Adm_Master_College_Student"."AMCST_MobileNo",
        (SUM("CLG"."Fee_College_Student_Status"."FCSS_PaidAmount") - SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount")) AS "FCSS_PaidAmount",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "balance", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "concession",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_WaivedAmount") AS "waived", SUM("CLG"."Fee_College_Student_Status"."FCSS_RebateAmount") AS "rebate", SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount") AS "fine", SUM("CLG"."Fee_College_Student_Status"."FCSS_CurrentYrCharges") AS "totalpayable",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_OBArrearAmount") AS "openingbalnce"
        FROM "CLG"."Fee_College_Student_Status"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Fee_College_Student_Status"."Amcst_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" ON "Adm_Master_Course"."AMCO_Id" = "CLG"."Adm_College_Yearly_Student"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ON "Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id"
        INNER JOIN "Fee_Master_Group" ON "CLG"."Fee_College_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Status"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Student_Status"."FTI_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
        WHERE ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "Asmay_id" || ') AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "Mi_Id" || ') AND ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "Asmay_id" || ')
        AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND "Adm_Master_Course"."AMCO_Id" IN (' || "amco_ids" || ')
        AND "Adm_Master_Branch"."AMB_Id" IN (' || "amb_ids" || ')
        AND "Adm_Master_Semester"."AMSE_Id" IN (' || "amse_ids" || ') AND ("CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" = 1)
        GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_FirstName", "CLG"."Adm_Master_College_Student"."AMCST_MiddleName", "CLG"."Adm_Master_College_Student"."AMCST_LastName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", "Adm_Master_Course"."AMCO_CourseName", "Adm_Master_Semester"."AMSE_SEMName",
        "CLG"."Adm_Master_Branch"."AMB_BranchName", "CLG"."Adm_Master_College_Student"."AMCST_MobileNo"
        HAVING SUM("CLG"."Fee_College_Student_Status"."FCSS_PaidAmount") > 0 OR SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") > 0 OR SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") > 0 OR SUM("CLG"."Fee_College_Student_Status"."FCSS_WaivedAmount") > 0 OR SUM("CLG"."Fee_College_Student_Status"."FCSS_RebateAmount") > 0 OR SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount") > 0 OR SUM("CLG"."Fee_College_Student_Status"."FCSS_CurrentYrCharges") > 0';

    ELSIF "option" = 'FGW' THEN
        "query" := 'SELECT DISTINCT "dbo"."Fee_Master_Group"."FMG_GroupName", (SUM("CLG"."Fee_College_Student_Status"."FCSS_PaidAmount") - SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount")) AS "FCSS_PaidAmount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "balance", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "concession", SUM("CLG"."Fee_College_Student_Status"."FCSS_WaivedAmount") AS "waived", SUM("CLG"."Fee_College_Student_Status"."FCSS_RebateAmount") AS "rebate",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount") AS "fine", SUM("CLG"."Fee_College_Student_Status"."FCSS_TotalCharges") AS "totalpayable", SUM("CLG"."Fee_College_Student_Status"."FCSS_OBArrearAmount") AS "openingbalnce"
        FROM "CLG"."Fee_College_Student_Status"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id"
        INNER JOIN "dbo"."Fee_Master_Group" ON "CLG"."Fee_College_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
        INNER JOIN "dbo"."Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "Adm_College_Yearly_Student"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "Adm_College_Yearly_Student"."AMCO_Id"
        WHERE ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "Asmay_id" || ') AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "Mi_Id" || ') AND
        ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "Asmay_id" || ') AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "Mi_Id" || ')
        AND "Adm_Master_Course"."AMCO_Id" IN (' || "amco_ids" || ')
        AND "Adm_Master_Branch"."AMB_Id" IN (' || "amb_ids" || ')
        AND "Adm_Master_Semester"."AMSE_Id" IN (' || "amse_ids" || ')
        GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';

    ELSIF "option" = 'FHW' THEN
        "query" := 'SELECT DISTINCT "dbo"."Fee_Master_Head"."FMH_FeeName", (SUM("CLG"."Fee_College_Student_Status"."FCSS_PaidAmount") - SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount")) AS "FCSS_PaidAmount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "balance", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "concession", SUM("CLG"."Fee_College_Student_Status"."FCSS_WaivedAmount") AS "waived", SUM("CLG"."Fee_College_Student_Status"."FCSS_RebateAmount") AS "rebate",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_FineAmount") AS "fine", SUM("CLG"."Fee_College_Student_Status"."FCSS_TotalCharges") AS "totalpayable", SUM("CLG"."Fee_College_Student_Status"."FCSS_OBArrearAmount") AS "openingbalnce"
        FROM "CLG"."Fee_College_Student_Status"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id"
        INNER JOIN "dbo"."Fee_Master_Group" ON "CLG"."Fee_College_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
        INNER JOIN "dbo"."Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "Adm_College_Yearly_Student"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "Adm_College_Yearly_Student"."AMCO_Id"
        WHERE ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "Asmay_id" || ') AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "Mi_Id" || ') AND
        ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "Asmay_id" || ') AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "Mi_Id" || ')
        AND "Adm_Master_Course"."AMCO_Id" IN (' || "amco_ids" || ')
        AND "Adm_Master_Branch"."AMB_Id" IN (' || "amb_ids" || ')
        AND "Adm_Master_Semester"."AMSE_Id" IN (' || "amse_ids" || ')
        GROUP BY "dbo"."Fee_Master_Head"."FMH_FeeName"';

    ELSIF "option" = 'STRMW' THEN
        "query" := 'SELECT DISTINCT "b"."AMCST_Id",
        SUM("a"."FCSS_OBArrearAmount") AS "Arrear", SUM("a"."FCSS_OBExcessAmount") AS "Excess", SUM("a"."FCSS_ToBePaid") AS "Balance",
        SUM("a"."FCSS_PaidAmount") AS "Paid",
        SUM("a"."FCSS_ConcessionAmount") AS "Concession", SUM("a"."FCSS_TotalCharges") AS "Charges", SUM("a"."FCSS_OBArrearAmount") AS "openingbalnce",
        (COALESCE("b"."AMCST_FirstName", '' '') || '' '' || COALESCE("b"."AMCST_MiddleName", '' '') || '' '' || COALESCE("b"."AMCST_LastName", '' '')) AS "StudentName",
        "l"."AMSE_SEMName" AS "ASMCL_ClassName", "b"."AMCST_AdmNo"
        FROM "CLG"."Fee_College_Student_Status" "a"
        INNER JOIN "CLG"."Adm_Master_College_Student" "b" ON "a"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "c" ON "b"."AMCST_Id" = "c"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "e" ON "e"."AMCO_id" = "c"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "c"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "l" ON "l"."AMSE_Id" = "c"."AMSE_Id"
        INNER JOIN "Fee_T_Installment" "g" ON "a"."FTI_Id" = "g"."FTI_Id"
        INNER JOIN "CLG"."Fee_College_Master_Amount" "h" ON "h"."MI_Id" = ' || "Mi_Id" || '
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "m" ON "m"."FCMA_Id" = "h"."FCMA_Id" AND "m"."FCMAS_Id" = "a"."FCMAS_Id"
        WHERE "a"."MI_Id" = ' || "Mi_Id" || ' AND "b"."MI_Id" = ' || "Mi_Id" || '
        AND "a"."ASMAY_Id" = ' || "Asmay_id" || ' AND "c"."ASMAY_Id" = ' || "Asmay_id" || ' AND "e"."MI_Id" = ' || "Mi_Id" || ' AND "e"."AMCO_Id" = "c"."AMCO_Id"
        AND "f"."MI_Id" = ' || "Mi_Id" || ' AND "f"."AMB_Id" = "c"."AMB_Id"
        AND "g"."MI_ID" = ' || "Mi_Id" || '
        AND "a"."FMG_Id" IN (' || "fmg_id" || ')
        AND "e"."AMCO_Id" IN (' || "amco_ids" || ')
        AND "f"."AMB_Id" IN (' || "amb_ids" || ')
        AND "l"."AMSE_Id" IN (' || "amse_ids" || ')
        GROUP BY "b"."AMCST_Id", "b"."AMCST_FirstName", "b"."AMCST_MiddleName", "b"."AMCST_LastName", "e"."AMCO_CourseName", "f"."AMB_BranchName", "b"."AMCST_AdmNo", "l"."AMSE_SEMName"
        HAVING SUM("a"."FCSS_OBArrearAmount") > 0 OR SUM("a"."FCSS_OBExcessAmount") > 0 OR SUM("a"."FCSS_ToBePaid") > 0 OR SUM("a"."FCSS_PaidAmount") > 0
        OR SUM("a"."FCSS_ConcessionAmount") > 0 OR SUM("a"."FCSS_CurrentYrCharges") > 0
        ORDER BY "StudentName"';

    ELSIF "option" = 'CTC' THEN
        "query" := 'SELECT DISTINCT "m"."AMSE_Id", "j"."FMH_Id", "FMH_FeeName",
        SUM("a"."FCSS_OBArrearAmount") AS "Arrear", SUM("a"."FCSS_OBExcessAmount") AS "Excess", SUM("a"."FCSS_ToBePaid") AS "TotalBalance", SUM("a"."FCSS_PaidAmount") AS "TotalPaid",
        SUM("a"."FCSS_ConcessionAmount") AS "TotalConcession", SUM("a"."FCSS_TotalCharges") AS "TotalCharges", SUM("a"."FCSS_OBArrearAmount") AS "openingbalnce",
        "e"."AMCO_CourseName", "f"."AMB_BranchName", "l"."AMSE_SEMName"
        FROM "CLG"."Fee_College_Student_Status" "a"
        INNER JOIN "CLG"."Adm_Master_College_Student" "b" ON "a"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "c" ON "b"."AMCST_Id" = "c"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "e" ON "c"."AMCO_Id" = "e"."AMCO_id"
        INNER JOIN "CLG"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "c"."AMB_Id"
        INNER JOIN "Fee_T_Installment" "g" ON "a"."FTI_Id" = "g"."FTI_Id"
        INNER JOIN "CLG"."Fee_College_Master_Amount" "h" ON "h"."MI_Id" = ' || "Mi_Id" || '
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "m" ON "m"."FCMA_Id" = "h"."FCMA_Id" AND "m"."FCMAS_Id" = "a"."FCMAS_Id"
        INNER JOIN "Fee_Master_Head" "j" ON "a"."FMH_Id" = "j"."FMH_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "l" ON "l"."AMSE_Id" = "c"."AMSE_Id"
        WHERE "a"."MI_Id" = ' || "Mi_Id" || ' AND "b"."MI_Id" = ' || "Mi_Id" || ' AND "a"."ASMAY_Id" = ' || "Asmay_id" || ' AND "c"."ASMAY_Id" = ' || "Asmay_id" || ' AND "e"."MI_Id" = ' || "Mi_Id" || '
        AND "f"."MI_Id" = ' || "Mi_Id" || '
        AND "g"."MI_ID" = ' || "Mi_Id" || '
        AND "a"."FMG_Id" IN (' || "fmg_id" || ')
        AND "e"."AMCO_Id" IN (' || "amco_ids" || ')
        AND "f"."AMB_Id" IN (' || "amb_ids" || ')
        AND "l"."AMSE_Id" IN (' || "amse_ids" || ')
        GROUP BY "FMH_FeeName", "j"."FMH_Id", "e"."AMCO_CourseName", "f"."AMB_BranchName", "l"."AMSE_SEMName", "m"."AMSE_Id"
        ORDER BY "m"."AMSE_Id"';
    END IF;

    RETURN QUERY EXECUTE "query";
END;
$$;