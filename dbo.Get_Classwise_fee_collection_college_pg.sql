CREATE OR REPLACE FUNCTION "clg"."Get_Classwise_fee_collection_college"(
    "@MI_Id" int,
    "@ASMAY_Id" int
)
RETURNS TABLE(
    "callected" numeric,
    "ballance" numeric,
    "concession" numeric,
    "waived" numeric,
    "rebate" numeric,
    "fine" numeric,
    "class" varchar,
    "classid" int,
    "AMB_Order" int,
    "receivable" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    RETURN QUERY
    SELECT 
        DISTINCT(SUM("clg"."Fee_College_Student_Status"."FCSS_PaidAmount") - SUM("clg"."Fee_College_Student_Status"."FCSS_FineAmount")) AS "callected",
        SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "ballance",
        SUM("clg"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "concession",
        SUM("clg"."Fee_College_Student_Status"."FCSS_WaivedAmount") AS "waived",
        SUM("clg"."Fee_College_Student_Status"."FCSS_RebateAmount") AS "rebate",
        SUM("clg"."Fee_College_Student_Status"."FCSS_FineAmount") AS "fine",
        "clg"."Adm_Master_Branch"."AMB_BranchName" AS "class",
        "clg"."Adm_Master_Branch"."AMB_Id" AS "classid",
        "clg"."Adm_Master_Branch"."AMB_Order",
        SUM("clg"."Fee_College_Student_Status"."FCSS_CurrentYrCharges") AS "receivable"
    FROM  
        "clg"."Fee_College_Student_Status"
    INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Fee_College_Student_Status"."AMCST_Id" = "clg"."Adm_College_Yearly_Student"."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Branch" ON "clg"."Adm_Master_Branch"."AMB_Id" = "clg"."Adm_College_Yearly_Student"."AMB_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "clg"."Fee_College_Student_Status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "clg"."Fee_College_Student_Status"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status"."FTI_Id"
    GROUP BY "clg"."Adm_Master_Branch"."AMB_BranchName", "clg"."Adm_Master_Branch"."AMB_Id", "clg"."Adm_Master_Branch"."AMB_Order";

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

END;
$$;