CREATE OR REPLACE FUNCTION "dbo"."Clg_StudentLedgerReport"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FMG_Id text,
    p_FMH_Id text,
    p_AMCST_Id bigint
)
RETURNS TABLE(
    "ASMAY_Year" varchar(200),
    "AMB_BranchName" varchar(300),
    "AMSE_SEMName" varchar(300),
    "StudentName" varchar(300),
    "AMCST_FatherName" varchar(300),
    "ACQ_QuotaName" varchar(300),
    "FMG_GroupName" varchar(200),
    "FMH_FeeName" varchar(200),
    "Receipt" varchar(200),
    "StudentFeesDue" decimal(18,2),
    "TotalCharges" decimal(18,2),
    "ConcessionAmount" decimal(18,2),
    "PaidAmount" decimal(18,2),
    "AdjustedAmount" decimal(18,2),
    "ExcessAmountAdjusted" decimal(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlQuery TEXT;
    v_ASMAY_Year varchar(200);
    v_AMB_BranchName varchar(300);
    v_AMSE_Id bigint;
    v_AMSE_SEMName varchar(300);
    v_StudentName varchar(300);
    v_AMCST_FatherName varchar(300);
    v_ACQ_QuotaName varchar(300);
    v_FMG_GroupName varchar(200);
    v_FMH_FeeName varchar(200);
    v_Receipt varchar(200);
    v_StudentFeesDue decimal(18,2);
    v_TotalCharges decimal(18,2);
    v_ConcessionAmount decimal(18,2);
    v_PaidAmount decimal(18,2);
    v_AdjustedAmount decimal(18,2);
    v_ExcessAmountAdjusted decimal(18,2);
    rec_fees RECORD;
BEGIN

    DROP TABLE IF EXISTS "StudentLedgerReport";

    CREATE TEMP TABLE "StudentLedgerReport"(
        "ASMAY_Year" varchar(200),
        "AMB_BranchName" varchar(300),
        "AMSE_SEMName" varchar(300),
        "StudentName" varchar(300),
        "AMCST_FatherName" varchar(300),
        "ACQ_QuotaName" varchar(300),
        "FMG_GroupName" varchar(200),
        "FMH_FeeName" varchar(200),
        "Receipt" varchar(200),
        "StudentFeesDue" decimal(18,2),
        "TotalCharges" decimal(18,2),
        "ConcessionAmount" decimal(18,2),
        "PaidAmount" decimal(18,2),
        "AdjustedAmount" decimal(18,2),
        "ExcessAmountAdjusted" decimal(18,2)
    ) ON COMMIT DROP;

    FOR v_ASMAY_Year, v_AMB_BranchName, v_AMSE_Id, v_AMSE_SEMName, v_StudentName, v_AMCST_FatherName, v_ACQ_QuotaName IN
        SELECT DISTINCT "ASMAY"."ASMAY_Year", "AMB"."AMB_BranchName", "AMS"."AMSE_Id", "AMS"."AMSE_SEMName",
               CONCAT("AMCS"."AMCST_FirstName", "AMCS"."AMCST_MiddleName", "AMCS"."AMCST_LastName") AS "StudentName",
               "AMCS"."AMCST_FatherName", "ACQ"."ACQ_QuotaName"
        FROM "CLG"."Adm_Master_College_Student" "AMCS"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" 
            AND "AMCS"."AMCST_SOL" = 'S' AND "AMCS"."AMCST_ActiveFlag" = 1 AND "ACYS"."ACYST_ActiveFlag" = 1 
            AND "AMCS"."MI_Id" = p_MI_Id
        INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "AMCS"."AMB_Id" 
            AND "AMB"."AMB_Id" = "ACYS"."AMB_Id" AND "AMB"."MI_Id" = p_MI_Id
        INNER JOIN "CLG"."Adm_Master_Semester" "AMS" ON "AMS"."AMSE_Id" = "AMCS"."AMSE_Id" 
            AND "AMS"."AMSE_Id" = "ACYS"."AMSE_Id" AND "AMS"."MI_Id" = p_MI_Id
        INNER JOIN "CLG"."Adm_College_Quota" "ACQ" ON "ACQ"."ACQ_Id" = "AMCS"."ACQ_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id" = p_MI_Id 
            AND "ASMAY"."ASMAY_Id" = p_ASMAY_Id
        WHERE "AMCS"."AMCST_Id" = p_AMCST_Id AND "AMCS"."MI_Id" = p_MI_Id AND "AMCS"."ASMAY_Id" = p_ASMAY_Id
    LOOP

        v_SqlQuery := 'SELECT "FMG"."FMG_GroupName", "FMH"."FMH_FeeName", 
            ("FYP"."FYP_ReceiptNo" || ''-'' || TO_CHAR("FYP"."FYP_DOE", ''DD/MM/YYYY'')) AS "Receipt",
            SUM("FCSS"."FCSS_OBArrearAmount") AS "StudentFeesDue",
            SUM("FCSS"."FCSS_TotalCharges") AS "TotalCharges",
            SUM("FCSS"."FCSS_ConcessionAmount") AS "ConcessionAmount",
            SUM("FTCP"."FTCP_PaidAmount") AS "PaidAmount",
            SUM("FCSS"."FCSS_AdjustedAmount") AS "AdjustedAmount",
            SUM("FCSS"."FCSS_ExcessAmountAdjusted") AS "ExcessAmountAdjusted"
            FROM "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS"
            INNER JOIN "CLG"."Fee_T_College_Payment" "FTCP" ON "FTCP"."FCMAS_Id" = "FCMAS"."FCMAS_Id" 
                AND "FCMAS"."MI_Id" = ' || p_MI_Id || ' AND "FCMAS"."AMSE_Id" = ' || v_AMSE_Id || '
            INNER JOIN "CLG"."Fee_Y_Payment" "FYP" ON "FYP"."FYP_Id" = "FTCP"."FYP_Id" 
                AND "FYP"."MI_Id" = ' || p_MI_Id || ' AND "FYP"."ASMAY_Id" = ' || p_ASMAY_Id || '
            INNER JOIN "CLG"."Fee_Y_Payment_College_Student" "FYPCS" ON "FYPCS"."FYP_Id" = "FYP"."FYP_Id" 
                AND "FYPCS"."FYP_Id" = "FTCP"."FYP_Id" AND "FYPCS"."ASMAY_Id" = ' || p_ASMAY_Id || '
            INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" ON "FCSS"."MI_Id" = ' || p_MI_Id || ' 
                AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id" AND "FCSS"."AMCST_Id" = "FYPCS"."AMCST_Id" 
                AND "FCSS"."AMCST_Id" = ' || p_AMCST_Id || '
            INNER JOIN "dbo"."Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" 
                AND "FMG"."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "dbo"."Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCSS"."FMH_Id" 
                AND "FMH"."MI_Id" = ' || p_MI_Id || '
            WHERE "FCSS"."MI_Id" = ' || p_MI_Id || ' AND "FCSS"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND "FCSS"."FMG_Id" IN (' || p_FMG_Id || ') AND "FCSS"."FMH_Id" IN (' || p_FMH_Id || ') 
                AND "FCSS"."AMCST_Id" = ' || p_AMCST_Id || '
            GROUP BY "FMG"."FMG_GroupName", "FMH"."FMH_FeeName", 
                ("FYP"."FYP_ReceiptNo" || ''-'' || TO_CHAR("FYP"."FYP_DOE", ''DD/MM/YYYY''))';

        FOR rec_fees IN EXECUTE v_SqlQuery
        LOOP
            v_FMG_GroupName := rec_fees."FMG_GroupName";
            v_FMH_FeeName := rec_fees."FMH_FeeName";
            v_Receipt := rec_fees."Receipt";
            v_StudentFeesDue := rec_fees."StudentFeesDue";
            v_TotalCharges := rec_fees."TotalCharges";
            v_ConcessionAmount := rec_fees."ConcessionAmount";
            v_PaidAmount := rec_fees."PaidAmount";
            v_AdjustedAmount := rec_fees."AdjustedAmount";
            v_ExcessAmountAdjusted := rec_fees."ExcessAmountAdjusted";

            INSERT INTO "StudentLedgerReport"(
                "ASMAY_Year", "AMB_BranchName", "AMSE_SEMName", "StudentName", "AMCST_FatherName", "ACQ_QuotaName",
                "FMG_GroupName", "FMH_FeeName", "Receipt", "StudentFeesDue", "TotalCharges", "ConcessionAmount",
                "PaidAmount", "AdjustedAmount", "ExcessAmountAdjusted"
            )
            VALUES(
                v_ASMAY_Year, v_AMB_BranchName, v_AMSE_SEMName, v_StudentName, v_AMCST_FatherName, v_ACQ_QuotaName,
                v_FMG_GroupName, v_FMH_FeeName, v_Receipt, v_StudentFeesDue, v_TotalCharges, v_ConcessionAmount,
                v_PaidAmount, v_AdjustedAmount, v_ExcessAmountAdjusted
            );
        END LOOP;

    END LOOP;

    RETURN QUERY SELECT * FROM "StudentLedgerReport";

END;
$$;