CREATE OR REPLACE FUNCTION "dbo"."FEE_STUDENTS_list_clg"(
    "@MI_Id" VARCHAR(100),
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@ASMAY_Id" VARCHAR(100),
    "@AMSE_Id" TEXT,
    "@fmg_id" TEXT,
    "@FMH_Id" TEXT,
    "@flag" VARCHAR(10)
)
RETURNS TABLE(
    "amcsT_Id" INTEGER,
    "studentname" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "dynamicsql" TEXT;
BEGIN
    IF "@flag" = 'F' THEN
        "dynamicsql" := 'SELECT "clg"."Adm_Master_College_Student"."AMCST_Id" as "amcsT_Id",
            (COALESCE("clg"."Adm_Master_College_Student"."AMCST_FirstName",'''') || '' '' || 
             COALESCE("clg"."Adm_Master_College_Student"."AMCST_MiddleName",'''') || '' '' || 
             COALESCE("clg"."Adm_Master_College_Student"."AMCST_LastName",'''')) AS "studentname"
        FROM "Fee_Master_Group"
        INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" ON "clg"."Adm_Master_College_Student"."AMCST_Id" = "clg"."Fee_College_Student_Status"."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" ON "clg"."Adm_College_Yearly_Student"."AMCST_Id" = "clg"."Adm_Master_College_Student"."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" ON "clg"."Adm_College_Master_Section"."ACMS_Id" = "clg"."Adm_College_Yearly_Student"."ACMS_Id"
        WHERE ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "@ASMAY_Id" || ')
        AND ("clg"."Fee_College_Student_Status"."FMG_Id" IN (' || "@fmg_id" || '))
        AND ("clg"."Fee_College_Student_Status"."FMH_Id" IN (' || "@FMH_Id" || '))
        AND ("clg"."Fee_College_Student_Status"."MI_Id" = ' || "@MI_Id" || ')
        AND ("clg"."Fee_College_Student_Status"."FCSS_ToBePaid" > 0)
        AND ("clg"."Adm_College_Yearly_Student"."AMCO_Id" IN (' || "@AMCO_Id" || '))
        AND ("clg"."Adm_College_Yearly_Student"."AMB_Id" IN (' || "@AMB_Id" || '))
        AND ("clg"."Adm_College_Yearly_Student"."AMSE_Id" IN (' || "@AMSE_Id" || '))
        AND ("clg"."Fee_College_Student_Status"."ASMAY_Id" = ' || "@ASMAY_Id" || ')';
    ELSIF "@flag" = 'S' THEN
        "dynamicsql" := 'SELECT "AMCS"."AMCST_Id" as "amcsT_Id",
            (COALESCE("AMCS"."AMCST_FirstName",'''') || '' '' || 
             COALESCE("AMCS"."AMCST_MiddleName",'''') || '' '' || 
             COALESCE("AMCS"."AMCST_LastName",'''')) AS "studentname"
        FROM "clg"."Adm_Master_College_Student" "AMCS" 
        INNER JOIN "clg"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id"
        WHERE "AMCS"."MI_Id" = ' || "@MI_Id" || ' 
        AND "ACYS"."ASMAY_Id" = ' || "@ASMAY_Id" || ' 
        AND "ACYS"."AMCO_Id" IN (' || "@AMCO_Id" || ') 
        AND "ACYS"."AMSE_Id" IN (' || "@AMSE_Id" || ') 
        AND "AMCS"."AMCST_ActiveFlag" = 1 
        AND "ACYS"."ACYST_ActiveFlag" = 1 
        AND "AMCS"."AMCST_SOL" = ''S''';
    END IF;

    RETURN QUERY EXECUTE "dynamicsql";
END;
$$;