CREATE OR REPLACE FUNCTION "dbo"."College_defaulters_report"(
    "fmg_id" TEXT,
    "ASMAY_ID" TEXT,
    "amco_ids" TEXT,
    "option" TEXT,
    "active" TEXT,
    "deactive" TEXT,
    "left" TEXT,
    "section" TEXT,
    "userid" TEXT,
    "amb_ids" TEXT,
    "amse_ids" TEXT
)
RETURNS TABLE(
    "AMCST_AdmNo" VARCHAR,
    "StudentName" TEXT,
    "AMB_BranchName" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "AMCST_Id" BIGINT,
    "AMCST_MobileNo" VARCHAR,
    "AMCST_emailId" VARCHAR,
    "AMCST_FatherName" VARCHAR,
    "totalbalance" NUMERIC,
    "paid" NUMERIC,
    "FMG_GroupName" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "AMCO_CourseName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "temp1" VARCHAR(200);
    "temp2" VARCHAR(200);
    "fmg_id_new" BIGINT;
    "amst_sol" TEXT;
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

    SELECT "MI_Id" INTO "mi" FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = "ASMAY_ID"::BIGINT;

    IF "active" = '1' AND "deactive" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag"=1) and ("clg"."Adm_Master_College_Student"."AMCST_SOL"=''S'') and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag"=1)';
    ELSIF "deactive" = '1' AND "active" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag"=1) and ("clg"."Adm_Master_College_Student"."AMCST_SOL"=''D'') and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag"=1)';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag"=0) and ("clg"."Adm_Master_College_Student"."AMCST_SOL"=''L'') and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag"=0)';
    ELSIF "active" = '1' AND "deactive" = '1' AND "left" = '0' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag"=1) and ("clg"."Adm_Master_College_Student"."AMCST_SOL" IN (''S'',''D'')) and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag"=1)';
    ELSIF "left" = '1' AND "active" = '1' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (0,1)) and ("clg"."Adm_Master_College_Student"."AMCST_SOL" IN (''L'',''S'')) and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag" IN (0,1))';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (0,1)) and ("clg"."Adm_Master_College_Student"."AMCST_SOL" IN (''L'',''D'')) and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag" IN (0,1))';
    ELSIF "left" = '0' AND "active" = '1' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("clg"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (1)) and ("clg"."Adm_Master_College_Student"."AMCST_SOL" IN (''S'',''D'')) and ("clg"."Adm_Master_College_Student"."AMCST_ActiveFlag" IN (1))';
    ELSIF "active" = '1' AND "deactive" = '1' AND "left" = '1' THEN
        "amst_sol" := 'and ("clg"."Adm_Master_College_Student"."AMCST_SOL" IN (''S'',''D'',''L'')) ';
    END IF;

    IF "option" = 'FSW' THEN
        "query" := '
SELECT distinct "clg"."Adm_Master_College_Student"."AMCST_AdmNo","AMCST_AdmNo","StudentName","AMB_BranchName","ACMS_SectionName","AMCST_Id","AMCST_MobileNo","AMCST_emailId","AMCST_FatherName","totalbalance","paid",null::VARCHAR as "FMG_GroupName",null::VARCHAR as "FMH_FeeName",null::VARCHAR as "AMCO_CourseName"
FROM (SELECT "clg"."Adm_Master_College_Student"."AMCST_AdmNo",COALESCE("clg"."Adm_Master_College_Student"."AMCST_FirstName",'''')|| '' ''||COALESCE("clg"."Adm_Master_College_Student"."AMCST_MiddleName",'''')||'' ''||COALESCE("clg"."Adm_Master_College_Student"."AMCST_LastName",'''') as "StudentName",
"AMB_BranchName","ACMS_SectionName","clg"."Adm_Master_College_Student"."AMCST_Id","clg"."Adm_Master_College_Student"."AMCST_MobileNo","AMCST_emailId","clg"."Adm_Master_College_Student"."AMCST_FatherName",SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "totalbalance",SUM("FCSS_PaidAmount") as "paid"
FROM "Fee_Master_Group"
INNER JOIN "clg"."Fee_College_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_College_Student_Status"."FMG_Id"
INNER JOIN "Fee_Master_Head" on "Fee_College_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
INNER JOIN "clg"."Adm_Master_College_Student" on "clg"."Adm_Master_College_Student"."AMCST_Id"="Fee_College_Student_Status"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" on "clg"."Adm_College_Yearly_Student"."AMCST_Id"="clg"."Adm_Master_College_Student"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Master_Section" on "clg"."Adm_College_Master_Section"."ACMS_Id"="clg"."Adm_College_Yearly_Student"."ACMS_Id"
INNER JOIN "clg"."Adm_Master_Branch" on "clg"."Adm_Master_Branch"."AMB_Id"="clg"."Adm_College_Yearly_Student"."AMB_Id"
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ')
AND ("Fee_College_Student_Status"."FMG_Id" in (' || "fmg_id" || '))
AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || "mi" || ')
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0)
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" in (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" in (' || "amb_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMSE_Id" in (' || "amse_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') ' || "amst_sol" || '
 group by "AMB_BranchName","ACMS_SectionName","clg"."Adm_Master_College_Student"."AMCST_Id","AMCST_MobileNo","AMCST_FatherName","AMCST_AdmNo","AMCST_emailId","AMCST_MiddleName","AMCST_LastName","AMCST_FirstName") sub';
        RAISE NOTICE '%', "query";

    ELSIF "option" = 'FGW' THEN
        "query" := '
SELECT null::VARCHAR as "AMCST_AdmNo",null::TEXT as "StudentName",null::VARCHAR as "AMB_BranchName",null::VARCHAR as "ACMS_SectionName",null::BIGINT as "AMCST_Id",null::VARCHAR as "AMCST_MobileNo",null::VARCHAR as "AMCST_emailId",null::VARCHAR as "AMCST_FatherName","totalbalance","paid","FMG_GroupName",null::VARCHAR as "FMH_FeeName",null::VARCHAR as "AMCO_CourseName"
FROM (SELECT DISTINCT "FMG_GroupName",SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "totalbalance",SUM("FCSS_PaidAmount") as "paid"
from "Fee_Master_Group"
INNER JOIN "clg"."Fee_College_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_College_Student_Status"."FMG_Id"
INNER JOIN "Fee_Master_Head" on "Fee_College_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
INNER JOIN "clg"."Adm_Master_College_Student" on "clg"."Adm_Master_College_Student"."AMCST_Id"="Fee_College_Student_Status"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" on "clg"."Adm_College_Yearly_Student"."AMCST_Id"="clg"."Adm_Master_College_Student"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Master_Section" on  "clg"."Adm_College_Master_Section"."ACMS_Id"="clg"."Adm_College_Yearly_Student"."ACMS_Id"
WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ')
AND ("Fee_College_Student_Status"."FMG_Id" in (' || "fmg_id" || '))
AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || "mi" || ')
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0)
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" in (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" in (' || "amb_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMSE_Id" in (' || "amse_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') ' || "amst_sol" || '
  group by  "FMG_GroupName") sub';
        RAISE NOTICE '%', "query";

    ELSIF "option" = 'FHW' THEN
        "query" := '
SELECT null::VARCHAR as "AMCST_AdmNo",null::TEXT as "StudentName",null::VARCHAR as "AMB_BranchName",null::VARCHAR as "ACMS_SectionName",null::BIGINT as "AMCST_Id",null::VARCHAR as "AMCST_MobileNo",null::VARCHAR as "AMCST_emailId",null::VARCHAR as "AMCST_FatherName","totalbalance","paid",null::VARCHAR as "FMG_GroupName","FMH_FeeName",null::VARCHAR as "AMCO_CourseName"
FROM (SELECT DISTINCT "FMH_FeeName",sum("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "totalbalance",sum("FCSS_PaidAmount") as "paid"
FROM "Fee_Master_Group"
INNER JOIN "clg"."Fee_College_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_College_Student_Status"."FMG_Id"
INNER JOIN "Fee_Master_Head" on "Fee_College_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
INNER JOIN "clg"."Adm_Master_College_Student" on "clg"."Adm_Master_College_Student"."AMCST_Id"="Fee_College_Student_Status"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" on "clg"."Adm_College_Yearly_Student"."AMCST_Id"="clg"."Adm_Master_College_Student"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Master_Section" on  "clg"."Adm_College_Master_Section"."ACMS_Id"="clg"."Adm_College_Yearly_Student"."ACMS_Id"
WHERE("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ')
AND ("Fee_College_Student_Status"."FMG_Id" in (' || "fmg_id" || '))
AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || "mi" || ')
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0)
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" in (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" in (' || "amb_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMSE_Id" in (' || "amse_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') ' || "amst_sol" || '
 group by "FMH_FeeName") sub';
        RAISE NOTICE '%', "query";

    ELSIF "option" = 'FBW' THEN
        "query" := '
SELECT null::VARCHAR as "AMCST_AdmNo",null::TEXT as "StudentName","AMB_BranchName",null::VARCHAR as "ACMS_SectionName",null::BIGINT as "AMCST_Id",null::VARCHAR as "AMCST_MobileNo",null::VARCHAR as "AMCST_emailId",null::VARCHAR as "AMCST_FatherName","totalbalance","paid",null::VARCHAR as "FMG_GroupName",null::VARCHAR as "FMH_FeeName",null::VARCHAR as "AMCO_CourseName"
FROM (SELECT distinct "AMB_BranchName",SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "totalbalance",SUM("FCSS_PaidAmount") as "paid"
FROM "Fee_Master_Group"
INNER JOIN "clg"."Fee_College_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_College_Student_Status"."FMG_Id"
INNER JOIN "Fee_Master_Head" on "Fee_College_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
INNER JOIN "clg"."Adm_Master_College_Student" on "clg"."Adm_Master_College_Student"."AMCST_Id"="Fee_College_Student_Status"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" on "clg"."Adm_College_Yearly_Student"."AMCST_Id"="clg"."Adm_Master_College_Student"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Master_Section" on  "clg"."Adm_College_Master_Section"."ACMS_Id"="clg"."Adm_College_Yearly_Student"."ACMS_Id"
INNER JOIN "clg"."Adm_Master_Branch" on "clg"."Adm_Master_Branch"."AMB_Id"="clg"."Adm_College_Yearly_Student"."AMB_Id"
WHERE("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ')
AND ("Fee_College_Student_Status"."FMG_Id" in (' || "fmg_id" || '))
AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || "mi" || ')
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0)
AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" in (' || "amco_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" in (' || "amb_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMSE_Id" in (' || "amse_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') ' || "amst_sol" || '
 group by  "AMB_BranchName") sub';
        RAISE NOTICE '%', "query";

    ELSIF "option" = 'FCW' THEN
        "query" := '
SELECT null::VARCHAR as "AMCST_AdmNo",null::TEXT as "StudentName",null::VARCHAR as "AMB_BranchName",null::VARCHAR as "ACMS_SectionName",null::BIGINT as "AMCST_Id",null::VARCHAR as "AMCST_MobileNo",null::VARCHAR as "AMCST_emailId",null::VARCHAR as "AMCST_FatherName","totalbalance","paid",null::VARCHAR as "FMG_GroupName",null::VARCHAR as "FMH_FeeName","AMCO_CourseName"
FROM (SELECT distinct "AMCO_CourseName",SUM("clg"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "totalbalance",SUM("FCSS_PaidAmount") as "paid"
FROM "Fee_Master_Group"
INNER JOIN "clg"."Fee_College_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_College_Student_Status"."FMG_Id"
INNER JOIN "Fee_Master_Head" on "Fee_College_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id"
INNER JOIN "clg"."Adm_Master_College_Student" on "clg"."Adm_Master_College_Student"."AMCST_Id"="Fee_College_Student_Status"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" on "clg"."Adm_College_Yearly_Student"."AMCST_Id"="clg"."Adm_Master_College_Student"."AMCST_Id"
INNER JOIN "clg"."Adm_College_Master_Section" on  "clg"."Adm_College_Master_Section"."ACMS_Id"="clg"."Adm_College_Yearly_Student"."ACMS_Id"
INNER JOIN "clg"."Adm_Master_Course" on "clg"."Adm_Master_Course"."AMCO_Id"="clg"."Adm_College_Yearly_Student"."AMCO_Id"
WHERE("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ')
and ("Fee_College_Student_Status"."FMG_Id" in (' || "fmg_id" || '))
AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || "mi" || ')
AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0)
and ("clg"."Adm_College_Yearly_Student"."AMCO_Id" in (' || "amco_ids" || '))
and ("clg"."Adm_College_Yearly_Student"."AMB_Id" in (' || "amb_ids" || '))
AND ("clg"."Adm_College_Yearly_Student"."AMSE_Id" in (' || "amse_ids" || '))
AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') ' || "amst_sol" || '
  group by  "AMCO_CourseName") sub';
        RAISE NOTICE '%', "query";
    END IF;

    RETURN QUERY EXECUTE "query";
END;
$$;