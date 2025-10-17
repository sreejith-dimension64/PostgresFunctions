CREATE OR REPLACE FUNCTION "dbo"."College_defaulters_report_old"(
    "fmg_id" TEXT,
    "ASMAY_ID" TEXT,
    "amco_ids" TEXT,
    "option" TEXT,
    "active" TEXT,
    "deactive" TEXT,
    "left" TEXT,
    "section" TEXT,
    "userid" TEXT,
    "amb_ids" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "temp1" VARCHAR(200);
    "temp2" VARCHAR(200);
    "fmg_id_new" BIGINT;
    "amst_sol" VARCHAR(1);
    "mi" TEXT;
    "dt" BIGINT;
    "mt" BIGINT;
    "ftdd_day" BIGINT;
    "ftdd_month" BIGINT;
    "endyr" BIGINT;
    "startyr" BIGINT;
    "duedate" TEXT;
    "duedate1" TEXT;
    "fromdate" DATE;
    "todate" DATE;
    "oResult" VARCHAR(50);
    "days" VARCHAR(550);
    "months" VARCHAR(550);
    "query" TEXT;
    "str1" TEXT;
    "mi_new" TEXT;
    "asmay_new" TEXT;
BEGIN

    "amst_sol" := '';
    "mi" := '0';
    "ftdd_day" := 0;
    "ftdd_month" := 0;
    "endyr" := 0;
    "startyr" := 0;
    "days" := '0';
    "months" := '0';
    "dt" := 0;
    "mt" := 0;

    IF "option" = 'FSW' THEN

        "query" := 'SELECT SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance, SUM("FCSS_PaidAmount") AS paid,
COALESCE("clg"."Adm_Master_College_Student"."AMCST_FirstName", '''') || '' '' || COALESCE("clg"."Adm_Master_College_Student"."AMCST_MiddleName", '''') || '' '' || COALESCE("clg"."Adm_Master_College_Student"."AMCST_LastName", '''') AS StudentName,
"clg"."Adm_Master_College_Student"."AMCST_AdmNo", "AMB_BranchName" AS ACMS_SectionName, 
"clg"."Adm_Master_College_Student"."AMCST_MobileNo", "AMCST_emailId", "clg"."Adm_Master_College_Student"."AMCST_FatherName" 
FROM "Fee_Master_Group" 
INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_College_Student_Status"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "Fee_College_Student_Status"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id" 
AND "clg"."Adm_College_Yearly_Student"."ASMAY_Id" = "clg"."Fee_College_Student_Status"."ASMAY_Id" 
INNER JOIN "clg"."Adm_College_Master_Section" ON "clg"."Adm_College_Master_Section"."ACMS_Id" = "clg"."Adm_College_Yearly_Student"."ACMS_Id" 
INNER JOIN "clg"."Adm_Master_Branch" ON "clg"."Adm_Master_Branch"."AMB_Id" = "clg"."Adm_College_Yearly_Student"."AMB_Id"
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') 
AND ("Fee_College_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
AND ("clg"."Fee_College_Student_Status"."MI_Id" = 19)  
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0) 
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "amb_ids" || ')) 
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND "ACYST_ActiveFlag" = 1
GROUP BY "AMB_BranchName", 
"clg"."Adm_Master_College_Student"."AMCST_MobileNo", "AMCST_FatherName", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_AdmNo", "AMCST_emailId"';

    ELSIF "option" = 'FGW' THEN

        "query" := 'SELECT SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance, SUM("FCSS_PaidAmount") AS paid, "FMG_GroupName"
FROM "Fee_Master_Group" 
INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_College_Student_Status"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "Fee_College_Student_Status"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Master_Section" ON "clg"."Adm_College_Master_Section"."ACMS_Id" = "clg"."Adm_College_Yearly_Student"."ACMS_Id" 
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') 
AND ("Fee_College_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
AND ("clg"."Fee_College_Student_Status"."MI_Id" = 19)  
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0) 
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "amb_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND "ACYST_ActiveFlag" = 1
GROUP BY "FMG_GroupName"';

    ELSIF "option" = 'FHW' THEN

        "query" := 'SELECT SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance, SUM("FCSS_PaidAmount") AS paid, "FMH_FeeName"
FROM "Fee_Master_Group" 
INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_College_Student_Status"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "Fee_College_Student_Status"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Master_Section" ON "clg"."Adm_College_Master_Section"."ACMS_Id" = "clg"."Adm_College_Yearly_Student"."ACMS_Id" 
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') 
AND ("Fee_College_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
AND ("clg"."Fee_College_Student_Status"."MI_Id" = 19)  
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0) 
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "amb_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND "ACYST_ActiveFlag" = 1
GROUP BY "FMH_FeeName"';

    ELSIF "option" = 'FBW' THEN

        "query" := 'SELECT SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance, SUM("FCSS_PaidAmount") AS paid, "AMB_BranchName"
FROM "Fee_Master_Group" 
INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_College_Student_Status"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "Fee_College_Student_Status"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Master_Section" ON "clg"."Adm_College_Master_Section"."ACMS_Id" = "clg"."Adm_College_Yearly_Student"."ACMS_Id" 
INNER JOIN "clg"."Adm_Master_Branch" ON "clg"."Adm_Master_Branch"."AMB_Id" = "clg"."Adm_College_Yearly_Student"."AMB_Id"
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') 
AND ("Fee_College_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
AND ("clg"."Fee_College_Student_Status"."MI_Id" = 19)  
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0) 
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "amb_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND "ACYST_ActiveFlag" = 1
GROUP BY "AMB_BranchName"';

    ELSIF "option" = 'FCW' THEN

        "query" := 'SELECT SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS totalbalance, SUM("FCSS_PaidAmount") AS paid, "AMCO_CourseName"
FROM "Fee_Master_Group" 
INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_College_Student_Status"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "Fee_College_Student_Status"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id" 
INNER JOIN "clg"."Adm_College_Master_Section" ON "clg"."Adm_College_Master_Section"."ACMS_Id" = "clg"."Adm_College_Yearly_Student"."ACMS_Id" 
INNER JOIN "clg"."Adm_Master_Course" ON "clg"."Adm_Master_Course"."AMCO_Id" = "clg"."Adm_College_Yearly_Student"."AMCO_Id"
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') 
AND ("Fee_College_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
AND ("clg"."Fee_College_Student_Status"."MI_Id" = 19)  
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0) 
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "amb_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND "ACYST_ActiveFlag" = 1
GROUP BY "AMCO_CourseName"';

    END IF;

    RETURN QUERY EXECUTE "query";

END;
$$;