CREATE OR REPLACE FUNCTION "dbo"."Fee_Montly_collection"(
    p_fromdate TEXT,
    p_todate TEXT,
    p_flag TEXT,
    p_allorind TEXT,
    p_amstid VARCHAR(100),
    p_groupids VARCHAR,
    p_left TEXT
)
RETURNS TABLE(
    result_data JSON
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_query TEXT;
    v_monthyearsd TEXT := '';
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_leftflag TEXT;
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT DISTINCT (TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month') || TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY')) AS monthyear
        FROM "dbo"."Adm_School_Y_Student" 
        INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        WHERE "Fee_Y_Payment"."FYP_Id" IN (
            SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id"
            WHERE "Fee_Yearly_Group"."FMG_Id"::TEXT IN (p_groupids)
        )
        AND "dbo"."Fee_Y_Payment"."fyp_date" >= TO_DATE(p_fromdate, 'DD/MM/YYYY')
        AND "dbo"."Fee_Y_Payment"."fyp_date" <= TO_DATE(p_todate, 'DD/MM/YYYY')
        AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> 'BO')
        ORDER BY monthyear
    LOOP
        v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE(rec.monthyear || ', ', '');
    END LOOP;
    
    v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);

    IF p_allorind = 'all' AND COALESCE(p_left, '') <> '1' THEN
        v_query := 'SELECT * FROM (SELECT "dbo"."Adm_M_Student"."AMST_Id", "dbo"."Adm_M_Student"."AMST_AdmNo" AS admno, 
        "dbo"."Adm_M_Student"."AMST_RegistrationNo", 
        ("dbo"."Adm_M_Student"."AMST_FirstName" || "dbo"."Adm_M_Student"."AMST_MiddleName" || "dbo"."Adm_M_Student"."AMST_LastName") AS "Name",
        "dbo"."Fee_Y_Payment"."FYP_Tot_Amount", 
        (TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear
        FROM "dbo"."Adm_School_Y_Student" 
        INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        WHERE "Fee_Y_Payment"."FYP_Id" IN (
            SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id"
            WHERE "Fee_Yearly_Group"."FMG_Id"::TEXT IN (' || quote_literal(p_groupids) || ')
        )
        AND "dbo"."Fee_Y_Payment"."fyp_date" >= TO_DATE(' || quote_literal(p_fromdate) || ', ''DD/MM/YYYY'')
        AND "dbo"."Fee_Y_Payment"."fyp_date" <= TO_DATE(' || quote_literal(p_todate) || ', ''DD/MM/YYYY'')
        AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ' || quote_literal(p_flag) || ')
        ORDER BY "AMST_AdmNo") AS s
        ORDER BY admno';
        
    ELSIF p_allorind = 'all' AND p_left = '1' THEN
        v_leftflag := 'L';
        
        v_query := 'SELECT * FROM (SELECT "dbo"."Adm_M_Student"."AMST_Id", "dbo"."Adm_M_Student"."AMST_AdmNo" AS admno, 
        "dbo"."Adm_M_Student"."AMST_RegistrationNo", 
        ("dbo"."Adm_M_Student"."AMST_FirstName" || "dbo"."Adm_M_Student"."AMST_MiddleName" || "dbo"."Adm_M_Student"."AMST_LastName") AS "Name",
        "dbo"."Fee_Y_Payment"."FYP_Tot_Amount", 
        (TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear
        FROM "dbo"."Adm_School_Y_Student" 
        INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        WHERE "Fee_Y_Payment"."FYP_Id" IN (
            SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id"
            WHERE "Fee_Yearly_Group"."FMG_Id"::TEXT IN (' || quote_literal(p_groupids) || ')
        )
        AND "dbo"."Fee_Y_Payment"."fyp_date" >= TO_DATE(' || quote_literal(p_fromdate) || ', ''DD/MM/YYYY'')
        AND "dbo"."Fee_Y_Payment"."fyp_date" <= TO_DATE(' || quote_literal(p_todate) || ', ''DD/MM/YYYY'')
        AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ' || quote_literal(p_flag) || ')
        AND "amst_sol" = ' || quote_literal(v_leftflag) || '
        ORDER BY "AMST_AdmNo") AS s';
        
    ELSIF p_allorind = 'indi' THEN
        v_query := 'SELECT * FROM (SELECT "dbo"."Adm_M_Student"."AMST_Id", "dbo"."Adm_M_Student"."AMST_AdmNo", 
        "dbo"."Adm_M_Student"."AMST_RegistrationNo", 
        ("dbo"."Adm_M_Student"."AMST_FirstName" || "dbo"."Adm_M_Student"."AMST_MiddleName" || "dbo"."Adm_M_Student"."AMST_LastName") AS "Name",
        ("dbo"."Fee_Y_Payment"."FYP_Tot_Amount") AS "Amount", 
        EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_Date") AS "FYP_Month",
        TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", ''Month'') AS "Month", 
        TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", ''YYYY'') AS "Year",
        "dbo"."Fee_Y_Payment"."FYP_Remarks" 
        FROM "dbo"."Adm_School_Y_Student"
        INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        WHERE "Fee_Y_Payment"."FYP_Id" IN (
            SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id"
            WHERE "Fee_Yearly_Group"."FMG_Id"::TEXT IN (' || quote_literal(p_groupids) || ')
        )
        AND "dbo"."Adm_School_Y_Student"."AMST_Id" IN (
            SELECT "AMST_Id" FROM "Adm_School_Y_Student" WHERE "AMST_Id" = ' || quote_literal(p_amstid) || '
        )
        AND "dbo"."Fee_Y_Payment"."fyp_date" >= TO_DATE(' || quote_literal(p_fromdate) || ', ''DD/MM/YYYY'')
        AND "dbo"."Fee_Y_Payment"."fyp_date" <= TO_DATE(' || quote_literal(p_todate) || ', ''DD/MM/YYYY'')
        AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ' || quote_literal(p_flag) || ')
        ORDER BY "AMST_AdmNo") AS s';
    END IF;

    RETURN QUERY EXECUTE v_query;
    
    RETURN;
END;
$$;