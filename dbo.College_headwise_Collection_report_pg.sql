CREATE OR REPLACE FUNCTION "dbo"."College_headwise_Collection_report"(
    p_fmg_id TEXT,
    p_Mi_Id TEXT,
    p_Asmay_id TEXT,
    p_amco_ids TEXT,
    p_amb_ids TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_section TEXT,
    p_userid TEXT,
    p_active TEXT,
    p_deactive TEXT,
    p_left TEXT
)
RETURNS TABLE(
    result_data json
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_head_names TEXT;
    v_sql1head TEXT;
    v_sqlhead TEXT;
    v_cols TEXT;
    v_cols1 TEXT;
    v_query TEXT;
    v_monthyearsd TEXT := '';
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_date TEXT;
    v_amst_sol TEXT;
    rec RECORD;
BEGIN

    -- Determine student status filter
    IF p_active='1' AND p_deactive='0' AND p_left='0' THEN
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag"=1) and ("Adm_Master_College_Student"."AMCST_SOL"=''S'') and ("Adm_Master_College_Student"."AMCST_ActiveFlag"=1)';
    ELSIF p_deactive='1' AND p_active='0' AND p_left='0' THEN
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag"=1) and ("Adm_Master_College_Student"."AMCST_SOL"=''D'') and ("Adm_Master_College_Student"."AMCST_ActiveFlag"=1)';
    ELSIF p_left='1' AND p_active='0' AND p_deactive='0' THEN
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag"=0) and ("Adm_Master_College_Student"."AMCST_SOL"=''L'') and ("Adm_Master_College_Student"."AMCST_ActiveFlag"=0)';
    ELSIF p_left='1' AND p_active='1' AND p_deactive='0' THEN
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (0,1)) and ("Adm_Master_College_Student"."AMCST_SOL" in (''L'',''S'')) and ("Adm_Master_College_Student"."AMCST_ActiveFlag" in(0,1))';
    ELSIF p_left='1' AND p_active='0' AND p_deactive='1' THEN
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (0,1)) and ("Adm_Master_College_Student"."AMCST_SOL" in (''L'',''D'')) and ("Adm_Master_College_Student"."AMCST_ActiveFlag" in(0,1))';
    ELSIF p_left='0' AND p_active='1' AND p_deactive='1' THEN
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (1)) and ("Adm_Master_College_Student"."AMCST_SOL" in (''S'',''D'')) and ("Adm_Master_College_Student"."AMCST_ActiveFlag" in(1))';
    ELSE
        v_amst_sol := 'and ("Adm_College_Yearly_Student"."ACYST_ActiveFlag" in (0,1)) and ("Adm_Master_College_Student"."AMCST_SOL" in (''S'',''D'',''L'')) and ("Adm_Master_College_Student"."AMCST_ActiveFlag" in(0,1))';
    END IF;

    -- Set date filter
    v_date := 'CAST("clg"."Fee_Y_Payment"."FYP_ReceiptDate" AS DATE) between ''' || p_fromdate || ''' and ''' || p_todate || '''';

    -- Build SQL to get distinct fee head names
    v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" 
                   FROM "Fee_Yearly_Group_Head_Mapping" 
                   INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" 
                   INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                   WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_Mi_Id || ') 
                   AND ("Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || p_Asmay_id || ') 
                   AND ("Fee_Master_Group"."FMG_Id" in (' || p_fmg_id || '))';

    -- Loop through fee head names to build pivot column list
    FOR rec IN EXECUTE v_sql1head LOOP
        v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || rec."FMH_FeeName" || '"' || ', ', '');
    END LOOP;

    -- Remove trailing comma and space
    IF LENGTH(v_monthyearsd) > 0 THEN
        v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
    END IF;

    -- Build main query with CROSSTAB for pivot functionality
    v_query := 'SELECT * FROM crosstab(
        ''SELECT DISTINCT 
            COALESCE("AMCST_FirstName",'''') || '''' '' || COALESCE("AMCST_MiddleName",'''') || '''' '' || COALESCE("AMCST_LastName",'''') AS "StudentName",
            "AMCO_CourseName",
            "AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            "FYP_ReceiptNo",
            "FMH_FeeName",
            "FTCP_PaidAmount" AS paid
        FROM "CLG"."Fee_Y_Payment" 
        INNER JOIN "CLG"."Fee_Y_Payment_College_Student" ON "CLG"."Fee_Y_Payment"."FYP_Id" = "CLG"."Fee_Y_Payment_College_Student"."FYP_Id" 
        INNER JOIN "CLG"."Adm_College_Master_Section" 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id" 
        INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id" 
        INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Branch"."AMB_Id" 
        ON "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_Y_Payment_College_Student"."FYP_Id" = "CLG"."Fee_T_College_Payment"."FYP_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" ON "clg"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id" = "CLG"."Fee_T_College_Payment"."FCMAS_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount" ON "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "clg"."Fee_College_Master_Amount"."FMH_Id" 
        WHERE ("clg"."Adm_Master_College_Student"."MI_Id" = ' || p_Mi_Id || ') 
        AND ("clg"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || p_Asmay_id || ') 
        AND ("clg"."Adm_Master_Course"."AMCO_Id" IN (' || p_amco_ids || ')) 
        AND ("clg"."Adm_Master_Branch"."AMB_Id" IN (' || p_amb_ids || ')) 
        AND "Fee_College_Master_Amount"."fmg_id" IN (' || p_fmg_id || ') 
        AND ' || v_date || ' ' || v_amst_sol || '
        ORDER BY "FYP_ReceiptNo", "FMH_FeeName"''
    ) AS ct("StudentName" TEXT, "AMCO_CourseName" TEXT, "AMB_BranchName" TEXT, "AMSE_SEMName" TEXT, "ACMS_SectionName" TEXT, "FYP_ReceiptNo" TEXT, ' || v_monthyearsd || ')';

    -- Execute the dynamic query
    RETURN QUERY EXECUTE v_query;

END;
$$;