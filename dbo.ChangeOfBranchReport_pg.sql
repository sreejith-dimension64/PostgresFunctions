CREATE OR REPLACE FUNCTION "dbo"."ChangeOfBranchReport" (
    "@MI_Id" TEXT, 
    "@ASMAY_Id" TEXT, 
    "@AMCO_Id" TEXT, 
    "@AMB_Id" TEXT
)
RETURNS TABLE (
    "name" TEXT,
    "oldregno" VARCHAR,
    "newregno" VARCHAR,
    "AMB_Id" INTEGER,
    "ACSCOB_AMB_Id" INTEGER,
    "fee" NUMERIC,
    "remarks" TEXT,
    "ACSCOB_COBDate" VARCHAR,
    "oldbranch" VARCHAR,
    "newbranch" VARCHAR,
    "oldsem" VARCHAR,
    "newsem" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "wherecondition" TEXT;
    "sqlquery" TEXT;
BEGIN

    IF "@AMCO_Id" = '0' THEN
        "wherecondition" := 'select "AMCO_Id" from "CLG"."Adm_Master_Course" where "MI_Id"=' || "@MI_Id" || ' and "AMCO_ActiveFlag"=1';
    ELSE
        "wherecondition" := "@AMCO_Id";
    END IF;

    "sqlquery" := 'SELECT (COALESCE("g"."AMCST_FirstName",'''') || '' '' || COALESCE("g"."AMCST_MiddleName",'''') || '' '' || COALESCE("g"."AMCST_LastName",'''')) as "name", 
"a"."ACSCOB_OldRegNo" as "oldregno", "a"."ACSCOB_NewRegNo" as "newregno", "g"."AMB_Id", "a"."ACSCOB_AMB_Id", "a"."ACSCOB_COBFees" as "fee", "a"."ACSCOB_Remarks" as "remarks",
TO_CHAR("ACSCOB_COBDate", ''DD/MM/YYYY'') as "ACSCOB_COBDate",
(select "AMB_BranchName" from "CLG"."Adm_College_Students_COB" "y"
inner join "CLG"."Adm_Master_Branch" "u" on "y"."AMB_Id"="u"."AMB_Id" and "y"."AMCST_Id"="a"."AMCST_Id" 
and "y"."AMCST_Id"="a"."AMCST_Id" and "y"."AMCO_Id"="b"."AMCO_Id" and "y"."ACSCOB_Id"="a"."ACSCOB_Id" and "y"."ACSCOB_ActiveFlag"=1 and "y"."amco_id" in (' || "wherecondition" || ')
and "y"."ASMAY_Id"=' || "@ASMAY_Id" || ') as "oldbranch",

(select "AMB_BranchName" from "CLG"."Adm_College_Students_COB" "y"
inner join "CLG"."Adm_Master_Branch" "u" on "y"."ACSCOB_AMB_Id"="u"."AMB_Id" and "y"."AMCST_Id"="a"."AMCST_Id"  
and "y"."AMCO_Id"="b"."AMCO_Id" and "y"."ACSCOB_Id"="a"."ACSCOB_Id"  and "y"."ACSCOB_ActiveFlag"=1 and "y"."amco_id" in (' || "wherecondition" || ')
and "y"."ASMAY_Id"=' || "@ASMAY_Id" || ') as "newbranch", 

(select "AMSE_SEMName" from "CLG"."Adm_College_Students_COB" "y" inner join "CLG"."Adm_Master_Semester" "u" on "y"."ACSCOB_AMSE_Id_Old"="u"."AMSE_Id" and "y"."AMCST_Id"="a"."AMCST_Id" 
and "y"."AMCST_Id"="a"."AMCST_Id" and "y"."AMCO_Id"="b"."AMCO_Id" and "y"."ACSCOB_Id"="a"."ACSCOB_Id" and "y"."ACSCOB_ActiveFlag"=1 and "y"."amco_id" in (' || "wherecondition" || ') 
and "y"."ASMAY_Id"=' || "@ASMAY_Id" || ') as "oldsem",

(select "AMSE_SEMName" from "CLG"."Adm_College_Students_COB" "y" inner join "CLG"."Adm_Master_Semester" "u" on "y"."ACSCOB_AMSE_Id_New"="u"."AMSE_Id" and "y"."AMCST_Id"="a"."AMCST_Id"  
and "y"."AMCO_Id"="b"."AMCO_Id" and "y"."ACSCOB_Id"="a"."ACSCOB_Id"  and "y"."ACSCOB_ActiveFlag"=1 and "y"."amco_id" in (' || "wherecondition" || ')
and "y"."ASMAY_Id"=' || "@ASMAY_Id" || ') as "newsem"

FROM "CLG"."Adm_College_Students_COB" "a"
INNER JOIN "CLG"."Adm_Master_Course" "b" on "a"."AMCO_Id" = "b"."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" "d" on "d"."AMB_Id" = "a"."AMB_Id"
INNER JOIN "CLG"."Adm_Master_College_Student" "g" on "g"."AMCST_Id" = "a"."AMCST_Id"
where "a"."amco_id" in (' || "wherecondition" || ') and "a"."ASMAY_Id"=' || "@ASMAY_Id" || ' and "a"."amco_id" in (' || "wherecondition" || ') and "a"."ASMAY_Id"=' || "@ASMAY_Id" || '
and "a"."ACSCOB_ActiveFlag"=1';

    RETURN QUERY EXECUTE "sqlquery";

END;
$$;