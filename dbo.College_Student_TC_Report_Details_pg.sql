CREATE OR REPLACE FUNCTION "dbo"."College_Student_TC_Report_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ACMS_Id" TEXT,
    "@column" TEXT,
    "@ALLORINDI" TEXT,
    "@PERORTEMP" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@ACTIVEFLAG" TEXT;
    "@SOLFLAG" TEXT;
    "@YACTIVEFLAG" TEXT;
    "@SQLQUERY" TEXT;
    "@BRANCHCONDITION" TEXT;
    "@SEMESTERCONDITION" TEXT;
    "@SECTIONCONDITION" TEXT;
BEGIN
    IF "@PERORTEMP" = 'PTC' THEN
        "@ACTIVEFLAG" := '0';
        "@SOLFLAG" := 'L';
        "@YACTIVEFLAG" := '0';
    ELSE
        "@ACTIVEFLAG" := '1';
        "@SOLFLAG" := 'T';
        "@YACTIVEFLAG" := '1';
    END IF;

    IF "@ALLORINDI" = 'all' THEN
        "@SQLQUERY" := 'SELECT DISTINCT ' || "@column" || ' FROM "CLG"."Adm_College_Student_TC" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id"=B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_ID"=B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id"=A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id"=A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id"=A."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id"=A."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" H ON H."ASMAY_Id"=A."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" I ON I."IVRMMC_Id"=C."IVRMMC_Id" 
        INNER JOIN "IVRM_Master_State" J ON J."IVRMMC_Id"=I."IVRMMC_Id" AND J."IVRMMS_Id"=C."AMCST_PerState"
        WHERE A."ASMAY_Id"=' || "@ASMAY_Id" || ' AND B."ASMAY_Id"=' || "@ASMAY_Id" || ' AND B."ACYST_ActiveFlag"=' || "@YACTIVEFLAG" || ' AND C."AMCST_SOL"=''' || "@SOLFLAG" || ''' 
        AND C."AMCST_ActiveFlag"=' || "@ACTIVEFLAG";
    ELSE
        IF "@AMB_Id" = '0' THEN
            "@BRANCHCONDITION" := 'select "AMB_Id" from "CLG"."Adm_Master_Branch" WHERE "AMB_ActiveFlag"=1 AND "MI_Id"=' || "@MI_Id";
        ELSE
            "@BRANCHCONDITION" := 'select "AMB_Id" from "CLG"."Adm_Master_Branch" WHERE "AMB_ActiveFlag"=1 AND "AMB_Id"=' || "@AMB_Id" || ' AND "MI_Id"=' || "@MI_Id";
        END IF;

        IF "@AMSE_Id" = '0' THEN
            "@SEMESTERCONDITION" := 'select "AMSE_Id" from "CLG"."Adm_Master_Semester" WHERE "AMSE_ActiveFlg"=1 AND "MI_Id"=' || "@MI_Id";
        ELSE
            "@SEMESTERCONDITION" := 'select "AMSE_Id" from "CLG"."Adm_Master_Semester" WHERE "AMSE_ActiveFlg"=1 AND "AMSE_Id"=' || "@AMSE_Id" || ' AND "MI_Id"=' || "@MI_Id";
        END IF;

        IF "@ACMS_Id" = '0' THEN
            "@SECTIONCONDITION" := 'select "ACMS_Id" from "CLG"."Adm_College_Master_Section" WHERE "ACMS_ActiveFlag"=1 AND "MI_Id"=' || "@MI_Id";
        ELSE
            "@SECTIONCONDITION" := 'select "ACMS_Id" from "CLG"."Adm_College_Master_Section" WHERE "ACMS_ActiveFlag"=1 AND "ACMS_Id"=' || "@ACMS_Id" || ' AND "MI_Id"=' || "@MI_Id";
        END IF;

        "@SQLQUERY" := 'SELECT DISTINCT ' || "@column" || ' FROM "CLG"."Adm_College_Student_TC" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id"=B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_ID"=B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id"=A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id"=A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id"=A."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id"=A."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" H ON H."ASMAY_Id"=A."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" I ON I."IVRMMC_Id"=C."IVRMMC_Id" 
        INNER JOIN "IVRM_Master_State" J ON J."IVRMMC_Id"=I."IVRMMC_Id" AND J."IVRMMS_Id"=C."AMCST_PerState"
        WHERE A."ASMAY_Id"=' || "@ASMAY_Id" || ' AND B."ASMAY_Id"=' || "@ASMAY_Id" || ' AND B."ACYST_ActiveFlag"=' || "@YACTIVEFLAG" || ' 
        AND C."AMCST_SOL"=''' || "@SOLFLAG" || ''' AND C."AMCST_ActiveFlag"=' || "@ACTIVEFLAG" || ' AND A."AMCO_Id" =' || "@AMCO_Id" || ' AND A."AMB_Id" IN(' || "@BRANCHCONDITION" || ') 
        AND A."AMSE_Id" IN (' || "@SEMESTERCONDITION" || ') AND A."ACMS_Id" IN (' || "@SECTIONCONDITION" || ')';
    END IF;

    EXECUTE "@SQLQUERY";

    RETURN;
END;
$$;